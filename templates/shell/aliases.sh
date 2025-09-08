# codex-1up: shell aliases
# Source this or let install.sh append a similar block to your shell rc

alias cx='codex exec'
alias cxdiff='git difftool -y'
alias tsgate='pnpm typecheck && pnpm test'

# fd on Debian/Ubuntu is fdfind
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  alias fd='fdfind'
fi
