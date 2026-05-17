#!/bin/sh
# Claude Code status line

# ─── Palette (Catppuccin Mocha-ish, 24-bit truecolor) ──────────────────────────
RESET='\033[0m'
BOLD='\033[1m'
LABEL='\033[38;2;166;173;200m'   # subtext0 — section labels
SEPC='\033[38;2;108;112;134m'    # overlay0 — section dividers
HINT='\033[38;2;127;132;156m'    # overlay1 — reset times
TRACK='\033[38;2;69;71;90m'      # surface1 — empty bar cells
PATHC='\033[38;2;137;220;235m'   # sky      — path
MODELC='\033[38;2;203;166;247m'  # mauve    — model
OK='\033[38;2;166;227;161m'      # green
WARN='\033[38;2;249;226;175m'    # yellow
MID='\033[38;2;250;179;135m'     # peach
DANGER='\033[38;2;243;139;168m'  # red

SEP="${SEPC}  │  ${RESET}"
SUBSEP="${SEPC}  ·  ${RESET}"

# ─── Layout: bars hidden on narrow terminals ───────────────────────────────
cols=$(tput cols 2>/dev/null || printf '%s' "${COLUMNS:-0}")
[ "${cols:-0}" -ge 80 ] && BAR_WIDTH=5 || BAR_WIDTH=0

# ─── Style: wrap text in escape codes ──────────────────────────────────────
paint()      { printf '%s%s%s'     "$1"    "$2" "$RESET"; }
paint_bold() { printf '%s%s%s%s'   "$BOLD" "$1" "$2" "$RESET"; }

# ─── Format: pure value transforms ─────────────────────────────────────────
# Severity color from percentage (0–100). usage: pct_color <pct>
pct_color() {
  if   [ "$1" -ge 95 ]; then printf '%s' "$DANGER"
  elif [ "$1" -ge 85 ]; then printf '%s' "$MID"
  elif [ "$1" -ge 70 ]; then printf '%s' "$WARN"
  else                       printf '%s' "$OK"
  fi
}

# Duration (seconds) → "now" / "Nm" / "NhMm" / "NdNh". usage: fmt_reset <secs>
fmt_reset() {
  if   [ "$1" -le 0 ];     then printf 'now'
  elif [ "$1" -lt 3600 ];  then printf '%dm' $(( $1 / 60 ))
  elif [ "$1" -lt 86400 ]; then printf '%dh%dm' $(( $1 / 3600 )) $(( ($1 % 3600) / 60 ))
  else                          printf '%dd%dh' $(( $1 / 86400 )) $(( ($1 % 86400) / 3600 ))
  fi
}

# Shorten $HOME to ~. usage: short_path <abs_path>
short_path() {
  case "$1" in
    "$HOME"*) printf '~%s' "${1#$HOME}" ;;
    *)        printf '%s' "$1" ;;
  esac
}

# ─── Render: single visual elements (empty when BAR_WIDTH=0) ───────────────
# Discrete bar of $BAR_WIDTH cells. usage: render_bar <pct> <color> <full_glyph> <empty_glyph>
render_bar() {
  [ "$BAR_WIDTH" -le 0 ] && return 0
  _filled=$(( ($1 * BAR_WIDTH + 50) / 100 ))
  [ "$_filled" -gt "$BAR_WIDTH" ] && _filled=$BAR_WIDTH
  [ "$_filled" -lt 0 ] && _filled=0
  _empty=$(( BAR_WIDTH - _filled ))
  _out="${BOLD}${2}"
  _i=0; while [ "$_i" -lt "$_filled" ]; do _out="${_out}${3}"; _i=$((_i+1)); done
  _out="${_out}${RESET}${TRACK}"
  _i=0; while [ "$_i" -lt "$_empty" ];  do _out="${_out}${4}"; _i=$((_i+1)); done
  printf '%s%s' "$_out" "$RESET"
}

# 1-cell pie (○ ◔ ◑ ◕ ●) in 25% steps. usage: render_pie <pct> <color>
render_pie() {
  [ "$BAR_WIDTH" -le 0 ] && return 0
  _q=$(( ($1 + 12) / 25 ))
  [ "$_q" -gt 4 ] && _q=4
  case "$_q" in
    0) _g='○' ;; 1) _g='◔' ;; 2) _g='◑' ;; 3) _g='◕' ;; 4) _g='●' ;;
  esac
  paint_bold "$2" "$_g"
}

# ─── Section: one labelled chunk; empty string when input is missing ───────
# usage: section_path <cwd>
section_path() {
  [ -z "$1" ] && return 0
  paint "$PATHC" "$(short_path "$1")"
}

# usage: section_model <name>
section_model() {
  [ -z "$1" ] && return 0
  paint "$MODELC" "$1"
}

# Pie + percentage. usage: section_ctx <pct_raw>
section_ctx() {
  [ -z "$1" ] && return 0
  _pct=$(printf '%.0f' "$1")
  _col=$(pct_color "$_pct")
  _pie=$(render_pie "$_pct" "$_col")
  _label=$(paint "$LABEL" "ctx")
  _val=$(paint_bold "$_col" "${_pct}%")
  if [ -n "$_pie" ]; then printf '%s %s %s' "$_label" "$_pie" "$_val"
  else                    printf '%s %s'    "$_label" "$_val"
  fi
}

# Bar + percentage + reset hint. usage: section_quota <label> <pct_raw> <reset_epoch> <now>
section_quota() {
  [ -z "$2" ] && return 0
  _pct=$(printf '%.0f' "$2")
  _col=$(pct_color "$_pct")
  _bar=$(render_bar "$_pct" "$_col" '■' '□')
  _label=$(paint "$LABEL" "$1")
  _val=$(paint_bold "$_col" "${_pct}%")
  _hint=""
  [ -n "$3" ] && _hint=" $(paint "$HINT" "($(fmt_reset $(( $3 - $4 ))))")"
  if [ -n "$_bar" ]; then printf '%s %s %s%s' "$_label" "$_bar" "$_val" "$_hint"
  else                    printf '%s %s%s'    "$_label" "$_val" "$_hint"
  fi
}

# ─── Compose: join non-empty pieces with a separator ───────────────────────
# usage: append <accum> <next> <sep>
append() {
  if   [ -z "$1" ]; then printf '%s' "$2"
  elif [ -z "$2" ]; then printf '%s' "$1"
  else                   printf '%s%s%s' "$1" "$3" "$2"
  fi
}

# ─── Parse stdin ───────────────────────────────────────────────────────────
# ASCII Unit Separator avoids POSIX `read` IFS-whitespace collapsing of empty fields.
SEP_CHAR=$(printf '\037')
parsed=$(jq -r --arg s "$SEP_CHAR" '[
  .workspace.current_dir // .cwd // "",
  .model.display_name // "",
  .context_window.used_percentage // "",
  .rate_limits.five_hour.used_percentage // "",
  .rate_limits.five_hour.resets_at // "",
  .rate_limits.seven_day.used_percentage // "",
  .rate_limits.seven_day.resets_at // ""
] | join($s)')
IFS="$SEP_CHAR" read -r cwd model ctx_pct five_pct five_reset seven_pct seven_reset << EOF
$parsed
EOF

# ─── Build output ──────────────────────────────────────────────────────────
now=$(date +%s)
out=""
out=$(append "$out" "$(section_path  "$cwd")"    "$SEP")
out=$(append "$out" "$(section_model "$model")"  "$SEP")
out=$(append "$out" "$(section_ctx   "$ctx_pct")" "$SEP")

quota=""
quota=$(append "$quota" "$(section_quota '5h' "$five_pct"  "$five_reset"  "$now")" "$SUBSEP")
quota=$(append "$quota" "$(section_quota '7d' "$seven_pct" "$seven_reset" "$now")" "$SUBSEP")
out=$(append "$out" "$quota" "$SEP")

printf '%b' "$out"
