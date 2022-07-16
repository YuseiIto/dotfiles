#!/bin/zsh


DOTFILES_DIR=$(cd $(dirname $0); pwd)
echo $DOTFILES_DIR
ln -fns $DOTFILES_DIR/.zshrc ~/.zshrc
ln -fns $DOTFILES_DIR/.config/nvim ~/.config/nvim
ln -fns $DOTFILES_DIR/.hyper.js ~/.hyper.js 
ln -fns $DOTFILES_DIR/.tmux.conf ~/.tmux.conf
ln -fns $DOTFILES_DIR/Brewfile ~/Brewfile
