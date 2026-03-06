#!/bin/bash
set -euo pipefail

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Ensure gum is available
if ! command -v gum &> /dev/null; then
    echo "gum is required but not installed. Please install it first."
    exit 1
fi

gum style --border normal --margin "1 2" --padding "1 2" --border-foreground 212 "Welcome to the yuseiito-dev Live Environment Installer!"

# Step 1: Select Disk
gum style --foreground 212 "Step 1: Select Installation Target Disk"
DISKS=$(lsblk -dno NAME,SIZE,MODEL | grep -v "loop" | awk '{print "/dev/"$1" - "$2" "$3" "$4}')

if [[ -z "$DISKS" ]]; then
    gum style --foreground 196 "No suitable disks found!"
    exit 1
fi

SELECTED_DISK_RAW=$(echo "$DISKS" | gum choose --header "Select a disk to ERASE and INSTALL the OS:")
SELECTED_DISK=$(echo "$SELECTED_DISK_RAW" | awk '{print $1}')

# Step 2: Confirmation
gum confirm "WARNING: This will ERASE ALL DATA on $SELECTED_DISK. Are you absolutely sure?" || exit 1

# Step 3: Partitioning
gum spin --spinner dot --title "Partitioning $SELECTED_DISK..." -- sleep 1
cat <<EOF | sfdisk "$SELECTED_DISK"
label: gpt

1 : size=512M, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, name="EFI"
2 : type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, name="ROOT"
EOF

if [[ "$SELECTED_DISK" == *nvme* || "$SELECTED_DISK" == *mmcblk* ]]; then
    EFI_PART="${SELECTED_DISK}p1"
    ROOT_PART="${SELECTED_DISK}p2"
else
    EFI_PART="${SELECTED_DISK}1"
    ROOT_PART="${SELECTED_DISK}2"
fi

# Step 4: Formatting
gum spin --spinner dot --title "Formatting partitions..." -- bash -c "
    mkfs.fat -F32 '$EFI_PART' > /dev/null
    mkfs.ext4 -F '$ROOT_PART' > /dev/null
"

# Step 5: Mounting
MNT="/mnt/installer"
mkdir -p "$MNT"
mount "$ROOT_PART" "$MNT"
mkdir -p "$MNT/boot/efi"
mount "$EFI_PART" "$MNT/boot/efi"

# Cleanup handler: unmount everything on exit (success or failure)
cleanup() {
    umount -R "$MNT" 2>/dev/null || true
}
trap cleanup EXIT

# Step 6: Copying OS (rsync)
gum style --foreground 212 "Step 2: Copying System Files (this may take several minutes)..."
rsync -aAXv / \
    "$MNT/" \
    --exclude=/dev/* \
    --exclude=/proc/* \
    --exclude=/sys/* \
    --exclude=/tmp/* \
    --exclude=/run/* \
    --exclude=/mnt/* \
    --exclude=/media/* \
    --exclude=/lost+found \
    --exclude=/home/ubuntu/dotfiles/.git \
    --info=progress2

# Step 7: Finalizing (GRUB & Config)
gum style --foreground 212 "Step 3: Finalizing System Configuration..."
for i in /dev /dev/pts /proc /sys /run; do mount --bind "$i" "$MNT$i"; done

# Install GRUB (UEFI)
chroot "$MNT" grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=yuseiito-dev-live --recheck
chroot "$MNT" update-grub

# Generate fstab
ROOT_UUID=$(blkid -s UUID -o value "$ROOT_PART")
EFI_UUID=$(blkid -s UUID -o value "$EFI_PART")
cat <<EOF > "$MNT/etc/fstab"
UUID=$ROOT_UUID /               ext4    errors=remount-ro 0       1
UUID=$EFI_UUID  /boot/efi       vfat    umask=0077      0       1
EOF

gum style --border double --margin "1 2" --padding "1 2" --border-foreground 46 "Success! OS has been installed to $SELECTED_DISK. Please remove the USB and REBOOT."
