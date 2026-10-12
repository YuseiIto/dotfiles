#!/bin/bash
# Assertions are single-quoted `bash -c` strings so they expand when the check runs.
# shellcheck disable=SC2016
set -e
# shellcheck source=/dev/null
source dev-container-features-test-lib
check "firewall came up after common-utils" bash -c '[ -z "$(dig +short +time=2 +tries=1 example.com)" ]'
check "general sudo denied" bash -c '! sudo -n true'
reportResults
