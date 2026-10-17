#!/bin/bash
# Check that every dev container feature changed since its merge base with
# BASE_REF (default: origin/main) has a higher version than at that merge base.
# Publishing skips a version that already exists without failing, so a missed
# bump would leave the change unpublished.
# NOTE: On a pull request HEAD is the merge commit, so the merge base is the
# target tip the merge ref was built on. On a push BASE_REF is the previous tip,
# so the merge base is BASE_REF itself. Locally it is the last common ancestor,
# which misses bumps landed on BASE_REF since then.
# Usage: scripts/check-feature-versions.sh [BASE_REF]
set -euo pipefail

cd "$(dirname "$0")/.."

command -v jq >/dev/null || {
	echo "jq is required" >&2
	exit 2
}

base_ref="${1:-origin/main}"
src=devcontainer-features/src
merge_base="$(git merge-base "$base_ref" HEAD)" || {
	echo "no merge base between $base_ref and HEAD (shallow clone?)" >&2
	exit 2
}

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
fail() {
	report "$@"
	status=1
}

# Reads a devcontainer-feature.json on stdin and prints its version. Fails when
# the version is missing or not a string, which would otherwise compare as
# "null" and sort above every real version.
version() {
	jq -er '.version | strings'
}

# NOTE: Diffs against the working tree and adds untracked files so uncommitted
# changes count locally. README.md is excluded: it is packaged but unused at
# install time, so a stale copy in the published version is harmless.
# --no-renames keeps the source side of a file moved between features, which
# rename detection would hide.
exclude=":(exclude)$src/*/README.md"
changed="$(git diff --name-only --no-renames "$merge_base" -- "$src" "$exclude")"
untracked="$(git ls-files --others --exclude-standard -- "$src" "$exclude")"
features="$(printf '%s\n%s\n' "$changed" "$untracked" | cut -d/ -f3 | sort -u)"

for feature in $features; do
	file="$src/$feature/devcontainer-feature.json"
	# A removed feature has nothing to publish.
	[ -d "$src/$feature" ] || continue
	# A new feature has no version to compare against.
	git cat-file -e "$merge_base:$file" 2>/dev/null || continue
	if ! head="$(version <"$file")"; then
		fail "$file" "feature '$feature' changed but has no valid version"
		continue
	fi
	if ! base="$(git show "$merge_base:$file" | version)"; then
		fail "$file" "feature '$feature' has no valid version at the merge base with $base_ref"
		continue
	fi
	# NOTE: sort -V is not semver: it orders 1.0.0-rc.1 after 1.0.0. That is fine
	# while features publish no prerelease versions.
	newest="$(printf '%s\n%s\n' "$base" "$head" | sort -V | tail -n 1)"
	if [ "$head" = "$base" ] || [ "$newest" != "$head" ]; then
		fail "$file" "feature '$feature' changed but its version $head is not higher than $base at the merge base with $base_ref"
	fi
done
exit "$status"
