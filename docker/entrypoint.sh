#!/usr/bin/env zsh
# shellcheck disable=SC1071
[ -f "$HOME/.zshenv" ] && source "$HOME/.zshenv"
exec "$@"
