# *NIX Fresh Installation

> Essential tools and apps you are too lazy to install

Don't like to recovering your sysmtem from a backup? With this tool you can install a fresh copy of *macOS* or *debian based linux* any day and still have all the tools you want.


## Requirements

Not much, just a modern version of mac/linux with an internet connection, `bash` and `curl` will work.

## Usage

To get specific tools/apps, just fork this repo to fit your needs.

### Easy install:

```shell
curl -fsSL https://raw.githubusercontent.com/pablopunk/fresh-install/master/fresh-install.sh | sudo bash -s
```

## What does this install?

| | Mac | Linux (debian) |
|-|:---:|:-----:|
|[homebrew](https://brew.sh)|x||
|[homebrew cask](https://caskroom.github.io)|x||
|[some cli tools from brew](./install/brew)|x||
|[some cli tools from apt](./install/apt)||x|
|[some cli tools from pip3](./install/pip3)|x|x|
|[some npm modules](./install/npm)|x|x|
|[mac apps](./install/cask)|x||
|[my dotfiles](https://github.com/pablopunk/dotfiles)|x|x|
|keyboard config|x||
|global git config|x|x|
|[Disable Apple persistance](https://apple.stackexchange.com/questions/124367/stop-mavericks-from-relaunching-applications)|x||
