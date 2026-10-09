# Python

## pyenv (lazy-loaded)
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$PYENV_ROOT/shims:$PATH"
pyenv() {
  unfunction pyenv
  eval "$(command pyenv init - zsh)"
  pyenv "$@"
}

# UV python
source "$HOME/.local/bin/env"
# UV completions — regenerate only when missing or older than the uv binary.
# Lives in fpath (not sourced): the 550KB script cost ~30ms per startup.
cache_gen ~/.zsh/completions/_uv uv uv generate-shell-completion zsh
