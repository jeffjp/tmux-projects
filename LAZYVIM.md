# LazyVim cheatsheet (the editor pane)

`tmux-projects` opens **LazyVim** (a batteries-included, VSCode-like Neovim
setup) in the right pane of each session. This is the survival guide.

## The two things that matter most

1. **The leader key is `Space`.** Almost every command starts by tapping `Space`.
2. **which-key shows you everything:** press `Space` and *pause* for a moment; a
   menu of every available command pops up. Whenever you're lost, tap `Space`
   and read the menu. (It also works after `g`, `]`, `[`, etc.)

## Vim survival basics (new to modal editing?)

- `i` = insert mode (type normally). `Esc` = back to normal mode (for commands).
- `:w` save, `:q` quit, `:wq` save + quit, `:q!` quit without saving.
- `Ctrl-s` = save (works from normal or insert mode).
- `Space q q` = quit everything.
- Feel stuck? Press `Esc` a few times; if you need to bail, `:q!` then Enter.

## VSCode → LazyVim

| What you want | Key |
|---|---|
| Open file by name (Cmd+P) | `Space Space` (or `Space f f`) |
| Search across project (Cmd+Shift+F) | `Space /` |
| File explorer / sidebar | `Space e` |
| Command palette | `Space` (then read which-key) |
| Go to definition (F12) | `g d` |
| Find references | `g r` |
| Hover docs | `K` |
| Rename symbol (F2) | `Space c r` |
| Quick fix / code action | `Space c a` |
| Toggle comment | `g c c` (line), `g c` (selection) |
| Integrated terminal | `Ctrl-/` (or `Space f t`) |
| Next / previous tab | `Shift-l` / `Shift-h` |
| Git UI | `Space g g` (lazygit) |

## Handy extras

- Move between editor splits: `Ctrl-h/j/k/l`.
- Diagnostics: `]d` / `[d` for next / previous; `Space c d` shows the line's issue.
- Open buffers (files): `Space ,` to pick one; `Space b d` to close one.
- Plugin manager: `Space l` (`:Lazy`). LSP/tool installer: `:Mason`.
- **Add language support:** run `:LazyExtras`, then enable the packs you use
  (e.g. `lang.python`, `lang.terraform`, `lang.json`, `lang.sql`). Press Enter to
  toggle a pack; it installs the LSP + treesitter automatically.

## Notes for this setup

- Icons need a Nerd Font: set the terminal font to **JetBrainsMono Nerd Font**
  (Apple Terminal: Settings → Profiles → Text → Font).
- `nvim` opens in the project's directory, so find-file and grep are scoped to it.
- Don't want the editor pane? Set `OPEN_NVIM=false` in `tmux-projects`.
- Official docs: <https://www.lazyvim.org> (keymaps: <https://www.lazyvim.org/keymaps>).
