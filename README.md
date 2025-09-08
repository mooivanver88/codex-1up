# codex-1up — One‑shot installer for OpenAI Codex CLI (GPT‑5) + pro tooling

**codex-1up** gives individual developers a *production‑ready* Codex setup in minutes:

- ✅ Installs **Codex CLI** (`@openai/codex`) and signs you in
- ✅ Adds **AST‑aware refactor tools**: `ast-grep` (TS/TSX ready)
- ✅ Adds fast shell power tools: `fd`, `ripgrep` (`rg`), `fzf`, `jq`, `yq`
- ✅ Wires up **semantic diffs** with `difftastic` (or `git-delta` fallback)
- ✅ Writes **~/.codex/config.toml** with **web search enabled by default**
- ✅ Adds handy **shell aliases** (`cx`, `cxdiff`, `tsgate`)
- ✅ Includes a **minimal AGENTS.md** so agents pick the right tool every time
- ✅ Works on **macOS** and **Linux** (Windows via **WSL**)

> **Why use this?**  
> Because the best AI coding outcomes come from the *right tools + sane defaults*:
> - **AST‑grep** for precise, structure‑aware refactors (no brittle grep)  
> - **difftastic** for human‑readable diffs of AI changes  
> - **web search ON** by default so the agent can look things up when needed  
> - A **clear AGENTS.md rubric** so the agent consistently chooses `fd/rg/ast-grep/fzf/jq/yq` correctly

## Quick start

```bash
git clone https://github.com/regenrek/codex-1up
cd codex-1up
./install.sh --yes
# Or use the wrapper:
./bin/codex-1up install --yes
```

### Common flags

- `--yes`                  : non-interactive; accept safe defaults
- `--dry-run`              : print what would happen, change nothing
- `--shell auto|zsh|bash|fish`
- `--git-external-diff`    : set difftastic as git's external diff (opt-in)
- `--vscode EXT_ID`        : install a VS Code extension (e.g. `openai.codex`)
- `--agents-md [PATH]`     : write a starter `AGENTS.md` to PATH (default: `$PWD/AGENTS.md`)
- `--no-vscode`            : skip VS Code extension checks
- `--install-node nvm|brew|skip` : how to install Node.js if missing (default: `nvm`)

### What gets installed

| Component                 | Why it matters                                                                          |
| ------------------------- | --------------------------------------------------------------------------------------- |
| **@openai/codex**         | The coding agent that can read, edit, and run your project locally.                     |
| **ast-grep**              | Syntax‑aware search/replace for safe, large‑scale refactors in TS/TSX.                  |
| **fd**                    | Fast file finder (gitignore‑aware).                                                     |
| **ripgrep (rg)**          | Fast text search across code.                                                           |
| **fzf**                   | Fuzzy‑finder to select among many matches.                                              |
| **jq** / **yq**           | Reliable JSON/YAML processing on the command line.                                      |
| **difftastic**            | Semantic code diffs for reviewing AI edits; falls back to `git-delta` when unavailable. |
| **shell aliases**         | `cx` (one‑shot Codex), `cxdiff` (semantic diffs), `tsgate` (typecheck+tests).           |
| **\~/.codex/config.toml** | Default **web search ON**; safe approval/sandbox defaults; commented options to tune.   |
| **AGENTS.md**             | Minimal rubric so agents consistently choose the right tool for each task.              |



### After installing

- Open a new terminal session (or source your shell rc)
- Run `codex` to sign in and start using the agent
- In any repo, run `codex` and try: *"Plan a refactor for X; then apply and run tests."*

## `AGENTS.md` in your repo

You can generate a starter file:

```bash
./bin/codex-1up agents --path /path/to/your/repo
# or during install
./install.sh --agents-md  # writes to $PWD/AGENTS.md
```

## Doctor & Uninstall

```bash
./bin/codex-1up doctor
./bin/codex-1up uninstall
```

> **Note:** This project is **idempotent**—running it again will skip what’s already installed. It won’t remove packages on uninstall; it cleans up shell aliases and git config it created.

## Supported platforms

- macOS (Intel/Apple Silicon) via **Homebrew**
- Linux via **apt**, **dnf**, **pacman**, or **zypper**
- Windows users: use **WSL** (Ubuntu) and run the Linux path

## License

MIT — see [LICENSE](LICENSE).
