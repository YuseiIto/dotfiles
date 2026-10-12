#!/bin/bash
# Assertions are single-quoted `bash -c` strings so they expand when the check runs.
# shellcheck disable=SC2016
set -e
# shellcheck source=/dev/null
source dev-container-features-test-lib
check "normalized entries recorded" bash -c 'grep -qx example.org /etc/agent-sandbox/allowed-domains.d/10-feature-options && grep -qx httpbin.org /etc/agent-sandbox/allowed-domains.d/10-feature-options'
check "extra domain reachable" curl -sS --max-time 10 -o /dev/null https://httpbin.org/get
check "example.org resolves" bash -c '[ -n "$(dig +short +time=2 +tries=1 example.org)" ]'
check "unrelated domain still blocked" bash -c '[ -z "$(dig +short +time=2 +tries=1 example.com)" ]'
reportResults
