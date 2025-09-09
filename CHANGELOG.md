# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

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


