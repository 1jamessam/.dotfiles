# Shell functions

# Yank into the macOS clipboard during vi-mode visual/yank
function vi-yank-clipboard {
  zle vi-yank
  echo "$CUTBUFFER" | pbcopy
}
zle -N vi-yank-clipboard

# yazi wrapper that cd's to the directory you quit in
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}
