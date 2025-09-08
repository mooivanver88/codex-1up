#!/usr/bin/env bash
set -euo pipefail

need() { command -v "$1" >/dev/null 2>&1; }
check() { if need "$1"; then echo "✔ $1"; else echo "✖ $1 (missing)"; fi }

echo "codex-boost doctor"
echo "--- binaries ---"
for c in node npm codex ast-grep fd fdfind rg fzf jq yq difft delta code; do
  check "$c"
done

echo "--- git ---"
echo "diff.external = $(git config --global --get diff.external || echo "(none)")"
echo "difftool.difftastic.cmd = $(git config --global --get difftool.difftastic.cmd || echo "(none)")"
echo "core.pager = $(git config --global --get core.pager || echo "(none)")"

echo "--- codex config ---"
CFG="$HOME/.codex/config.toml"
if [ -f "$CFG" ]; then
  echo "found: $CFG"
  if grep -Eiq '^\s*\[tools\]' "$CFG" && grep -Eiq '^\s*web_search\s*=\s*true' "$CFG"; then
    echo "✔ tools.web_search = true"
  else
    echo "✖ tools.web_search not enabled"
  fi
else
  echo "✖ ~/.codex/config.toml not found"
fi

echo "--- shell rc hints ---"
echo "SHELL=$SHELL"
for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.config/fish/config.fish"; do
  [ -f "$rc" ] && grep -q ">>> codex-boost >>>" "$rc" && echo "Found codex-boost block in $rc"
done

echo "Done."
