# VARIABLES

dotfiles_folder="$HOME/.dotfiles"
dotfiles_repo="git@github.com:pablopunk/dotfiles" # The repo should have an `install.sh` script

# FUNCTIONS

function install_cask {
if [ "$(uname)" = "Darwin" ]
then
  ls /usr/local/Caskroom/$1 > /dev/null 2>&1 || brew cask install $@ 2> /dev/null
elif [ "$(uname)" = "Linux" ]
then
  ls /home/linuxbrew/.linuxbrew/Caskroom//$1 > /dev/null 2>&1 || brew cask install $@ 2> /dev/null
fi
}

function install_npm {
  [[ -d "$NVM_DIR/versions/node/v$(<$NVM_DIR/alias/default)/lib/node_modules/$1" ]] || \
    npm i -g $@  > /dev/null 2>&1
}

function install_brew {
  if [ "$(uname)" = "Darwin" ]
  then
    ls /usr/local/Cellar/$1 > /dev/null 2>&1 || brew install $@ 2> /dev/null
  elif [ "$(uname)" = "Linux" ]
  then
    ls /home/linuxbrew/.linuxbrew/Cellar/$1 > /dev/null 2>&1 || brew install $@ 2> /dev/null
  fi
}

function install_mas {
  if [ -z "$(mas list | cut -d' ' -f2 | grep $1)" ]
  then
    mas lucky $1
  fi
}

function install_apt {
  sudo apt install $@ -y > /dev/null
}

# SCRIPT

echo

if [ "$(uname)" = "Darwin" ]
then
  echo "* macOS *"
  echo
  xcode-select -p 1>/dev/null || ( echo "Install xcode tools with `xcode-select --install`" && exit )
  hash brew 2>/dev/null || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  echo "Cask apps"
  install_cask appcleaner
  install_cask clipy
  install_cask font-cascadia
  install_cask font-hack
  install_cask google-chrome
  install_cask iina
  install_cask istat-menus
  install_cask iterm2
  install_cask karabiner-elements
  install_cask nordvpn
  install_cask slack
  install_cask spotify
  install_cask telegram-desktop
  install_cask transmission
  install_cask whatsapp

  echo "Homebrew tools"
  install_brew ag
  install_brew asciinema
  install_brew bash-completion
  install_brew brew-cask-completion
  install_brew coreutils
  install_brew lolcat
  install_brew mas
  install_brew neovim
  install_brew nvm
  install_brew pyenv
  install_brew starship
  install_brew tmux
  install_brew tmuxinator
  install_brew wget
  install_brew yarn
  install_brew yarn-completion
  install_brew pip-completion

  echo "Mac App Store apps"
  mas install 1470584107 # workaround to install Dato
  install_mas HyperDock
  install_mas Lungo
  install_mas Newton

  echo "Apple configs"
  defaults write com.apple.dock autohide-delay -float 0
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false && \
  defaults write NSGlobalDomain KeyRepeat -int 1 && \
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
  defaults write -g ApplePersistence -bool no

elif [ "$(uname)" = "Linux" ]
then
  echo "* linux *"

  echo "APT tools"
  sudo apt update > /dev/null
  install_apt build-essential
  install_apt curl
  install_apt git
  install_apt python-dev
  install_apt python-pip
  install_apt python3-dev
  install_apt python3-pip
  install_apt python3-venv
  install_apt silversearcher-ag
  install_apt software-properties-common
  install_apt tmux
  install_apt vim
  install_apt zsh

  echo "Homebrew tools"
  hash brew 2>/dev/null || sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
  install_brew asciinema
  install_brew neovim
  install_brew tmuxinator
  install_brew nvm
fi

echo "Configure NVM"
export NVM_DIR="$HOME/.nvm"
mkdir -p $NVM_DIR
if [ "$(uname)" = "Darwin" ]; then
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
else
  [ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ] && . "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"
fi
nvm install 10.18.1 > /dev/null 2>&1
nvm use 10.18.1 > /dev/null 2>&1
nvm alias default 10.18.1 > /dev/null 2>&1

echo "NPM tools"
install_npm bashy
install_npm diff-so-fancy
install_npm eslint
install_npm eslint-config-standard
install_npm eslint-plugin-import
install_npm eslint-plugin-node
install_npm eslint-plugin-promise
install_npm eslint-plugin-react
install_npm eslint-plugin-standard
install_npm fd-find
install_npm miny
install_npm neovim
install_npm now
install_npm nuup
install_npm odf
install_npm prettier
install_npm serve
install_npm taski
install_npm tldr
install_npm trash-cli
install_npm typescript

function install_pip3 {
  pip3 install $@ > /dev/null 2>&1
}

echo "pip3 tools"
install_pip3 grip
install_pip3 neovim --user
install_pip3 --upgrade pip setuptools

echo "oh-my-zsh"
if [ ! -d $HOME/.oh-my-zsh ]
then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

echo "rust & cargo"
hash cargo 2>/dev/null || curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y

echo "Dotfiles"
if [ ! -d $dotfiles_folder ]
then
  git clone $dotfiles_repo $dotfiles_folder
  bash $dotfiles_folder/install.sh
fi

echo
