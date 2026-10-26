# Tests

Offline checks for niw-guru. They don't need the `claude` CLI or the network, so they run fast
and are safe in CI.

Python 3 and standard Unix utilities are required. ShellCheck, Poppler, and an HTML-to-PDF
renderer enable additional checks; their absence is reported as a skip.

```bash
tests/run-tests.sh
```

## What it covers

- **Shell syntax** — `bash -n` on the launcher, `setup.sh`, and every helper script; `shellcheck`
  too if it's installed.
- **Skill frontmatter** — the two authored skills have valid `name:` / `description:` headers.
- **`settings.json`** — parses as valid JSON.
- **Launcher behavior** — `-h` exits 0, a missing `-s` exits 2, `--dry-run` exits 0.
- **Isolated contracts** — dry-run works without Claude and never invokes an available Claude
  command; missing/empty sources are rejected; actual runs require Claude and propagate its
  failure status. Tests use temporary synthetic evidence and a fake Claude executable on a
  controlled PATH, so no credentials, real model calls, or personal documents are used.
- **Quote matching logic** — deterministic mocked PDF extraction checks full matches and
  unrelated quotes independently of installed PDF tools. This does not test real PDF parsing.
- **`pdf-locate-quote.sh` guards** — non-PDF and missing-file inputs return `not-a-pdf` (no
  fabricated page numbers).
- **Render + locate round-trip** — renders the local `fixtures/locator.html` to PDF with a
  headless browser (via a `file://` URL, so it's offline) and confirms the locator finds the
  known phrase. Skipped automatically if no renderer is available.

Skips never fail the suite; only real failures return a non-zero exit code.

## Known-defect regressions

`test_regressions.py` records four outstanding bugs as `expected failure` results:

- Output inside the source folder is not rejected before writing.
- A run name containing `../` can escape the output root.
- A successful model process with missing deliverables still returns success.
- A quote with an altered ending can return a page based only on its first 12 words.

These results are **not passes** and do not mean the bugs are fixed. To run all contracts as
ordinary failing tests while implementing fixes:

```bash
NIW_STRICT_REGRESSIONS=1 python3 tests/test_regressions.py
```

The normal suite reports expected failures explicitly. An unexpected success also fails the
suite: once a fix lands, remove that test's `@known_defect` decorator to make it a permanent
passing regression test. Keep the positive control tests passing when changing the fixtures.

## Not covered here

A full end-to-end run uses the `claude` CLI plus live web research and downloads, so it isn't part
of the automated suite. Exercise it manually against the synthetic example:

```bash
./bin/niw-guru -s ./examples/sample-run/input -o /tmp/niw-smoke --yes
```
