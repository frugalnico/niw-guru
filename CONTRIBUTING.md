# Contributing to niw-guru

Thanks for your interest! niw-guru is an open-source Claude Code agent that helps STEM
self-petitioners assemble the evidence core of an EB-2 NIW petition. Contributions of all
kinds — bug reports, docs, knowledge-base updates, and new/improved skills — are welcome.

By participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md).

## Ground rules (please read)

These three rules are the whole point of the project. PRs that violate them won't be merged:

1. **The user's evidence folder is read-only.** Nothing in the pipeline may create, edit, move,
   or delete files inside a user's source directory. Output goes under `output/` only.
2. **Zero unverified claims.** Skills must not fabricate sources, quotes, page numbers,
   statistics, or facts. Anything unverifiable is marked `[VERIFY]`, never invented.
3. **No real PII in the repo.** Examples must be clearly synthetic. Never commit a real person's
   CV, documents, or case data. The `examples/` profile is fictional and must stay that way.

Also: keep the **"not legal advice"** framing intact wherever it appears. This is a legal-adjacent
tool and the disclaimers are load-bearing.

## Dev setup

```bash
git clone https://github.com/<your-username>/niw-guru.git
cd niw-guru
./setup.sh        # installs poppler + an HTML→PDF renderer check + the immigration skills
make build        # builds bin/niw-guru from src/niw-guru.in  (see INSTALL.md)
```

Requirements: [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`claude`), `git`,
`poppler`, and Chrome/Chromium or `wkhtmltopdf` for HTML→PDF. The `niw-guru` command is built
from source — edit [`src/niw-guru.in`](src/niw-guru.in), not the generated `bin/niw-guru`.

## How the repo is organized

| Path | What it is |
|---|---|
| `src/niw-guru.in` | The launcher **source** (built into `bin/niw-guru`). Parses args, pre-flights, drives `claude -p`. |
| `Makefile` | Build/install: `make build`, `make install`, `make test`, `make clean`. |
| `.claude/commands/niw-run.md` | The orchestrator — the six-stage pipeline playbook. |
| `.claude/skills/niw-federal-evidence-harvester/` | **Authored here.** Search → download PDFs → page-located quotes. |
| `.claude/skills/niw-future-endeavors/` | **Authored here.** Propose 3–5 endeavors. |
| `.claude/skills/<others>/` | Installed from upstream by `setup.sh` (not committed; see `.gitignore`). |
| `knowledge/` | NIW best-practices + the current-standard research note. |
| `templates/` | Output templates the skills fill in. |
| `docs/`, `examples/`, `tests/` | Docs, the synthetic example, offline checks. |

## Making changes

### Shell scripts (`bin/`, `setup.sh`, `*/scripts/*.sh`)
- Start with `set -euo pipefail` (or `set -uo pipefail` where a script must continue past
  non-zero, like the fetch fallbacks) and a header comment describing inputs/outputs.
- Keep them **portable across macOS and Linux** (macOS ships no `timeout`/GNU coreutils — see the
  `run_capped` watchdog in `fetch-to-pdf.sh` for the pattern).
- Run `shellcheck` and `bash -n` before pushing; CI runs both.

### Skills (`.claude/skills/<name>/SKILL.md`)
- Each skill is a Markdown file with YAML frontmatter (`name`, `description`) and a clear,
  staged body. Put any helpers in a `scripts/` subfolder.
- Read from `knowledge/`; write only under the run directory.
- If you add a stage or skill, update `.claude/commands/niw-run.md`, `docs/how-it-works.md`, and
  `CLAUDE.md` so the pipeline description stays consistent.

### Knowledge base (`knowledge/`)
- Keep entries concise and **dated** — policy changes. If you update the NIW standard, update
  `knowledge/research/current-niw-standard.md` and cite official USCIS sources.
- No PII; best-practices only.

## Running tests

```bash
tests/run-tests.sh
```

This runs offline static checks (`bash -n`, `shellcheck` if present) and unit-tests the helper
scripts that don't need the network. A full end-to-end run uses the `claude` CLI and the web, so
it isn't part of the automated suite — exercise it manually with the synthetic example:

```bash
./bin/niw-guru -s ./examples/sample-run/input -o /tmp/niw-smoke --yes
```

## Submitting a PR

1. Fork, branch from `main` (e.g. `fix/fetch-timeout`, `feat/bibtex-export`).
2. Keep PRs focused; describe the change and how you tested it (fill in the PR template).
3. Make sure `tests/run-tests.sh` passes and docs are updated.
4. Open the PR. Be patient and kind in review.

## Reporting bugs / requesting features

Use the issue templates. For anything security- or privacy-related, **do not open a public
issue** — follow [SECURITY.md](SECURITY.md) instead.
