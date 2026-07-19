# twigsmux

A tmux session switcher with git-worktree integration, built around
[worktrunk](https://github.com/max-sixty/worktrunk) (`wt`) and fzf. Distributed
as a TPM plugin.

- **Switch** sessions from an fzf popup (`prefix+t` / `prefix+T`).
- **Create** a worktree-backed session in one keystroke (`prefix+y`): makes a
  `wt switch --create` worktree, scaffolds an editor/git/query/ai window
  layout, and records the branch on the session.
- **Remove** a worktree and its session together (`ctrl-r` in the popup), with
  layered safety checks so the wrong worktree is never deleted.
- **Scaffold** the workspace window layout in any session (`prefix+O`).
- **Kick** other attached clients from a popup (`prefix+F6`), control-mode
  clients protected.

> Status: in development, pre-cutover. The canonical copies still live in the
> author's dotfiles; this repo becomes canonical at cutover.

## Requirements

tmux >= 3.3, zsh, fzf, git, and worktrunk (`wt`) for the worktree features.
Plain session switching works without `wt`.

## Install

With [TPM](https://github.com/tmux-plugins/tpm), in `.tmux.conf`:

```tmux
set -g @plugin 'aurokin/twigsmux'
```

Then `prefix+I`. For interactive `wtct` / `wtrt` / `twm` in your shell, add to
`.zshrc`:

```zsh
[[ -f "$HOME/.tmux/plugins/twigsmux/shell/init.zsh" ]] && \
    source "$HOME/.tmux/plugins/twigsmux/shell/init.zsh"
```

The two pieces are independent: the tmux keybinds work without the `.zshrc`
line (popups never read your shell config), and the shell functions work
without the keybinds.

## Keybinds

| Key | Action |
| --- | --- |
| `prefix+t` | switcher popup (half screen) |
| `prefix+T` | switcher popup (full screen) |
| `prefix+y` | switcher popup; creating a session also creates a worktree + scaffold |
| `prefix+O` | scaffold editor/git/query/ai windows in the current session |
| `prefix+F6` / `prefix+Y` | detach-client picker (half / full) |

Inside the switcher: `enter` select, `ctrl-n` new, `ctrl-k` kill session,
`ctrl-r` remove worktree + session.

## Configuration

| Setting | Effect |
| --- | --- |
| `set -g @twigsmux-bindings off` | install no keybinds (use the scripts your own way) |
| `TWIGSMUX_WT=/path/to/wt` | escape hatch for `wt` discovery in popups |

## Shell functions

- `wtct [--branch <name>] [--select-window <name>]` — create worktree (from
  the session name if no branch given), scaffold windows, optionally jump to a
  window.
- `wtrt [--cwd <repo>] [--session <tmux-session>] <worktree>` — remove a
  worktree (`wt remove --force-delete`) and kill its session when it can be
  identified unambiguously.
- `twm` — run the switcher from a shell.

## Design notes

- **No `zsh -lic`.** Popup-side invocations go through `shell/run-fn.zsh`,
  which constructs the two things a login-interactive shell used to smuggle
  in: `wt` on PATH (`shell/resolve-wt.zsh`, resolved at call time) and
  worktrunk's cd hook (so `wt switch --create` cd's the process and
  `$PWD`-after-switch logic works). A broken user zshrc cannot break the
  keybinds.
- **All binds live in `twigsmux.tmux`**, pointing at the clone's own scripts —
  an uninstalled plugin means unbound keys, never dangling run-shell paths.
- **State** is recorded in tmux session options (`@twigsmux_worktree_branch`,
  `@twigsmux_worktree_cwd`); removal flows trust recorded state over
  name/path inference and refuse on conflicts.
- `scripts/tmux-popup.sh` is vendored (byte-identical to the author's dotfiles
  copy, which other tools there share).
- Future path if the functions ever become executables: a cd-relay over a
  dedicated fd, mirroring worktrunk's directive-file mechanism. Not built; the
  sourced-function design makes it unnecessary today.

## Tests

```sh
tests/twigsmux-unit.sh   # session/worktree inference logic (23 tests)
tests/wtct-unit.zsh      # scaffold argument capture
tests/wtrt-unit.zsh      # removal + session-kill safety (8 tests)
```
