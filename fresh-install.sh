#!/usr/bin/env bash
# vim:fileencoding=utf-8:ft=bash:foldmethod=marker

sudo echo -n # require sudo perms

# Variables {{{
dotfiles_folder="$HOME/.dotfiles"
dotfiles_repo_https="https://github.com/pablopunk/dotfiles"
dotfiles_repo_ssh="git@github.com:pablopunk/dotfiles"
# }}}

# Install functions {{{
brew_list=""
function brew_install {
  [[ -z $brew_list ]] && brew_list="$(brew list)" # cache installed brew packages
  [[ -z "$(echo $brew_list | grep -w $1)" ]] && brew install $1 > /dev/null # install only if it's not installed
  echo -e "\033[32m✔︎\033[0m $1"
}

npm_list=""
function npm_install {
  [[ -z $npm_list ]] && npm_list="$(npm list -g --depth=0)" # cache installed npm packages
  [[ -z "$(echo $npm_list | grep -w $1)" ]] && npm install -g $1 > /dev/null # install only if it's not installed
  echo -e "\033[32m✔︎\033[0m $1"
}

pip3_list=""
function pip3_install {
  [[ -z $pip3_list ]] && pip3_list="$(python3 -m pip list)" # cache installed pip3 packages
  [[ -z "$(echo $pip3_list | grep -w $1)" ]] && python3 -m pip install $@ > /dev/null # install only if it's not installed
  echo -e "\033[32m✔︎\033[0m $1"
}

function apt_install {
  if ! dpkg -s "$1" >/dev/null 2>&1; then
    sudo apt install -y "$@"
  fi
  echo -e "\033[32m✔︎\033[0m $1"
}

function section {
  echo -e "\033[94m→\033[0m $@"
}
# }}}

# Homebrew {{{
section Homebrew install
if [[ "$(uname)" = "Darwin" ]] && [[ ! -f /opt/homebrew/bin/brew ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ "$(uname)" = "Linux" ]] && [[ ! -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  sudo apt install -y curl 2>/dev/null 1>/dev/null
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
# }}}

# macOS {{{
if [ "$(uname)" = "Darwin" ]
then
  echo
  section macOS
  gcc 2> /dev/null || xcode-select -p 1>/dev/null || ( xcode-select --install )
  pgrep oahd > /dev/null || softwareupdate --install-rosetta
# }}}
# Linux {{{
elif [ "$(uname)" = "Linux" ]
then
  echo
  section Linux

  section APT update
  sudo apt update -qq

  echo
  section APT packages
  apt_install build-essential
  apt_install curl
  apt_install git
fi
# }}}

# Dotfiles {{{
section Dotfiles
brew_install pablopunk/brew/dot
if [[ ! -d $dotfiles_folder ]]
then
  git clone $dotfiles_repo_https $dotfiles_folder
  echo
  echo "Dotfiles are under $dotfiles_folder"
  echo "Go run dot with any of the profiles. Example:"
  echo
  echo "  cd $dotfiles_folder && dot m1pro"
  echo
  echo "If you've set up an ssh key for github, you can also run:"
  echo
  echo "  cd $dotfiles_folder && git remote set-url origin $dotfiles_repo_ssh"
  echo
fi

echo
