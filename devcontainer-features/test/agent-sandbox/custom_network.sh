#!/bin/bash
# Assertions are single-quoted `bash -c` strings so they expand when the check runs.
# shellcheck disable=SC2016
set -e
# shellcheck source=/dev/null
source dev-container-features-test-lib
check "upstream is the embedded resolver" grep -qx 127.0.0.11 /var/lib/agent-sandbox/upstream-dns
check "api.github.com reachable" curl -sS --max-time 10 -o /dev/null https://api.github.com/zen
check "example.com does not resolve" bash -c '[ -z "$(dig +short +time=2 +tries=1 example.com)" ]'
# Docker DNATs 127.0.0.11:53 to random ports; querying those directly must fail too.
check "embedded resolver ports listed" grep -q ' 0B00007F:' /proc/net/udp
check "embedded resolver real UDP port blocked" bash -c 'for h in $(awk "NR>1 {print \$2}" /proc/net/udp | sed -n "s/^0B00007F://p"); do ! dig -p "$((16#$h))" +time=2 +tries=1 example.com @127.0.0.11 || exit 1; done'
check "embedded resolver real TCP port blocked" bash -c 'for h in $(awk "NR>1 {print \$2}" /proc/net/tcp | sed -n "s/^0B00007F://p"); do ! dig +tcp -p "$((16#$h))" +time=2 +tries=1 example.com @127.0.0.11 || exit 1; done'
reportResults
