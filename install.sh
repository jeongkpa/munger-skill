#!/usr/bin/env bash
# install.sh — Installer for the /munger Claude Code skill
#
# One-line usage (via curl):
#   curl -fsSL https://raw.githubusercontent.com/jeongkpa/munger-skill/main/install.sh | bash
#
# Manual usage (after git clone):
#   ./install.sh
#
# What this does:
#   1. Checks prerequisites (git, ~/.claude exists, write permission)
#   2. Backs up any existing ~/.claude/skills/munger to ~/.claude/skills/munger.bak.<timestamp>
#   3. Clones (or copies) the munger-skill into ~/.claude/skills/munger
#   4. Creates the default consultation directory ~/.munger/consultations
#   5. Prints next-steps + env-var hints

set -euo pipefail

REPO_URL="https://github.com/jeongkpa/munger-skill"
TARGET_DIR="$HOME/.claude/skills/munger"
CONSULT_DIR_DEFAULT="$HOME/.munger/consultations"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

# ---------- colors ----------
if [ -t 1 ]; then
  BOLD=$(tput bold || true)
  RED=$(tput setaf 1 || true)
  GREEN=$(tput setaf 2 || true)
  YELLOW=$(tput setaf 3 || true)
  CYAN=$(tput setaf 6 || true)
  RESET=$(tput sgr0 || true)
else
  BOLD=""; RED=""; GREEN=""; YELLOW=""; CYAN=""; RESET=""
fi

info()  { printf "%s[info]%s %s\n" "$CYAN" "$RESET" "$*"; }
ok()    { printf "%s[ ok ]%s %s\n" "$GREEN" "$RESET" "$*"; }
warn()  { printf "%s[warn]%s %s\n" "$YELLOW" "$RESET" "$*"; }
fail()  { printf "%s[fail]%s %s\n" "$RED" "$RESET" "$*" >&2; exit 1; }

# ---------- preflight ----------
info "Installing /munger — Charlie Munger Consultation Skill"
echo

command -v git >/dev/null 2>&1 || fail "git is required but not installed."

if [ ! -d "$HOME/.claude" ]; then
  warn "$HOME/.claude does not exist. Creating it (this is unusual — install Claude Code first if you have not)."
  mkdir -p "$HOME/.claude"
fi

mkdir -p "$HOME/.claude/skills"

# ---------- backup existing install ----------
if [ -e "$TARGET_DIR" ]; then
  BACKUP="$TARGET_DIR.bak.$TIMESTAMP"
  warn "Existing install detected at $TARGET_DIR"
  info "Backing up to $BACKUP"
  mv "$TARGET_DIR" "$BACKUP"
  ok "Backup complete."
fi

# ---------- clone ----------
info "Cloning $REPO_URL into $TARGET_DIR ..."
git clone --depth 1 "$REPO_URL" "$TARGET_DIR"
ok "Clone complete."

# ---------- consultation dir ----------
if [ -n "${MUNGER_CONSULTATIONS:-}" ]; then
  CONSULT_DIR="$MUNGER_CONSULTATIONS"
else
  CONSULT_DIR="$CONSULT_DIR_DEFAULT"
fi
mkdir -p "$CONSULT_DIR"
ok "Consultation directory ready: $CONSULT_DIR"

# ---------- verify ----------
EXPECTED_FILES=(
  "$TARGET_DIR/SKILL.md"
  "$TARGET_DIR/brain/00-brain-of-munger.md"
  "$TARGET_DIR/brain/_evals/canonical.md"
  "$TARGET_DIR/brain/_evals/extracted-quotes.md"
)
for f in "${EXPECTED_FILES[@]}"; do
  [ -f "$f" ] || fail "Missing expected file after install: $f"
done
ok "All expected files in place."

# ---------- summary ----------
echo
printf "%s========================================%s\n" "$BOLD" "$RESET"
printf "%s✓ /munger installed successfully%s\n"        "$BOLD$GREEN" "$RESET"
printf "%s========================================%s\n" "$BOLD" "$RESET"
echo
printf "Skill location:        %s\n" "$TARGET_DIR"
printf "Consultations saved:   %s\n" "$CONSULT_DIR"
echo
printf "%sNext steps:%s\n" "$BOLD" "$RESET"
echo "  1. Open a Claude Code session."
echo "  2. Type: /munger should I quit my job and start a company?"
echo "  3. Try the modes:"
echo "       /munger --quick is BRK.B cheap here?"
echo "       /munger --buffett 집을 사야 할까?"
echo "       /munger --debate exercise ISOs and pay AMT?"
echo "       /munger --retro       (after a few consultations)"
echo "       /munger --eval        (after editing the brain)"
echo
printf "%sOptional environment variables%s (add to your ~/.zshrc or ~/.bashrc):\n" "$BOLD" "$RESET"
echo "  export MUNGER_CONSULTATIONS=\"\$HOME/Obsidian/Munger/_consultations\"   # custom save path"
echo "  export MUNGER_USER_LINK='[[YourName]]'                                # Obsidian author wikilink"
echo
printf "%sSources, license, disclaimer:%s\n" "$BOLD" "$RESET"
echo "  $TARGET_DIR/README.md"
echo "  $TARGET_DIR/README.ko.md (한국어)"
echo "  $TARGET_DIR/LICENSE"
echo
printf "%sUpdate later:%s  cd %s && git pull\n" "$BOLD" "$RESET" "$TARGET_DIR"
echo
ok "Take a simple idea and take it seriously."
