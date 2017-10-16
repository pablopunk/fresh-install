# mac-fresh-install

## Use

Use this script to get essential tools and apps on a clean installation of macOS

Easy install:

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/pablopunk/mac-fresh-install/master/mac-fresh-install.sh)"
```

## Utils

- Xcode command line tools
- [Homebrew](https://brew.sh) package manager
- [Homebrew cask](https://caskroom.github.io) to install mac apps
- Command line tools
  - `wget` cause *curl* is alone
  - `neovim` cause I'm a freak and I edit 24/7 with vim
  - `tmux` cause vim was not enough
  - `ag` a.k.a the_silver_searcher (to use *Ack* in vim, better than *grep*)
  - `reattach-to-user-namespace` to make Mac clipboard work in *tmux*
  - [`node`](https://nodejs.org) cause I can't live without it
  - [`bashy`](https://github.com/pablopunk/bashy) to look fabulous
- Fira Code and [Powerline Fonts](https://github.com/powerline/fonts)
- Config files found in [pablopunk/dotfiles](https://github.com/pablopunk/dotfiles), best repo I've ever made
- [Some mac apps](https://gist.github.com/pablopunk/048e164bb0fd2920711483029d9cc915/raw) I wanna have
