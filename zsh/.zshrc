# zmodload zsh/zprof
# Shell

# Dedupe PATH entries (keeps first occurrence)
typeset -U path PATH

# Regenerate a cached init/completion script only when it's missing or older
# than its source binary, then source it. Avoids a subshell on every startup.
cache_source() {
  local cache=$1 bin=$2; shift 2
  local binpath=$(command -v "$bin")
  if [[ -n $binpath && ( ! -f $cache || $cache -ot $binpath ) ]]; then
    "$@" > $cache
  fi
  [[ -f $cache ]] && source $cache
}

# Homebrew
export PATH=/opt/homebrew/bin:$PATH

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source ~/.zsh/zsh-completions/zsh-completions.plugin.zsh
source ~/.zsh/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Zsh
## Zsh Completion System — only rebuild dump once per day
fpath=($HOME/.docker/completions ~/.zfunc $fpath)
autoload -U compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
_comp_options+=(globdots) # with hidden files
## Zsh config
setopt interactivecomments
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -v
# bindkey 'y' vi-yank-clipboard  # defined in ~/.zsh/functions.zsh
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

###################################################################

# Java
# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

###################################################################

# Homebrew
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@15/include"
# export CFLAGS='-std=c++17'
# Hardcoded brew/xcrun paths to avoid ~200ms of subshells at startup
export CFLAGS="-I/opt/homebrew/opt/openssl@3/include -I/opt/homebrew/opt/bzip2/include -I/opt/homebrew/opt/readline/include -I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include" LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib -L/opt/homebrew/opt/readline/lib -L/opt/homebrew/opt/zlib/lib -L/opt/homebrew/opt/bzip2/lib -L/opt/homebrew/opt/postgresql@15/lib"

# Helm completions — cached to avoid ~40ms subshell
cache_source ~/.zsh/_helm_completion helm helm completion zsh
export GOOGLE_CLOUD_PROJECT="prj-rentspree-dev-429603"
source ~/.zsh_aliases

# Modular config (order-independent pieces) ########################
for f in functions python paths; do source ~/.zsh/$f.zsh; done

###################################################################

# Personal

## Zoxide (better cd) — must be last, cached to avoid subshell
cache_source ~/.zsh/_zoxide_init zoxide zoxide init zsh
