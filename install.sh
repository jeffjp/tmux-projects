#!/usr/bin/env bash
# Install tmux-projects: put the command on your PATH and the tmux config
# in place. Safe to re-run. Backs up any existing real ~/.tmux.conf.
set -eu

here="$(cd "$(dirname "$0")" && pwd)"

# 1) Make `tmux-projects` runnable from anywhere via a personal bin dir.
bindir="$HOME/.local/bin"
mkdir -p "$bindir"
ln -sf "$here/tmux-projects" "$bindir/tmux-projects"
echo "linked $bindir/tmux-projects -> $here/tmux-projects"
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

echo ""
echo "Done. If tmux isn't installed yet:  brew install tmux"
echo "Then run:  tmux-projects"
