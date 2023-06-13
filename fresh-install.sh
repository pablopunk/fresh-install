sudo echo # require sudo perms

# VARIABLES

dotfiles_folder="$HOME/.dotfiles"
dotfiles_repo="git@github.com:pablopunk/dotfiles" # The repo should have an install.sh script
# node_version="$(curl -s https://versions.pablopunk.com/api/node/v16/latest)"
node_version="18.16.0"
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

brew_list=""
function brew_install {
  [[ -z $brew_list ]] && brew_list="$(brew list)" # cache installed brew packages
  [[ -z "$(echo $brew_list | grep -w $1)" ]] && brew install $1 > /dev/null # install only if it's not installed
  echo "✅ $1"
}

npm_list=""
function npm_install {
  [[ -z $npm_list ]] && npm_list="$(npm list -g --depth=0)" # cache installed npm packages
  [[ -z "$(echo $npm_list | grep -w $1)" ]] && npm install -g $1 > /dev/null # install only if it's not installed
  echo "✅ $1"
}

pip3_list=""
function pip3_install {
  [[ -z $pip3_list ]] && pip3_list="$(python3 -m pip list)" # cache installed pip3 packages
  [[ -z "$(echo $pip3_list | grep -w $1)" ]] && python3 -m pip install $@ > /dev/null # install only if it's not installed
  echo "✅ $1"
}

if [ "$(uname)" = "Darwin" ]
then
  echo "[[ macOS ]]"
  echo
  gcc 2> /dev/null || xcode-select -p 1>/dev/null || ( echo "Install xcode tools with `xcode-select --install`" && exit )
  pgrep oahd > /dev/null || softwareupdate --install-rosetta

  echo "Installing homebrew"
  hash brew 2>/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"

  echo
  echo "[Homebrew]"
  echo
  brew_install alt-tab
  brew_install arc
  brew_install asdf
  brew_install bash-completion
  brew_install cleanshot
  brew_install coreutils
  brew_install cron
  brew_install discord
  brew_install docker
  brew_install git-delta
  brew_install google-chrome
  brew_install google-drive
  brew_install helix
  brew_install homebrew/cask-fonts/font-caskaydia-cove-nerd-font
  brew_install hyperswitch
  brew_install karabiner-elements
  brew_install kitty
  brew_install latest
  brew_install missive
  brew_install monitorcontrol
  brew_install pritunl
  brew_install python
  brew_install raycast
  brew_install rectangle
  brew_install ripgrep
  brew_install slack
  brew_install spotify
  brew_install telegram-desktop
  brew_install tmux
  brew_install tmuxinator
  brew_install typescript-language-server
  brew_install vanilla
  brew_install watchman
  brew_install wget
  brew_install whatsapp
  brew_install zoom
  brew_install zsh-autosuggestions
  brew_install zsh-syntax-highlighting

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
  echo "[[ Linux ]]"

  echo
  echo "[APT]"
  echo
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

  echo
  echo "[rust & cargo]"
  echo
  hash cargo 2>/dev/null || curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y

  echo
  echo "[cargo packages]"
  echo
  # cargo install watchman
  cargo install git-delta
  cargo install ripgrep
fi

echo
echo "[asdf]"
echo
. /opt/homebrew/opt/asdf/libexec/asdf.sh
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs $node_version
asdf global nodejs $node_version

echo
echo "[NPM tools]"
echo
npm_install @typescript-eslint/eslint-plugin
npm_install @typescript-eslint/parser
npm_install bashy
npm_install eslint
npm_install eslint-plugin-react
npm_install fd-find
npm_install neovim
npm_install odf
npm_install pino-pretty
npm_install pnpm@8
npm_install prettier
npm_install tldr
npm_install trash-cli
npm_install typescript
npm_install vercel

echo
echo "[pip]"
echo
pip3_install neovim --user
pip3_install grip

echo
echo "[oh-my-zsh]"
echo
if [ ! -d $HOME/.oh-my-zsh ]
then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

echo
echo "[dotfiles]"
echo
if [ ! -d $dotfiles_folder ]
then
  git clone $dotfiles_repo $dotfiles_folder
  bash $dotfiles_folder/install.sh
fi

echo
