#!/bin/zsh

# Auto complete (ssh,rsync,etc..)
# NOTE: enhancdのinit.shでcompdefが使われるので、.zshrc_specificより先にcompinitを動かす
autoload -U compinit
compinit

# デバイス固有の設定がある場合は~/.zshrc_specificを作って書いておく
if  [ -f ~/.zshrc_specific ]; then
  source ~/.zshrc_specific
fi


export EDITOR=nvim
eval "$(direnv hook zsh)"
eval "$(starship init zsh)"

# tmuxでCtrl-a とかが使えるようにする
bindkey -e
