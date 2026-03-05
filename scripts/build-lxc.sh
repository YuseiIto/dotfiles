#!/bin/bash
# Build a local LXC image for the given variant.
# Usage: sudo scripts/build-lxc.sh <variant>
# Requires: debootstrap, squashfs-tools, xz-utils, oras, systemd-nspawn
set -euo pipefail

VARIANT="${1:?Usage: $0 <variant>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

case "${VARIANT}" in
  plum)
    SUITE=bookworm
    OS=debian
    RELEASE=bookworm
    TARGET_USER=debian
    COMPONENTS=main,non-free
    ;;
  bamboo | pine)
    SUITE=noble
    OS=ubuntu
    RELEASE=24.04
    TARGET_USER=ubuntu
    COMPONENTS=main,universe,multiverse
    ;;
  *)
    echo "Unknown variant: ${VARIANT}" >&2
    exit 1
    ;;
esac

ROOTFS="/tmp/rootfs-${VARIANT}"
ARCH="$(dpkg --print-architecture 2>/dev/null || uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')"

cleanup() {
  echo "--> Removing rootfs at ${ROOTFS}..."
  rm -rf "${ROOTFS}"
}
trap cleanup EXIT

echo "==> Building LXC image for variant=${VARIANT} (${OS} ${RELEASE}, arch=${ARCH})"

# Step 1: debootstrap
echo "--> Running debootstrap..."
debootstrap \
  --include=systemd,systemd-sysv,dbus,sudo,curl,ca-certificates,tar,openssh-server \
  --components="${COMPONENTS}" \
  "${SUITE}" \
  "${ROOTFS}"

# Step 1b: Append -updates and -security to sources.list
# debootstrap only generates the base suite; add updates/security to match official images.
echo "--> Configuring apt sources..."
if [[ "${OS}" == "ubuntu" ]]; then
  printf 'deb http://archive.ubuntu.com/ubuntu %s-updates %s\n' "${SUITE}" "${COMPONENTS}" >> "${ROOTFS}/etc/apt/sources.list"
  printf 'deb http://security.ubuntu.com/ubuntu %s-security %s\n' "${SUITE}" "${COMPONENTS}" >> "${ROOTFS}/etc/apt/sources.list"
else
  printf 'deb http://deb.debian.org/debian %s-updates %s\n' "${SUITE}" "${COMPONENTS}" >> "${ROOTFS}/etc/apt/sources.list"
  printf 'deb http://security.debian.org/debian-security %s-security %s\n' "${SUITE}" "${COMPONENTS}" >> "${ROOTFS}/etc/apt/sources.list"
fi
chroot "${ROOTFS}" apt-get update -qq

# Step 2: Create user (debootstrap does not create default users for any variant)
echo "--> Configuring user ${TARGET_USER}..."
if ! chroot "${ROOTFS}" id "${TARGET_USER}" &>/dev/null; then
  chroot "${ROOTFS}" groupadd --gid 1000 "${TARGET_USER}" 2>/dev/null || true
  chroot "${ROOTFS}" useradd --uid 1000 --gid 1000 -m -s /bin/bash "${TARGET_USER}"
fi
echo "${TARGET_USER} ALL=(ALL) NOPASSWD:ALL" > "${ROOTFS}/etc/sudoers.d/${TARGET_USER}"
chmod 0440 "${ROOTFS}/etc/sudoers.d/${TARGET_USER}"
echo "${VARIANT}" > "${ROOTFS}/etc/hostname"
echo "127.0.1.1 ${VARIANT}" >> "${ROOTFS}/etc/hosts"
chroot "${ROOTFS}" systemctl enable ssh 2>/dev/null || true

# Step 3: Copy dotfiles
echo "--> Copying dotfiles..."
DEST="${ROOTFS}/home/${TARGET_USER}/dotfiles"
mkdir -p "${DEST}"
rsync -a --exclude='.git' "${REPO_ROOT}/" "${DEST}/"
chown -R 1000:1000 "${DEST}"

# Step 4: Run setup.sh
echo "--> Running setup.sh inside rootfs..."
systemd-nspawn \
  --directory="${ROOTFS}" \
  --hostname="${VARIANT}" \
  --bind-ro=/etc/resolv.conf \
  --user="${TARGET_USER}" \
  --setenv=HOME="/home/${TARGET_USER}" \
  --setenv=USER="${TARGET_USER}" \
  --setenv=DOTFILES_ROLE="${VARIANT}" \
  --setenv=LANG=C.UTF-8 \
  --setenv=DEBIAN_FRONTEND=noninteractive \
  --chdir="/home/${TARGET_USER}/dotfiles" \
  bash setup.sh

# Step 4.5: Validate with goss
echo "--> Validating with goss..."
GOSSFILE="/home/${TARGET_USER}/dotfiles/mitamae/roles/${VARIANT}/goss.yaml"
# Run via zsh so ~/.zshenv is sourced, giving goss the same PATH as the user's shell
# (includes ~/.local/bin, ~/.nodenv/bin, ~/.nodenv/shims, etc.)
systemd-nspawn \
  --directory="${ROOTFS}" \
  --hostname="${VARIANT}" \
  --user="${TARGET_USER}" \
  --setenv=HOME="/home/${TARGET_USER}" \
  --setenv=USER="${TARGET_USER}" \
  zsh -c "goss --gossfile '${GOSSFILE}' validate"

# Step 5: Cleanup
echo "--> Cleaning up..."
rm -rf "${ROOTFS}/var/cache/apt"
rm -rf "${ROOTFS}/var/log"
find "${ROOTFS}/tmp" -mindepth 1 -delete

# Step 6: Create squashfs
echo "--> Creating rootfs.squashfs..."
mksquashfs "${ROOTFS}" "${REPO_ROOT}/rootfs-${VARIANT}.squashfs" \
  -comp xz \
  -noappend \
  -no-progress

# Step 7: Create lxd.tar.xz metadata
echo "--> Creating lxd-${VARIANT}.tar.xz..."
CREATION_DATE=$(date +%s)
TMP_META=$(mktemp -d)
sed \
  -e "s/__ARCH__/${ARCH}/g" \
  -e "s/__CREATION_DATE__/${CREATION_DATE}/g" \
  -e "s/__VARIANT__/${VARIANT}/g" \
  -e "s/__OS__/${OS}/g" \
  -e "s/__RELEASE__/${RELEASE}/g" \
  "${REPO_ROOT}/lxc/metadata.yaml.template" > "${TMP_META}/metadata.yaml"
tar -cJf "${REPO_ROOT}/lxd-${VARIANT}.tar.xz" -C "${TMP_META}" metadata.yaml
rm -rf "${TMP_META}"

echo ""
echo "Done! Artifacts created in ${REPO_ROOT}:"
echo "  lxd-${VARIANT}.tar.xz"
echo "  rootfs-${VARIANT}.squashfs"
echo ""
echo "To import into Incus:"
echo "  incus image import lxd-${VARIANT}.tar.xz rootfs-${VARIANT}.squashfs --alias ${VARIANT}"
