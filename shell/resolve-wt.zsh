# Ensure worktrunk's `wt` binary is reachable, resolving at call time.
#
# Popup-side processes (tmux run-shell -> display-popup -> run-fn.zsh) inherit
# the tmux server's environment, which may predate PATH changes or miss them
# entirely. Never snapshot a location; walk the chain on every invocation.
#
# Chain: PATH -> $TWIGSMUX_WT -> brew -> mise shims -> `mise which` -> fail.

twigsmux_resolve_wt() {
    command -v wt >/dev/null 2>&1 && return 0

    if [[ -n "${TWIGSMUX_WT:-}" && -x "$TWIGSMUX_WT" ]]; then
        path=("${TWIGSMUX_WT:h}" $path)
        command -v wt >/dev/null 2>&1 && return 0
    fi

    local dir
    for dir in /opt/homebrew/bin /home/linuxbrew/.linuxbrew/bin \
        "$HOME/.local/share/mise/shims" "$HOME/.local/bin"; do
        if [[ -x "$dir/wt" ]]; then
            path=("$dir" $path)
            return 0
        fi
    done

    if command -v mise >/dev/null 2>&1; then
        local wt_bin
        wt_bin="$(mise which wt 2>/dev/null || true)"
        if [[ -n "$wt_bin" && -x "$wt_bin" ]]; then
            path=("${wt_bin:h}" $path)
            return 0
        fi
    fi

    echo "twigsmux: could not find 'wt' (worktrunk); install it or set TWIGSMUX_WT to the binary" >&2
    return 1
}
