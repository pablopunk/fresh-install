#!/bin/bash
# Copyright Pablo Varela 2016

bold="\x01$(tput bold)\x02"
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
is nvim || brewy neovim
brewy ctags
brewy fd
brewy wget
brewy ag
brewy koekeishiya/formulae/kwm
brewy tmux
brewy reattach-to-user-namespace
brewy node
brewy mosh
brewy fzy
npm config set prefix "$HOME/.npm-global"

# Install bashy
pr "Installing bashy"
is bashy || npm install --global bashy

# Install fonts
step "Fonts"
pr "Powerline fonts"
git clone https://github.com/powerline/fonts /tmp/fonts
bash /tmp/fonts/install.sh
brew tap caskroom/fonts
pr "Fira code"
casky font-fira-code

# Dotfiles
step "Configuration"
pr "Dotfiles"
git clone https://github.com/pablopunk/dotfiles $HOME/.dotfiles
[ -d "$HOME/.dotfiles" ] && bash $HOME/.dotfiles/install.sh
pr "Keyboard configuration"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false && \
defaults write NSGlobalDomain KeyRepeat -int 2 && \
defaults write NSGlobalDomain InitialKeyRepeat -int 10
pr "Trackpad configuration"
sudo defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true && \
sudo defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1 && \
sudo defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1 && \

# Install apps
step "Apps"
while read line; do
  casky $line;
done < <(curl -sL https://gist.github.com/pablopunk/048e164bb0fd2920711483029d9cc915/raw)

echo -e "$green${bold}✓ DONE! You should restart your computer to get everything working as expected.$normal"
