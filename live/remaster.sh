#!/bin/bash
# Remaster the official Ubuntu Desktop 24.04 ISO with dotfiles customizations.
# Usage: sudo live/remaster.sh [--keep-work]
# Requires: unsquashfs, mksquashfs, xorriso, systemd-nspawn, wget, rsync (Linux only, run as root)
set -euo pipefail

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
ISO_URL="https://releases.ubuntu.com/24.04.4/ubuntu-24.04.4-desktop-amd64.iso"
ISO_SHA256="3a4c9877b483ab46d7c3fbe165a0db275e1ae3cfe56a5657e5a47c2f99a99d1e"
ISO_FILENAME="ubuntu-24.04.4-desktop-amd64.iso"
HOSTNAME_LIVE="pine-live"

KEEP_WORK=false
for arg in "$@"; do
    case "${arg}" in
        --keep-work) KEEP_WORK=true ;;
        *) echo "Unknown argument: ${arg}" >&2; exit 1 ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

CACHE_DIR="${SCRIPT_DIR}/cache"
WORK_DIR="${SCRIPT_DIR}/work"
OUTPUT_DIR="${SCRIPT_DIR}/output"

ISO_MOUNT="${WORK_DIR}/iso-mount"
ROOTFS="${WORK_DIR}/rootfs"
ISO_STAGING="${WORK_DIR}/iso-staging"
LAYERS_DIR="${WORK_DIR}/layers"
OVERLAY_MERGED="${WORK_DIR}/overlay-merged"

# Tracks mounts opened during layer extraction for cleanup
LAYER_MOUNT_POINTS=()
OVERLAY_MOUNTED=false

# ---------------------------------------------------------------------------
# Step 0 - Prerequisites
# ---------------------------------------------------------------------------
echo "==> Checking prerequisites..."

if [[ "$(uname -s)" != "Linux" ]]; then
    echo "ERROR: This script must run on Linux." >&2
    exit 1
fi

if [[ "${EUID}" -ne 0 ]]; then
    echo "ERROR: This script must run as root." >&2
    exit 1
fi

for tool in unsquashfs mksquashfs xorriso systemd-nspawn wget rsync; do
    if ! command -v "${tool}" &>/dev/null; then
        echo "ERROR: Required tool not found: ${tool}" >&2
        exit 1
    fi
done

# ---------------------------------------------------------------------------
# Cleanup trap
# ---------------------------------------------------------------------------
cleanup() {
    echo "--> Cleanup..."
    if "${OVERLAY_MOUNTED}" && mountpoint -q "${OVERLAY_MERGED}" 2>/dev/null; then
        umount "${OVERLAY_MERGED}" || true
    fi
    for mp in "${LAYER_MOUNT_POINTS[@]+"${LAYER_MOUNT_POINTS[@]}"}"; do
        if mountpoint -q "${mp}" 2>/dev/null; then umount "${mp}"; fi
    done
    if mountpoint -q "${ISO_MOUNT}" 2>/dev/null; then
        umount "${ISO_MOUNT}" || true
    fi
    if [[ "${KEEP_WORK}" == "false" ]]; then
        rm -rf "${WORK_DIR}"
    fi
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Step 1 - Download base ISO (with cache)
# ---------------------------------------------------------------------------
echo "==> Step 1: Download base ISO..."
mkdir -p "${CACHE_DIR}"

if [[ ! -f "${CACHE_DIR}/${ISO_FILENAME}" ]]; then
    echo "--> Downloading ${ISO_URL}..."
    wget -O "${CACHE_DIR}/${ISO_FILENAME}" "${ISO_URL}"
else
    echo "--> Using cached ${ISO_FILENAME}"
fi

echo "--> Verifying SHA256..."
echo "${ISO_SHA256}  ${CACHE_DIR}/${ISO_FILENAME}" | sha256sum -c -

# ---------------------------------------------------------------------------
# Step 2 - Prepare work directories
# ---------------------------------------------------------------------------
echo "==> Step 2: Prepare work directories..."
rm -rf "${WORK_DIR}"
mkdir -p "${ISO_MOUNT}" "${ROOTFS}" "${ISO_STAGING}" "${LAYERS_DIR}" "${OVERLAY_MERGED}"
mkdir -p "${OUTPUT_DIR}"

# ---------------------------------------------------------------------------
# Step 3 - Mount and extract
# ---------------------------------------------------------------------------
echo "==> Step 3: Mount and extract ISO..."
mount -o loop,ro "${CACHE_DIR}/${ISO_FILENAME}" "${ISO_MOUNT}"

echo "--> Copying ISO tree (excluding squashfs files)..."
# Ubuntu 24.04 uses layered squashfs; exclude all of them and repack as one later.
rsync -a --exclude='casper/*.squashfs' --exclude='casper/*.squashfs.gpg' \
    "${ISO_MOUNT}/" "${ISO_STAGING}/"

# Ubuntu 24.04 Desktop ISO uses layered squashfs (overlayfs semantics: whiteout files,
# opaque directories). Merging with rsync breaks these semantics, so mount each layer
# as a loopback squashfs and let the kernel's overlayfs do the merge.
echo "--> Mounting squashfs layers..."
for layer in minimal.squashfs minimal.standard.squashfs minimal.standard.live.squashfs; do
    if [[ -f "${ISO_MOUNT}/casper/${layer}" ]]; then
        echo "    -> ${layer}"
        MOUNT_PT="${LAYERS_DIR}/${layer%.squashfs}"
        mkdir -p "${MOUNT_PT}"
        mount -t squashfs -o loop,ro "${ISO_MOUNT}/casper/${layer}" "${MOUNT_PT}"
        LAYER_MOUNT_POINTS+=("${MOUNT_PT}")
    else
        echo "    (skipped: ${layer} not found)"
    fi
done

# Build overlayfs lowerdir: highest-priority layer leftmost
REVERSED=()
for ((i=${#LAYER_MOUNT_POINTS[@]}-1; i>=0; i--)); do
    REVERSED+=("${LAYER_MOUNT_POINTS[$i]}")
done
LOWERDIR=$(IFS=:; echo "${REVERSED[*]}")

echo "--> Merging layers via overlayfs..."
mount -t overlay overlay -o "lowerdir=${LOWERDIR}" "${OVERLAY_MERGED}"
OVERLAY_MOUNTED=true

echo "--> Copying merged rootfs..."
rsync -a "${OVERLAY_MERGED}/" "${ROOTFS}/"

umount "${OVERLAY_MERGED}"
OVERLAY_MOUNTED=false
for mp in "${LAYER_MOUNT_POINTS[@]}"; do
    umount "${mp}"
done
LAYER_MOUNT_POINTS=()

# ---------------------------------------------------------------------------
# Step 4 - Rsync dotfiles into rootfs
# ---------------------------------------------------------------------------
echo "==> Step 4: Rsync dotfiles into rootfs..."
DOTFILES_DEST="${ROOTFS}/home/ubuntu/dotfiles"
mkdir -p "${DOTFILES_DEST}"
rsync -a --delete \
    --exclude='.git/' \
    --exclude='live/cache/' \
    --exclude='live/work/' \
    --exclude='live/output/' \
    "${REPO_ROOT}/" "${DOTFILES_DEST}/"

# ---------------------------------------------------------------------------
# Step 5 - Run customize-chroot.sh via systemd-nspawn
# ---------------------------------------------------------------------------
echo "==> Step 5: Customize rootfs via systemd-nspawn..."
systemd-nspawn \
    --directory="${ROOTFS}" \
    --hostname="${HOSTNAME_LIVE}" \
    --bind-ro=/etc/resolv.conf \
    --setenv=DEBIAN_FRONTEND=noninteractive \
    --setenv=DOTFILES_ROLE=pine \
    --setenv=HOME=/home/ubuntu \
    /home/ubuntu/dotfiles/live/customize-chroot.sh

# ---------------------------------------------------------------------------
# Step 6 - Repack squashfs
# ---------------------------------------------------------------------------
echo "==> Step 6: Repack squashfs..."
# Pack the customized rootfs into minimal.squashfs (the base layer).
mksquashfs "${ROOTFS}" "${ISO_STAGING}/casper/minimal.squashfs" \
    -comp xz \
    -noappend

echo "--> Updating minimal.size..."
du -sx --block-size=1 "${ROOTFS}" | cut -f1 > "${ISO_STAGING}/casper/minimal.size"

echo "--> Regenerating minimal.manifest..."
# shellcheck disable=SC2016
systemd-nspawn \
    --directory="${ROOTFS}" \
    dpkg-query -W --showformat='${Package} ${Version}\n' \
    > "${ISO_STAGING}/casper/minimal.manifest"

# Casper expects all squashfs layer files that existed in the original ISO to be present.
# We replaced minimal.squashfs with our full system, so create empty stubs for the
# other layers that casper will try to load (they add nothing on top).
echo "--> Creating empty stubs for remaining casper layers..."
STUB_DIR=$(mktemp -d)
for layer_path in "${ISO_MOUNT}/casper/"*.squashfs; do
    layer_file=$(basename "${layer_path}")
    if [[ "${layer_file}" != "minimal.squashfs" ]] && \
       [[ ! -f "${ISO_STAGING}/casper/${layer_file}" ]]; then
        mksquashfs "${STUB_DIR}" "${ISO_STAGING}/casper/${layer_file}" \
            -comp xz -noappend -quiet
    fi
done
rmdir "${STUB_DIR}"

# ---------------------------------------------------------------------------
# Step 7 - Edit GRUB config (add hostname to kernel cmdline)
# ---------------------------------------------------------------------------
echo "==> Step 7: Edit GRUB config..."
GRUB_CFG="${ISO_STAGING}/boot/grub/grub.cfg"
if [[ -f "${GRUB_CFG}" ]]; then
    # Add hostname=pine-live to kernel cmdline if not already present
    if ! grep -q "hostname=${HOSTNAME_LIVE}" "${GRUB_CFG}"; then
        sed -i "s|quiet splash|quiet splash hostname=${HOSTNAME_LIVE}|g" "${GRUB_CFG}"
    fi
fi

# ---------------------------------------------------------------------------
# Step 8 - Regenerate md5sum.txt
# ---------------------------------------------------------------------------
echo "==> Step 8: Regenerate md5sum.txt..."
pushd "${ISO_STAGING}" > /dev/null
find . -type f \
    ! -name 'md5sum.txt' \
    ! -path './boot/grub/efi.img' \
    -exec md5sum {} \; > md5sum.txt
popd > /dev/null

# ---------------------------------------------------------------------------
# Step 9 - Build ISO with xorriso
# ---------------------------------------------------------------------------
echo "==> Step 9: Build ISO..."
OUTPUT_ISO="${OUTPUT_DIR}/pine-live.iso"

# Ubuntu 24.04 ISOs do not ship boot_hybrid.img as a file inside the ISO.
# Instead, the MBR and EFI partition are embedded raw bytes that must be
# extracted from the original ISO and fed back to xorriso.
# Use 'xorriso -report_el_torito as_mkisofs' to determine the exact intervals.
echo "--> Extracting boot images from original ISO..."
XORRISO_BOOT=$(xorriso -indev "${CACHE_DIR}/${ISO_FILENAME}" \
    -report_el_torito as_mkisofs 2>/dev/null)

# The EFI interval line looks like:
#   -append_partition 2 <GUID> --interval:local_fs:<START>d-<END>d::'<ISO>'
# The 'd' suffix = 512-byte disk sectors.
EFI_LINE=$(echo "${XORRISO_BOOT}" | grep "^-append_partition 2")
# Line format: -append_partition 2 <GUID> --interval:local_fs:<START>d-<END>d::'<ISO>'
if [[ "${EFI_LINE}" =~ local_fs:([0-9]+)d-([0-9]+)d:: ]]; then
    EFI_START="${BASH_REMATCH[1]}"
    EFI_END="${BASH_REMATCH[2]}"
else
    echo "ERROR: Could not parse EFI interval from xorriso output." >&2
    exit 1
fi
EFI_COUNT=$(( EFI_END - EFI_START + 1 ))

dd if="${CACHE_DIR}/${ISO_FILENAME}" bs=512 skip="${EFI_START}" count="${EFI_COUNT}" \
    of="${WORK_DIR}/efi.img" status=none

# MBR: sectors 0-15 (8 KB hybrid boot area)
dd if="${CACHE_DIR}/${ISO_FILENAME}" bs=512 count=16 \
    of="${WORK_DIR}/mbr.img" status=none

xorriso -as mkisofs \
    -r \
    -iso-level 3 \
    -V "Pine Live" \
    -o "${OUTPUT_ISO}" \
    --grub2-mbr "${WORK_DIR}/mbr.img" \
    --protective-msdos-label \
    -partition_cyl_align off \
    -partition_offset 16 \
    --mbr-force-bootable \
    -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b "${WORK_DIR}/efi.img" \
    -appended_part_as_gpt \
    -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
    -c '/boot.catalog' \
    -b '/boot/grub/i386-pc/eltorito.img' \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    --grub2-boot-info \
    -eltorito-alt-boot \
    -e '--interval:appended_partition_2:::' \
    -no-emul-boot \
    -boot-load-size "${EFI_COUNT}" \
    "${ISO_STAGING}"

echo ""
echo "Done! Output ISO: ${OUTPUT_ISO}"
echo "  Size: $(du -sh "${OUTPUT_ISO}" | cut -f1)"
