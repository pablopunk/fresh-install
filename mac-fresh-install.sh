#!/bin/bash
# Copyright Pablo Varela 2018

# Custom
github_raw="https://raw.githubusercontent.com/pablopunk/mac-fresh-install/master/install"
dotfiles_repo="https://github.com/pablopunk/dotfiles" # The repo should have an `install.sh` script
dotfiles_folder="$HOME/.dotfiles"
npm_global_dir="$HOME/.npm-global"

# Globals
bold="\x01$(tput bold)\x02"
normal="\x01$(tput sgr0)\x02"
cyan="\x01\033[36m\x02"
green="\x01\033[32m\x02"
step_symbol="#"
pr_symbol="↪"

function pr {
  echo -e "$cyan$bold$pr_symbol $1$normal"
}

function step {
  echo
  echo -e "$green$bold$step_symbol $1$normal"
}

function is {
  hash $1 2>/dev/null && true || false
}

function is_npm_installed {
  ls "$npm_global_dir/lib/node_modules/$1" > /dev/null 2>&1
}

function brewy {
  pr "Installing tool '$1'"
  is $1 || brew install $1 2> /dev/null
}

function casky {
  pr "Installing app '$1'"
  brew cask install $1 2> /dev/null
}

function npmy {
  pr "Installing module '$1'"
  is_npm_installed $1 || npm i -g $1 > /dev/null
}

function install_from_github {
  while read line; do
    ${1}y $line
  done < <(curl -sL "$github_raw/$1")
}

function install_dotfiles {
  git clone $dotfiles_repo $dotfiles_folder
  bash ${dotfiles_folder}/install.sh
}

function keyboard_config {
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false && \
  defaults write NSGlobalDomain KeyRepeat -int 2 && \
  defaults write NSGlobalDomain InitialKeyRepeat -int 10
}

# Install command line tools
step "Xcode command line tools"
is gcc || xcode-select --install
pr "Installed"

# Install homebrew
step "Homebrew (package manager)"
is brew || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
pr "Installed"

# install homebrew cask
step "Homebrew cask (app manager)"
brew tap caskroom/cask
brew tap caskroom/fonts
pr "Installed"

# Utils
step "More command line tools"
install_from_github brew

# Npm modules
step "Npm global modules"
npm config set prefix $npm_global_dir && \
install_from_github npm

# Install apps
step "Apps"
install_from_github cask

# Dotfiles
step "Configuration"
pr "Dotfiles"
[ -d "$dotfiles_folder" ] || install_dotfiles

pr "Keyboard configuration"
keyboard_config

echo
echo -e "$green${bold}✓ DONE! You should restart your computer to get everything working as expected.$normal"
