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
# UV completions — cached to avoid subshell
if [[ ! -f ~/.zsh/_uv_completion || ~/.zsh/_uv_completion -ot $(command -v uv) ]]; then
  uv generate-shell-completion zsh > ~/.zsh/_uv_completion
fi
source ~/.zsh/_uv_completion
