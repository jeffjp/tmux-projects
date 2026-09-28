#!/usr/bin/env bash
# Install Jeff's tmux setup: link the tmux config and the net-status helper,
# and set up Neovim + LazyVim. Safe to re-run. Backs up any existing real
# ~/.tmux.conf.
set -eu

here="$(cd "$(dirname "$0")" && pwd)"

# 1) Put the helpers on your PATH via a personal bin dir.
bindir="$HOME/.local/bin"
mkdir -p "$bindir"
ln -sf "$here/net-status" "$bindir/net-status"   # tmux status segment: which link carries traffic
echo "linked $bindir/net-status -> $here/net-status"
# The session-per-project launcher was retired 2026-09-28; drop its old link
# if it still points into this checkout.
if [ -L "$bindir/tmux-projects" ] && [ ! -e "$bindir/tmux-projects" -o "$(readlink "$bindir/tmux-projects")" = "$here/tmux-projects" ]; then
  rm -f "$bindir/tmux-projects" && echo "removed old launcher link $bindir/tmux-projects"
fi
case ":$PATH:" in
  *":$bindir:"*) ;;
  *)
    echo "NOTE: $bindir is not on your PATH yet. Add this to ~/.zshrc:"
    echo '      export PATH="$HOME/.local/bin:$PATH"'
    ;;
esac

# 2) Install the tmux config as ~/.tmux.conf (back up an existing real file).
target="$HOME/.tmux.conf"
if [ -e "$target" ] && [ ! -L "$target" ]; then
  backup="$target.backup.$(date +%Y%m%d%H%M%S)"
  cp "$target" "$backup"
  echo "backed up existing $target -> $backup"
fi
ln -sf "$here/tmux.conf" "$target"
echo "linked $target -> $here/tmux.conf"

# 3) Neovim + LazyVim (optional editor; run `nvim` in any pane). This installs
#    Neovim + tools + a Nerd Font and drops in the LazyVim starter, without
#    clobbering an existing config.
if command -v brew >/dev/null 2>&1; then
  echo ""
  echo "Setting up Neovim + LazyVim (editor pane)..."
  brew install neovim ripgrep fd lazygit >/dev/null 2>&1 || echo "  (some nvim deps failed; check 'brew doctor')"
  brew install --cask font-jetbrains-mono-nerd-font >/dev/null 2>&1 || true
  if [ -e "$HOME/.config/nvim" ]; then
    echo "  ~/.config/nvim exists; leaving your Neovim config as-is"
  else
    if git clone --depth 1 https://github.com/LazyVim/starter "$HOME/.config/nvim" >/dev/null 2>&1; then
      rm -rf "$HOME/.config/nvim/.git"
      echo "  installed LazyVim starter to ~/.config/nvim"
      nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 && echo "  pre-installed LazyVim plugins" || echo "  (plugins will install on first nvim launch)"
    else
      echo "  (LazyVim clone failed; skipped)"
    fi
  fi
  echo "  -> set your terminal font to 'JetBrainsMono Nerd Font' so icons render."
else
  echo ""
  echo "NOTE: Homebrew not found; skipping Neovim/LazyVim. See https://www.lazyvim.org"
fi

echo ""
echo "Done. If tmux isn't installed yet:  brew install tmux"
echo "Then reload tmux:  tmux source-file ~/.tmux.conf   (or prefix r)"
