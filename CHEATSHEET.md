# tmux cheatsheet (Jeff's setup)

Config lives at `~/.tmux.conf`. Reload after edits with `prefix r`.

## The one concept that matters: the prefix

Almost every tmux command is two steps: press the **prefix**, let go, then
press the command key. Your prefix is **`Ctrl-b`** (hold Ctrl, tap b, release).

Below, `prefix` means "press Ctrl-b first." So `prefix |` = Ctrl-b, then `|`.

## Mental model

```
server                 (one background process; survives terminal closing)
└── session            (one per project, e.g. "api", "webapp")
    └── window         (like a browser tab; full screen)
        └── pane       (a split within a window)
```

The big win: a session keeps running after you **detach** or close the
terminal. Your Claude Code processes stay alive. Reattach anytime.

## Daily workflow for multiple projects

```bash
# Start (or create) a named session for a project:
tmux new -s api          # creates session "api"
cd ~/Development/api && claude   # run Claude Code inside it

# Detach (leave it running in the background):
prefix d

# See everything that's running:
tmux ls

# Jump back into a project:
tmux attach -t api       # or: tmux a -t api

# Switch between running sessions WITHOUT detaching:
prefix s                 # pick from a list
```

One session per project is the recommended pattern: `tmux ls` becomes your
project switcher, and each project's Claude session keeps running on its own.

## Essential keys

### Sessions
| Keys | Action |
|------|--------|
| `tmux new -s NAME` | new named session (run in shell) |
| `tmux a -t NAME` | attach to a session |
| `tmux ls` | list sessions |
| `prefix d` | detach (leaves it running) |
| `prefix s` | switch session (visual list) |
| `prefix $` | rename current session |

### Windows (tabs)
| Keys | Action |
|------|--------|
| `prefix c` | new window |
| `prefix ,` | rename current window |
| `prefix n` / `prefix p` | next / previous window |
| `prefix 1`..`9` | jump to window by number |
| `prefix w` | window list (visual picker) |
| `prefix &` | close current window |

### Panes (splits)
| Keys | Action |
|------|--------|
| `prefix \|` | split left/right (custom) |
| `prefix -` | split top/bottom (custom) |
| `prefix h/j/k/l` | move between panes (or arrow keys) |
| `prefix z` | zoom pane fullscreen (toggle) |
| `prefix x` | close current pane |
| `prefix {` / `prefix }` | swap pane position |
| `prefix space` | cycle through layouts |
| mouse | click a pane to focus, drag border to resize |

### Scrolling & copying
| Keys | Action |
|------|--------|
| `prefix [` | enter scroll/copy mode (then arrows / PgUp) |
| scroll wheel | scroll back (mouse is on) |
| `v` then `y` | (in copy mode) select, then copy to macOS clipboard |
| `q` | leave copy mode |

## When something feels stuck

- **Frozen?** You probably half-pressed the prefix. Press `Enter` or `q`,
  or `prefix` again.
- **Want out of scroll mode?** Press `q`.
- **Forgot a key?** `prefix ?` lists every binding (press `q` to exit).

## Cleaning up
```bash
tmux kill-session -t api   # stop one project's session
tmux kill-server           # stop everything tmux is running
```
