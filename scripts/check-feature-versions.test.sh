#!/bin/bash
# Tests for check-feature-versions.sh against throwaway git repositories.
set -euo pipefail

script="$(cd "$(dirname "$0")" && pwd)/check-feature-versions.sh"
failures=0

# Creates a repo whose main branch has feature `foo` at version 1.9.0, then
# checks out a work branch.
setup() {
	repo="$(mktemp -d)"
	git -C "$repo" init -q -b main
	git -C "$repo" config user.email test@example.com
	git -C "$repo" config user.name test
	mkdir -p "$repo/scripts" "$repo/devcontainer-features/src/foo"
	cp "$script" "$repo/scripts/"
	set_version foo 1.9.0
	echo 'echo foo' > "$repo/devcontainer-features/src/foo/install.sh"
	echo '# foo' > "$repo/devcontainer-features/src/foo/README.md"
	commit
	git -C "$repo" checkout -q -b work
}

set_version() {
	mkdir -p "$repo/devcontainer-features/src/$1"
	printf '{\n  "id": "%s",\n  "version": "%s"\n}\n' "$1" "$2" \
		> "$repo/devcontainer-features/src/$1/devcontainer-feature.json"
}

commit() {
	git -C "$repo" add -A
	git -C "$repo" commit -q -m change
}

# expect NAME STATUS [PATTERN]: runs the check against main and compares its
# exit status and, if given, its output.
expect() {
	local name="$1" want="$2" pattern="${3:-}" got=0 output
	output="$("$repo/scripts/check-feature-versions.sh" main 2>&1)" || got=$?
	if [ "$got" != "$want" ] || { [ -n "$pattern" ] && ! grep -q "$pattern" <<<"$output"; }; then
		echo "FAIL $name (exit $got, want $want)"
		printf '    %s\n' "$output"
		failures=$((failures + 1))
	else
		echo "ok   $name"
	fi
	rm -rf "$repo"
}

setup
echo 'echo changed' > "$repo/devcontainer-features/src/foo/install.sh"
commit
expect "change without bump fails" 1 "foo.*1\.9\.0"

setup
echo 'echo changed' > "$repo/devcontainer-features/src/foo/install.sh"
set_version foo 1.10.0
commit
expect "bump compares as semver" 0

setup
echo 'echo changed' > "$repo/devcontainer-features/src/foo/install.sh"
set_version foo 1.8.0
commit
expect "downgrade fails" 1 "foo"

setup
echo 'echo changed' > "$repo/devcontainer-features/src/foo/install.sh"
expect "uncommitted change without bump fails" 1 "foo"

setup
echo '# foo, reworded' > "$repo/devcontainer-features/src/foo/README.md"
commit
expect "README-only change passes" 0

setup
set_version bar 0.1.0
commit
expect "new feature passes" 0

setup
git -C "$repo" rm -q -r devcontainer-features/src/foo
commit
expect "removed feature passes" 0

setup
echo 'unrelated' > "$repo/other.txt"
commit
expect "no feature change passes" 0

[ "$failures" = 0 ]
