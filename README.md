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
- **`claude-attn`** : Claude Code hook that marks a window in the window list
  when the Claude session in it waits on you (`?` a dialog is open, `!` the
  turn is over, `~` the turn is over but background tasks still run and
  nothing was asked, `x` it stopped on an error), yellow when it is new to
  you and grey once you have looked. Linked into `~/.local/bin` and
  registered in `~/.claude/settings.json` by `install.sh`. See "Attention
  marks" below.
- **`CHEATSHEET.md`** : the tmux keys worth memorizing.
- **`LAZYVIM.md`** : LazyVim survival guide + a VSCode-to-LazyVim keymap cheatsheet.
- **`bootstrap-mac.sh`** + **`Brewfile`** : one-run setup of a fresh Mac for construct (below).
- **`install.sh`** : links the tmux config, `net-status` and `claude-attn`,
  registers the `claude-attn` hooks, and sets up Neovim + LazyVim.

## New Mac (construct and Claude Code)

`bootstrap-mac.sh` sets up a fresh Mac to run construct: it checks for the
Command Line Tools and Homebrew (and prints the command if either is missing,
since both need a click or a password), installs the `Brewfile` packages and
the Claude Code CLI, adds the `~/.zshrc` lines construct uses, sets the git
global ignore, then runs `install.sh`. Safe to re-run; no secrets in it.

```bash
./bootstrap-mac.sh              # tools, shell, tmux setup
./bootstrap-mac.sh --always-on  # also no sleep, lid closed, no display (sudo)
```

It ends with the by-hand list (logins, tokens, keys). Copying repos and Claude
state from the old Mac is in construct's `docs/WORKFLOW.md` (New machine).

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

## Attention marks (claude-attn, added 2026-11-18)

With several Claude windows open, the window list (row 1) shows which ones
wait on you, so you do not have to cycle through them:

| Mark | Meaning | Clears when |
|---|---|---|
| `?` | a dialog is open: a question, a permission prompt, plan approval | you answer it |
| `!` | the turn is over (or it sits at the prompt, or at the folder-trust prompt of a new workspace); also when background tasks still run but the reply ends on a question | you send the next prompt |
| `~` (grey) | the turn is over, background tasks still run and the reply asked nothing (usually a watch that the task's finish wakes) | the task wakes it, or you send the next prompt |
| `x` | it stopped on an API error | you send the next prompt |
| none | it is working, or no Claude runs there | |

Yellow means new, grey means quiet (seen state, added 2026-11-24). Before
this every parked worker stayed yellow until its next prompt, so with a dozen
of them the whole row was yellow and said nothing.

| Inactive window looks like | Meaning |
|---|---|
| yellow block, `!3:name` | the turn ended since you last looked |
| yellow block, `?3:name` or `x3:name` | a dialog or an error: stays yellow until dealt with |
| yellow block, `!3:name` (folder trust) | the folder-trust prompt of a new workspace: stays yellow until answered |
| plain grey row with a yellow `!` | still waiting, but you have seen it, or it sits at a fresh prompt with nothing asked (`@attn` `idle`) |
| grey block, `~3:name` | background tasks run, nothing asked |

A finished turn counts as seen once its window has been the active one, with
the terminal focused, for 3 seconds without a change. Flipping past it
(next-window, the chooser) in under 3 seconds does not count, nor does a
window that is active while you are in another app; it turns grey 3 seconds
after you come back. A turn that ends while you watch the window goes grey
after the same 3 seconds. The next turn end makes it yellow again. The active
window keeps its blue and shows the mark in yellow (new) or light grey
(quiet). You still answer in that window.

Background tasks (added 2026-11-19): when a turn ends while a shell or agent
still runs in the background, the hook keeps the reply's last line and adds
"(N background task(s) running)". If one of the last three lines ends in `?`
it is a question for you (`@attn` `bgwait`, mark `!`); otherwise `bg`, mark
`~`. Before this, every such turn showed no mark and only the task count, so
a worker that asked "Go to apply?" looked busy for as long as its shell ran.

How it works: `claude-attn` runs as a Claude Code hook on a handful of events
(prompt submitted, permission or question dialog, tool finished, turn over,
session start and end) and sets window options on its own tmux window,
found from `$TMUX_PANE`: `@attn` (state), `@attn_mark`, `@attn_since` and
`@attn_msg` (one line: the question, the tool asking permission, or the last
line of the reply), and it clears `@attn_seen`. `tmux.conf` shows
`@attn_mark` and colours it; construct's `bin/ws-status --board` reads the
rest and prints `new` or `seen` next to each waiting row. Outside tmux it
does nothing. The hook always exits 0 and prints nothing; a call takes about
40 to 60 ms, most of it starting `jq` and `tmux`.

Seen state lives in `tmux.conf`, not in the hook: tmux hooks on window
change, session switch and terminal focus bump a per-session counter
(`@attn_tick`) and run the user hook `@attn-arm`, which schedules a check 3
seconds out inside tmux (`run -b -d 3 -C`: no shell, never blocks). The check
sets `@attn_seen` to 1 only if the counter and the window's `@attn_since` are
unchanged, the window is still active and still `done` or `bgwait`, and a
focused client shows its session (`client_flags`). At each `done` or `bgwait`
the hook runs `@attn-arm` itself (`set-hook -R`), which covers a turn that
ends while you watch. On a server still running an older `tmux.conf` that
call fails quietly and the rest of the update stands.

- Register or remove: `claude-attn install` / `claude-attn uninstall`
  (`install.sh` runs the first). Running sessions pick the change up at their
  next event; no restart needed.
- Inspect a window: `claude-attn show` (this window) or `claude-attn show <target>`;
  `seen=1` means it has been looked at.
- After `tmux source-file ~/.tmux.conf` the windows already parked have no
  seen flag yet, so they all show yellow until you visit each for 3 seconds
  or its next turn ends. Idle ones turn grey at once.
- Not detected: an interrupt (Esc or Ctrl-C mid-turn) fires no hook event,
  so that window keeps no mark until the next prompt. You were in it anyway.
- The hook entries are guarded like Orca's were: if `~/.local/bin/claude-attn`
  is missing, the entry just drains its input and exits.

## Neovim + LazyVim (optional)

`install.sh` installs Neovim, `ripgrep`/`fd`/`lazygit`, and a Nerd Font, then
drops in the **[LazyVim](https://www.lazyvim.org)** starter config (it leaves an
existing `~/.config/nvim` alone). Open it in any pane with `nvim`.

For icons to render you need a Nerd Font (the installer adds **JetBrainsMono Nerd
Font**): in Apple Terminal, Settings, Profiles, Text, Font.

New to LazyVim? See **`LAZYVIM.md`** for a survival guide and a VSCode-to-LazyVim
keymap cheatsheet. The one thing to remember: the leader key is `Space`, and
pressing `Space` (then pausing) shows a menu of every command.
