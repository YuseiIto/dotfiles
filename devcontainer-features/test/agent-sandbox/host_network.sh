#!/bin/bash
# Assertions are single-quoted `bash -c` strings so they expand when the check runs.
# shellcheck disable=SC2016
set -e
# shellcheck source=/dev/null
source dev-container-features-test-lib
check "firewall starts with host network enabled" bash -c 'sudo -n /usr/local/share/agent-sandbox/init-firewall.sh 2>&1 | grep -q "firewall ready"'
check "flag recorded" grep -qx true /etc/agent-sandbox/allow-host-network
check "internet still blocked" bash -c '! curl -sS --max-time 5 -o /dev/null https://1.1.1.1'
check "host.docker.internal forwarded to the host set" grep -qx 'ipset=/host.docker.internal/agent-sandbox-host4' /run/agent-sandbox/dnsmasq.conf
reportResults
