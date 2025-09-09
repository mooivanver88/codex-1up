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

### Docs
- README: Added Codex config reference link in the install table and in the Config profiles section, pointing to `https://github.com/openai/codex/blob/main/docs/config.md`.
 - README: Added "Global guidance with AGENTS.md" section with link to [Memory with AGENTS.md](https://github.com/openai/codex/blob/main/docs/getting-started.md#memory-with-agentsmd).
 - README: Added "Upgrade" section with steps to update and re-run installer.

### Changed
- Config flow: choose profile first, then confirm overwrite (with backup).
- NPM globals install flow now checks installed vs latest and only installs when needed.


