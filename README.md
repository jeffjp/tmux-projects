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

Projects live as `<dev-root>/<category>/<project>`, e.g.
`~/Development/oracle/oci-api`. Each top-level folder is a *category*; each of its
subfolders is a *project*.

The dev root is detected automatically, so the same checkout works on more than
one Mac: it uses `$DEV_ROOT` if set, otherwise the first of `~/Developer`,
`~/Development`, `~/dev`, `~/code` that exists.

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
- `DEV_ROOT_CANDIDATES` : where your category folders live.
- `EXCLUDE_CATEGORIES` : category folders to never open.
- `START_CLAUDE` : set `true` to auto-launch `claude` in each session's left pane.
