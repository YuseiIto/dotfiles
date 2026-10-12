#!/usr/bin/env bash
# onCreate (root via sudo): give the remote user the shared Claude config
# volume. The volume is seeded with the UID the user had when the image was
# built, but on Linux hosts the devcontainer CLI rewrites that UID to match
# the host user afterwards, and another image may have seeded it first.
set -euo pipefail

state_dir=/mnt/agent-sandbox/claude-config
user="$(cat /etc/agent-sandbox/remote-user)"
uid="$(id -u "$user")"
gid="$(id -g "$user")"

if [ "$(stat -c %u "$state_dir")" != "$uid" ]; then
  chown -R "$uid:$gid" "$state_dir"
fi
chmod 0700 "$state_dir"
