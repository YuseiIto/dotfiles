#!/bin/zsh



DOTFILES_DIR=$(cd $(dirname $0); pwd)
echo $DOTFILES_DIR
ln -fns $DOTFILES_DIR/.zshrc ~/.zshrc
ln -fns $DOTFILES_DIR/.config/nvim ~/.config/nvim
ln -fns $DOTFILES_DIR/.tmux.conf ~/.tmux.conf
ln -fns $DOTFILES_DIR/.config/git ~/.config/git
ln -fns $DOTFILES_DIR/.tmux ~/.tmux

cd $DOTFILES_DIR && git submodule init && git submodule update

if [[ $OSTYPE == 'darwin'* ]]; then
	ln -fns $DOTFILES_DIR/Brewfile ~/Brewfile
#	brew bundle
fi

if [[ $OSTYPE == 'linux-gnu'* ]]; then
	source $DOTFILES_DIR/install_linux.sh
fi
