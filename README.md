# tmux-projects

Jeff's tmux config and small helpers, shared by the work Mac and the personal
Mac (both symlink `~/.tmux.conf` to this checkout).

Sessions and windows are no longer organized one per project. On both Macs a
**construct** (a Claude Code operator setup) owns the tmux layout: one session,
an `operator` window where work starts, and one window per job. The work Mac's
session is `ocp-construct`, the personal Mac's is `construct`; `prefix g` jumps
to whichever one is running. The session-per-project launcher that used to
live here was retired on 2026-09-28.

## What's here

- **`tmux.conf`** : beginner-friendly tmux config (mouse on, big scrollback,
  intuitive `|` / `-` splits, vim-style pane nav, copy to the macOS clipboard,
  obvious active-pane borders and labels, `prefix g` to the construct session).
  Installed as `~/.tmux.conf`.
- **`net-status`** : tmux status segment showing which link carries traffic
  (`eth`, `wifi`, `vpn/eth`, `vpn/wifi`; a red `vpn/wifi!` means a VPN is riding
  Wi-Fi while Ethernet is up, so a Wi-Fi drop kills the VPN). Linked into
  `~/.local/bin` by `install.sh`, used in `status-right`. macOS only; shows
  nothing if it is not installed.
- **`CHEATSHEET.md`** : the tmux keys worth memorizing.
- **`LAZYVIM.md`** : LazyVim survival guide + a VSCode-to-LazyVim keymap cheatsheet.
- **`install.sh`** : links the tmux config and `net-status`, and sets up Neovim +
  LazyVim.

## Install (or update after pulling)

Requires [Homebrew](https://brew.sh).

```bash
brew install tmux
git clone https://github.com/jeffjp/tmux-projects.git   # first time only
cd tmux-projects
./install.sh          # safe to re-run; also removes the old launcher's link
tmux source-file ~/.tmux.conf   # if tmux is already running (or prefix r)
```

Inside tmux (prefix is `Ctrl-b`): `prefix g` construct session, `prefix w`
window list, `prefix <n>` window n, `prefix |` / `prefix -` split panes,
`prefix r` reload the config. See `CHEATSHEET.md` for the rest.

## Neovim + LazyVim (optional)

`install.sh` installs Neovim, `ripgrep`/`fd`/`lazygit`, and a Nerd Font, then
drops in the **[LazyVim](https://www.lazyvim.org)** starter config (it leaves an
existing `~/.config/nvim` alone). Open it in any pane with `nvim`.

For icons to render you need a Nerd Font (the installer adds **JetBrainsMono Nerd
Font**): in Apple Terminal, Settings, Profiles, Text, Font.

New to LazyVim? See **`LAZYVIM.md`** for a survival guide and a VSCode-to-LazyVim
keymap cheatsheet. The one thing to remember: the leader key is `Space`, and
pressing `Space` (then pausing) shows a menu of every command.
