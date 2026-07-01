# Sample run (synthetic)

A tiny, **fully fictional** example so you can see what niw-guru does without using real data.

- **`input/`** — a fake petitioner ("Dr. A. Researcher," grid-scale energy storage): `cv.md`,
  `publications.md`, `google_scholar.txt`. No real person; the papers don't exist.
- **`output/`** — *illustrative* versions of three deliverables (`national_importance_quotes.md`,
  `future_endeavors.md`, and `partial_petition_letter_draft.md`), hand-written to show the format.
  They reference real U.S. programs (DOE Long-Duration Storage Shot, the IRA, the CET list) but the
  **quote text is illustrative paraphrase, not verified verbatim** — a real run downloads each
  source as a PDF and extracts exact quotes with located page numbers.

## Run it yourself

```bash
./bin/niw-guru -s ./examples/sample-run/input -o /tmp/niw-smoke --yes
```

Then compare `/tmp/niw-smoke/<run-name>/` against `output/` here. A real run will also create
`federal_documents/*.pdf`, `petitioner_profile.md`, `national_importance_research.md`, and
`RUN_SUMMARY.md`, and its quotes will carry real page numbers (or `[VERIFY]` where it couldn't
confirm one).

> The committed `output/` files were written by hand for illustration, **not** produced by a
> download. Don't cite them as evidence.
