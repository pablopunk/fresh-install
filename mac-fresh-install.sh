#!/bin/bash
# Copyright Pablo Varela 2016

ld="\x01$(tput bold)\x02"
normal="\x01$(tput sgr0)\x02"
cyan="\x01\033[36m\x02"
green="\x01\033[32m\x02"
dot="⦿"
arrow="↪"

function pr {
  echo -e "$cyan$bold$arrow $1$normal"
}

function step {
  echo -e "$green$bold$dot $1$normal"
}

function is {
  hash $1 2>/dev/null && true || false
}

function brewy {
  pr "Installing $1"
  is $1 || brew install $1
}

function casky {
  pr "Installing $1"
  brew cask install $1 2> /dev/null
}

# Install command line tools
step "XCODE COMMAND LINE TOOLS"
is gcc || xcode-select --install

# Install homebrew
step "HOMEBREW CASK"
is brew || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install homebrew cask
step "HOMEBREW CASK"
brew tap caskroom/cask

# Install wget,vim
step "UTILITIES"
brewy vim
brewy wget
brewy ag
brewy tmux
brewy reattach-to-user-namespace

# Install nodejs
pr "Installing nodejs"
is node || brew install node

# Install bashy
pr "Installing bashy"
is bashy || npm install --global bashy

# Install powerline fonts
pr "Installing powerline fonts"
git clone https://github.com/powerline/fonts /tmp/fonts
/tmp/fonts/install.sh

# Dotfiles
step "CONFIG FILES"
git clone https://github.com/pablopunk/dotfiles ~/.dotfiles
~/.dotfiles/install.sh

# Install apps
step "MAC APPS"
while read line; do
  casky $line;
done < <(curl -sL https://gist.github.com/pablopunk/048e164bb0fd2920711483029d9cc915/raw)

echo -e "$green${bold}✓ DONE!$normal"
