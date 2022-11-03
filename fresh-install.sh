sudo echo # require sudo perms

# VARIABLES

dotfiles_folder="$HOME/.dotfiles"
dotfiles_repo="git@github.com:pablopunk/dotfiles" # The repo should have an install.sh script
node_version="$(curl -s https://versions.pablopunk.com/api/node/v14/latest)"
email="pablo@pablopunk.com"

# SCRIPT

if [ ! -f ~/.ssh/id_rsa ]; then
  echo "Github SSH keys"
  ssh-keygen -t rsa -b 4096 -C "$email"
  ssh-add ~/.ssh/id_rsa
  url="https://github.com/settings/ssh/new"
  echo
  echo "Title: $(hostname)"
  echo
  echo "Key:"
  echo
  cat ~/.ssh/id_rsa.pub
  echo
  [ -x "$(command -v xdg-open)" ] && xdg-open "$url"
  [ -x "$(command -v open)" ] && open "$url"
  echo "Copy the public key above to Github and then run this script again"
  echo $url
fi

echo "rust & cargo"
hash cargo 2>/dev/null || curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y

if [ "$(uname)" = "Darwin" ]
then
  echo "macOS detected"
  echo
  xcode-select -p 1>/dev/null || ( echo "Install xcode tools with `xcode-select --install`" && exit )
  softwareupdate --install-rosetta

  echo "Installing homebrew"
  hash brew 2>/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"

  echo "Homebrew apps"
  brew install alt-tab
  brew install arc
  brew install bash-completion
  brew install cleanshot
  brew install coreutils
  brew install cron
  brew install discord
  brew install git-delta
  brew install google-chrome
  brew install homebrew/cask-fonts/font-caskaydia-cove-nerd-font
  brew install hyperswitch
  brew install karabiner-elements
  brew install kitty
  brew install missive
  brew install monitorcontrol
  brew install nvm
  brew install pritunl
  brew install python
  brew install raycast
  brew install ripgrep
  brew install slack
  brew install spotify
  brew install telegram-desktop
  brew install tmux
  brew install tmuxinator
  brew install vanilla
  brew install watchman
  brew install wget
  brew install whatsapp
  brew install zoom
  brew install zsh-autosuggestions
  brew install zsh-syntax-highlighting

  echo "Apple configs"
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


elif [ "$(uname)" = "Linux" ]
then
  echo "Linux detected"

  echo "APT tools"
  sudo apt update
  sudo apt install -y build-essential
  sudo apt install -y curl
  sudo apt install -y git
  sudo apt install -y neovim
  sudo apt install -y python3
  sudo apt install -y software-properties-common
  sudo apt install -y tmux
  sudo apt install -y vim
  sudo apt install -y zsh

  echo "Installing NVM"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

  echo "Cargo tools"
  # cargo install watchman
  cargo install git-delta
  cargo install ripgrep
fi

echo "Configure NVM"
export NVM_DIR="$HOME/.nvm"
mkdir -p $NVM_DIR
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # macOS
nvm install $node_version
nvm use $node_version
nvm alias default $node_version

echo "NPM tools"
npm i -g bashy
npm i -g eslint
npm i -g eslint-config-standard
npm i -g eslint-plugin-import
npm i -g eslint-plugin-node
npm i -g eslint-plugin-promise
npm i -g eslint-plugin-react
npm i -g eslint-plugin-standard
npm i -g fd-find
npm i -g neovim
npm i -g odf
npm i -g prettier
npm i -g tldr
npm i -g trash-cli
npm i -g typescript
npm i -g vercel

echo "Python tools"
python3 -m pip install neovim --user
python3 -m pip install grip

echo "oh-my-zsh"
if [ ! -d $HOME/.oh-my-zsh ]
then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

echo
echo "Dotfiles"
if [ ! -d $dotfiles_folder ]
then
  git clone $dotfiles_repo $dotfiles_folder
  bash $dotfiles_folder/install.sh
fi

echo
