#!/bin/bash
# Assertions are single-quoted `bash -c` strings so they expand when the check runs.
# shellcheck disable=SC2016
set -e
# shellcheck source=/dev/null
source dev-container-features-test-lib
check "connectors not disabled" bash -c '! jq -e ".disableClaudeAiConnectors == true" /etc/claude-code/managed-settings.json 2>/dev/null'
check "connector proxy resolves" bash -c '[ -n "$(dig +short +time=2 +tries=1 mcp-proxy.anthropic.com)" ]'
check "write tools forced to ask" jq -e '.permissions.ask | index("mcp__claude_ai_*__create_*") and index("mcp__claude_ai_*__send_*")' /etc/claude-code/managed-settings.json
check "hooks restricted to managed settings" jq -e '.allowManagedHooksOnly == true' /etc/claude-code/managed-settings.json
reportResults
