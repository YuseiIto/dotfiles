#!/bin/bash
# Runs inside chroot via systemd-nspawn: sets up user, installs packages, runs mitamae.
set -euo pipefail

TARGET_USER=ubuntu
DOTFILES_ROLE="${DOTFILES_ROLE:-pine}"
DEST="/home/${TARGET_USER}/dotfiles"

echo "==> Configuring user ${TARGET_USER}..."
if ! id "${TARGET_USER}" > /dev/null 2>&1; then
    useradd --uid 1000 -U -m -s /usr/bin/zsh "${TARGET_USER}"
else
    # Desktop ISO creates ubuntu user with /bin/bash; switch to zsh
    usermod -s /usr/bin/zsh "${TARGET_USER}" || true
fi

# Passwordless sudo
mkdir -p /etc/sudoers.d
echo "${TARGET_USER} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${TARGET_USER}"
chmod 0440 "/etc/sudoers.d/${TARGET_USER}"
visudo -c -f "/etc/sudoers.d/${TARGET_USER}"

echo "==> Installing packages..."
apt-get update -qq
PACKAGES=()
while IFS= read -r line || [[ -n "${line}" ]]; do
    # Strip comments and blank lines
    line="${line%%#*}"
    line="${line//[[:space:]]/}"
    [[ -n "${line}" ]] && PACKAGES+=("${line}")
done < "${DEST}/live/packages.list"

if [[ ${#PACKAGES[@]} -gt 0 ]]; then
    apt-get install -y --no-install-recommends "${PACKAGES[@]}"
fi

echo "==> Running mitamae provisioning for ${DOTFILES_ROLE}..."
cd "${DEST}"
HOME="/home/${TARGET_USER}" DOTFILES_ROLE="${DOTFILES_ROLE}" bash setup.sh

echo "==> Fixing ownership and permissions..."
chown -R "${TARGET_USER}:${TARGET_USER}" "/home/${TARGET_USER}"

for dir in .ssh .gnupg; do
    if [ -d "/home/${TARGET_USER}/${dir}" ]; then
        chmod 700 "/home/${TARGET_USER}/${dir}"
        find "/home/${TARGET_USER}/${dir}" -type f -exec chmod 600 {} \;
    fi
done

echo "==> Cleaning up apt cache..."
apt-get clean
rm -rf /var/lib/apt/lists/*
