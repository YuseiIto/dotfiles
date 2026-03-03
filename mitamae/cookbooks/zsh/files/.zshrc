#!/bin/zsh

# Auto complete (ssh,rsync,etc..)
# NOTE: enhancd's init.sh uses compdef, so run compinit before .zshrc_specific
autoload -U compinit
compinit

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

# Enable Ctrl-a and other keybindings in tmux
bindkey -e
