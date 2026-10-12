#!/usr/bin/env bash
# Build-time setup for the agent-sandbox Feature. Runs as root.
set -euo pipefail

FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"
SHARE_DIR=/usr/local/share/agent-sandbox
CONF_DIR=/etc/agent-sandbox
REMOTE_USER="${_REMOTE_USER:?_REMOTE_USER must be set by the devcontainer CLI}"

if [ "$REMOTE_USER" = root ]; then
  # Claude Code refuses --dangerously-skip-permissions as root, and a root
  # remote user could tear the firewall down.
  echo "agent-sandbox: remoteUser must be a non-root user" >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
# dnsmasq-base ships the binary and the `dnsmasq` system user without the
# systemd service that the `dnsmasq` package would add.
apt-get install -y --no-install-recommends \
  ca-certificates curl dnsmasq-base dnsutils ipset iptables iproute2 jq sudo
rm -rf /var/lib/apt/lists/*

install -d -m 0755 "$SHARE_DIR" "$CONF_DIR" "$CONF_DIR/allowed-domains.d" /var/lib/agent-sandbox
install -m 0755 "$FEATURE_DIR/init-firewall.sh" "$SHARE_DIR/init-firewall.sh"
install -m 0755 "$FEATURE_DIR/link-credentials.sh" "$SHARE_DIR/link-credentials.sh"
install -m 0644 "$FEATURE_DIR/allowed-domains" "$CONF_DIR/allowed-domains.d/00-default"

printf '%s\n' "$REMOTE_USER" > "$CONF_DIR/remote-user"
printf '%s\n' "${ALLOWHOSTNETWORK:-false}" > "$CONF_DIR/allow-host-network"
printf '%s\n' "${RESTRICTSUDO:-true}" > "$CONF_DIR/restrict-sudo"
: > "$CONF_DIR/allowed-domains.d/10-feature-options"
chmod 0644 "$CONF_DIR"/remote-user "$CONF_DIR"/allow-host-network \
  "$CONF_DIR"/restrict-sudo "$CONF_DIR/allowed-domains.d/10-feature-options"

# postStartCommand runs the firewall script through sudo as the remote user.
# Task 3 inserts the removal of other sudo rights directly above this block.
printf '%s ALL=(root) NOPASSWD: %s\n' "$REMOTE_USER" "$SHARE_DIR/init-firewall.sh" \
  > /etc/sudoers.d/agent-sandbox
chmod 0440 /etc/sudoers.d/agent-sandbox
visudo -c
