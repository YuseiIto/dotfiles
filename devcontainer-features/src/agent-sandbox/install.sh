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
install -m 0755 "$FEATURE_DIR/fix-state-ownership.sh" "$SHARE_DIR/fix-state-ownership.sh"
install -m 0644 "$FEATURE_DIR/allowed-domains" "$CONF_DIR/allowed-domains.d/00-default"

printf '%s\n' "$REMOTE_USER" > "$CONF_DIR/remote-user"
printf '%s\n' "${ALLOWHOSTNETWORK:-false}" > "$CONF_DIR/allow-host-network"
printf '%s\n' "${RESTRICTSUDO:-true}" > "$CONF_DIR/restrict-sudo"
: > "$CONF_DIR/allowed-domains.d/10-feature-options"
chmod 0644 "$CONF_DIR"/remote-user "$CONF_DIR"/allow-host-network \
  "$CONF_DIR"/restrict-sudo "$CONF_DIR/allowed-domains.d/10-feature-options"

IFS=',' read -r -a extra_domains <<< "${ALLOWEDDOMAINS:-}"
for d in "${extra_domains[@]}"; do
  d="$(echo "$d" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')"
  d="${d#http://}"; d="${d#https://}"; d="${d%%/*}"
  [ -z "$d" ] && continue
  if ! [[ "$d" =~ ^([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z]{2,}$ ]]; then
    echo "agent-sandbox: invalid entry in allowedDomains: '$d'" >&2
    exit 1
  fi
  echo "$d" >> "$CONF_DIR/allowed-domains.d/10-feature-options"
done

if [ "${RESTRICTSUDO:-true}" = true ]; then
  # Drop every sudoers rule that names the remote user, so it cannot run
  # `iptables -F` and disable the firewall.
  for f in /etc/sudoers /etc/sudoers.d/*; do
    [ -f "$f" ] || continue
    [ "$f" = /etc/sudoers.d/agent-sandbox ] && continue
    sed -i -E "/^[[:space:]]*${REMOTE_USER}[[:space:]]/d" "$f"
    [ -s "$f" ] || [ "$f" = /etc/sudoers ] || rm -f "$f"
  done
  # Group grants (`%sudo`, `%admin`) are left alone. Instead, remove the user from those groups.
  for g in sudo admin wheel; do
    if getent group "$g" | cut -d: -f4 | tr ',' '\n' | grep -qx "$REMOTE_USER"; then
      gpasswd -d "$REMOTE_USER" "$g"
    fi
  done
fi

# Lifecycle hooks run these root-only scripts through sudo as the remote user.
printf '%s ALL=(root) NOPASSWD: %s, %s\n' "$REMOTE_USER" \
  "$SHARE_DIR/init-firewall.sh" "$SHARE_DIR/fix-state-ownership.sh" \
  > /etc/sudoers.d/agent-sandbox
chmod 0440 /etc/sudoers.d/agent-sandbox
visudo -c

# The mount point must exist and be owned by the user before the first mount:
# Docker seeds an empty named volume from the image directory, including its
# ownership.
install -d -m 0700 -o "$REMOTE_USER" -g "$(id -gn "$REMOTE_USER")" \
  /mnt/agent-sandbox/claude-config

install -d -m 0755 /etc/claude-code
managed=/etc/claude-code/managed-settings.json
[ -f "$managed" ] || echo '{}' > "$managed"
# The config volume is shared by every project, so a hook written by one
# session would otherwise run in all of them.
jq '.allowManagedHooksOnly = true' "$managed" > "$managed.tmp"
mv "$managed.tmp" "$managed"
if [ "${BYPASSPERMISSIONS:-true}" = true ]; then
  # NOTE: Managed rather than user settings so the warning dialog does not
  # rewrite a settings.json that dotfiles keep as a symlink.
  jq '.permissions.defaultMode = "bypassPermissions" | .skipDangerousModePermissionPrompt = true' \
    "$managed" > "$managed.tmp"
  mv "$managed.tmp" "$managed"
fi
if [ "${ALLOWCLAUDEAICONNECTORS:-false}" = true ]; then
  echo 'mcp-proxy.anthropic.com' >> "$CONF_DIR/allowed-domains.d/10-feature-options"
  # NOTE: Personal "needs approval" settings on claude.ai do not reach a
  # bypassPermissions session; managed ask rules do.
  jq --arg rules "${CONNECTORASKRULES:-}" \
    '.permissions.ask = ((.permissions.ask // []) + ($rules | split(",") | map(gsub("^\\s+|\\s+$"; "")) | map(select(length > 0))) | unique)' \
    "$managed" > "$managed.tmp"
else
  jq '.disableClaudeAiConnectors = true' "$managed" > "$managed.tmp"
fi
mv "$managed.tmp" "$managed"
chown root:root "$managed"
chmod 0644 "$managed"
