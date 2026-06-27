# How it works

niw-guru is a Claude Code agent. The `niw-guru` command is a thin launcher; the real work is a
five-stage pipeline defined in [`.claude/commands/niw-run.md`](../.claude/commands/niw-run.md) and
carried out by skills in [`.claude/skills/`](../.claude/skills).

## The launcher (`bin/niw-guru`)

The launcher is **built from [`src/niw-guru.in`](../src/niw-guru.in)** by `make build` (or the
manual `sed` step in [INSTALL.md](../INSTALL.md)); the build bakes the project's absolute path in
as `NIW_GURU_HOME`. At run time it:

1. Resolves the project root from the baked `NIW_GURU_HOME` (falling back to its own location, or
   an explicit `NIW_GURU_HOME` env override).
2. Pre-flight checks: `claude` is installed, the source dir exists and is non-empty, PDF tools present.
3. Computes the run directory `output/<run-name>/` and writes `.niw-run.env` with the resolved paths.
4. Invokes `claude -p` from the project root with the orchestrator prompt, adding the source and
   run directories with `--add-dir` so they're reachable.
5. Prints which deliverables were produced.

## Permission model

A full run uses web search, web fetch, file writes, and shell commands (downloads, PDF tools).
For that to run unattended, the tools must be pre-approved:

- **Default (scoped, autonomous):** the launcher passes `--permission-mode acceptEdits` and an
  `--allowedTools` list (`Read,Write,Edit,Glob,Grep,Bash,WebSearch,WebFetch,Task,TodoWrite`).
  Because `claude -p` is headless there are no interactive prompts — the allowlist decides what
  the run may do, and it covers everything the pipeline needs. `.claude/settings.json` carries a
  matching scoped allowlist for interactive `/niw-run` use.
- **`--yes` (unrestricted):** the launcher passes `--dangerously-skip-permissions` so nothing is
  ever denied. Use this on your own machine with your own data for the most hands-off run.

## The stages (five, plus a finish step)

| # | Stage | Skill | Writes |
|---|-------|-------|--------|
| 1 | Intake & profile | `document-summary-arrangement` | `petitioner_profile.md`, `evidence-index.md` |
| 2 | Source research | `niw-national-importance-research` | `national_importance_research.md` |
| 3 | Harvest & quote | **`niw-federal-evidence-harvester`** | `federal_documents/*.pdf`, `national_importance_quotes.md` |
| 4 | Future endeavors | **`niw-future-endeavors`** | `future_endeavors.md` |
| 5 | Summary & gaps | (orchestrator) | `RUN_SUMMARY.md` |

**Stage 1 — Profile.** Scans and reads your materials, builds an evidence index, and distills a
profile: field, sub-fields, the methods/instruments you personally command, your key results
(each tied to a source file), your trajectory, and whether your field maps to a Critical &
Emerging Technology (CET) category.

**Stage 2 — Source research.** From the profile, identifies the national problem(s) your work
addresses and produces a *ranked list of candidate sources* — statutes, executive orders, agency
strategies, funding solicitations, workforce/competitiveness reports, and reputable media — each
with a real URL and a reason it connects to your specific work.

**Stage 3 — Harvest & quote** (the new core). For each chosen source it:
- **downloads it as a PDF** into `federal_documents/` (`scripts/fetch-to-pdf.sh` — direct
  download for PDFs, headless-browser render for HTML pages, text fallback otherwise);
- **extracts the strongest exact quotes** and **locates each quote's page** in the downloaded
  PDF (`scripts/pdf-locate-quote.sh`);
- writes **`national_importance_quotes.md`**: per source — title, source+date+URL, local file,
  verbatim quotes with page numbers, and a *"Connection to the petitioner's work"* paragraph.

**Stage 4 — Future endeavors** (the new core). Cross-references your competencies with the
harvested national-interest themes and proposes **3–5 specific endeavors**, each with objective,
technical approach, sub-aims, milestones (Yr 1–2 / 3–4 / 5+), why you're well positioned, and a
national-interest alignment that cites specific harvested sources by file + page. Ends with a
Dhanasar Prong 1/2 mapping and a recommended lead endeavor.

**Stage 5 — Summary.** `RUN_SUMMARY.md`: counts, assumptions made, gaps to fill, and the full
`[VERIFY]` list.

## Design guarantees

- **Read-only source.** Your input folder is never modified.
- **Zero unverified claims.** Every fact traces to a supplied file or a downloaded source;
  unverifiable items are marked `[VERIFY]`, never invented.
- **Local by default.** Outputs stay under `output/`. Only the research queries/downloads leave
  your machine.
