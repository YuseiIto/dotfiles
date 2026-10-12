#!/bin/bash
# Assertions are single-quoted `bash -c` strings so they expand when the check runs.
# shellcheck disable=SC2016
set -e
# shellcheck source=/dev/null
source dev-container-features-test-lib
check "general sudo kept when restrictSudo=false" sudo -n true
check "firewall still enforced" bash -c '[ -z "$(dig +short +time=2 +tries=1 example.com)" ]'
reportResults
