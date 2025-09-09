# Changelog

All notable changes to this project will be documented in this file.

## [0.1]

### Added
- Interactive config profile selection when creating `~/.codex/config.toml`:
  - `SAFE` — most restrictive, prompts on failures
  - `DEFAULT` — balanced (recommended)
  - `YOLO` — full access, never asks (double‑confirmation with clear warnings)
  - `NO CHANGES` — do not create/modify config
- Consent prompts before any permanent system changes:
  - Git configuration (difftool/pager) — optional
  - Shell aliases — shows exact aliases before applying
  - Config creation — profile picked by user; backups on overwrite
- `--skip-confirmation` flag for fully non‑interactive installs.

### Changed
- Git difftool setup is now robust across environments:
  - Skip entirely if `git` is not installed
  - Safer command execution (no `eval`), correct quoting of `$LOCAL/$REMOTE`
- Aliases: removed `tsgate`; only `cx` and `cxdiff` are installed (optional).
- Config generation now uses template profiles under `templates/configs/`.

### Fixed
- Crash during git difftool setup caused by expansion of `$LOCAL`/`$REMOTE`.
- Project root detection when calling installer via wrapper.


## [0.2] - 2025-09-09

### Added
- Installer now prints a link to the Codex config reference after creating `~/.codex/config.toml`: `https://github.com/openai/codex/blob/main/docs/config.md`.
- Installer prompts to create a global `~/.codex/AGENTS.md` (with backup if it exists).
- AGENTS templates: four variants under `templates/agent-templates/`: `AGENTS-default.md`, `AGENTS-typescript.md`, `AGENTS-python.md`, `AGENTS-shell.md`.
- CLI `bin/codex-1up agents` now accepts `--template default|typescript|python|shell`.
- Installer supports `--agents-template` to choose which template to write for both local and global `AGENTS.md`.

### Docs
- README: Added Codex config reference link in the install table and in the Config profiles section, pointing to `https://github.com/openai/codex/blob/main/docs/config.md`.
 - README: Added "Global guidance with AGENTS.md" section with link to [Memory with AGENTS.md](https://github.com/openai/codex/blob/main/docs/getting-started.md#memory-with-agentsmd).
 - README: Added "Upgrade" section with steps to update and re-run installer.
 - README: Documented AGENTS template selection flags and listed available templates.

### Changed
- Config flow: choose profile first, then confirm overwrite (with backup).
- NPM globals install flow now checks installed vs latest and only installs when needed.


## [0.3] - 2025-09-09

### Added
- Interactive global `AGENTS.md` flow in installer:
  - Asks whether to create `~/.codex/AGENTS.md` and to choose a template: 1) default, 2) typescript, 3) python, 4) shell, 5) none.
  - If the file exists, prompts to overwrite and creates a timestamped backup.
- `bin/codex-1up agents` now prompts for a template if `--template` is not provided, and asks before overwriting an existing destination (with backup).

### Docs
- No README changes needed; templates and flags are already documented.

