# .dotfiles Repository

## Requirements

1. neovim, fzf, neovide, npm(for mason packages)

```sh
brew install neovim fzf neovide node
```

## Cool commands

### Compare 2 files

- Open the first file as a buffer

```vim
:diffs[plit] <second-file>      " horizontal split
:vert diffs[plit] <second-file> " vertical split
```

- From terminal

```sh
nvim -d <first-file> <second-file>
```
