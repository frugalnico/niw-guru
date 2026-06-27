# Tests

Offline checks for niw-guru. They don't need the `claude` CLI or the network, so they run fast
and are safe in CI.

```bash
tests/run-tests.sh
```

## What it covers

- **Shell syntax** — `bash -n` on the launcher, `setup.sh`, and every helper script; `shellcheck`
  too if it's installed.
- **Skill frontmatter** — the two authored skills have valid `name:` / `description:` headers.
- **`settings.json`** — parses as valid JSON.
- **Launcher behavior** — `-h` exits 0, a missing `-s` exits 2, `--dry-run` exits 0.
- **`pdf-locate-quote.sh` guards** — non-PDF and missing-file inputs return `not-a-pdf` (no
  fabricated page numbers).
- **Render + locate round-trip** — renders the local `fixtures/locator.html` to PDF with a
  headless browser (via a `file://` URL, so it's offline) and confirms the locator finds the
  known phrase. Skipped automatically if no renderer is available.

Skips never fail the suite; only real failures return a non-zero exit code.

## Not covered here

A full end-to-end run uses the `claude` CLI plus live web research and downloads, so it isn't part
of the automated suite. Exercise it manually against the synthetic example:

```bash
./bin/niw-guru -s ./examples/sample-run/input -o /tmp/niw-smoke --yes
```
