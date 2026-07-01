# niw-guru — Agent Card

**Name:** niw-guru
**Type:** Claude Code agent (skills + orchestrator + launcher)
**Purpose:** Turn a STEM self-petitioner's own materials into the forward-looking, fully-sourced
evidence core of an EB-2 National Interest Waiver (NIW) petition — in one command.

## One command
```
niw-guru -s <directory of user-supplied evidence>
```
Point it at a folder containing your CV, publication list, Google Scholar export, prior
statements, awards, and offers. It runs the full research pipeline and writes four deliverables.

## Deliverables (per run)
| File | What it is |
|------|------------|
| `federal_documents/*.pdf` | Every relevant U.S. government / White House / Congress / national-lab / reputable-media source, downloaded as PDF. |
| `national_importance_quotes.md` | Exact quotes from those PDFs — each with its **page location** and a written explanation of how it connects to your background and proposed endeavor. |
| `future_endeavors.md` | **3–5 concrete future endeavors** with implementation plans, each fitting your expertise *and* mapped to the national-interest evidence. |
| `partial_petition_letter_draft.md` | The three above woven into the **petition-letter core**: background → national importance → how each endeavor advances the evidence found (Dhanasar Prongs 1–3). A partial draft, not a filing-ready letter. |
| `RUN_SUMMARY.md` | What ran, what was found, and every item to verify before filing. |

## How it works
A thin launcher — built from `src/niw-guru.in` into `bin/niw-guru` (see `INSTALL.md`) — drives
the `claude` CLI through a six-stage pipeline (`.claude/commands/niw-run.md`) built from skills:

1. `document-summary-arrangement` → profile the petitioner from their materials
2. `niw-national-importance-research` → find authoritative national-importance sources
3. **`niw-federal-evidence-harvester`** → download sources as PDFs + extract page-located quotes
4. **`niw-future-endeavors`** → propose 3–5 concrete, evidence-anchored endeavors
5. synthesize 1–4 → `partial_petition_letter_draft.md` (the petition-letter core)
6. summary & gap report

The two **bold** skills are authored in this repo; the rest are installed from
[`claude_immigration_attorney`](https://github.com/juntoku9/claude_immigration_attorney) by `setup.sh`.

## Principles
- The user's source folder is **read-only**. Output is written elsewhere.
- **Zero unverified claims** — every fact traces to a supplied file or a downloaded source;
  unverifiable items are marked `[VERIFY]`.
- Drafts and research aids, **not legal advice**. Have a licensed attorney review before filing.

## Requirements
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`claude` on PATH)
- `poppler` (PDF tools) and, for capturing web pages as PDFs, Chrome/Chromium or `wkhtmltopdf`
- `git` (to install the immigration skills); `make` optional (for the build)

Build it: `./setup.sh` (dependencies + skills), then `make build` (renders `bin/niw-guru`).
See `INSTALL.md` for the full build/install instructions, including a no-`make` path.
