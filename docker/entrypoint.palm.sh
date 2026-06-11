#!/usr/bin/env bash
# shellcheck source=/dev/null
[ -f "$HOME/.shell-env.sh" ] && source "$HOME/.shell-env.sh"
exec "$@"
