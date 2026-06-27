# Getting started

## 1. Install & build

```bash
cd niw-guru
./setup.sh        # installs poppler, checks for a renderer, installs the immigration skills
make build        # builds ./bin/niw-guru from src/niw-guru.in
```

`setup.sh` installs `poppler` (PDF tools), checks for an HTML→PDF renderer (Chrome/Chromium or
`wkhtmltopdf`), and installs the
[`claude_immigration_attorney`](https://github.com/juntoku9/claude_immigration_attorney) skills
into `.claude/skills/`. `make build` renders the launcher from source. You also need the
[`claude`](https://docs.anthropic.com/en/docs/claude-code) CLI on your PATH.

No `make`? Build by hand:

```bash
mkdir -p bin && sed "s|@NIW_GURU_HOME@|$(pwd)|g" src/niw-guru.in > bin/niw-guru && chmod +x bin/niw-guru
```

Optionally put the command on your PATH:

```bash
sudo make install      # or: sudo ln -sf "$PWD/bin/niw-guru" /usr/local/bin/niw-guru
```

Full build details and troubleshooting: [INSTALL.md](../INSTALL.md).

## 2. Try the synthetic example

The repo ships a tiny, fully fictional profile (a grid-scale energy-storage researcher) so you
can see the shape of a run without using real data:

```bash
./bin/niw-guru -s ./examples/sample-run/input -o /tmp/niw-smoke --yes
```

When it finishes, look in `/tmp/niw-smoke/<run-name>/` for `federal_documents/`,
`national_importance_quotes.md`, `future_endeavors.md`, and `RUN_SUMMARY.md`. Compare them to
the pre-written illustrative versions in
[`examples/sample-run/output/`](../examples/sample-run/output) to know what "good" looks like.

> A real run performs live web research and downloads, so it takes longer and consumes Claude
> Code usage. The committed example outputs are illustrative and were not produced by a download.

## 3. Run it on your own materials

Gather your materials into one folder:

```
my_niw_materials/
├── CV.pdf
├── publications.pdf           # or a Google Scholar export / a .txt with your Scholar URL
├── research_statement.pdf
└── awards_and_offers/...
```

Then:

```bash
niw-guru -s ~/my_niw_materials
```

- **Default**: runs autonomously with a pre-approved tool allowlist (no interactive prompts —
  `claude -p` is headless).
- **`--yes`**: skips all permission checks for the most hands-off run.
- Use `-o` to choose where output goes, `-n` to name the run, `--dry-run` to preview.

Your source folder is never modified.

## 4. After the run

Open `RUN_SUMMARY.md` first — it lists what was downloaded, the proposed endeavors, and every
`[VERIFY]` item to confirm before filing. Then read `national_importance_quotes.md` and
`future_endeavors.md`.

To go further, open `claude` in the `niw-guru` folder and run the installed skills
interactively, e.g. `/case-strength-assessor`, `/niw-petition-narrative`, `/petition-audit`.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `the 'claude' CLI was not found` | Install Claude Code; ensure `claude` is on PATH. |
| `missing tools: pdftotext` | Run `./setup.sh` (installs poppler). |
| HTML sources saved as `.txt`, not PDF | No renderer found — install Chrome/Chromium or `wkhtmltopdf`, then re-run. |
| Intake/research stage seems to skip | `setup.sh` couldn't clone the immigration skills (offline?). Re-run it online. |
| A run stops to ask permission | Re-run with `--yes`, or approve the prompts. |
