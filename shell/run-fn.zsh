#!/usr/bin/env zsh
# Popup-side runner: invoke a twigsmux shell function (wtct / wtrt) from a
# non-interactive process without touching the user's zshrc.
#
#   zsh .../shell/run-fn.zsh wtct --branch foo --select-window ai
#
# This replaces the old `zsh -lic 'wtct ...'` hack by constructing exactly the
# two things -lic smuggled in from the interactive environment:
#   1. worktrunk's `wt` on PATH (resolve-wt.zsh, resolved at call time)
#   2. worktrunk's cd hook, so `wt switch --create` cd's this process and
#      wtct's $PWD-after-switch logic keeps working
# --then-interactive: after the function runs (pass or fail), exec an
# interactive zsh in this process — used by the --start-worktree-session pane
# so the wt cd hook's directory change survives into the pane's shell.
set -u

then_interactive=0
if [[ "${1:-}" == "--then-interactive" ]]; then
    then_interactive=1
    shift
fi

SCRIPT_DIR="${${(%):-%x}:A:h}"

source "$SCRIPT_DIR/resolve-wt.zsh"
if ! twigsmux_resolve_wt; then
    # In pane-bootstrap mode still hand the user a shell (old -lic parity:
    # wtct failed inside the shell, the shell survived).
    (( then_interactive )) && exec zsh -i
    exit 1
fi

source "$SCRIPT_DIR/init.zsh"

if [[ $# -eq 0 ]]; then
    echo "run-fn.zsh: usage: run-fn.zsh [--then-interactive] <function> [args...]" >&2
    exit 2
fi

if ! typeset -f "$1" >/dev/null 2>&1; then
    echo "run-fn.zsh: unknown function: $1" >&2
    (( then_interactive )) && exec zsh -i
    exit 2
fi

if (( then_interactive )); then
    "$@"
    exec zsh -i
fi

"$@"
