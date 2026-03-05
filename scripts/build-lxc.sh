#!/bin/bash
# Build a local LXC image for the given variant.
# Usage: sudo scripts/build-lxc.sh <variant>
# Requires: debootstrap, squashfs-tools, xz-utils, oras, systemd-nspawn
set -euCo pipefail

VARIANT="${1:?Usage: $0 <variant>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

case "${VARIANT}" in
  plum)
    SUITE=bookworm
    OS=debian
    RELEASE=bookworm
    TARGET_USER=debian
    ;;
  bamboo | pine)
    SUITE=noble
    OS=ubuntu
    RELEASE=24.04
    TARGET_USER=ubuntu
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
  "${SUITE}" \
  "${ROOTFS}"

# Step 2: Create user (debootstrap does not create default users for any variant)
echo "--> Configuring user ${TARGET_USER}..."
if ! chroot "${ROOTFS}" id "${TARGET_USER}" &>/dev/null; then
  chroot "${ROOTFS}" groupadd --gid 1000 "${TARGET_USER}" 2>/dev/null || true
  chroot "${ROOTFS}" useradd --uid 1000 --gid 1000 -m -s /bin/bash "${TARGET_USER}"
fi
echo "${TARGET_USER} ALL=(ALL) NOPASSWD:ALL" > "${ROOTFS}/etc/sudoers.d/${TARGET_USER}"
chmod 0440 "${ROOTFS}/etc/sudoers.d/${TARGET_USER}"
echo "${VARIANT}" > "${ROOTFS}/etc/hostname"
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
  --bind-ro=/etc/resolv.conf \
  --user="${TARGET_USER}" \
  --setenv=HOME="/home/${TARGET_USER}" \
  --setenv=USER="${TARGET_USER}" \
  --setenv=DOTFILES_ROLE="${VARIANT}" \
  --setenv=LANG=C.UTF-8 \
  --setenv=DEBIAN_FRONTEND=noninteractive \
  --chdir="/home/${TARGET_USER}/dotfiles" \
  bash setup.sh

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
