#!/usr/bin/env bash
# onboard.sh — Interactive onboarding for /munger
#
# Run automatically at the end of install.sh when stdin is a TTY.
# Can also be run manually:
#   bash ~/.claude/skills/munger/onboard.sh
#
# What this asks:
#   1. Where to save consultation files (default / Obsidian vault auto-detect / custom)
#   2. Your Obsidian wikilink for the `author:` frontmatter field
#   3. Which shell profile to update with env vars (auto-detect / manual)

set -euo pipefail

SKILL_DIR="${SKILL_DIR:-$HOME/.claude/skills/munger}"

# ---------- colors ----------
if [ -t 1 ]; then
  BOLD=$(tput bold || true)
  DIM=$(tput dim || true)
  GREEN=$(tput setaf 2 || true)
  YELLOW=$(tput setaf 3 || true)
  CYAN=$(tput setaf 6 || true)
  MAGENTA=$(tput setaf 5 || true)
  RESET=$(tput sgr0 || true)
else
  BOLD=""; DIM=""; GREEN=""; YELLOW=""; CYAN=""; MAGENTA=""; RESET=""
fi

prompt()  { printf "%s? %s%s " "$BOLD$CYAN" "$1" "$RESET"; }
hint()    { printf "  %s%s%s\n" "$DIM" "$1" "$RESET"; }
ok()      { printf "%s✓%s %s\n" "$GREEN" "$RESET" "$*"; }
note()    { printf "%s•%s %s\n" "$MAGENTA" "$RESET" "$*"; }

# Bail cleanly on Ctrl+C
trap 'echo; echo "${YELLOW}Onboarding cancelled. You can re-run it anytime: bash $SKILL_DIR/onboard.sh${RESET}"; exit 130' INT

clear || true

cat <<'BANNER'

  ┌──────────────────────────────────────────────────────────────┐
  │                                                              │
  │   /munger — Onboarding                                       │
  │   "Take a simple idea and take it seriously."                │
  │                                                              │
  │   3 quick questions to set up your environment.              │
  │   Press Enter to accept the [default] in brackets.           │
  │                                                              │
  └──────────────────────────────────────────────────────────────┘

BANNER

# ============================================================
# Q1 — Consultation save path
# ============================================================

echo "${BOLD}Q1. Where should consultation files be saved?${RESET}"
echo

# Auto-detect Obsidian vault paths
OBSIDIAN_CANDIDATES=()
shopt -s nullglob
for p in \
  "$HOME"/Library/CloudStorage/GoogleDrive-*/My\ Drive/40_Obsidian \
  "$HOME"/Library/CloudStorage/GoogleDrive-*/My\ Drive/Obsidian \
  "$HOME"/Library/CloudStorage/Dropbox*/Obsidian \
  "$HOME"/Obsidian \
  "$HOME"/Documents/Obsidian \
  "$HOME"/Library/Mobile\ Documents/iCloud~md~obsidian/Documents
do
  if [ -d "$p" ]; then
    OBSIDIAN_CANDIDATES+=("$p")
  fi
done
shopt -u nullglob

DEFAULT_PATH="$HOME/.munger/consultations"

OPTIONS=()
OPTIONS+=("$DEFAULT_PATH   (default — simple, no Obsidian)")
for vault in "${OBSIDIAN_CANDIDATES[@]}"; do
  OPTIONS+=("$vault/40. Reference/Munger/_consultations   (Obsidian vault detected)")
done
OPTIONS+=("Custom path — I'll type it")

idx=1
for opt in "${OPTIONS[@]}"; do
  printf "  %s[%d]%s %s\n" "$BOLD" "$idx" "$RESET" "$opt"
  idx=$((idx+1))
done
LAST_IDX=$((idx - 1))

echo
prompt "Choose [1]:"
read -r CHOICE
CHOICE="${CHOICE:-1}"

CONSULT_DIR=""
if [ "$CHOICE" = "1" ]; then
  CONSULT_DIR="$DEFAULT_PATH"
elif [ "$CHOICE" = "$LAST_IDX" ]; then
  # Custom
  echo
  prompt "Enter absolute path:"
  read -r CONSULT_DIR
  # Expand ~ if present
  CONSULT_DIR="${CONSULT_DIR/#\~/$HOME}"
else
  # One of the Obsidian options
  vault_idx=$((CHOICE - 2))
  if [ "$vault_idx" -ge 0 ] && [ "$vault_idx" -lt "${#OBSIDIAN_CANDIDATES[@]}" ]; then
    CONSULT_DIR="${OBSIDIAN_CANDIDATES[$vault_idx]}/40. Reference/Munger/_consultations"
  else
    CONSULT_DIR="$DEFAULT_PATH"
  fi
fi

mkdir -p "$CONSULT_DIR"
ok "Consultations will be saved to: ${BOLD}$CONSULT_DIR${RESET}"
echo

# ============================================================
# Q2 — Author wikilink
# ============================================================

echo "${BOLD}Q2. What's your Obsidian wikilink for the author field?${RESET}"
hint "Used in consultation file frontmatter. Examples: [[Fran]], [[정기]], [[John Doe]]"
hint "Plain string also fine (no brackets — we'll add them). Press Enter for default [[Author]]."
echo
prompt "Author wikilink [[[Author]]]:"
read -r AUTHOR_INPUT
AUTHOR_INPUT="${AUTHOR_INPUT:-[[Author]]}"
# Ensure brackets are present if user typed plain name
if [[ "$AUTHOR_INPUT" != \[\[*\]\] ]]; then
  AUTHOR_LINK="[[${AUTHOR_INPUT}]]"
else
  AUTHOR_LINK="$AUTHOR_INPUT"
fi
ok "Author: ${BOLD}$AUTHOR_LINK${RESET}"
echo

# ============================================================
# Q3 — Shell profile to update
# ============================================================

echo "${BOLD}Q3. Add environment variables to your shell profile?${RESET}"
hint "We'll append 2 lines so /munger remembers your settings across sessions."

# Detect shell profile
PROFILE_DEFAULT=""
case "$(basename "${SHELL:-/bin/bash}")" in
  zsh)  PROFILE_DEFAULT="$HOME/.zshrc"  ;;
  bash) PROFILE_DEFAULT="$HOME/.bashrc" ;;
  fish) PROFILE_DEFAULT="$HOME/.config/fish/config.fish" ;;
  *)    PROFILE_DEFAULT="$HOME/.profile" ;;
esac

echo
printf "  %s[1]%s Yes — append to %s\n" "$BOLD" "$RESET" "$PROFILE_DEFAULT"
printf "  %s[2]%s Yes — different file (I'll type the path)\n" "$BOLD" "$RESET"
printf "  %s[3]%s Skip — I'll add them manually later\n" "$BOLD" "$RESET"
echo
prompt "Choose [1]:"
read -r SHELL_CHOICE
SHELL_CHOICE="${SHELL_CHOICE:-1}"

PROFILE_TARGET=""
case "$SHELL_CHOICE" in
  1) PROFILE_TARGET="$PROFILE_DEFAULT" ;;
  2)
    prompt "Profile path:"
    read -r PROFILE_TARGET
    PROFILE_TARGET="${PROFILE_TARGET/#\~/$HOME}"
    ;;
  *) PROFILE_TARGET="" ;;
esac

# Compose env block (skip MUNGER_CONSULTATIONS if user picked default — defaults handle it)
ENV_BLOCK=""
if [ "$CONSULT_DIR" != "$DEFAULT_PATH" ]; then
  ENV_BLOCK+="export MUNGER_CONSULTATIONS=\"$CONSULT_DIR\""$'\n'
fi
if [ "$AUTHOR_LINK" != "[[Author]]" ]; then
  ENV_BLOCK+="export MUNGER_USER_LINK='$AUTHOR_LINK'"$'\n'
fi

if [ -n "$PROFILE_TARGET" ] && [ -n "$ENV_BLOCK" ]; then
  if grep -q "^# /munger skill — added by onboard.sh" "$PROFILE_TARGET" 2>/dev/null; then
    note "Existing /munger env block detected in $PROFILE_TARGET — not modified. Edit manually if needed."
  else
    {
      echo ""
      echo "# /munger skill — added by onboard.sh on $(date '+%Y-%m-%d')"
      printf "%s" "$ENV_BLOCK"
    } >> "$PROFILE_TARGET"
    ok "Appended env vars to ${BOLD}$PROFILE_TARGET${RESET}"
    note "Run ${BOLD}source $PROFILE_TARGET${RESET} or open a new terminal to activate."
  fi
elif [ -n "$ENV_BLOCK" ]; then
  note "Add these lines to your shell profile manually:"
  echo
  printf "%s" "$ENV_BLOCK" | sed 's/^/    /'
  echo
else
  ok "Using all defaults — no env vars needed."
fi
echo

# ============================================================
# Summary
# ============================================================

cat <<EOF

${BOLD}========================================${RESET}
${BOLD}${GREEN}✓ Onboarding complete${RESET}
${BOLD}========================================${RESET}

  Skill:           ${BOLD}$SKILL_DIR${RESET}
  Consultations:   ${BOLD}$CONSULT_DIR${RESET}
  Author:          ${BOLD}$AUTHOR_LINK${RESET}

${BOLD}Try it now${RESET} in any Claude Code session:

  /munger should I quit my job to start a company?
  /munger --quick is BRK.B cheap here?
  /munger --buffett 집을 사야 할까?
  /munger --debate exercise ISOs and pay AMT?

${BOLD}Re-run onboarding anytime:${RESET}
  bash $SKILL_DIR/onboard.sh

${BOLD}Update the skill:${RESET}
  cd $SKILL_DIR && git pull

${DIM}"Take a simple idea and take it seriously."${RESET}

EOF
