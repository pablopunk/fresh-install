#!/usr/bin/env bash
# vim:fileencoding=utf-8:ft=bash:foldmethod=marker

sudo echo -n # require sudo perms

# Variables {{{
dotfiles_folder="$HOME/.dotfiles"
dotfiles_repo="git@github.com:pablopunk/dotfiles" # This repo should have an install.sh script
email="pablo@pablopunk.com"
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

section dotfiles
if [[ ! -d $dotfiles_folder ]]
then
  git clone $dotfiles_repo $dotfiles_folder
  pushd $dotfiles_folder
    bash install.sh
  popd
fi
# }}}

# oh-my-zsh {{{
section oh-my-zsh
[[ -d $HOME/.oh-my-zsh ]] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
[[ -d $HOME/.oh-my-zsh/custom/plugins/zsh-github-copilot ]] || git clone https://github.com/loiccoyle/zsh-github-copilot ~/.oh-my-zsh/custom/plugins/zsh-github-copilot
# }}}

# Github cli and ssh {{{
section Github cli
gh auth status | grep "Logged in to github.com account pablopunk" > /dev/null || gh auth login --web -h github.com
gh extension list | grep gh-copilot > /dev/null || gh extension install github/gh-copilot
# }}}

# macOS {{{
if [ "$(uname)" = "Darwin" ]
then
  echo
  section macOS
  gcc 2> /dev/null || xcode-select -p 1>/dev/null || ( echo "Install xcode tools with `xcode-select --install`" && exit )
  pgrep oahd > /dev/null || softwareupdate --install-rosetta

  section Homebrew casks
  brew_install arc
  brew_install arq
  brew_install cleanshot
  brew_install cyberduck
  brew_install discord
  brew_install gh
  brew_install git-delta
  brew_install hiddenbar
  brew_install latest
  brew_install missive
  brew_install monitorcontrol
  brew_install notion-calendar
  brew_install orbstack
  brew_install raycast
  brew_install scroll-reverser
  brew_install slack
  brew_install spotify
  brew_install trash-cli
  brew_install whatsapp
  brew_install zoom

  echo
  section Homebrew packages
  brew_install coreutils
  brew_install docker
  brew_install fd
  brew_install homebrew/core/docker-compose
  brew_install tldr
  brew_install watchman
  brew_install wget

  echo
  section macOS settings
  # don't restore apps on reboot
  defaults write -g ApplePersistence -bool no
  # tap to click
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  # mission control on three fingers up and app windows on down
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 2
  # disable hold keys to show keyboard popup keys
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  # better key repeat
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
  defaults write NSGlobalDomain KeyRepeat -int 1
  # no delay for dock hiding
  defaults write com.apple.dock autohide-delay -float 0
  dscacheutil -flushcache
  # windows minimize on app icons
  defaults write com.apple.dock minimize-to-application -bool true
  # scaling effect on minimize
  defaults write com.apple.dock mineffect -string "scale"
  # make mission control work like exposé
  defaults write com.apple.dock expose-group-by-app -bool false
  # make Dock icons of hidden applications translucent
  defaults write com.apple.dock showhidden -bool true
  # show status bar and path on Finder
  defaults write com.apple.finder ShowStatusBar -bool true
  defaults write com.apple.finder ShowPathbar -bool true
  # show all file extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  # drag with trackpad (not sure if it works)
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -bool true
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

  echo
  section Homebrew packages
  brew_install fd
  brew_install gh
  brew_install tldr
  brew_install trash-cli
fi
# }}}

# NPM {{{
echo
section NPM
npm_install neovim
npm_install odf
npm_install pino-pretty
# }}}

echo
