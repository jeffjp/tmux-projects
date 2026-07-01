# tmux-projects

A small tmux setup for juggling many projects at once: a friendly `tmux.conf`
plus `tmux-projects`, a launcher that opens one tmux session per project you've
actually worked on recently.

## What's here

- **`tmux-projects`** : auto-discovers your projects and opens a session (two
  panes) for each one with a file modified in the last 14 days.
- **`tmux.conf`** : beginner-friendly tmux config (mouse on, big scrollback,
  intuitive `|` / `-` splits, vim-style pane nav, copy to the macOS clipboard).
  Installs to `~/.tmux.conf`.
- **`CHEATSHEET.md`** : the keys worth memorizing.
- **`install.sh`** : symlinks the command onto your PATH and the config into place.

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
- `START_CLAUDE` : set `true` to auto-launch `claude` in each session's left pane.
