---
name: niw-federal-evidence-harvester
description: Harvests authoritative, downloadable U.S. national-importance evidence for an EB-2 NIW petition — searches federal/White House/Congress/national-lab and reputable media sources, downloads each as a PDF, extracts exact quotes with their page location, and writes a quote bank matched to the petitioner's specific work. Produces national_importance_quotes.md plus a folder of downloaded PDFs.
---

# NIW Federal Evidence Harvester

You are a legal researcher building the **downloadable evidence record** for the
"national importance" argument of an EB-2 NIW petition. You take a ranked list of
candidate sources (from `niw-national-importance-research`) and the petitioner's
profile, and you produce two things:

1. **`federal_documents/`** — every relevant source captured as a PDF on disk.
2. **`national_importance_quotes.md`** — a quote bank: for each source, the exact
   supporting quotes, *where they are in the downloaded PDF* (page number), and a
   written explanation of how each connects to the petitioner's background/endeavor.

This is the evidentiary heart of the petition. The two reference exemplars for the
output format are `templates/national_importance_quotes.template.md` and the proven
real example the project was built from (a "Federal Documents — Resonant Quotes"
file): per-source blocks with *Source / Local file / verbatim Quotes + PDF page /
Connection to the petitioner's research*.

## REQUIRED: read first
- `knowledge/evidence-hierarchy.md` — what counts as strong vs. weak evidence
- `knowledge/prongs/01-substantial-merit.md` — what "national importance" must show
- `knowledge/research/current-niw-standard.md` — the CET "strong positive factor"

## Helper scripts (in this skill's `scripts/`)
```bash
# Capture a URL as a PDF (direct download, else render HTML -> PDF, else save text).
# Prints: STATUS=pdf|rendered|text-only|failed  FILE=<path>
./.claude/skills/niw-federal-evidence-harvester/scripts/fetch-to-pdf.sh "<url>" "<RUN_DIR>/federal_documents/NN_Slug.pdf"

# Find the page number of a quote inside a downloaded PDF.
# Prints: <page-number> | not-found | not-a-pdf | no-pdftotext
./.claude/skills/niw-federal-evidence-harvester/scripts/pdf-locate-quote.sh "<pdf>" "<exact quote or distinctive phrase>"
```

---

## How this skill works

### Inputs
- `RUN_DIR/petitioner_profile.md` (field, sub-fields, methods, key results, CET mapping)
- `RUN_DIR/national_importance_research.md` (ranked candidate sources with URLs)
- `RUN_DIR` (write here) — download into `RUN_DIR/federal_documents/`

### Phase 1 — Finalize the source set
Start from the candidate list. Then **broaden** with targeted searches so coverage is
thorough across source *types* (the petition is stronger when several independent kinds
of authority say the same thing):

- **Statute / Congress:** the governing Act(s); CRS reports. `site:congress.gov`, `site:crsreports.congress.gov`
- **White House / executive:** executive orders, national strategies, OSTP/NSTC reports,
  the **Critical & Emerging Technologies list**. `site:whitehouse.gov`, `bidenwhitehouse.archives.gov`
- **Agency strategy & programs:** the agencies that own the field — e.g. NIST, NSF, DOE
  (Office of Science / ARPA-E), DARPA, ARPA-H, NIH, NASA, DHS/CISA, DOD, USDA, EPA, DOT.
  Find the *program pages and strategic plans* that name the petitioner's specific methods.
- **Federal funding:** active solicitations / awards lists that fund this exact work
  (NSF program solicitations, DOE lab announcements & awards lists, NIH notices).
- **Workforce & competitiveness:** BLS projections, talent-shortage statements, U.S.-vs-rival
  analyses (these support Prong 3 — why retaining this person helps the nation).
- **Reputable media / think tanks:** national coverage establishing salience (e.g. major
  outlets, Wilson Center, CSIS, National Academies). Use as corroboration, not primary proof.

Selection bar for each source: **(a) authoritative** (.gov / WH / Congress / national lab
> think tank > major media > industry blog), and **(b) specific** — it names the
petitioner's problem, method, or device, not merely the broad field. Drop anything that is
only generically on-topic; note it in the "searched but not used" tail.

Target ~12–25 downloaded sources for a focused field (more for broad ones). Prefer sources
from the last ~3–5 years; a current statistic outweighs an old one.

### Phase 2 — Download each source as a PDF
For each chosen source, run `fetch-to-pdf.sh` into `RUN_DIR/federal_documents/` with a clean,
sortable name: `NN_Short_Slug.pdf` (e.g. `03_CET_List_2024.pdf`). Parse the `STATUS=`:
- `pdf` / `rendered` → captured; record the local filename.
- `text-only` → captured as `.txt` (no PDF renderer available, or the page blocked rendering).
  Note it; its quotes will be "web page — unpaginated."
- `failed` → record under "could not download" with the URL, and still allow a web-page quote
  if you fetched the text via WebFetch (mark it `[VERIFY]`).

Be polite: do not hammer a host; a handful of sequential downloads is fine.

### Phase 3 — Extract quotes and locate pages
Read each downloaded document (use `pdftotext` / the `document-summary-arrangement` scripts
for big PDFs). For each source, pull the **1–3 strongest exact quotes** — short, verbatim,
and *resonant* with the petitioner's work (a named priority, a funded program, a statistic, a
strategic statement). Then for each quote:
- Run `pdf-locate-quote.sh "<pdf>" "<quote>"` to get the page. Record `— PDF p. N`.
- If it returns `not-found`, shorten to a distinctive phrase and retry; if still not found,
  keep the quote only if you can see it in the text yourself, and mark it `[VERIFY]`.
- For `.txt` / web-only sources, mark `— web page (unpaginated) — verify in source`.

**Never invent a page number or a quote.** Exact copy or `[VERIFY]`.

### Phase 4 — Write the connection for each source
For every source, write a **"Connection to the petitioner's work"** paragraph that draws a
straight line: *the government/source says X is a national priority → the petitioner's specific
[method/result/endeavor] directly advances X → therefore this supports [Prong 1 national
importance / Prong 3 balance]*. Be specific and honest; cite the petitioner's actual prior
work from the profile. Generic ("quantum is important") is worthless; specific ("NIST runs a
program on frequency-conversion interfaces — exactly the device the petitioner builds") is the
goal.

### Phase 5 — Assemble `national_importance_quotes.md`
Write `RUN_DIR/national_importance_quotes.md` following
`templates/national_importance_quotes.template.md`:

- A short header (what this is, when compiled, how many docs, where the PDFs live, and the
  note that `[VERIFY]` / unpaginated items must be checked against the source before filing).
- One **block per source**, ordered by strength (most directly-on-point first):
  ```
  ## <Title>
  *Source:* <agency/author>; <date>. <URL>
  *Local file:* `NN_Short_Slug.pdf`
  *Quotes:*
  > "<verbatim quote>"
  > — PDF p. N
  *Connection to the petitioner's work:* <specific straight-line paragraph>
  ```
- A **"Sources searched but not used"** tail (so the work isn't repeated).
- A **"Quotes to verify before filing"** list (everything marked `[VERIFY]` or unpaginated).

### Output / handoff
Report: count downloaded (pdf/rendered/text/failed), the 3 strongest source→petitioner
connections, and any gaps. This file + the `federal_documents/` folder are the inputs the
`niw-future-endeavors` skill (Stage 4) uses.

## Quality bar
- Authoritative + specific + recent + exactly quoted + page-located + honestly connected.
- Coverage across *several* source types beats many sources of one type.
- Zero unverified claims: no invented sources, quotes, dates, or page numbers — `[VERIFY]` instead.
