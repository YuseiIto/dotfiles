#!/bin/bash
# Detect system packages installed outside mitamae's control ("drift"):
#
#     drift = installed_manual - declared - baseline
#
# Detect-and-report only; it never installs or removes anything.
# Full rationale and workflow: mitamae/audit/README.md
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MITAMAE_DIR="${REPO_ROOT}/mitamae"
AUDIT_DIR="${MITAMAE_DIR}/audit"

# Role selection mirrors setup.sh: DOTFILES_ROLE, else the short hostname.
ROLE="${DOTFILES_ROLE:-$(hostname -s | tr '[:upper:]' '[:lower:]')}"
ROLE_PATH="roles/${ROLE}/default.rb"
BASELINE_FILE="${AUDIT_DIR}/baseline.${ROLE}.txt"

case "$(uname | tr '[:upper:]' '[:lower:]')" in
  linux) PLATFORM=debian ;;
  darwin) PLATFORM=darwin ;;
  *) echo "Unsupported platform: $(uname)" >&2; exit 1 ;;
esac

# --- data sources (each emits one package name per line, sorted and unique) ---

# Names mitamae would manage for this role. Captured from a debug-level dry run
# so already-installed packages are still listed (a plain dry run only reports
# pending changes). Homebrew casks run via `execute[install <name> via homebrew
# cask]`, so they are matched separately.
declared_packages() {
  local log
  log="$(cd "${MITAMAE_DIR}" && DOTFILES_ROLE="${ROLE}" \
    bin/mitamae local --dry-run -l debug lib/custom_resources.rb "${ROLE_PATH}" 2>&1)"
  {
    printf '%s\n' "${log}" | grep -oE 'package\[[^]]+\]' | sed -E 's/^package\[(.*)\]$/\1/'
    printf '%s\n' "${log}" | sed -nE 's/.*execute\[install (.+) via homebrew cask\].*/\1/p'
  } | sort -u
}

# Packages explicitly installed on this host (excluding automatic dependencies).
installed_manual() {
  case "${PLATFORM}" in
    debian) apt-mark showmanual ;;
    darwin)
      brew leaves --installed-on-request
      brew list --cask -1 2>/dev/null || true
      ;;
  esac | sort -u
}

# Packages acknowledged as legitimately outside mitamae's control.
baseline() {
  [ -f "${BASELINE_FILE}" ] || return 0
  grep -vE '^\s*(#|$)' "${BASELINE_FILE}" | sort -u
}

# --- set arithmetic ---

# installed_manual - declared: everything the recipes do not explain.
undeclared() {
  comm -23 <(installed_manual) <(declared_packages)
}

# undeclared - baseline: the unexplained remainder.
drift() {
  comm -23 <(undeclared) <(baseline)
}

# --- commands ---

require_role() {
  [ -f "${MITAMAE_DIR}/${ROLE_PATH}" ] && return 0
  echo "Error: role '${ROLE}' not found at mitamae/${ROLE_PATH}" >&2
  echo "Set DOTFILES_ROLE to a valid role under mitamae/roles/." >&2
  exit 1
}

# Build mitamae before shelling out to it, so a fresh checkout works.
prepare() {
  require_role
  (cd "${MITAMAE_DIR}" && bin/setup >/dev/null)
}

cmd_list_declared() {
  declared_packages
}

cmd_update_baseline() {
  mkdir -p "${AUDIT_DIR}"
  {
    echo "# Packages present outside mitamae's control for role '${ROLE}' (${PLATFORM})."
    echo "# Acknowledged as expected (base image seed, accepted one-offs)."
    echo "# Regenerate with: DOTFILES_ROLE=${ROLE} scripts/audit-packages.sh --update-baseline"
    echo "# Anything installed later that is neither declared nor listed here"
    echo "# will be reported as drift by scripts/audit-packages.sh."
    undeclared
  } >"${BASELINE_FILE}"
  echo "Wrote baseline to ${BASELINE_FILE}" >&2
}

cmd_audit() {
  local drift_list
  drift_list="$(drift)"
  if [ -z "${drift_list}" ]; then
    echo "OK: no undeclared packages for role '${ROLE}' (${PLATFORM})."
    exit 0
  fi
  echo "Undeclared packages for role '${ROLE}' (${PLATFORM}):" >&2
  echo "  (installed manually but neither declared in mitamae nor baselined)" >&2
  echo "" >&2
  printf '%s\n' "${drift_list}"
  echo "" >&2
  echo "Resolve each by one of: add a cookbook, add to ${BASELINE_FILE#"${REPO_ROOT}/"}," >&2
  echo "or remove the package. Re-run with --update-baseline to accept current state." >&2
  exit 1
}

usage() {
  cat >&2 <<EOF
Usage: $0 [--update-baseline | --list-declared]

  (no args)          report undeclared packages (drift); exit 1 if any
  --update-baseline  accept the current state as the role's baseline
  --list-declared    print the package set mitamae declares, then exit

Role: DOTFILES_ROLE, else the short hostname. See mitamae/audit/README.md.
EOF
}

case "${1:-}" in
  "")                prepare; cmd_audit ;;
  --list-declared)   prepare; cmd_list_declared ;;
  --update-baseline) prepare; cmd_update_baseline ;;
  -h|--help)         usage ;;
  *)                 echo "Unknown option: $1" >&2; usage; exit 2 ;;
esac
