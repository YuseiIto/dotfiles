#!/bin/bash
# Check that every version and asset digest pinned in a cookbook is tracked by
# Renovate.
#
# By convention each `<name>_version = '...'` constant and `'<tag>@<sha256>'`
# digest pin carries a `# renovate:` annotation on the line directly above,
# naming the datasource renovate.json expects for it; without one the pin
# silently stops receiving updates. A digest pin's tag must also name the
# release its cookbook installs, because Renovate recomputes the digest from
# that tag on the next bump.
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

version_pin="^[[:space:]]*[a-z0-9_]+_version = '"
digest_pin="'[^'@]+@[0-9a-f]{64}'"

# Collected up front rather than read through process substitution, whose
# exit status `set -e` never sees: a failing or empty search would otherwise
# check nothing and still pass.
if ! pins="$(git grep -nE "${version_pin}|${digest_pin}" -- 'mitamae/cookbooks/*.rb')"; then
	echo "no version pins found under mitamae/cookbooks" >&2
	exit 1
fi

status=0
while IFS=: read -r file line content; do
	previous=""
	if ((line > 1)); then
		previous="$(sed -n "$((line - 1))p" "$file")"
	fi

	if [[ "$content" =~ \'([^\'@]+)@[0-9a-f]{64}\' ]]; then
		tag="${BASH_REMATCH[1]}"
		expected="github-release-attachments"
		if ! grep -qE "${version_pin}${tag#v}'" "$file"; then
			report "$file" "$line" "digest is pinned for '${tag}', which matches no version in this file"
			status=1
		fi
	else
		expected="[^[:space:]]+"
	fi

	if ! [[ "$previous" =~ ^[[:space:]]*#\ renovate:\ datasource=${expected}\  ]]; then
		report "$file" "$line" "pin lacks a matching '# renovate:' annotation on the line above"
		status=1
	elif [[ -z "${tag:-}" && "$previous" == *datasource=github-release-attachments* ]]; then
		report "$file" "$line" "version pin is annotated with the digest datasource"
		status=1
	fi
	unset tag
done <<<"$pins"
exit "$status"
