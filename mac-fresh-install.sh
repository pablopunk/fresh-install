#!/bin/bash
# Copyright Pablo Varela 2016

ld="\x01$(tput bold)\x02"
normal="\x01$(tput sgr0)\x02"
cyan="\x01\033[36m\x02"
green="\x01\033[32m\x02"
step_symbol="❤︎"
pr_symbol="↪"

function pr {
  echo -e "$cyan$bold$pr_symbol $1$normal"
}

function step {
  echo -e "$green$bold$step_symbol $1$normal"
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
step "Xcode command line tools"
is gcc || xcode-select --install

# Install homebrew
step "Homebrew (package manager)"
is brew || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install homebrew cask
step "Homebrew cask (app manager)"
brew tap caskroom/cask

# Utils
step "More command line tools"
brewy neovim
brewy wget
brewy ag
brewy tmux
brewy reattach-to-user-namespace
brewy node

# Install bashy
pr "Installing bashy"
is bashy || npm install --global bashy

# Install fonts
step "Fonts"
pr "Powerline fonts"
git clone https://github.com/powerline/fonts /tmp/fonts
/tmp/fonts/install.sh
brew tap caskroom/fonts
casky font-fira-code

# Dotfiles
step "Configuration files"
git clone https://github.com/pablopunk/dotfiles ~/.dotfiles
~/.dotfiles/install.sh
npm config set prefix '~/.npm-global'

# Install apps
step "Apps"
while read line; do
  casky $line;
done < <(curl -sL https://gist.github.com/pablopunk/048e164bb0fd2920711483029d9cc915/raw)

echo -e "$green${bold}✓ DONE!$normal"
