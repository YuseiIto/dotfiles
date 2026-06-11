#!/bin/zsh
# ~/.zshenv is sourced by zsh for ALL invocations: login, non-login, interactive, non-interactive.
# PATH and environment exports live in the shell-agnostic ~/.shell-env.sh (shared with bash),
# symlinked by the shell-env cookbook.
[ -f "$HOME/.shell-env.sh" ] && . "$HOME/.shell-env.sh"
