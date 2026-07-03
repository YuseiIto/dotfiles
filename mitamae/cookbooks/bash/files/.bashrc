# shellcheck shell=bash
# All PATH / env wiring (incl. opam) lives in the shell-agnostic ~/.shell-env.sh, shared with zsh.
# shellcheck source=/dev/null
[ -f "$HOME/.shell-env.sh" ] && . "$HOME/.shell-env.sh"
