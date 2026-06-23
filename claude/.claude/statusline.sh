#!/usr/bin/env bash
# Claude Code status line — session metadata (model, context, effort, cost, rate limits)

input=$(cat)
j() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }

# Abbreviate a token count: 122164 -> 122k, 1000000 -> 1M
abbr() {
  awk -v n="$1" 'BEGIN{
    if (n=="") exit
    if (n>=1000000) printf "%.1fM", n/1000000
    else if (n>=1000) printf "%dk", n/1000
    else printf "%d", n
  }' | sed 's/\.0\([Mk]\)/\1/'
}

cwd=$(j '.workspace.current_dir'); [ -z "$cwd" ] && cwd=$(j '.cwd')
model=$(j '.model.display_name')
used=$(j '.context_window.used_percentage')
used_tok=$(j '.context_window.total_input_tokens')
size_tok=$(j '.context_window.context_window_size')
effort=$(j '.effort.level')
thinking=$(j '.thinking.enabled')
fast=$(j '.fast_mode')
cost=$(j '.cost.total_cost_usd')
added=$(j '.cost.total_lines_added')
removed=$(j '.cost.total_lines_removed')
r5=$(j '.rate_limits.five_hour.used_percentage')
r7=$(j '.rate_limits.seven_day.used_percentage')

DIM='\033[2m'
RST='\033[0m'
B='\033[1m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
MAG='\033[35m'
BLUE='\033[34m'

parts=()

# Current directory (abbreviate $HOME as ~), bold blue
if [ -n "$cwd" ]; then
  d="$cwd"
  case "$d" in
    "$HOME") d="~" ;;
    "$HOME"/*) d="~${d#"$HOME"}" ;;
  esac
  parts+=("$(printf '%b%b%s%b' "$B" "$BLUE" "$d" "$RST")")
fi

# Model
[ -n "$model" ] && parts+=("$(printf '%b%s%b' "$CYAN" "$model" "$RST")")

# Context: "12% ctx (122k/1M)", colored by usage
if [ -n "$used" ]; then
  c="$GREEN"
  awk "BEGIN{exit !($used >= 50 && $used < 80)}" && c="$YELLOW"
  awk "BEGIN{exit !($used >= 80)}" && c="$RED"
  ctx="$(printf '%b%s%% ctx%b' "$c" "$used" "$RST")"
  if [ -n "$used_tok" ] && [ -n "$size_tok" ]; then
    ctx+="$(printf ' %b(%s/%s)%b' "$DIM" "$(abbr "$used_tok")" "$(abbr "$size_tok")" "$RST")"
  fi
  parts+=("$ctx")
fi

# Effort level
[ -n "$effort" ] && parts+=("$(printf '%beffort:%s%b' "$MAG" "$effort" "$RST")")

# Thinking / fast-mode flags
flags=""
[ "$thinking" = "true" ] && flags+="thinking"
[ "$fast" = "true" ] && {
  [ -n "$flags" ] && flags+=" "
  flags+="fast"
}
[ -n "$flags" ] && parts+=("$(printf '%b%s%b' "$DIM" "$flags" "$RST")")

# Cost
[ -n "$cost" ] && parts+=("$(printf '%b$%.2f%b' "$DIM" "$cost" "$RST")")

# Lines changed
if [ -n "$added" ] || [ -n "$removed" ]; then
  parts+=("$(printf '%b+%s%b%b/%b%b-%s%b' "$GREEN" "${added:-0}" "$RST" "$DIM" "$RST" "$RED" "${removed:-0}" "$RST")")
fi

# Rate limits (5h / 7d usage)
if [ -n "$r5" ] || [ -n "$r7" ]; then
  parts+=("$(printf '%b5h:%s%% 7d:%s%%%b' "$DIM" "${r5:-0}" "${r7:-0}" "$RST")")
fi

# Join with a dim separator
sep=$(printf ' %b|%b ' "$DIM" "$RST")
out=""
for p in "${parts[@]}"; do
  [ -n "$out" ] && out+="$sep"
  out+="$p"
done
printf '%b' "$out"
