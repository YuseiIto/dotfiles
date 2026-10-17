#!/bin/bash
# Check that every dev container feature changed since BASE_REF (default:
# origin/main) has a higher version than on BASE_REF. Publishing skips a
# version that already exists without failing, so a missed bump would leave
# the change unpublished.
# Usage: scripts/check-feature-versions.sh [BASE_REF]
set -euo pipefail

cd "$(dirname "$0")/.."

base_ref="${1:-origin/main}"
src=devcontainer-features/src
merge_base="$(git merge-base "$base_ref" HEAD)"

# Emit GitHub annotations in CI so failures point at the offending file.
report() {
	local file="$1" message="$2"
	if [ -n "${GITHUB_ACTIONS:-}" ]; then
		echo "::error file=${file}::${message}"
	else
		echo "${file}: ${message}" >&2
	fi
}

# NOTE: Diffs against the working tree so uncommitted changes count locally.
# README.md is excluded because it is read on GitHub, not from the package.
features="$(git diff --name-only "$merge_base" -- "$src" |
	grep -v '/README\.md$' |
	cut -d/ -f3 |
	sort -u)" || true

status=0
for feature in $features; do
	file="$src/$feature/devcontainer-feature.json"
	# Removed features have nothing to publish; new ones have no base version.
	[ -f "$file" ] || continue
	base="$(git show "$merge_base:$file" 2>/dev/null | jq -r .version)" || continue
	head="$(jq -r .version "$file")"
	newest="$(printf '%s\n%s\n' "$base" "$head" | sort -V | tail -n 1)"
	if [ "$head" = "$base" ] || [ "$newest" != "$head" ]; then
		report "$file" "feature '$feature' changed but its version $head is not higher than $base on $base_ref"
		status=1
	fi
done
exit "$status"
