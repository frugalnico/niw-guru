# Security & Privacy Policy

niw-guru handles **highly sensitive personal data** (CVs, immigration history, and the documents
people attach to a petition). Security and privacy are first-class concerns.

## Privacy model

- **Local-first.** niw-guru runs on your machine via the `claude` CLI. Your source documents are
  read locally; the agent does not upload them anywhere. Only the **web search queries and
  document downloads** needed for national-importance research leave your machine.
- **Read-only source.** Your evidence folder is never modified.
- **Output stays local.** Run output is written under `output/`, which is **git-ignored** by
  default so you don't accidentally commit personal data.
- **No telemetry.** niw-guru contains no analytics, tracking, or phone-home code.
- **You own your data.** Deleting an `output/<run>/` folder removes that run's artifacts.

> Note: niw-guru runs *inside* Claude Code. Your use of the `claude` CLI is governed by
> Anthropic's own terms and privacy policy. niw-guru does not change how Claude Code handles data;
> review Anthropic's policies for how your prompts and tool calls are processed.

## Your responsibilities

- Protect your own evidence folder and the `output/` directory (they contain PII).
- Don't commit real personal documents to a public repo. Keep `output/` git-ignored.
- If your materials contain **other people's** personal information (e.g., recommenders), handle
  it responsibly.

## Reporting a vulnerability

**Please do not open a public GitHub issue for security or privacy vulnerabilities.**

Instead, report privately via one of:

1. **GitHub Private Vulnerability Reporting** — on the repository, go to
   **Security → Report a vulnerability** (preferred).
2. **Email** — `<your-security-contact-email>` (repo owner: replace this before publishing).

Please include: a description, steps to reproduce, affected files/versions, and the potential
impact. We aim to acknowledge reports within a few days and to address confirmed issues promptly.
Responsible disclosure is appreciated — give us reasonable time to fix before public disclosure.

## Scope

In scope: the launcher, the orchestrator, the authored skills and their helper scripts, and the
setup script — e.g. path-handling bugs, command injection, unsafe downloads, or anything that
could leak or modify a user's data.

Out of scope: vulnerabilities in upstream dependencies (Claude Code, the
`claude_immigration_attorney` skills, Chrome, poppler) — report those to their projects — and the
security of a user's own machine or documents.

## Supported versions

niw-guru is pre-1.0; security fixes target the latest `main`. Pin a commit if you need stability.
