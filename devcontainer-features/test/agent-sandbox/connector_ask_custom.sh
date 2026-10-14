#!/bin/bash
set -e
# shellcheck source=/dev/null
source dev-container-features-test-lib
check "custom ask rules replace defaults" jq -e '.permissions.ask == ["mcp__claude_ai_*"]' /etc/claude-code/managed-settings.json
reportResults
