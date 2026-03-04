#!/bin/bash
set -euCo pipefail

cd mitamae
bin/setup

# Determine the target role based on the DOTFILES_ROLE environment variable or the hostname
LOWERCASE_HOSTNAME=$(hostname | tr '[:upper:]' '[:lower:]')

# If DOTFILES_ROLE is set, use it; otherwise, use the lowercase hostname
ROLE="${DOTFILES_ROLE:-$LOWERCASE_HOSTNAME}"

ROLE_PATH="roles/${ROLE}/default.rb"

if [ ! -f "${ROLE_PATH}" ]; then
  echo "Error: Role definition for '${ROLE}' not found at ${ROLE_PATH}"
  exit 1
fi

echo "Running mitamae for target: ${ROLE}"
bin/mitamae local $@ "lib/custom_resources.rb" "${ROLE_PATH}"
