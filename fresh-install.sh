sudo echo -n # require sudo perms

# VARIABLES

dotfiles_folder="$HOME/.dotfiles"
dotfiles_repo="git@github.com:pablopunk/dotfiles"
node_version="20.10.0"
email="pablo@pablopunk.com"

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

section Homebrew install
if ! -f /opt/homebrew/bin/brew; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

section dotfiles
if [[ ! -d $dotfiles_folder ]]
then
  git clone $dotfiles_repo $dotfiles_folder
  pushd $dotfiles_folder
    bash link.sh
    bash bootstrap.sh
  popd
fi

section oh-my-zsh
[[ -d $HOME/.oh-my-zsh ]] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"



if [ "$(uname)" = "Darwin" ]
then
  echo
  section macOS
  gcc 2> /dev/null || xcode-select -p 1>/dev/null || ( echo "Install xcode tools with `xcode-select --install`" && exit )
  pgrep oahd > /dev/null || softwareupdate --install-rosetta

  section Homebrew casks
  brew_install alt-tab
  brew_install arc
  brew_install arq
  brew_install cleanshot
  brew_install cyberduck
  brew_install discord
  brew_install hiddenbar
  brew_install latest
  brew_install missive
  brew_install monitorcontrol
  brew_install notion-calendar
  brew_install orbstack
  brew_install raycast
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
  brew_install python
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
  brew_install tldr
  brew_install trash-cli
fi

echo
section mise
if ! hash mise 2>/dev/null;
then
  hash mise 2>/dev/null || curl https://mise.jdx.dev/install.sh | sh
  eval "$(~/.local/bin/mise activate zsh)"
  export PATH="$HOME/.local/share/mise/shims:$PATH"
  mise use --global node@$node_version
fi

echo
section NPM
npm_install @typescript-eslint/eslint-plugin
npm_install @typescript-eslint/parser
npm_install eslint
npm_install eslint-plugin-react
npm_install neovim
npm_install odf
npm_install pino-pretty
npm_install prettier
npm_install typescript

echo
