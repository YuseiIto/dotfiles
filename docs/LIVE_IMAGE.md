# Live USB Image (Rescue & Installer)

This repository builds a bootable Live USB image by remastering the official
Ubuntu Desktop 24.04 ISO: the squashfs layers are extracted, customized via
`mitamae` (pine role), and repacked into a new hybrid ISO.

## Features

- **Base OS**: Ubuntu Desktop 24.04 (Noble Numbat)
- **Pre-installed**: Everything defined in the `pine` role (Neovim, Zsh, Ollama, Rust, etc.)
- **Rescue Ready**: Modern CLI tools available immediately after boot
- **Offline-capable**: All tools baked into the squashfs layer

## Building the Image

### Prerequisites

Linux host with the following tools installed:

```bash
sudo apt install \
  squashfs-tools \
  xorriso \
  systemd-container \
  wget \
  rsync
```

~25 GB of free disk space is required.

### Local Build

```bash
make live-build
# → live/output/pine-live.iso
```

Or directly:

```bash
sudo live/remaster.sh [--keep-work]
```

`--keep-work` preserves `live/work/` after the build for debugging.

### How It Works

| Step | Description |
|---|---|
| 1 | Download Ubuntu Desktop 24.04 ISO (cached in `live/cache/`) |
| 2 | Mount the ISO and merge squashfs layers via overlayfs |
| 3 | Rsync dotfiles into the merged rootfs |
| 4 | Run `mitamae` (pine role) inside `systemd-nspawn` |
| 5 | Repack as `casper/minimal.squashfs` |
| 6 | Rebuild ISO with `xorriso` (MBR + EFI hybrid boot preserved) |

## How to Use

### 1. Write to USB

```bash
sudo dd if=live/output/pine-live.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

### 2. Boot

- Insert the USB and boot your PC.
- Select the UEFI boot entry for the USB.
- Log in as `ubuntu` (passwordless sudo enabled).

### 3. Test with QEMU

```bash
sudo qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -cdrom live/output/pine-live.iso \
  -boot d \
  -vga virtio \
  -display sdl
```

## Directory Layout

```
live/
  remaster.sh           # Main build script
  customize-chroot.sh   # Runs inside chroot: packages + mitamae
  packages.list         # Additional packages (beyond Ubuntu Desktop defaults)
  .gitignore
  cache/                # (gitignored) cached base ISO
  work/                 # (gitignored) temporary build tree
  output/               # (gitignored) final ISO
    pine-live.iso
```

## Customization

- **Add packages**: edit `live/packages.list`
- **Change provisioning**: edit `live/customize-chroot.sh` or `mitamae/roles/pine/default.rb`
- **Change hostname**: edit `HOSTNAME_LIVE` in `live/remaster.sh`
