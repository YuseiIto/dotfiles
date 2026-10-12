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

check "example.com does not resolve" bash -c '[ -z "$(dig +short +time=2 +tries=1 example.com)" ]'
check "look-alike domain does not resolve" bash -c '[ -z "$(dig +short +time=2 +tries=1 notgithub.com)" ]'
check "subdomain of allowed domain resolves" bash -c '[ -n "$(dig +short +time=2 +tries=1 api.github.com)" ]'
check "AAAA answers filtered" bash -c '[ -z "$(dig +short AAAA +time=2 +tries=1 github.com)" ]'
check "api.github.com reachable" curl -sS --max-time 10 -o /dev/null https://api.github.com/zen
check "objects.githubusercontent.com reachable" bash -c 'curl -sS --max-time 10 -o /dev/null https://objects.githubusercontent.com'
check "api.anthropic.com reachable" bash -c 'curl -sS --max-time 10 -o /dev/null https://api.anthropic.com'
check "non-allowlisted IP unreachable" bash -c '! curl -sS --max-time 5 -o /dev/null https://1.1.1.1'
check "public resolver blocked" bash -c '! dig +time=2 +tries=1 example.com @8.8.8.8'
check "upstream resolver bypass blocked" bash -c '! dig +time=2 +tries=1 example.com @"$(cat /var/lib/agent-sandbox/upstream-dns)"'
check "IPv6 egress blocked" bash -c '! curl -6 -sS --max-time 5 -o /dev/null "https://[2606:4700:4700::1111]"'
check "firewall re-run is idempotent" sudo -n /usr/local/share/agent-sandbox/init-firewall.sh
check "still works after re-run" curl -sS --max-time 10 -o /dev/null https://api.github.com/zen

reportResults
