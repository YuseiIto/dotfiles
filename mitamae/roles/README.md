# Roles

This directory contains the mItamae roles.

Each role represents a specific host or container variant. There are two kinds:

- **Container variants** (`pine`, `bamboo`, `plum`, `palm`, `devcontainer`): reusable image tiers shared across Docker and LXC builds (`devcontainer` is Docker-only). These are documented in [VARIANTS.md](../../docs/VARIANTS.md).
- **Host roles** (`belle`, `hercules`, `pc137`): configurations tied to a specific physical machine. Each is documented in its own `README.md` within the role directory.

