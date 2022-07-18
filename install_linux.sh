#!/bin/bash

sudo apt update

# setup anyenv
ln -fsn $DOTFILES_DIR/anyenv ~/.anyenv
sudo apt install python3-pip
cd $DOTFILES_DIR/anyenv&&python setup.py install
anyenv install --init


# Setup Zsh
sudo apt install zsh

# Powerline dependencies
sudo apt update
sudo apt install powerline fonts-powerline

# Install latest neovim
sudo apt remove neovim
sudo apt-add-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim


# Install nodejs for fern
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
