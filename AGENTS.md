# Agent Instructions

## Status
- Pre-cutover: canonical copies of most files still live in `~/.dotfiles` and are in daily use there.
- Behavior parity with the dotfiles copies is the contract; behavioral changes must be deliberate and noted in commit messages.
- `scripts/tmux-popup.sh` is a vendored copy — keep it byte-identical to `~/.dotfiles/zsh/.zshrc.d/scripts/tmux-popup.sh`.

## Layout
- `twigsmux.tmux` — TPM entry point; ALL keybinds are installed here and only here.
- `scripts/` — bash executables (`twigsmux.sh` switcher, `tmux-workspace.sh`, `tmux-kick.sh`, `tmux-popup.sh`, `tmux-pane-utils.sh` sourced lib).
- `shell/init.zsh` — interactive-shell entry (sets `TWIGSMUX_ROOT`, sources functions, `twm` alias).
- `shell/run-fn.zsh` — popup-side runner for the functions; the only sanctioned non-interactive entry.
- `shell/resolve-wt.zsh` — call-time `wt` (worktrunk) discovery chain.
- `shell/functions/` — `wtct.zsh`, `wtrt.zsh` (sourced zsh functions, not executables).

## Commands
| Task | Command |
|------|---------|
| Test switcher logic | `tests/twigsmux-unit.sh` |
| Test wtct | `tests/wtct-unit.zsh` |
| Test wtrt | `tests/wtrt-unit.zsh` |
| Syntax check bash | `bash -n twigsmux.tmux scripts/*.sh` |
| Syntax check zsh | `zsh -n shell/run-fn.zsh shell/init.zsh shell/resolve-wt.zsh shell/functions/*.zsh` |

## Key Conventions
- Never invoke the functions via `zsh -lic`; popup-side calls go through `shell/run-fn.zsh` (it provides `wt` on PATH and worktrunk's cd hook).
- Scripts self-locate (`SCRIPT_DIR`/`PLUGIN_ROOT`/`TWIGSMUX_ROOT`); never hardcode an install path outside README examples.
- Session state lives in tmux options `@twigsmux_worktree_branch` / `@twigsmux_worktree_cwd`; user config uses `@twigsmux-*` (dash) options.
- `scripts/` is bash; `shell/` is zsh. Match the file's dialect.
- Tests mock `tmux` and `wt` — never touch a live tmux server or create/remove real worktrees from tests or ad-hoc verification.
- Interactive runtime verification: dedicated tmux server (`tmux -L <socket>`, `env -u TMUX`) with an overridden `HOME` (worktrunk's `worktree-path` is `~`-relative, so worktrees stay contained), driven through a real PTY client via `termctrl` (kitlangton/terminal-control) — popups need an attached client.
- Run all three test files after any change to `scripts/twigsmux.sh` or `shell/functions/`.

## External References
| Need | File |
|------|------|
| User docs, keybinds, install | `README.md` |
| Design rationale, migration/cutover plan | `~/.dotfiles/docs/twigsmux-extraction.md` (author machines only) |
