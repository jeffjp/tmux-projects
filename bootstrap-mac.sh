#!/usr/bin/env bash
# bootstrap-mac.sh : set up a fresh Mac to run construct (operator and worker
# windows in tmux) and Claude Code. Safe to re-run: every step checks first.
# No secrets here: logins and tokens are entered by hand afterwards.
#
#   ./bootstrap-mac.sh              install tools, shell and tmux setup
#   ./bootstrap-mac.sh --always-on  also keep the Mac awake lid closed (sudo)
#
# Needs: the Xcode Command Line Tools and Homebrew. Both need a password or a
# GUI click, so this script checks for them and tells you what to run.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
always_on=0
for arg in "$@"; do
  case "$arg" in
    --always-on) always_on=1 ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

say() { printf '\n== %s\n' "$*"; }
export PATH="$HOME/.local/bin:$PATH"   # claude and net-status live here

[ "$(uname -s)" = Darwin ] || { echo "macOS only" >&2; exit 1; }

# 1) Command Line Tools (git, python3, make). Installing them opens a GUI prompt.
say "Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  echo "ok: $(xcode-select -p)"
else
  xcode-select --install >/dev/null 2>&1 || true
  echo "Not installed. Click Install in the dialog on this Mac's screen, then re-run."
  exit 1
fi

# 2) Homebrew. Its installer asks for the admin password, so run it yourself.
say "Homebrew"
brew_bin=/opt/homebrew/bin/brew
if [ ! -x "$brew_bin" ]; then
  echo "Not installed. Run this in a terminal on this Mac, then re-run:"
  echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi
eval "$("$brew_bin" shellenv bash)"
echo "ok: $(brew --version | head -1)"
zprofile="$HOME/.zprofile"
shellenv_line='eval "$(/opt/homebrew/bin/brew shellenv zsh)"'
if ! { grep -qF 'brew shellenv' "$zprofile" 2>/dev/null; }; then
  printf '\n%s\n' "$shellenv_line" >> "$zprofile"
  echo "added brew shellenv to $zprofile"
fi

# 3) Packages from the Brewfile.
say "brew bundle"
brew bundle install --file="$here/Brewfile"

# 4) Claude Code CLI (native installer, self-updating, in ~/.local/bin).
say "Claude Code"
if [ -x "$HOME/.local/bin/claude" ]; then
  echo "ok: $("$HOME/.local/bin/claude" --version 2>/dev/null || echo installed)"
else
  curl -fsSL https://claude.ai/install.sh | bash
fi

# 5) Git: global ignore for per-machine Claude settings. Identity only if unset.
say "git"
if [ -z "$(git config --global user.name || true)" ]; then
  git config --global user.name "${BOOTSTRAP_GIT_NAME:-Jeff Parker}"
fi
if [ -z "$(git config --global user.email || true)" ]; then
  git config --global user.email "${BOOTSTRAP_GIT_EMAIL:-jeffjparker@gmail.com}"
fi
ignore="$HOME/.config/git/ignore"
mkdir -p "$(dirname "$ignore")"
if ! { grep -qxF '**/.claude/settings.local.json' "$ignore" 2>/dev/null; }; then
  echo '**/.claude/settings.local.json' >> "$ignore"
fi
echo "ok: $(git config --global user.name) <$(git config --global user.email)>"

# 6) ~/.zshrc lines construct relies on. Each is added only if missing.
say "~/.zshrc"
zshrc="$HOME/.zshrc"
touch "$zshrc"
add_line() {
  if ! { grep -qxF "$1" "$zshrc"; }; then
    printf '%s\n' "$1" >> "$zshrc"
    echo "added: $1"
  fi
}
add_line 'export PATH="$HOME/.local/bin:$PATH"'
add_line 'alias construct=~/Development/construct/bin/ws-restore'
add_line '[[ -o interactive && -z "$TMUX" ]] && ~/Development/construct/bin/ws-hint'
echo "ok"

# 7) tmux config, net-status and LazyVim. install.sh links into its own folder,
#    so run the main checkout's copy (this script may run from a job worktree).
say "install.sh (tmux, net-status, LazyVim)"
tp="${TMUX_PROJECTS_DIR:-$HOME/Development/tmux-projects}"
[ -x "$tp/install.sh" ] || tp="$here"
"$tp/install.sh"

# 8) Optional: stay awake and reachable with the lid closed and no display.
if [ "$always_on" = 1 ]; then
  say "always on (sudo)"
  sudo pmset -a sleep 0 disksleep 0 powernap 0 womp 1 tcpkeepalive 1 ttyskeepawake 1
  sudo pmset -a disablesleep 1
  pmset -g | grep -E 'SleepDisabled| sleep |disksleep|womp'
fi

# 9) What only a person can do.
say "By hand next"
cat <<'EOF'
  - claude, then /login            (Claude account)
  - gh auth login                  (GitHub, https, browser)
  - Copy ~/Development, ~/.claude/projects and the rest (see construct docs/WORKFLOW.md, New machine)
  - Secrets: HASS_TOKEN in ~/.claude/settings.json (vi), UniFi plugin password (plugin prompt)
  - New SSH key (ssh-keygen -t ed25519) for the metrics Pi and GitHub if needed
  - Allow Terminal to control Mail (first osascript run prompts)
  - Xcode from the App Store if this Mac builds iOS apps
EOF
