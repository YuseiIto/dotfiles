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


# Check if "$HOME/.nodenv" exists (i.e. containers)
if [ -d "$HOME/.nodenv" ]; then
  export PATH="$HOME/.nodenv/shims:$HOME/.nodenv/bin:${PATH}"
fi

# Initialize nodenv if it's installed
if command -v nodenv > /dev/null 2>&1; then
  eval "$(nodenv init -)"
fi


# uv-based tools etc..
if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:${PATH}"
fi

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Enable Ctrl-a and other keybindings in tmux
bindkey -e
