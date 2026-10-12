#!/bin/bash
# Assertions are single-quoted `bash -c` strings so they expand when the check runs.
# shellcheck disable=SC2016
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "runs as non-root user" bash -c '[ "$(id -un)" = ubuntu ]'
check "packages installed" bash -c 'command -v dnsmasq ipset iptables ip6tables dig curl jq sudo'
check "remote user recorded" bash -c '[ "$(cat /etc/agent-sandbox/remote-user)" = ubuntu ]'
check "default allowlist installed" grep -qx 'api.anthropic.com' /etc/agent-sandbox/allowed-domains.d/00-default
check "config is root-owned" bash -c '[ "$(stat -c %U /etc/agent-sandbox/allowed-domains.d/00-default)" = root ]'

reportResults
