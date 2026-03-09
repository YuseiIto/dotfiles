# Live OS Image (Rescue & Installer)

This repository provides a system to build a bootable, self-contained Live OS image (disk image) containing all your development tools, dotfiles, and a custom installer.

## Features

- **Base OS**: Ubuntu 24.04 (Noble Numbat).
- **Pre-installed**: Everything defined in the `pine` role (Neovim, Zsh, Ollama, Rust, etc.).
- **Rescue Ready**: Modern CLI tools like `gum`, `nmap`, `git`, and `cloudflared` are available immediately.
- **Auto-Installer**: A custom TUI wizard (`yuseiito-dev-install`) to clone the environment to your local SSD.
- **Cloud-init Support**: Ready for deployment as a Proxmox VM template or cloud instance.

## Building the Image

The image is built using [mkosi](https://github.com/systemd/mkosi).

### Method 1: GitHub Actions (Recommended)

1.  Push changes to `main` or manually trigger the **"Build OS Images"** workflow.
2.  Download the `yuseiito-dev-live_pine.raw.xz` artifact from the Actions run.

### Method 2: Local Build

Requires a Linux host with `mkosi` and `systemd-container`, `systemd-ukify`, `systemd-boot ` installed.

```bash
# Build the .raw image
sudo mkosi build --output=yuseiito-dev-live_pine.raw
```

## How to Use

### 1. Create a Live USB

Once you have the `.raw.xz` file, write it to a USB drive (replace `/dev/sdX` with your USB device):

```bash
xzcat yuseiito-dev-live_pine.raw.xz | sudo dd of=/dev/sdX bs=4M status=progress
```

### 2. Boot and Rescue

- Insert the USB and boot your PC.
- Select the UEFI boot entry for the USB.
- Log in with `ubuntu` / `ubuntu`.
- All your tools and dotfiles are already there!

### 3. Install to Disk

To permanently install this environment to your PC's SSD:

1.  Run the installer:
    ```bash
    sudo yuseiito-dev-install
    ```
2.  Follow the **gum**-powered TUI wizard:
    - Select your target SSD.
    - Confirm the erasure of data.
    - Wait for the `rsync` process to complete.
3.  Reboot and remove the USB.

## Architecture

- **`mkosi.conf`**: Defines the base OS and packages.
- **`mkosi.postinst`**: Hook that runs `setup.sh` (Mitamae) during the build process to inject your dotfiles and recipes.
- **`mitamae/cookbooks/installer`**: Contains the `yuseiito-dev-install` script and logic.
- **`cloud-init`**: Configured via `/etc/cloud/cloud.cfg.d/99_yuseiito.cfg` for initial boot setup (especially useful in VM environments).


## Customization

To add new tools or change the installer behavior:
- Modify `mitamae/cookbooks/installer/files/yuseiito-dev-install.sh` for installer changes.
- Add recipes to `mitamae/roles/pine/default.rb` to include them in the image.
- Edit `mkosi.conf` to add base system packages or change the OS distribution.
