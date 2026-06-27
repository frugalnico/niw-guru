<!-- Thanks for contributing to niw-guru! Please fill this out. -->

## What this changes
A short description of the change and the motivation. Link any related issue (e.g. `Closes #12`).

## Type
- [ ] Bug fix
- [ ] New feature / skill
- [ ] Docs / knowledge base
- [ ] Tooling / CI
- [ ] Other:

## How it was tested
- [ ] `tests/run-tests.sh` passes
- [ ] `shellcheck` / `bash -n` clean on any changed scripts
- [ ] Manually ran the pipeline (synthetic example) if behavior changed:
      `./bin/niw-guru -s ./examples/sample-run/input -o /tmp/niw-smoke --yes`
- Notes:

## Ground-rules checklist
- [ ] The user's source directory remains **read-only** (no writes outside the run dir).
- [ ] **Zero unverified claims** preserved — no fabricated sources/quotes/pages; unverifiable
      items use `[VERIFY]`.
- [ ] **No real PII** added anywhere (examples stay synthetic).
- [ ] "Not legal advice" framing kept intact where relevant.
- [ ] Updated docs (`docs/`, `CLAUDE.md`, orchestrator) if the pipeline/skills changed.
- [ ] Cross-platform (macOS + Linux) shell, if scripts changed.

## Anything reviewers should know
Trade-offs, follow-ups, or open questions.
