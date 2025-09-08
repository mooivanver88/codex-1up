# codex-1up: fish aliases
alias cx 'codex exec'
alias cxdiff 'git difftool -y'
alias tsgate 'pnpm typecheck && pnpm test'

if type -q fdfind; and not type -q fd
  alias fd 'fdfind'
end
