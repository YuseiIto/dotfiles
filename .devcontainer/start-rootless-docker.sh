#!/usr/bin/env bash
# Start a rootless Docker daemon inside the dev container.
#
# This replaces the previous `/var/run/docker.sock` bind mount, which shared
# the host's Docker daemon with the container. Access to that socket is
# effectively host root (a container could start a privileged container or
# mount the host filesystem), so a container compromise escalated straight to
# the host. A rootless daemon runs entirely inside the container's user
# namespace, removing that escalation path.
#
# This script always exits 0: Docker availability must never block container
# startup. When the rootless tooling is absent (e.g. an older base image that
# predates docker-ce-rootless-extras), it simply no-ops.
set -u

uid="$(id -u)"
user="$(id -un)"
runtime_dir="/run/user/${uid}"
sock="${runtime_dir}/docker.sock"

# Already running? Nothing to do.
if [ -S "${sock}" ]; then
  exit 0
fi

# The rootless launcher is provided by docker-ce-rootless-extras. If it is not
# installed, leave Docker unconfigured rather than failing startup.
if ! command -v dockerd-rootless.sh >/dev/null 2>&1; then
  echo "rootless docker: dockerd-rootless.sh not found, skipping startup" >&2
  exit 0
fi

# Ensure subordinate UID/GID ranges exist for the current user; rootless mode
# needs them to map container UIDs into the user namespace.
if ! grep -q "^${user}:" /etc/subuid 2>/dev/null; then
  echo "${user}:100000:65536" | sudo tee -a /etc/subuid >/dev/null
fi
if ! grep -q "^${user}:" /etc/subgid 2>/dev/null; then
  echo "${user}:100000:65536" | sudo tee -a /etc/subgid >/dev/null
fi

# Ensure the XDG runtime directory exists and is owned by the user.
if [ ! -d "${runtime_dir}" ]; then
  sudo install -d -m 0700 -o "${uid}" -g "${uid}" "${runtime_dir}"
fi
export XDG_RUNTIME_DIR="${runtime_dir}"

# Launch the daemon in the background. It listens on
# unix://${XDG_RUNTIME_DIR}/docker.sock, which DOCKER_HOST points to.
nohup dockerd-rootless.sh >"${runtime_dir}/dockerd.log" 2>&1 &

exit 0
