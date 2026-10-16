#!/bin/bash
# Check that every version pinned in a cookbook is tracked by Renovate.
#
# renovate.json picks up a `<name>_version = '...'` constant only when the line
# directly above it is a `# renovate:` annotation; without one the pin silently
# stops receiving updates.
set -euo pipefail

cd "$(dirname "$0")/.."

# Emit GitHub annotations in CI so failures point at the offending line.
report() {
	local file="$1" line="$2" message="$3"
	if [ -n "${GITHUB_ACTIONS:-}" ]; then
		echo "::error file=${file},line=${line}::${message}"
	else
		echo "${file}:${line}: ${message}" >&2
	fi
}

status=0
while IFS=: read -r file line _; do
	previous="$(sed -n "$((line - 1))p" "$file")"
	if ! [[ "$previous" =~ ^[[:space:]]*#\ renovate:\  ]]; then
		report "$file" "$line" "version pin lacks a '# renovate:' annotation on the line above"
		status=1
	fi
done < <(git grep -nE "^[[:space:]]*[a-z_]+_version = '" -- 'mitamae/cookbooks/*.rb')
exit "$status"
