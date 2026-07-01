# Changelog

All notable changes to niw-guru are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **`partial_petition_letter_draft.md`** — a fourth deliverable produced by the same one command.
  A new pipeline stage synthesizes the run's three existing outputs (`petitioner_profile.md`,
  `national_importance_quotes.md`, `future_endeavors.md`) into the connective core of the petition
  letter: background → national importance → how each proposed endeavor advances the specific
  harvested evidence (Dhanasar Prongs 1–3). It introduces no new quote, page, or source, and
  carries every `[VERIFY]` forward. Adds `templates/partial_petition_letter_draft.template.md`;
  the orchestrator is now a six-stage pipeline.

- See the [roadmap](README.md#roadmap).

## [0.1.0] - 2026-06-26

Initial release.

### Added
- **`niw-guru` launcher**, shipped as source (`src/niw-guru.in`) and **built** with `make build`
  (or the manual step in `INSTALL.md`) into `bin/niw-guru` — one command
  (`niw-guru -s <evidence_dir>`) that drives Claude Code through the full pipeline, with
  `-o/--output`, `-n/--name`, `--yes`, `--dry-run`, and `-h`.
- **`Makefile` + `INSTALL.md`** — `make build` / `install` / `setup` / `test` / `clean`, plus
  detailed manual build instructions. No prebuilt binary is shipped.
- **Five-stage orchestrator** (`.claude/commands/niw-run.md`): profile → source research →
  harvest + quote → future endeavors → summary.
- **`niw-federal-evidence-harvester` skill** — searches authoritative U.S. sources, downloads
  each as a PDF, extracts exact quotes, and locates each quote's page; produces
  `national_importance_quotes.md` and a folder of downloaded PDFs.
  - `scripts/fetch-to-pdf.sh` — direct-download / headless-browser-render / text fallback, with a
    portable wall-clock watchdog so a stuck renderer can't hang the run.
  - `scripts/pdf-locate-quote.sh` — whitespace/punctuation-insensitive page locator.
- **`niw-future-endeavors` skill** — proposes 3–5 concrete, evidence-anchored future endeavors
  with implementation plans; produces `future_endeavors.md`.
- **`setup.sh`** — installs `poppler`, checks for an HTML→PDF renderer, and installs the
  `claude_immigration_attorney` skills into `.claude/skills/`.
- **Knowledge base** (`knowledge/`) — NIW best-practices and a current-standard research note
  (PA-2025-03 + Critical & Emerging Technologies).
- **Output templates** (`templates/`), **docs** (`docs/`, incl. `architecture.svg`), and a
  **synthetic example** (`examples/sample-run/`).
- **Tooling & community files** — `tests/run-tests.sh`, a CI workflow, issue/PR templates,
  `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `DISCLAIMER.md`, and MIT `LICENSE`.

### Design guarantees
- The user's source directory is treated as read-only.
- Zero unverified claims — unverifiable items are flagged `[VERIFY]`, never fabricated.
- Runs locally; no telemetry.

[Unreleased]: https://github.com/<your-username>/niw-guru/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/<your-username>/niw-guru/releases/tag/v0.1.0
