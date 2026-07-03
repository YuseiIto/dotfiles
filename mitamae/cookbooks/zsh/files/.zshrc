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
