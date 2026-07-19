#!/usr/bin/env bash
# Start a rootless Docker daemon inside the dev container.
#
# This replaces the previous `/var/run/docker.sock` bind mount, which shared
# the host's Docker daemon with the container. Access to that socket is
# effectively host root (a container could start a privileged container or
# mount the host filesystem), so a container compromise escalated straight to
# the host. A rootless daemon runs entirely inside the container's user
# namespace, removing that escalation path. It requires the relaxed
# seccomp/AppArmor profile and /dev/fuse configured via runArgs in
# devcontainer.json.
#
# This script always exits 0: Docker availability must never block container
# startup. Failures are still reported loudly on stderr so they show up in
# the container creation log instead of being buried in dockerd.log.
set -u

uid="$(id -u)"
user="$(id -un)"
runtime_dir="/run/user/${uid}"
sock="${runtime_dir}/docker.sock"
log_file="${runtime_dir}/dockerd.log"
export XDG_RUNTIME_DIR="${runtime_dir}"
export DOCKER_HOST="unix://${sock}"

warn() {
  echo "rootless docker: WARNING: $*" >&2
}

# A responsive daemon means a previous start already succeeded. Checking with
# `docker info` instead of testing for the socket file also catches a stale
# socket left behind by a dead daemon (e.g. after a container restart).
if docker info >/dev/null 2>&1; then
  echo "rootless docker: daemon already running (${DOCKER_HOST})"
  exit 0
fi

# The launcher comes from docker-ce-rootless-extras, but its presence alone
# does not mean the image is ready: docker-ce pulls the extras in via
# Recommends, so older images ship dockerd-rootless.sh without the uidmap/
# networking/storage prerequisites and the daemon dies at startup. Require
# the full toolset and skip (loudly) if any piece is missing.
for cmd in dockerd-rootless.sh newuidmap newgidmap slirp4netns fuse-overlayfs; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    warn "${cmd} not found (image predates the rootless tooling), skipping startup"
    exit 0
  fi
done

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

# Remove a stale socket so the new daemon can bind it.
rm -f "${sock}"

nohup dockerd-rootless.sh >"${log_file}" 2>&1 &

# Wait for the daemon to come up and verify it actually answers, so a broken
# setup is visible in the creation log instead of failing silently.
for _ in $(seq 1 30); do
  if docker info >/dev/null 2>&1; then
    # Keep the conventional socket path working for tools that do not read
    # DOCKER_HOST (and for shells started before the daemon came up). The
    # symlink target is the user-owned rootless socket, so this grants no
    # extra privileges.
    sudo ln -sf "${sock}" /var/run/docker.sock
    echo "rootless docker: daemon is up (${DOCKER_HOST})"
    exit 0
  fi
  sleep 1
done

warn "daemon did not become ready within 30s; docker will be unavailable"
warn "last lines of ${log_file}:"
tail -n 20 "${log_file}" >&2 || true

# Ubuntu 23.10+ hosts restrict user namespaces for unconfined unprivileged
# processes via AppArmor, which fails rootlesskit's UID/GID map setup with
# EPERM. The sysctl is host-global and readable from inside the container,
# so give a targeted hint instead of leaving only a generic timeout.
restrict="/proc/sys/kernel/apparmor_restrict_unprivileged_userns"
if [ -r "${restrict}" ] && [ "$(cat "${restrict}")" = "1" ]; then
  warn "the HOST kernel restricts unprivileged user namespaces (AppArmor)."
  warn "fix on the host: sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0"
fi

# Namespace failures depend on host state the error message does not show
# (setuid bits survive image builds?, seccomp/NoNewPrivs on this process,
# whether the container itself sits in a user namespace, ...), so dump the
# relevant facts to make the next failure diagnosable from the log alone.
warn "diagnostics:"
{
  ls -l "$(command -v newuidmap)" "$(command -v newgidmap)" 2>/dev/null
  grep -E 'NoNewPrivs|CapBnd|CapEff|Seccomp:' /proc/self/status
  echo "container uid_map: $(tr -s ' \n' ' ' </proc/self/uid_map)"
  echo "subuid: $(tr '\n' ' ' </etc/subuid 2>/dev/null)"
  if unshare -U -r true 2>/dev/null; then
    echo "unshare -U -r (self-map): OK"
  else
    echo "unshare -U -r (self-map): FAILED"
  fi
} >&2
exit 0
