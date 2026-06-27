# Output format

Every run writes to `output/<run-name>/`:

```
output/<run-name>/
├── federal_documents/                # downloaded sources, named NN_Short_Slug.pdf
│   ├── 01_<Statute_or_Strategy>.pdf
│   ├── 02_<Agency_Program>.pdf
│   └── …
├── national_importance_quotes.md     # deliverable #1+#2: the quote bank
├── future_endeavors.md               # deliverable #3: 3–5 proposed endeavors
├── petitioner_profile.md             # intermediate: who you are, from your materials
├── evidence-index.md                 # intermediate: index of your supplied materials
├── national_importance_research.md   # intermediate: ranked candidate sources
├── RUN_SUMMARY.md                    # what ran, counts, assumptions, and the [VERIFY] list
└── .niw-run.env                      # the resolved SOURCE_DIR / RUN_DIR for this run
```

## `national_importance_quotes.md`

One block per downloaded source, strongest first. Each block:

```markdown
## Critical and Emerging Technologies List Update
*Source:* White House / NSTC; Feb 2024. https://…/Critical-and-Emerging-Technologies-List-2024-Update.pdf
*Local file:* `03_CET_List_2024.pdf`

*Quotes:*
> "Advanced energy technologies … grid-scale energy storage"
> — PDF p. 11

*Connection to the petitioner's work:* The petitioner's long-duration grid-storage research
sits inside a formally designated Critical & Emerging Technology — a strong national-importance
factor and, for an advanced-STEM-degree holder in a CET, a positive Prong-3 factor.
```

Conventions:
- **Page numbers** (`— PDF p. N`) refer to the downloaded PDF and are located automatically.
- **Web-only** sources (no renderer, or a blocked page) read `— web page (unpaginated) — verify in source`.
- **`[VERIFY]`** marks any quote, page, or claim the agent could not confirm. The tail section
  **"Quotes to verify before filing"** collects them. **Check every `[VERIFY]` before filing.**
- A **"Sources searched but not used"** tail records what was considered and rejected, so the
  research isn't repeated.

## `future_endeavors.md`

3–5 endeavors, each: title + thesis, objective, technical approach, sub-aims (each linked to
your prior work), milestones (Yr 1–2 / 3–4 / 5+), why you're well positioned (Prong 2), and
national-interest alignment citing harvested sources by file + page (Prong 1). It closes with a
Dhanasar mapping table and a recommended lead endeavor. See the template in
[`templates/future_endeavors.template.md`](../templates/future_endeavors.template.md).

## `RUN_SUMMARY.md`

Read this first. It contains the petitioner profile in brief, download/quote/endeavor counts,
sources that failed to download (with why), the assumptions the agent made, the gaps you should
still fill, and the consolidated `[VERIFY]` list.

## Using the output

These files are **drafts and research aids**. The quote bank feeds a petition letter (try the
`niw-petition-narrative` skill); the endeavors become your proposed-endeavor statement. Confirm
every `[VERIFY]` item, then have a licensed immigration attorney review everything before filing.
