# tmux-projects

A small tmux setup for juggling many projects at once: a friendly `tmux.conf`
plus `tmux-projects`, a launcher that opens one tmux session per project you've
actually worked on recently.

## What's here

- **`tmux-projects`** : auto-discovers your projects (and their active Claude
  worktrees) and opens a two-pane session for each one modified in the last 14 days
  (a shell on the left, LazyVim on the right).
- **`tmux.conf`** : beginner-friendly tmux config (mouse on, big scrollback,
  intuitive `|` / `-` splits, vim-style pane nav, copy to the macOS clipboard).
  Installs to `~/.tmux.conf`.
- **`CHEATSHEET.md`** : the keys worth memorizing.
- **`install.sh`** : symlinks the command onto your PATH, installs the tmux config, and sets up Neovim + LazyVim for the editor pane.

## Folder convention

Two layouts are supported, and the launcher figures out which one a machine uses:

- **nested** — `<dev-root>/<category>/<project>`, e.g. `~/Development/oracle/oci-api`
  (each top-level folder is a *category*; each of its subfolders is a *project*).
- **flat** — `<dev-root>/<project>`, e.g. `~/Development/oci-api`
  (each top-level folder is a *project*).

By default (`LAYOUT=auto`) it decides per top-level folder: a git repo (or a
folder with no subfolders) is a project, and a folder that *contains* subfolders
is a category to descend into. So auto also handles a **mixed** root — some loose
repos alongside some category folders — and the same checkout works unchanged on a
nested work Mac and a flat personal Mac. Force one interpretation with
`LAYOUT=flat`/`nested` in the script, or the `DEV_LAYOUT` env var (see *Tweaking*).

The dev root is likewise detected automatically: it uses `$DEV_ROOT` if set,
otherwise the first of `~/Developer`, `~/Development`, `~/dev`, `~/code` that exists.

## Claude Code worktrees

When `INCLUDE_WORKTREES` is on (the default), each repo is also asked — via
`git worktree list` — for the isolated worktrees Claude Code creates under
`<repo>/.claude/worktrees/`. Recently-touched ones get their own session named
`<project>-<worktree>` (e.g. `slamlabs-site-hardcore-gagarin-40f5b2`), so they
sort right under their parent repo in `tmux ls` / `prefix s`.

A worktree is judged active on its **own** files, independent of the parent repo,
so a worktree can open even when the main project is idle (and vice-versa). Gone,
prunable, or locked worktrees are skipped. Because worktrees exist for Claude
work, they auto-launch `claude` in the left pane when `START_CLAUDE_IN_WORKTREES`
is `true` — separately from the `START_CLAUDE` toggle for regular projects.

## Editor pane (LazyVim)

The right pane of every session opens **[LazyVim](https://www.lazyvim.org)** (a
Neovim-based, IDE-like setup) in the project directory, controlled by `OPEN_NVIM`
(default `true`). `install.sh` installs Neovim, `ripgrep`/`fd`/`lazygit`, and a
Nerd Font, then drops in the LazyVim starter config.

For icons to render you need a Nerd Font (the installer adds **JetBrainsMono Nerd
Font**): in Apple Terminal, Settings → Profiles → Text → Font. Set
`OPEN_NVIM=false` to keep the right pane a plain shell.

## Install

Requires [Homebrew](https://brew.sh).

```bash
brew install tmux
git clone https://github.com/jeffjp/tmux-projects.git
cd tmux-projects
./install.sh
```

Open a new terminal and run `tmux-projects`.

## Usage

```bash
tmux-projects     # open a session per recently-worked project, attach to the first
```

Inside tmux (prefix is `Ctrl-b`):

- `prefix s` : switch between projects
- `prefix d` : detach (everything keeps running in the background)
- `prefix |` / `prefix -` : split panes

See `CHEATSHEET.md` for the rest.

## Tweaking

Edit the config block at the top of `tmux-projects`:

- `DAYS` : how far back "recently worked on" reaches (default 14).
- `LAYOUT` : `auto` (default), `flat`, or `nested`. Override per-machine without
  editing via the `DEV_LAYOUT` env var, e.g. `DEV_LAYOUT=flat tmux-projects`.
- `DEV_ROOT_CANDIDATES` : where your projects live. Override via `DEV_ROOT`.
- `EXCLUDE_CATEGORIES` : top-level folders to never open.
- `START_CLAUDE` : set `true` to auto-launch `claude` in each project session's left pane.
- `OPEN_NVIM` : open LazyVim (nvim) in each session's right pane (default `true`).
- `INCLUDE_WORKTREES` : also open sessions for active Claude worktrees (default `true`).
- `START_CLAUDE_IN_WORKTREES` : auto-launch `claude` in worktree sessions (default `true`).
