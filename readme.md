# Mac Fresh Installation

> Essential tools and apps you are to lazy to install

Don't like to recover your sysmtem from a backup? With this
tool you can install a fresh copy of macOS any day and still
have all the tools you want.


## Requirements

Not much, just a modern mac with an internet connection will work.


## Use

Use this script to get essential tools and apps on a clean installation of macOS. To get specific tools/apps, just fork this repo to fit your needs.

### Easy install:

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/pablopunk/mac-fresh-install/master/mac-fresh-install.sh)"
```


## What does this install?

- Xcode command line tools
- [Homebrew](https://brew.sh) package manager
- [Homebrew cask](https://caskroom.github.io) to install mac apps
- [Some command line tools from brew](./install/brew)
- [Some command line tools from pip3](./install/pip3)
- [Some npm modules](./install/npm)
- [Some mac apps](./install/cask)
- [Dotfiles](https://github.com/pablopunk/dotfiles)
- Keyboard configurations
- [Disable Apple persistance](https://apple.stackexchange.com/questions/124367/stop-mavericks-from-relaunching-applications)
