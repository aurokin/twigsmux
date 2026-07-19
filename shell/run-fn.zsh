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
set -u

SCRIPT_DIR="${${(%):-%x}:A:h}"

source "$SCRIPT_DIR/resolve-wt.zsh"
twigsmux_resolve_wt || exit 1

source "$SCRIPT_DIR/init.zsh"

if [[ $# -eq 0 ]]; then
    echo "run-fn.zsh: usage: run-fn.zsh <function> [args...]" >&2
    exit 2
fi

if ! typeset -f "$1" >/dev/null 2>&1; then
    echo "run-fn.zsh: unknown function: $1" >&2
    exit 2
fi

"$@"
