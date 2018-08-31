#!/bin/bash
# Copyright Pablo Varela 2018

# Customize!
github_raw="https://raw.githubusercontent.com/pablopunk/mac-fresh-install/master/install"
dotfiles_repo="https://github.com/pablopunk/dotfiles" # The repo should have an `install.sh` script
dotfiles_folder="$HOME/.dotfiles"
npm_global_dir="$HOME/.npm-global"
git_user="pablopunk"
git_email="pablovarela182@gmail.com"

# Globals
bold="\x01$(tput bold)\x02"
normal="\x01$(tput sgr0)\x02"
cyan="\x01\033[36m\x02"
green="\x01\033[32m\x02"
step_symbol="#"
pr_symbol="↪"


# *nix
if [ "$(uname)" = "Linux" ]
then
  linux=1
else
  mac=1
fi

function is_mac {
  [ "$mac" = "1" ]
}

function is_linux {
  [ "$linux" = "1" ]
}

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

function add_apt_repositories {
  while read line; do
    sudo add-apt-repository -y $line
  done < <(curl -sL "$github_raw/apt-repository")
}

function brewy {
  pr "Installing tool (from brew) '$1'"
  is $1 || brew install $@ 2> /dev/null
}

function casky {
  pr "Installing app '$1'"
  brew cask install $1 2> /dev/null
}

function npmy {
  pr "Installing module (from npm) '$1'"
  is_npm_installed $1 || npm i -g $@ > /dev/null
}

function pip3y {
  pr "Installing tool (from pip3) '$1'"
  pip3 install $@ 2> /dev/null 1>&2
}

function apty {
  pr "Installing tool (from apt) '$1'"
  sudo apt install -y $1 2> /dev/null 1>&2
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
  defaults write NSGlobalDomain KeyRepeat -int 1 && \
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
}

function mouse_configuration {
  defaults write .GlobalPreferences com.apple.mouse.scaling -1
}

if is_mac
then
  # Install command line tools
  step "Xcode command line tools"
  is gcc || xcode-select --install
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

  # Install apps
  step "Apps"
  install_from_github cask

  # brew cli tools
  step "Brew command line tools"
  install_from_github brew
fi

if is_linux
then
  step "APT tools"
  pr "Adding repositories"
  add_apt_repositories
  sudo apt update
  pr "Installing tools"
  install_from_github apt
fi


# pip3 cli tools
step "pip3 command line tools"
install_from_github pip3

if is_linux
then
  step "Installing nodejs from ppa"
  curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
  sudo apt install -y nodejs
fi

# Npm modules
step "Npm global modules"
npm config set prefix $npm_global_dir && \
install_from_github npm

# Dotfiles
step "Configuration"
pr "Dotfiles"
[ -d "$dotfiles_folder" ] || install_dotfiles

if is_mac
then
  pr "Keyboard configuration"
  keyboard_config
  pr "Mouse configuration"
  mouse_configuration
  pr "Disable Apple persistance"
  defaults write -g ApplePersistence -bool no
fi

pr "Git configuration"
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global push.default current

echo
echo -e "$green${bold}✓ DONE! You should restart your computer to get everything working as expected.$normal"
