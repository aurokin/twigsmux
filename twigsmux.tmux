#!/usr/bin/env bash
# TPM entry point for twigsmux. Installs all keybinds against this clone's own
# scripts, so an uninstalled plugin means unbound keys — never a dangling
# run-shell path.
#
# Options (set in .tmux.conf before the plugin loads):
#   @twigsmux-bindings off   disable every bind this file would install
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

main() {
    local bindings
    bindings="$(tmux show-option -gqv @twigsmux-bindings 2>/dev/null || true)"
    [[ "$bindings" == "off" ]] && return 0

    local popup="$CURRENT_DIR/scripts/tmux-popup.sh"
    local twigsmux="$CURRENT_DIR/scripts/twigsmux.sh"
    local workspace="$CURRENT_DIR/scripts/tmux-workspace.sh"
    local kick="$CURRENT_DIR/scripts/tmux-kick.sh"

    # Session switcher popups.
    tmux bind-key t run-shell "$popup half -- $twigsmux"
    tmux bind-key T run-shell "$popup full -- $twigsmux"
    tmux bind-key y run-shell "$popup half -d #{q:pane_current_path} -- $twigsmux --prefix-current --run-wtct-on-create"

    # Workspace scaffold/reorder.
    tmux bind-key O run-shell "$workspace scaffold '#{client_tty}' '#{pane_id}'"

    # Client detach picker.
    tmux bind-key F6   run-shell "$popup half -- $kick --client-tty '#{client_tty}'"
    tmux bind-key S-F6 run-shell "$popup full -- $kick --client-tty '#{client_tty}'"
    tmux bind-key Y    run-shell "$popup full -- $kick --client-tty '#{client_tty}'"
}

main
