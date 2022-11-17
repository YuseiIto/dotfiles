#!/bin/zsh

#Anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

# Powerline
function powerline_precmd() {
    PS1="$(powerline-shell --shell zsh $?)"
}

function install_powerline_precmd() {
  for s in "${precmd_functions[@]}"; do
    if [ "$s" = "powerline_precmd" ]; then
      return
    fi
  done
  precmd_functions+=(powerline_precmd)
}

if [ "$TERM" != "linux" ]; then
    install_powerline_precmd
fi


export PATH="$PYENV_ROOT/bin:$PATH"

# EB CLI on Docker
alias eb='docker run  --rm -it -v ~/.aws:/root/.aws -v $(pwd):/work -w /work coxauto/aws-ebcli eb'


# psql
export PATH=/usr/local/Cellar/postgresql/10.1/bin/:$PATH

# mysql(MariaDB) client
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/mysql-client/lib $LDFLAGS"
export CPPFLAGS="-I/opt/homebrew/opt/mysql-client/include $CPPFLAGS"
export PKG_CONFIG_PATH="/opt/homebrew/opt/mysql-client/lib/pkgconfig"

export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib $LDFLAGS"
export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include $CPPFLAGS"

# Flutter
export PATH="/Users/yuseiito/flutter/flutter/bin:$PATH"

#AWS CLI on Docker
alias aws='docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli'
#Ruby(brew)
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"

#MysqlClient(brew)
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/mysql-client/lib"
export CPPFLAGS="-I/opt/homebrew/opt/mysql-client/include"

# Poetry and others
export PATH="/Users/yuseiito/.local/bin:$PATH"

# Auto complete (ssh,rsync,etc..)
autoload -U compinit
compinit

# Custom Aliases
alias doc="cd ~/SynologyDrive/documents"
alias t=task
alias vim='nvim'
export PATH="~/SynologyDrive/documents/00_assets/utils:$PATH"
source ~/SynologyDrive/documents/00_assets/utils/enhancd/init.sh
