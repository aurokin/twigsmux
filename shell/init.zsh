# Interactive shell integration for twigsmux.
#
# .zshrc residue (the only line dotfiles needs):
#   [[ -f "$HOME/.tmux/plugins/twigsmux/shell/init.zsh" ]] && \
#       source "$HOME/.tmux/plugins/twigsmux/shell/init.zsh"
#
# Provides: wtct / wtrt functions, the twm alias, and — when nothing else has
# installed it — worktrunk's cd hook (wt switch must be able to cd the shell).

export TWIGSMUX_ROOT="${${(%):-%x}:A:h:h}"

source "$TWIGSMUX_ROOT/shell/functions/wtct.zsh"
source "$TWIGSMUX_ROOT/shell/functions/wtrt.zsh"

alias twm="$TWIGSMUX_ROOT/scripts/twigsmux.sh"

# Defer to an existing hook (e.g. dotfiles' worktrunk.zsh) if one is loaded.
if (( ! $+functions[wt] )) && command -v wt >/dev/null 2>&1; then
    eval "$(wt config shell init zsh 2>/dev/null || true)"
fi
