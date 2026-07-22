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

# Fully relaunch sketchybar. Use this instead of `sketchybar --reload`: an
# in-process reload races Control Center alias resolution, so the sound/battery/
# wifi icons come up blank. A fresh process resolves them cleanly, like the old
# `brew services restart sketchybar` did.
function sbreload() {
	pkill sketchybar 2>/dev/null
	sketchybar >/dev/null 2>&1 &
	disown
}
