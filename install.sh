#!/usr/bin/env bash
set -euo pipefail

VERSION="1.0.1"
PROJECT="codex-boost"

DRY_RUN=false
ASSUME_YES=false
SHELL_TARGET="auto"
VSCE_ID=""
NO_VSCODE=false
GIT_EXTERNAL_DIFF=false
INSTALL_NODE="nvm"
AGENTS_TARGET=""

LOG_DIR="${HOME}/.${PROJECT}"
mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/install-$(date +%Y%m%d-%H%M%S).log"

# --- colors ---
if [ -t 1 ]; then
  BOLD="\\033[1m"; GREEN="\\033[32m"; YELLOW="\\033[33m"; RED="\\033[31m"; RESET="\\033[0m"
else
  BOLD=""; GREEN=""; YELLOW=""; RED=""; RESET=""
fi

log()   { echo -e "$1" | tee -a "$LOG_FILE"; }
info()  { log "${BOLD}${1}${RESET}"; }
ok()    { log "${GREEN}✔${RESET} ${1}"; }
warn()  { log "${YELLOW}⚠${RESET} ${1}"; }
err()   { log "${RED}✖${RESET} ${1}"; }
run()   { if $DRY_RUN; then echo "[dry-run] $*"; else eval "$@" >>"$LOG_FILE" 2>&1; fi }

usage() {
  cat <<USAGE
${PROJECT} installer v${VERSION}

Usage: ./install.sh [options]

  --yes                     non-interactive; accept safe defaults
  --dry-run                 print actions without making changes
  --shell auto|zsh|bash|fish
  --vscode EXT_ID           install VS Code extension id (e.g. openai.codex)
  --no-vscode               skip VS Code extension checks
  --git-external-diff       set difftastic as git's external diff (opt-in)
  --install-node nvm|brew|skip   how to install Node if missing (default: nvm)
  --agents-md [PATH]        write starter AGENTS.md to PATH (default: \$PWD/AGENTS.md)
  -h, --help                show help
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --yes) ASSUME_YES=true ;;
    --dry-run) DRY_RUN=true ;;
    --shell) SHELL_TARGET="${2:-auto}"; shift ;;
    --vscode) VSCE_ID="${2:-}"; shift ;;
    --no-vscode) NO_VSCODE=true ;;
    --git-external-diff) GIT_EXTERNAL_DIFF=true ;;
    --install-node) INSTALL_NODE="${2:-nvm}"; shift ;;
    --agents-md)
      if [ "${2:-}" ] && [[ ! "${2}" =~ ^-- ]]; then AGENTS_TARGET="${2}"; shift; else AGENTS_TARGET="$PWD/AGENTS.md"; fi
      ;;
    -h|--help) usage; exit 0 ;;
    *) warn "Unknown arg: $1"; usage; exit 1 ;;
  esac
  shift
done

confirm() {
  $ASSUME_YES && return 0
  read -r -p "$1 [y/N] " ans || true
  [[ "${ans}" =~ ^[Yy]$ ]]
}

need_cmd() { command -v "$1" >/dev/null 2>&1; }

detect_pm() {
  if need_cmd brew; then echo brew
  elif need_cmd apt-get; then echo apt
  elif need_cmd dnf; then echo dnf
  elif need_cmd pacman; then echo pacman
  elif need_cmd zypper; then echo zypper
  else echo none
  fi
}

install_pkg() {
  local pm="$1"; shift
  local pkgs=("$@")
  case "$pm" in
    brew) run brew update; run brew install "${pkgs[@]}" ;;
    apt)  run sudo apt-get update -y; run sudo apt-get install -y "${pkgs[@]}" ;;
    dnf)  run sudo dnf install -y "${pkgs[@]}" ;;
    pacman) run sudo pacman -Sy --noconfirm "${pkgs[@]}" ;;
    zypper) run sudo zypper refresh; run sudo zypper install -y "${pkgs[@]}" ;;
    *) err "No supported package manager found"; return 1 ;;
  esac
}

ensure_brew() {
  if need_cmd brew; then return 0; fi
  if [[ "$(uname -s)" != "Darwin" ]]; then return 0; fi
  info "Homebrew not found; installing Homebrew"
  if $DRY_RUN; then echo "[dry-run] install Homebrew"; return 0; fi
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >>"$LOG_FILE" 2>&1
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

ensure_node() {
  if need_cmd node && need_cmd npm; then ok "Node.js present ($(node -v))"; return 0; fi
  case "$INSTALL_NODE" in
    nvm)
      info "Installing Node.js via nvm"
      if $DRY_RUN; then echo "[dry-run] install nvm + Node LTS"; return 0; fi
      export NVM_DIR="$HOME/.nvm"
      if [ ! -d "$NVM_DIR" ]; then
        curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash >>"$LOG_FILE" 2>&1
      fi
      # shellcheck disable=SC1090
      [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
      nvm install --lts >>"$LOG_FILE" 2>&1
      ;;
    brew)
      ensure_brew
      install_pkg brew node
      ;;
    skip)
      warn "Skipping Node installation; please install Node 18+ manually"
      ;;
  esac
  if need_cmd node; then ok "Node.js installed ($(node -v))"; else err "Node installation failed"; exit 1; fi
}

install_npm_globals() {
  info "Installing global npm packages (@openai/codex, @ast-grep/cli)"
  run npm install -g @openai/codex @ast-grep/cli
  if need_cmd codex; then ok "Codex CLI installed"; else err "Codex CLI not found after install"; fi
  if need_cmd ast-grep; then ok "ast-grep installed"; else warn "ast-grep not found; check npm global path"; fi
}

ensure_tools() {
  local pm="$(detect_pm)"
  info "Detected package manager: ${pm}"
  case "$pm" in
    brew)
      install_pkg brew fd ripgrep fzf jq yq difftastic
      ;;
    apt)
      install_pkg apt ripgrep fzf jq yq git-delta || true
      if ! need_cmd fd; then install_pkg apt fd-find || true; fi
      ;;
    dnf)
      install_pkg dnf ripgrep fd-find fzf jq yq git-delta || true
      ;;
    pacman)
      install_pkg pacman ripgrep fd fzf jq yq git-delta || true
      ;;
    zypper)
      install_pkg zypper ripgrep fd fzf jq yq git-delta || true
      ;;
    *)
      warn "Could not detect a supported package manager; please install tools manually"
      ;;
  esac

  # Try to install difftastic via cargo if not present
  if ! need_cmd difft && ! need_cmd difftastic; then
    if need_cmd cargo; then
      info "Installing difftastic via cargo"
      run cargo install difftastic
    else
      warn "difftastic not found and Rust/cargo missing; falling back to git-delta"
    fi
  fi

  # Symlink fd on Debian/Ubuntu (fd-find)
  if need_cmd fdfind && ! need_cmd fd; then
    mkdir -p "${HOME}/.local/bin"
    if [ ! -e "${HOME}/.local/bin/fd" ]; then
      run ln -s "$(command -v fdfind)" "${HOME}/.local/bin/fd"
    fi
    ok "fd alias created at ~/.local/bin/fd"
  fi

  # Show summary
  for c in fd fdfind rg fzf jq yq difft difftastic delta ast-grep; do
    if need_cmd "$c"; then ok "$c ✓"; fi
  done
}

configure_git() {
  info "Configuring git difftool aliases"
  if need_cmd difft || need_cmd difftastic; then
    run git config --global difftool.difftastic.cmd 'difft "$LOCAL" "$REMOTE"'
    run git config --global difftool.prompt false
    ok "Configured git difftool 'difftastic'"
    if $GIT_EXTERNAL_DIFF; then
      run git config --global diff.external difft
      ok "Set git diff.external = difft"
    fi
  elif need_cmd delta; then
    run git config --global core.pager delta
    ok "Configured git pager to delta (fallback)"
  else
    warn "No difftastic or delta found; git diff will remain default"
  fi
}

target_shell_rc() {
  local st="${SHELL_TARGET}"
  if [ "$st" = "auto" ]; then
    case "${SHELL:-}" in
      */zsh) echo "${HOME}/.zshrc" ;;
      */bash) echo "${HOME}/.bashrc" ;;
      */fish) echo "${HOME}/.config/fish/config.fish" ;;
      *) echo "${HOME}/.bashrc" ;;
    esac
  else
    case "$st" in
      zsh) echo "${HOME}/.zshrc" ;;
      bash) echo "${HOME}/.bashrc" ;;
      fish) echo "${HOME}/.config/fish/config.fish" ;;
      *) echo "${HOME}/.bashrc" ;;
    esac
  fi
}

configure_shell() {
  local rc_file
  rc_file="$(target_shell_rc)"
  info "Updating shell rc: ${rc_file}"
  mkdir -p "$(dirname "$rc_file")"

  local begin="# >>> ${PROJECT} >>>"
  local end="# <<< ${PROJECT} <<<"
  local block
  block=$(cat <<'EOF'
# >>> codex-boost >>>
# Aliases
alias cx='codex exec'
alias cxdiff='git difftool -y'
alias tsgate='pnpm typecheck && pnpm test'
# fd alias on Debian/Ubuntu
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  alias fd='fdfind'
fi
# <<< codex-boost <<<
EOF
  )

  # Remove existing block
  if [ -f "$rc_file" ] && grep -q ">>> ${PROJECT} >>>" "$rc_file"; then
    run sed -i.bak -e "/>>> ${PROJECT} >>>/,/<<< ${PROJECT} <</d" "$rc_file"
  fi

  if [[ "$rc_file" == *fish* ]]; then
    block=$(cat <<'EOF'
# >>> codex-boost >>>
alias cx 'codex exec'
alias cxdiff 'git difftool -y'
alias tsgate 'pnpm typecheck && pnpm test'
if type -q fdfind; and not type -q fd
  alias fd 'fdfind'
end
# <<< codex-boost <<<
EOF
    )
  fi

  if $DRY_RUN; then
    echo "[dry-run] append block to ${rc_file}"
  else
    {
      echo ""
      echo "$begin"
      echo "$block"
      echo "$end"
      echo ""
    } >> "$rc_file"
    ok "Appended aliases to ${rc_file}"
  fi
}

write_codex_config() {
  local cfg="${HOME}/.codex/config.toml"
  if [ -f "$cfg" ]; then
    ok "~/.codex/config.toml already exists"
    return 0
  fi

  info "Writing ~/.codex/config.toml (web_search enabled)"
  mkdir -p "${HOME}/.codex"
  cat > "$cfg" <<'CFG'
# ~/.codex/config.toml — created by codex-boost

# Core
model = "gpt-5"
approval_policy = "on-request"       # untrusted|on-failure|on-request|never
sandbox_mode   = "workspace-write"   # read-only|workspace-write|danger-full-access

[tools]
web_search = true                    # enable the native web-search tool by default

# Optional privacy & UX
# disable_response_storage = true     # zero-data-retention mode
# file_opener = "vscode"              # vscode|vscode-insiders|windsurf|cursor|none

# Reasoning / verbosity (GPT‑5 family)
# model_reasoning_effort = "medium"   # minimal|low|medium|high|none
# model_verbosity = "medium"          # low|medium|high
# model_reasoning_summary = "auto"    # auto|concise|detailed|none

# Sandbox network: keep off unless you need arbitrary HTTP (curl, etc.)
# [sandbox_workspace_write]
# network_access = false

# Example: MCP server
# [mcp_servers.server-name]
# command = "npx"
# args = ["-y", "mcp-remote", "https://example.com/api/mcp"]

# Example: Azure provider profile
# [profiles.azure]
# model = "gpt-5"
# model_provider = "azure"
# [model_providers.azure]
# name = "Azure"
# base_url = "https://<resource>.openai.azure.com/openai"
# env_key = "AZURE_OPENAI_API_KEY"
# query_params = { api-version = "2025-04-01-preview" }
# wire_api = "responses"
CFG
  ok "Wrote ${cfg}"
}

maybe_install_vscode_ext() {
  $NO_VSCODE && return 0
  if [ -z "$VSCE_ID" ]; then
    info "VS Code extension id not provided. Use: --vscode <publisher.extension>"
    return 0
  fi
  if ! need_cmd code; then
    warn "'code' (VS Code) not in PATH; skipping extension install"
    return 0
  fi
  info "Installing VS Code extension: ${VSCE_ID}"
  run code --install-extension "${VSCE_ID}" --force
  ok "VS Code extension '${VSCE_ID}' installed (or already present)"
}

maybe_write_agents() {
  if [ -z "${AGENTS_TARGET}" ]; then return 0; fi
  local path="${AGENTS_TARGET}"
  if [ -d "$path" ]; then path="${path%/}/AGENTS.md"; fi
  info "Writing starter AGENTS.md to: ${path}"
  if $DRY_RUN; then echo "[dry-run] write AGENTS.md to ${path}"; else
    cat > "${path}" <<'AGENTS'
# AGENTS.md — Tool Selection for Shell Interactions

When you need to call tools from the shell, **use this rubric**:

- **Is it about finding FILES?** use `fd`
- **Is it about finding TEXT/strings?** use `rg`
- **Is it about finding CODE STRUCTURE?** use `ast-grep`
  - **Default to TypeScript:**  
    - `.ts` → `ast-grep --lang ts -p '<pattern>'`
    - `.tsx` (React) → `ast-grep --lang tsx -p '<pattern>'`
  - For other languages, set `--lang` appropriately (e.g., `--lang rust`).
- **Need to SELECT from multiple results?** pipe to `fzf`
- **Interacting with JSON?** use `jq`
- **Interacting with YAML or XML?** use `yq`

You run in an environment where **`ast-grep` is available**.
Whenever a search requires **syntax‑aware / structural matching**, **default to `ast-grep`** with the correct `--lang`, and **avoid** falling back to text‑only tools like `rg` or `grep` unless a plain‑text search is explicitly requested.
AGENTS
    ok "Wrote AGENTS.md"
  fi
}

main() {
  info "==> ${PROJECT} installer"
  info "Log: ${LOG_FILE}"

  ensure_node
  install_npm_globals
  ensure_tools
  configure_git
  configure_shell
  write_codex_config
  maybe_install_vscode_ext
  maybe_write_agents

  ok "All done. Open a new shell or 'source' your rc file to load aliases."
  info "Try:  codex   # sign in; then ask it to plan a refactor"
}

main "$@"
