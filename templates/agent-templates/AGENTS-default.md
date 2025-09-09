# AGENTS.md — Tool Selection (Generic)

When you need to call tools from the shell, use this rubric:

- Find Files: `fd`
- Find Text: `rg` (ripgrep)
- Find Code Structure: `ast-grep`
  - Default to TypeScript when in TS/TSX repos:
    - `.ts` → `ast-grep --lang ts -p '<pattern>'`
    - `.tsx` (React) → `ast-grep --lang tsx -p '<pattern>'`
  - Other common languages:
    - Python → `ast-grep --lang python -p '<pattern>'`
    - Bash → `ast-grep --lang bash -p '<pattern>'`
    - JavaScript → `ast-grep --lang js -p '<pattern>'`
    - Rust → `ast-grep --lang rust -p '<pattern>'`
    - JSON → `ast-grep --lang json -p '<pattern>'`
- Select among matches: pipe to `fzf`
- JSON: `jq`
- YAML/XML: `yq`

If `ast-grep` is available, avoid plain‑text searches (`rg`/`grep`) when you need syntax‑aware matching. Use `rg` only when a plain‑text search is explicitly requested.