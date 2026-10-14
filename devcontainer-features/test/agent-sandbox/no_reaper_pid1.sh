#!/bin/bash
# Assertions are single-quoted `bash -c` strings so they expand when the check runs.
# shellcheck disable=SC2016
set -e
# shellcheck source=/dev/null
source dev-container-features-test-lib
check "firewall re-run completes" timeout 60 sudo -n /usr/local/share/agent-sandbox/init-firewall.sh
check "still resolves after re-run" bash -c '[ -n "$(dig +short +time=2 +tries=1 api.github.com)" ]'
reportResults
