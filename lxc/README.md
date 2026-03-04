# LXC Images

LXC system container images built from the same mitamae provisioning as the Docker devcontainers.
Unlike Docker containers, LXC images run a full systemd init and are designed for persistent development environments.

Images are published to GHCR as OCI Artifacts using [oras](https://oras.land/).

## Prerequisites

Install [Incus](https://linuxcontainers.org/incus/docs/main/installing/) and [oras](https://oras.land/docs/installation):

```bash
# Incus (Debian/Ubuntu)
sudo apt-get install incus

# oras
ORAS_VERSION="1.2.0"
curl -sLO "https://github.com/oras-project/oras/releases/download/v${ORAS_VERSION}/oras_${ORAS_VERSION}_linux_amd64.tar.gz"
sudo tar -xzf "oras_${ORAS_VERSION}_linux_amd64.tar.gz" -C /usr/local/bin oras
```

## Available Variants

| Variant | Base OS | GHCR Tag |
|---|---|---|
| `plum` | Debian Bookworm | `ghcr.io/yuseiito/yuseiito-dev-lxc:plum-latest` |
| `bamboo` | Ubuntu 24.04 | `ghcr.io/yuseiito/yuseiito-dev-lxc:bamboo-latest` |
| `pine` | Ubuntu 24.04 | `ghcr.io/yuseiito/yuseiito-dev-lxc:pine-latest` |

Branch builds are tagged as `<variant>-<branch-name>` (slashes replaced with hyphens).

## Usage

### Pull and import

```bash
# Pull the OCI Artifact from GHCR
oras pull ghcr.io/yuseiito/yuseiito-dev-lxc:bamboo-latest

# Import into Incus
incus image import lxd-bamboo.tar.xz rootfs-bamboo.squashfs --alias bamboo
```

### Launch and connect

```bash
# Create and start a container
incus launch bamboo my-dev

# Open a shell
incus exec my-dev -- /usr/bin/zsh

# Stop when done
incus stop my-dev
```

### Persistent volumes

Mount a host directory to persist shell history and other data across container lifecycles:

```bash
# Create a container with a persistent volume for zsh history
incus launch bamboo my-dev
incus config device add my-dev zsh-data disk \
  source="${HOME}/.local/share/lxc-zsh" \
  path=/home/ubuntu/.local/share/zsh

# Restart to apply the device
incus restart my-dev
```

## Local Build

Building requires `root`, `debootstrap`, `squashfs-tools`, `xz-utils`, and `systemd-nspawn`.

```bash
# Build a specific variant locally (outputs lxd-<variant>.tar.xz + rootfs-<variant>.squashfs)
make build-lxc-bamboo
```

