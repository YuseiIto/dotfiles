#!/bin/bash
set -e
# shellcheck source=/dev/null
source dev-container-features-test-lib
check "default mode left unset" jq -e '.permissions.defaultMode == null' /etc/claude-code/managed-settings.json
check "bypass warning dialog not skipped" jq -e '.skipDangerousModePermissionPrompt == null' /etc/claude-code/managed-settings.json
reportResults
