#!/bin/zsh

# Auto complete (ssh,rsync,etc..)
# NOTE: enhancd's init.sh uses compdef, so run compinit before .zshrc_specific
autoload -Uz compinit
# Rebuild the completion dump (with the full security check) at most once a day;
# otherwise load the cached dump directly via -C to shorten startup. The glob
# qualifier (N.mh+24) matches a plain file modified over 24h ago, so this stays
# portable across macOS and Linux without shelling out to stat(1). Note the glob
# must run in a normal command context (an array assignment), not inside [[ ]],
# where zsh does not perform filename generation. On first run the dump is absent,
# so the -C branch is taken and compinit -C still creates it.
zcompdump_stale=(${ZDOTDIR:-$HOME}/.zcompdump(N.mh+24))
if (( ${#zcompdump_stale} )); then
  compinit
else
  compinit -C
fi
unset zcompdump_stale

# Command history persistence.
# zsh does NOT save history to a file unless both HISTFILE and SAVEHIST are set.
# Use an XDG-style data location so it can be mounted as a directory in containers
# (a single dotfile target turns into a directory under volume/bind mounts).
HISTFILE="$HOME/.local/share/zsh/history"
HISTSIZE=100000
SAVEHIST=100000
mkdir -p "${HISTFILE:h}"      # zsh won't create the parent dir on its own
setopt SHARE_HISTORY          # read/write history across concurrent sessions
setopt EXTENDED_HISTORY       # record command start time and duration
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicates of a command
setopt HIST_IGNORE_SPACE      # skip commands that start with a space
setopt HIST_REDUCE_BLANKS     # collapse superfluous whitespace before saving

# If you have device-specific settings, create ~/.zshrc_specific and write them there
if  [ -f ~/.zshrc_specific ]; then
  source ~/.zshrc_specific
fi

# Set nvim as the default editor if installed
if command -v nvim > /dev/null 2>&1; then
  export EDITOR=nvim
fi

# Point Docker clients at the per-user rootless daemon when one is running (e.g. inside a devcontainer).
# The socket path depends on the current UID, so resolve it here instead of hardcoding it in container config.
# Hosts using the system daemon are unaffected: the rootless socket does not exist there, and an explicitly set DOCKER_HOST always wins.
if [ -z "${DOCKER_HOST:-}" ] && [ -S "/run/user/$(id -u)/docker.sock" ]; then
  export DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"
fi

# Initialize direnv if it's installed
if command -v direnv > /dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Initialize starship if it's installed
if command -v starship > /dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Initialize zoxide if it's installed
if command -v zoxide > /dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi


# Lazy-init nodenv: its shims are already on PATH via ~/.shell-env.sh (sourced from
# ~/.zshenv), so `nodenv init` only adds completion and the `nodenv` shell function.
# Defer that cost until nodenv is first invoked to keep interactive startup fast.
if command -v nodenv > /dev/null 2>&1; then
  nodenv() {
    unfunction nodenv
    eval "$(command nodenv init -)"
    nodenv "$@"
  }
fi

# Lazy-init rbenv (same rationale as nodenv above; shims come from ~/.shell-env.sh).
if command -v rbenv > /dev/null 2>&1; then
  rbenv() {
    unfunction rbenv
    eval "$(command rbenv init - zsh)"
    rbenv "$@"
  }
fi

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
if [ -d "$HOME/.sdkman" ]; then
  export SDKMAN_DIR="$HOME/.sdkman"
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# Enable Ctrl-a and other keybindings in tmux
bindkey -e

# zshguy: natural-language command widget. Press Ctrl-X Ctrl-G, describe what you
# want in plain words, and Claude fills in a shell command at the cursor. A zsh/ZLE
# port of bashguy (https://github.com/mattn/bashguy), which is bash-only because it
# relies on readline's `bind -x` and $READLINE_LINE; ZLE needs a `zle -N` widget
# over $BUFFER/$CURSOR instead. Must sit after `bindkey -e`, which would otherwise
# reset the keymap and drop the binding below.
#
# Bound to the ^X^G chord (unbound by default) rather than a lone ^G so we keep
# ^G = send-break; every free single Ctrl key in the emacs keymap already has a
# useful default. Override ZSHGUY_KEY to rebind.
if command -v claude > /dev/null 2>&1; then
  # zsh's own minibuffer reader; handles ZLE state that a raw tty read would not.
  autoload -Uz read-from-minibuffer

  _zshguy_widget() {
    emulate -L zsh
    # Split at the cursor so a partially typed line is completed in place rather
    # than overwritten, mirroring bashguy's prefix/suffix handling.
    local prefix="${BUFFER[1,CURSOR]}" suffix="${BUFFER[CURSOR+1,-1]}"

    read-from-minibuffer '[zshguy] ' || return   # aborted (Ctrl-G / Ctrl-C)
    local prompt="$REPLY"
    [[ -n "$prompt" ]] || return

    zle -R "[zshguy] generating..."   # transient status; next redraw clears it

    local system
    if [[ -n "$prefix" || -n "$suffix" ]]; then
      system="You are a shell command generator. The user has a partially written command line.
The text before the cursor is: ${prefix}
The text after the cursor is: ${suffix}
Output ONLY the text to insert at the cursor position (no explanation, no markdown, no code fences, no trailing newline). The inserted text combined with the existing text should form a valid shell command. OS: $(uname -s). Current directory: $(pwd)"
    else
      system="You are a shell command generator. The user describes what they want to do in natural language. Output ONLY a single shell command (no explanation, no markdown, no code fences, no trailing newline). The command must work on this OS: $(uname -s). Current directory: $(pwd)"
    fi

    # Pass --model only when ZSHGUY_MODEL is set, so the account default (kept
    # current by the claude-code cookbook) is used instead of a pinned model.
    # Built as an array because zsh does not word-split unquoted expansions.
    local -a model_args
    [[ -n "$ZSHGUY_MODEL" ]] && model_args=(--model "$ZSHGUY_MODEL")

    local result
    result=$(claude --no-session-persistence -p "${model_args[@]}" \
      --system-prompt "$system" "$prompt" 2>/dev/null)

    if [[ -n "$result" ]]; then
      BUFFER="${prefix}${result}${suffix}"
      CURSOR=$(( ${#prefix} + ${#result} ))
    fi
    zle -R   # clear the transient status line
  }
  zle -N _zshguy_widget
  # ~/.zshrc_specific is sourced earlier, so a host can set ZSHGUY_KEY there.
  bindkey "${ZSHGUY_KEY:-^X^G}" _zshguy_widget
fi
