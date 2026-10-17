#!/bin/bash
# Tests for check-feature-versions.sh against throwaway git repositories.
set -euo pipefail

script="$(cd "$(dirname "$0")" && pwd)/check-feature-versions.sh"
failures=0
repo=
trap 'rm -rf "$repo"' EXIT

# Replaces the previous case's repo with one whose main branch has feature `foo`
# at version 1.9.0, then checks out a work branch.
setup() {
	rm -rf "$repo"
	repo="$(mktemp -d)"
	git -C "$repo" init -q -b main
	git -C "$repo" config user.email test@example.com
	git -C "$repo" config user.name test
	git -C "$repo" config commit.gpgsign false
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

change() {
	echo 'echo changed' > "$repo/devcontainer-features/src/$1/install.sh"
}

commit() {
	git -C "$repo" add -A
	git -C "$repo" commit -q -m change
}

# Commits on top of main as well, so the change is part of the merge base. Only
# valid while work has not diverged from main.
commit_base() {
	commit
	git -C "$repo" branch -q -f main
}

# expect NAME STATUS [PATTERN [ABSENT]]: runs the check against BASE (default:
# main) and compares its exit status and, if given, requires PATTERN and
# forbids ABSENT in its output.
expect() {
	local name="$1" want="$2" pattern="${3:-}" absent="${4:-}" got=0 output
	output="$("$repo/scripts/check-feature-versions.sh" "${BASE:-main}" 2>&1)" || got=$?
	if [ "$got" != "$want" ] ||
		{ [ -n "$pattern" ] && ! grep -q "$pattern" <<<"$output"; } ||
		{ [ -n "$absent" ] && grep -q "$absent" <<<"$output"; }; then
		echo "FAIL $name (exit $got, want $want)"
		printf '    %s\n' "$output"
		failures=$((failures + 1))
	else
		echo "ok   $name"
	fi
}

setup
change foo
commit
expect "change without bump fails" 1 "foo.*1\.9\.0"

setup
change foo
set_version foo 1.10.0
commit
expect "bump compares numerically (1.9 < 1.10)" 0

setup
change foo
set_version foo 1.8.0
commit
expect "downgrade fails" 1 "foo.*1\.8\.0.*1\.9\.0"

setup
change foo
expect "uncommitted change without bump fails" 1 "foo.*1\.9\.0"

setup
echo 'echo new' > "$repo/devcontainer-features/src/foo/new.sh"
expect "untracked file without bump fails" 1 "foo.*1\.9\.0"

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

setup
change foo
printf '{\n  "id": "foo"\n}\n' > "$repo/devcontainer-features/src/foo/devcontainer-feature.json"
commit
expect "missing version fails" 1 "foo.*no valid version"

setup
git -C "$repo" rm -q devcontainer-features/src/foo/devcontainer-feature.json
commit
expect "removed metadata of a kept feature fails" 1 "foo.*no valid version"

setup
printf '{\n  "id": "foo",\n}\n' > "$repo/devcontainer-features/src/foo/devcontainer-feature.json"
commit_base
change foo
set_version foo 2.0.0
commit
expect "invalid version at the merge base fails" 1 "foo.*merge base"

setup
set_version bar 0.1.0
commit_base
change foo
change bar
set_version bar 0.2.0
commit
expect "only the feature missing a bump is reported" 1 "foo" "bar"

setup
set_version bar 0.1.0
commit_base
git -C "$repo" mv devcontainer-features/src/foo/install.sh devcontainer-features/src/bar/install.sh
set_version bar 0.2.0
commit
expect "file moved to another feature fails its source" 1 "foo.*1\.9\.0" "bar"

# The merge base, not the tip of main, is the baseline: a bump that landed on
# main after branching must not fail an unrelated branch.
setup
echo 'unrelated' > "$repo/other.txt"
commit
git -C "$repo" checkout -q main
change foo
set_version foo 1.10.0
commit
git -C "$repo" checkout -q work
expect "feature changed only on main passes" 0

# Two branches bump foo to the same version; once both are merged, the push
# check against the previous main tip catches the second one.
setup
change foo
set_version foo 1.10.0
commit
git -C "$repo" checkout -q main
echo 'echo other' > "$repo/devcontainer-features/src/foo/other.sh"
set_version foo 1.10.0
commit
before="$(git -C "$repo" rev-parse HEAD)"
git -C "$repo" merge -q --no-edit work
BASE="$before" expect "merge that reuses a landed version fails" 1 "foo.*1\.10\.0"

[ "$failures" = 0 ]
