#!/bin/bash
# Check that every role's `variant:` attribute equals its directory name.
set -euo pipefail

cd "$(dirname "$0")/.."

# Emit GitHub annotations in CI so failures point at the offending file.
report() {
	local file="$1" message="$2"
	if [ -n "${GITHUB_ACTIONS:-}" ]; then
		echo "::error file=${file}::${message}"
	else
		echo "${file}: ${message}" >&2
	fi
}

status=0
for dir in mitamae/roles/*/; do
	role="$(basename "$dir")"
	file="${dir}default.rb"
	[ -f "$file" ] || continue
	variant="$(sed -nE "s/^[[:space:]]*variant:[[:space:]]*'([^']*)'.*/\1/p" "$file")"
	if [ -z "$variant" ]; then
		report "$file" "no 'variant:' found"
		status=1
	elif [ "$variant" != "$role" ]; then
		report "$file" "variant '$variant' does not match role name '$role'"
		status=1
	fi
done
exit "$status"
