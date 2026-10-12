#!/usr/bin/env bash
# Restricts egress to the domains listed under /etc/agent-sandbox/allowed-domains.d.
# Runs as root (via the sudoers entry from install.sh) on every container start
# and must be idempotent.
set -euo pipefail

CONF_DIR=/etc/agent-sandbox
STATE_DIR=/var/lib/agent-sandbox
RUN_DIR=/run/agent-sandbox
IPSET_NAME=agent-sandbox-allowed4
HOST_IPSET_NAME=agent-sandbox-host4
DNSMASQ_PID="$RUN_DIR/dnsmasq.pid"
DNSMASQ_CONF="$RUN_DIR/dnsmasq.conf"
DOMAIN_RE='^([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z]{2,}$'
IPV4_RE='^[0-9]{1,3}(\.[0-9]{1,3}){3}$'

log() { echo "agent-sandbox: $*" >&2; }
die() { log "ERROR: $*"; exit 1; }

close_all() {
  # NOTE: Policies go to DROP before anything else so that a failure anywhere
  # below leaves the container closed rather than open.
  local t
  for t in iptables ip6tables; do
    "$t" -P INPUT DROP
    "$t" -P OUTPUT DROP
    "$t" -P FORWARD DROP
    "$t" -F
    "$t" -X
  done
}

resolve_upstream() {
  local first
  first="$(awk '/^nameserver/ { print $2; exit }' /etc/resolv.conf)"
  # After the first run resolv.conf points at our own dnsmasq; reuse the saved
  # upstream instead of forwarding to ourselves.
  if [ "$first" != 127.0.0.1 ]; then
    [[ "$first" =~ $IPV4_RE ]] || die "unsupported upstream resolver '$first' (IPv4 only)"
    printf '%s\n' "$first" > "$STATE_DIR/upstream-dns"
  fi
  [ -s "$STATE_DIR/upstream-dns" ] || die "no upstream resolver recorded"
  cat "$STATE_DIR/upstream-dns"
}

read_domains() {
  local file line
  for file in "$CONF_DIR"/allowed-domains.d/*; do
    while IFS= read -r line || [ -n "$line" ]; do
      line="${line%%#*}"
      line="$(echo "$line" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')"
      [ -z "$line" ] && continue
      [[ "$line" =~ $DOMAIN_RE ]] || die "invalid domain '$line' in $file"
      echo "$line"
    done < "$file"
  done | sort -u
}

start_dnsmasq() {
  local upstream="$1"; shift
  local domain
  install -d -m 0755 "$RUN_DIR"
  {
    echo "listen-address=127.0.0.1"
    echo "bind-interfaces"
    echo "no-resolv"
    echo "no-hosts"
    echo "user=dnsmasq"
    echo "pid-file=$DNSMASQ_PID"
    # Clients would otherwise try IPv6 first and wait for the DROP to time out.
    echo "filter-AAAA"
    # Everything not matched by a more specific server= line is NXDOMAIN.
    echo "address=/#/"
    for domain in "$@"; do
      echo "server=/$domain/$upstream"
      echo "ipset=/$domain/$IPSET_NAME"
    done
    if allow_host_network; then
      # Docker Desktop serves the host at host.docker.internal, outside the
      # gateway /24. Its address goes to a set that is open on every port.
      echo "server=/host.docker.internal/$upstream"
      echo "ipset=/host.docker.internal/$HOST_IPSET_NAME"
    fi
  } > "$DNSMASQ_CONF"

  stop_dnsmasq
  dnsmasq --conf-file="$DNSMASQ_CONF"
}

stop_dnsmasq() {
  local pid
  [ -s "$DNSMASQ_PID" ] || return 0
  pid="$(cat "$DNSMASQ_PID")"
  # The pid file survives `docker restart`, so the pid may now belong to an
  # unrelated process. A zombie (PID 1 not reaping) also passes `kill -0`.
  is_live_dnsmasq "$pid" || return 0
  kill "$pid"
  for _ in $(seq 50); do
    is_live_dnsmasq "$pid" || return 0
    sleep 0.1
  done
  die "dnsmasq (pid $pid) did not stop"
}

is_live_dnsmasq() {
  local pid="$1"
  [ "$(cat "/proc/$pid/comm" 2>/dev/null)" = dnsmasq ] || return 1
  ! awk '{ exit ($3 == "Z") ? 0 : 1 }' "/proc/$pid/stat" 2>/dev/null
}

allow_host_network() { [ "$(cat "$CONF_DIR/allow-host-network")" = true ]; }

apply_rules() {
  local upstream="$1" host_net
  ipset create "$IPSET_NAME" hash:ip -exist
  ipset flush "$IPSET_NAME"
  ipset create "$HOST_IPSET_NAME" hash:ip -exist
  ipset flush "$HOST_IPSET_NAME"

  # Only dnsmasq may open connections to the upstream resolver, on any port:
  # Docker's embedded DNS (127.0.0.11) is DNATed to random ports that clients
  # could otherwise query directly over loopback. Matching NEW keeps the
  # resolver's replies to dnsmasq, which share the upstream address, flowing.
  iptables -A OUTPUT -d "$upstream" -m owner --uid-owner dnsmasq -j ACCEPT
  iptables -A OUTPUT -d "$upstream" -m conntrack --ctstate NEW -j REJECT
  iptables -A OUTPUT -o lo -j ACCEPT
  iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
  iptables -A OUTPUT -p tcp -m multiport --dports 80,443 \
    -m set --match-set "$IPSET_NAME" dst -j ACCEPT

  iptables -A INPUT -i lo -j ACCEPT
  iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

  if allow_host_network; then
    host_net="$(ip route | awk '/^default/ { print $3; exit }' | sed 's/\.[0-9]*$/.0\/24/')"
    [ -n "$host_net" ] || die "could not detect host network"
    iptables -A OUTPUT -d "$host_net" -j ACCEPT
    iptables -A INPUT -s "$host_net" -j ACCEPT
    iptables -A OUTPUT -m set --match-set "$HOST_IPSET_NAME" dst -j ACCEPT
    iptables -A INPUT -m set --match-set "$HOST_IPSET_NAME" src -j ACCEPT
  fi

  iptables -A OUTPUT -p tcp -j REJECT --reject-with tcp-reset
  iptables -A OUTPUT -j REJECT --reject-with icmp-admin-prohibited

  ip6tables -A INPUT -i lo -j ACCEPT
  ip6tables -A OUTPUT -o lo -j ACCEPT
}

self_test() {
  local upstream="$1"
  # NOTE: Reachability checks accept any HTTP status (no curl -f): unauthenticated
  # api.github.com calls are rate-limited and return 403 after a few runs.
  [ -z "$(dig +short +time=2 +tries=1 example.com @127.0.0.1)" ] \
    || die "self-test: example.com resolved"
  ! curl -sS --max-time 5 -o /dev/null https://1.1.1.1 2>/dev/null \
    || die "self-test: reached a non-allowlisted IP"
  ! dig +time=2 +tries=1 example.com @"$upstream" >/dev/null 2>&1 \
    || die "self-test: upstream resolver reachable directly"
  curl -sS --max-time 10 -o /dev/null https://api.anthropic.com \
    || die "self-test: api.anthropic.com unreachable"
  curl -sS --max-time 10 -o /dev/null https://api.github.com/zen \
    || die "self-test: api.github.com unreachable"
}

audit_sudo() {
  local user
  [ "$(cat "$CONF_DIR/restrict-sudo")" = true ] || return 0
  user="$(cat "$CONF_DIR/remote-user")"
  # Catches grants added after the build (e.g. by a later Feature or layer).
  if sudo -l -U "$user" | sed -n '/may run the following/,$p' | tail -n +2 \
      | grep -v -F "NOPASSWD: /usr/local/share/agent-sandbox/init-firewall.sh" \
      | grep -q '[^[:space:]]'; then
    die "user '$user' has sudo rights beyond the firewall script"
  fi
}

main() {
  local upstream
  local -a domains
  close_all
  install -d -m 0755 "$RUN_DIR"
  upstream="$(resolve_upstream)"
  # Through a file rather than `< <(...)`: a die inside process substitution
  # would not abort the script.
  read_domains > "$RUN_DIR/domains"
  mapfile -t domains < "$RUN_DIR/domains"
  [ "${#domains[@]}" -gt 0 ] || die "allowlist is empty"
  apply_rules "$upstream"
  start_dnsmasq "$upstream" "${domains[@]}"
  printf 'nameserver 127.0.0.1\n' > /etc/resolv.conf
  self_test "$upstream"
  audit_sudo
  log "firewall ready (${#domains[@]} domains)"
}

main "$@"
