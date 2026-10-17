#!/bin/bash
# Check that every version and asset digest pinned in a cookbook is tracked by
# Renovate.
#
# By convention each `<name>_version = '...'` constant and `'<tag>@<sha256>'`
# digest pin carries a `# renovate:` annotation on the line directly above,
# naming the kind of datasource renovate.json expects for it; without one the
# pin silently stops receiving updates. The annotation must have exactly the
# shape renovate.json's matchStrings read, since any other key or key order
# makes Renovate skip the pin while it still looks annotated. Digest pins must
# also match the format renovate.json parses (lowercase hex, tag included), and
# their tag must equal a version constant in the same file, because Renovate
# recomputes the digest from that tag on the next bump. Versions must be
# constants, not literals inside a resource, which no manager reads.
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

cookbooks='mitamae/cookbooks/*.rb'
version_pin="^[[:space:]]*[a-z0-9_]+_version = '"
digest_pin="'[^'@]+@[0-9a-f]{64}'"

# Collected up front rather than read through process substitution, whose
# exit status `set -e` never sees: a failing or empty search would otherwise
# check nothing and still pass.
if ! pins="$(git grep -nE "${version_pin}|${digest_pin}" -- "$cookbooks")"; then
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
		# The digest matchString has no extractVersion group.
		annotation="datasource=github-release-attachments depName=[^[:space:]]+"
		version="${tag#v}"
		if ! grep -qE "${version_pin}${version//./\\.}'" "$file"; then
			report "$file" "$line" "digest is pinned for '${tag}', which matches no version in this file"
			status=1
		fi
	else
		annotation="datasource=[^[:space:]]+ depName=[^[:space:]]+( extractVersion=[^[:space:]]+)?"
	fi
	annotation="^[[:space:]]*# renovate: ${annotation}[[:space:]]*\$"

	if ! [[ "$previous" =~ $annotation ]]; then
		report "$file" "$line" "pin lacks a '# renovate:' annotation on the line above in the shape renovate.json reads"
		status=1
	elif [[ -z "${tag:-}" && "$previous" == *datasource=github-release-attachments* ]]; then
		report "$file" "$line" "version pin is annotated with the digest datasource"
		status=1
	fi
	unset tag
done <<<"$pins"

# Pins the search above cannot see, so Renovate would never update them.
# alacritty_dmg_sha256 is exempt: its own manager in renovate.json reads a
# bare digest.
while IFS=: read -r file line _; do
	report "$file" "$line" "digest is not pinned as '<tag>@<lowercase sha256>'"
	status=1
done < <(git grep -nE "_sha256[[:space:]=]*'" -- "$cookbooks" |
	grep -vE "${digest_pin}|alacritty_dmg_sha256 = '[0-9a-f]{64}'" || true)

while IFS=: read -r file line _; do
	report "$file" "$line" "version is a literal; pin it in an annotated <name>_version constant"
	status=1
done < <(git grep -nE "^[[:space:]]*version[[:space:]]+['\"]" -- "$cookbooks" || true)

exit "$status"
