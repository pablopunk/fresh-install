#!/bin/bash
# Copyright Pablo Varela 2016

ld="\x01$(tput bold)\x02"
normal="\x01$(tput sgr0)\x02"
cyan="\x01\033[36m\x02"
green="\x01\033[32m\x02"
step_symbol="↪"

function pr {
  echo -e "$cyan$bold$step_symbol $1$normal"
}

function is {
  hash $1 2>/dev/null && true || false
}

# Install command line tools
pr "Installing command line tools"
is gcc || xcode-select --install

# Install homebrew
pr "Installing homebrew.."
is brew || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install homebrew cask
pr "Installing homebrew cask.."
brew tap caskroom/cask

# Install wget,vim
pr "Installing some utilities.."
is vim || brew install vim
is wget || brew install wget

# Install nodejs
pr "Installing nodejs.."
is node || brew install node

# Install bashy
pr "Installing bashy.."
is bashy || npm install --global bashy

# Install powerline fonts
pr "Installing powerline fonts.."
git clone https://github.com/powerline/fonts /tmp/fonts
/tmp/fonts/install.sh

# Dotfiles
pr "Configuring dotfiles.."
git clone https://github.com/pablopunk/dotfiles ~/.dotfiles
~/.dotfiles/install.sh

# Install apps
pr "Install mac apps.."
while read line; do
  brew cask install $line;
done < <(curl -sL https://gist.github.com/pablopunk/048e164bb0fd2920711483029d9cc915/raw)

echo -e "$green${bold}✓ DONE!$normal"
