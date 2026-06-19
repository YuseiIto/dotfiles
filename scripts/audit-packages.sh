#!/bin/bash
# Audit installed system packages against what mitamae declares.
#
# mitamae is a convergent provisioner: it guarantees that declared packages are
# *present*, but it cannot guarantee that undeclared packages are *absent*. This
# script closes that gap by detecting drift:
#
#     drift = installed_manual_packages - declared_packages - baseline
#
#   - declared : every `package[...]` (and Homebrew cask) mitamae would manage,
#                derived automatically from the recipes via a dry run. The
#                recipes stay the single source of truth; there is no hand kept
#                list of "my" packages to maintain.
#   - baseline : packages that legitimately exist outside mitamae's control
#                (base image seed, accepted one-offs). Acknowledged explicitly in
#                mitamae/audit/baseline.<role>.txt. Keyed by role because each
#                role's base image seeds a different set (e.g. ubuntu vs debian).
#   - drift    : anything left over is unexplained. Investigate it: either add a
#                cookbook for it, add it to the baseline, or remove it.
#
# This is detect-and-report only; it never installs or removes anything.
#
# Usage:
#   scripts/audit-packages.sh                 # report drift, exit 1 if any
#   scripts/audit-packages.sh --update-baseline
#                                             # accept current state as baseline
#   scripts/audit-packages.sh --list-declared # print the declared set and exit
#
# Role selection mirrors setup.sh: DOTFILES_ROLE, else the short hostname.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MITAMAE_DIR="${REPO_ROOT}/mitamae"
AUDIT_DIR="${MITAMAE_DIR}/audit"

ROLE="${DOTFILES_ROLE:-$(hostname -s | tr '[:upper:]' '[:lower:]')}"
ROLE_PATH="roles/${ROLE}/default.rb"

case "$(uname | tr '[:upper:]' '[:lower:]')" in
  linux) PLATFORM=debian ;;
  darwin) PLATFORM=darwin ;;
  *) echo "Unsupported platform: $(uname)" >&2; exit 1 ;;
esac
BASELINE_FILE="${AUDIT_DIR}/baseline.${ROLE}.txt"

if [ ! -f "${MITAMAE_DIR}/${ROLE_PATH}" ]; then
  echo "Error: role '${ROLE}' not found at mitamae/${ROLE_PATH}" >&2
  echo "Set DOTFILES_ROLE to a valid role under mitamae/roles/." >&2
  exit 1
fi

# Names mitamae would manage for this role, one per line, sorted and unique.
# Captured from a dry run at debug level so that already-installed packages are
# still listed (a plain dry run only reports pending changes). Homebrew casks are
# installed via `execute[install <name> via homebrew cask]`, so they are matched
# separately.
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

baseline() {
  if [ -f "${BASELINE_FILE}" ]; then
    grep -vE '^\s*(#|$)' "${BASELINE_FILE}" | sort -u
  fi
}

# installed_manual - declared - baseline
drift() {
  comm -23 \
    <(comm -23 <(installed_manual) <(declared_packages)) \
    <(baseline)
}

ensure_mitamae() {
  (cd "${MITAMAE_DIR}" && bin/setup >/dev/null)
}

case "${1:-}" in
  --list-declared)
    ensure_mitamae
    declared_packages
    ;;
  --update-baseline)
    ensure_mitamae
    mkdir -p "${AUDIT_DIR}"
    {
      echo "# Packages present outside mitamae's control for role '${ROLE}' (${PLATFORM})."
      echo "# Acknowledged as expected (base image seed, accepted one-offs)."
      echo "# Regenerate with: DOTFILES_ROLE=${ROLE} scripts/audit-packages.sh --update-baseline"
      echo "# Anything installed later that is neither declared nor listed here"
      echo "# will be reported as drift by scripts/audit-packages.sh."
      comm -23 <(installed_manual) <(declared_packages)
    } >"${BASELINE_FILE}"
    echo "Wrote baseline to ${BASELINE_FILE}" >&2
    ;;
  "")
    ensure_mitamae
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
    ;;
  *)
    echo "Unknown option: $1" >&2
    echo "Usage: $0 [--update-baseline | --list-declared]" >&2
    exit 2
    ;;
esac
