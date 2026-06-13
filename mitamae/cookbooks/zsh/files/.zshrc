#!/bin/zsh

# Auto complete (ssh,rsync,etc..)
# NOTE: enhancd's init.sh uses compdef, so run compinit before .zshrc_specific
autoload -U compinit
compinit

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


# Initialize nodenv if it's installed
if command -v nodenv > /dev/null 2>&1; then
  eval "$(nodenv init -)"
fi

# Initialize rbenv if it's installed
if command -v rbenv > /dev/null 2>&1; then
  eval "$(rbenv init - zsh)"
fi

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
if [ -d "$HOME/.sdkman" ]; then
  export SDKMAN_DIR="$HOME/.sdkman"
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# Enable Ctrl-a and other keybindings in tmux
bindkey -e
