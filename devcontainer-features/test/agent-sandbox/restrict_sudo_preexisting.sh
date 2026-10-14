#!/bin/bash
# Assertions are single-quoted `bash -c` strings so they expand when the check runs.
# shellcheck disable=SC2016
set -e
# shellcheck source=/dev/null
source dev-container-features-test-lib
check "pre-existing NOPASSWD:ALL removed" bash -c '! sudo -n true'
check "firewall script still runs" sudo -n /usr/local/share/agent-sandbox/init-firewall.sh
reportResults
