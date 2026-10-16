#!/bin/bash
# Check that every version and asset digest pinned in a cookbook is tracked by
# Renovate.
#
# renovate.json picks up a `<name>_version = '...'` constant or a
# `'<tag>@<sha256>'` digest pin only when the line directly above it is a
# `# renovate:` annotation; without one the pin silently stops receiving
# updates. A digest pin's tag must also name the release its cookbook installs,
# because Renovate recomputes the digest from that tag on the next bump.
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
while IFS=: read -r file line content; do
	previous=""
	if ((line > 1)); then
		previous="$(sed -n "$((line - 1))p" "$file")"
	fi
	if ! [[ "$previous" =~ ^[[:space:]]*#\ renovate:\  ]]; then
		report "$file" "$line" "pin lacks a '# renovate:' annotation on the line above"
		status=1
	fi

	if [[ "$content" =~ \'([^\'@]+)@[0-9a-f]{64}\' ]]; then
		tag="${BASH_REMATCH[1]}"
		if ! grep -qE "^[[:space:]]*[a-z_]+_version = '${tag#v}'" "$file"; then
			report "$file" "$line" "digest is pinned for '${tag}', which matches no version in this file"
			status=1
		fi
	fi
done < <(git grep -nE "^[[:space:]]*[a-z_]+_version = '|'[^'@]+@[0-9a-f]{64}'" -- 'mitamae/cookbooks/*.rb')
exit "$status"
