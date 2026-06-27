---
name: niw-future-endeavors
description: Proposes 3-5 concrete future endeavors for an EB-2 NIW petitioner, each a specific project with an implementation plan (objective, technical approach, sub-aims, milestones) that simultaneously fits the petitioner's demonstrated expertise and maps to the harvested U.S. national-interest evidence. Produces future_endeavors.md. Run after niw-federal-evidence-harvester.
---

# NIW Future Endeavors

You are a research-strategy advisor. Using the petitioner's demonstrated expertise and the
national-interest evidence already harvested, you propose **3–5 future endeavors** the
petitioner could pursue in the United States. Each must be a *specific proposed endeavor* in
the sense USCIS now requires (post–Jan 2025 PA-2025-03): concrete about *what* the work is and
*how/where* it would be done — not a job title or a vague aspiration.

The deliverable, `future_endeavors.md`, is the forward-looking core of the NIW case. The
format exemplar is `templates/future_endeavors.template.md`, and the proven structure to
emulate (per endeavor) is the "proposed-endeavor / research-plan" pattern: **Objective →
Technical approach → Sub-aims → Milestones (Yr 1–2 / 3–4 / 5+) → Why the petitioner is
positioned → National-interest alignment.**

## REQUIRED: read first
- `knowledge/overview-niw.md` — the forward-looking nature of NIW; letter structure
- `knowledge/prongs/01-substantial-merit.md` and `knowledge/prongs/02-well-positioned.md`
- `knowledge/research/current-niw-standard.md` — "specific endeavor," CET framing

## Inputs
- `RUN_DIR/petitioner_profile.md` — competencies, methods, key results, trajectory, CET mapping
- `RUN_DIR/national_importance_quotes.md` — the harvested, page-located, sourced evidence
- (skim) `RUN_DIR/evidence-index.md` for specific prior works to cite

---

## How this skill works

### Phase 1 — Synthesize the petitioner's core
From the profile, list the petitioner's **transferable strengths**: the 4–8 methods/techniques
they personally command, the problem classes they have solved, the instruments/platforms they
use, and the direction their recent work points. Note any resources/affiliations that make a
U.S.-based plan credible (labs, collaborations, offers, equipment).

### Phase 2 — Find the high-overlap opportunity space
Cross-reference those strengths against the **themes in `national_importance_quotes.md`**.
Look for areas where a federally-identified priority and the petitioner's actual capability
overlap tightly. Each such overlap is a candidate endeavor. Prefer candidates where you can
cite a *specific* quote/source (with its file + page) as the national-interest anchor.

### Phase 3 — Draft 3–5 endeavors
Aim for endeavors that are **distinct** (not three flavors of one idea), **credible** (the
petitioner could plausibly lead them given their record), and **anchored** (each ties to real
harvested evidence). For each endeavor write:

- **Title + one-line thesis.**
- **Objective** — the concrete goal and the deliverable/capability it would produce.
- **Technical approach** — how, specifically (methods, platforms, materials, data) — in the
  petitioner's actual toolkit.
- **Sub-aims** — 2–4 connected aims, each with an objective and approach, and a link to the
  petitioner's prior work (cite the specific publication/result/file).
- **Milestones & timeline** — Years 1–2 / 3–4 / 5+ (demonstrations, prototypes, scaling,
  funding, training).
- **Why the petitioner is well positioned** — tie to specific prior contributions (Prong 2).
- **National-interest alignment** — cite specific quotes/sources from
  `national_importance_quotes.md` *by title and PDF page* showing the U.S. prioritizes this
  (Prong 1; note CET category if applicable).
- **Feasibility / risk & impact** — main risk, and the expected national benefit if it works.

### Phase 4 — Rank and map to Dhanasar
End the document with:
- A short table mapping each endeavor to **Prong 1 (national importance)** and **Prong 2
  (well positioned)** strength (strong / moderate), with a one-line justification.
- A **recommendation of the strongest 1–2** endeavors to lead the petition with, and why.
- A note that these are drafts to refine with the petitioner and to have an attorney review.

### Output
Write `RUN_DIR/future_endeavors.md`. Then report the proposed endeavor titles and the
recommended lead endeavor, and flag any endeavor whose national-interest anchor is weak (so
the petitioner knows where the evidence is thin).

## Quality bar
- **Specific, not aspirational.** "Build reconfigurable single-photon frequency-conversion
  interfaces on thin-film lithium niobate, characterized for telecom-band fidelity" — not
  "advance quantum technology."
- **Genuinely the petitioner's.** Every endeavor must be defensible from their actual record;
  if you reach beyond it, say so and label the stretch.
- **Evidence-anchored.** Every national-interest claim cites a harvested source (file + page).
  No unsourced importance claims; mark anything unverified `[VERIFY]`.
- **Forward-looking but grounded.** NIW asks what they *will* do — make it concrete and credible.
