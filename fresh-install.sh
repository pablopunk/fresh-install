#!/bin/bash
# Copyright Pablo Varela 2018

# Customize!
github_raw="https://raw.githubusercontent.com/pablopunk/mac-fresh-install/master/install"
dotfiles_repo="https://github.com/pablopunk/dotfiles" # The repo should have an `install.sh` script
dotfiles_folder="$HOME/.dotfiles"
npm_global_dir="$HOME/.npm-global"
git_user="pablopunk"
git_email="pablovarela182@gmail.com"

# *nix
if [ "$(uname)" = "Linux" ]; then
  linux=1
  npm=/snap/bin/npm
else
  mac=1
  npm=npm
fi

function sudoless_brew {
  su $SUDO_USER -c "brew $@"
}

function is_mac {
  [ "$mac" = "1" ]
}

function is_linux {
  [ "$linux" = "1" ]
}

if [ ! "$(whoami)" == "root" ]
then
  echo "Rerun as root"
  exit 1
fi

user=`who | awk '{print $1}'`

function pr {
  echo "  $1"
}

function step {
  echo
  echo "[$1]"
  echo
}

function is {
  hash $1 2>/dev/null && true || false
}

function is_npm_installed {
  ls "$npm_global_dir/lib/node_modules/$1" > /dev/null 2>&1
}

function add_apt_repositories {
  while read line; do
    add-apt-repository -y $line > /dev/null 2>&1
  done < <(curl -sL "$github_raw/apt-repository")
}

function brewy {
  ls /usr/local/Cellar/$1 > /dev/null || sudoless_brew "install $@ 2> /dev/null"
}

function casky {
  ls /usr/local/Caskroom/$1 > /dev/null || sudoless_brew "cask install $1 2> /dev/null"
}

function npmy {
  is_npm_installed $1 || $npm i -g $@ > /dev/null
}

function pip3y {
  pip3 install $@ 2> /dev/null 1>&2
}

function apty {
  apt install -y $1 2> /dev/null 1>&2
}

function snapy {
  snap install $@ 2> /dev/null 1>&2
}

function install_from_github {
  while read line; do
    pr $line
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

if is_mac
then
  # Install command line tools
  step "Xcode command line tools"
  is gcc || ( echo "Install xcode cli tools with 'xcode-select --install'" && exit )
  pr "Installed"

  # Install homebrew
  step "Homebrew (package manager)"
  is brew || su $SUDO_USER -c '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
  pr "Installed"

  # install homebrew cask
  step "Homebrew cask (app manager)"
  sudoless_brew "tap caskroom/cask"
  sudoless_brew "tap caskroom/fonts"
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
  apt-get install -y software-properties-common > /dev/null
  add_apt_repositories
  apt update > /dev/null
  echo
  pr "Installing tools"
  echo
  install_from_github apt
  step "Installing snaps"
  install_from_github snap
fi


# pip3 cli tools
step "pip3 command line tools"
install_from_github pip3

# Npm modules
step "Npm global modules"
$npm config set prefix $npm_global_dir && \
install_from_github npm

# Dotfiles
step "Configuration"
pr "Dotfiles"
[ -d "$dotfiles_folder" ] || install_dotfiles

if is_mac
then
  pr "Keyboard configuration"
  keyboard_config
  pr "Disable Apple persistance"
  defaults write -g ApplePersistence -bool no
fi

pr "Git configuration"
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global push.default current
git config --global user.email $git_email
git config --global user.name $git_user
git config --global core.editor nvim

# Fix perms
pr "Fixing permissions"
is_mac && chown -R $SUDO_USER:staff $HOME
is_linux && chown -R $SUDO_USER:$SUDO_USER $HOME

echo
echo "✓ DONE! You should restart your computer to get everything working as expected."
