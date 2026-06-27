#!/usr/bin/env bash
#
# niw-guru setup — run once before first use.
#   1. Installs document-processing tools (poppler: pdftotext / pdfinfo / pdftoppm).
#   2. Checks for an HTML->PDF renderer (Chrome/Chromium/Edge/Brave, or wkhtmltopdf).
#   3. Installs the claude_immigration_attorney skills into .claude/skills/.
#   4. Makes scripts executable and prints how to put `niw-guru` on your PATH.
#
# Re-runnable: re-running refreshes the installed skills from upstream.

set -euo pipefail

ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$ROOT"

SKILLS_REPO="https://github.com/juntoku9/claude_immigration_attorney"
TMP_CLONE="$ROOT/.upstream-skills"

say()  { printf '%s\n' "$*"; }
ok()   { printf '  \xE2\x9C\x93 %s\n' "$*"; }       # ✓
warn() { printf '  ! %s\n' "$*" >&2; }

say "=== niw-guru setup ==="
say "project: $ROOT"
say ""

# ---------------------------------------------------------------------------
# 1) PDF tooling (poppler) + .docx conversion
# ---------------------------------------------------------------------------
say "[1/4] Document-processing tools"
if [[ "$OSTYPE" == darwin* ]]; then
  if command -v brew >/dev/null 2>&1; then
    if ! command -v pdftotext >/dev/null 2>&1; then
      say "  installing poppler via Homebrew…"; brew install poppler
    else ok "poppler already installed"; fi
    command -v textutil >/dev/null 2>&1 && ok "textutil available (macOS built-in, for .docx)"
  else
    warn "Homebrew not found. Install it (https://brew.sh) then re-run, or install poppler manually."
  fi
elif [[ "$OSTYPE" == linux-gnu* || "$OSTYPE" == linux* ]]; then
  if ! command -v pdftotext >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
      say "  installing poppler-utils via apt…"; sudo apt-get update -qq && sudo apt-get install -y poppler-utils
    elif command -v dnf >/dev/null 2>&1; then
      say "  installing poppler-utils via dnf…"; sudo dnf install -y poppler-utils
    else
      warn "No apt/dnf found. Install 'poppler-utils' manually."
    fi
  else ok "poppler-utils already installed"; fi
  command -v libreoffice >/dev/null 2>&1 && ok "libreoffice available (for .docx)" || \
    warn "libreoffice not found (optional — only needed to read .docx sources on Linux)."
else
  warn "Unrecognized OS ($OSTYPE). Ensure 'pdftotext'/'pdfinfo' (poppler) are installed."
fi
command -v pdftotext >/dev/null 2>&1 && ok "pdftotext: $(command -v pdftotext)" || warn "pdftotext STILL missing — page extraction will be degraded."
say ""

# ---------------------------------------------------------------------------
# 2) HTML -> PDF renderer (so government web pages can be saved as PDFs)
# ---------------------------------------------------------------------------
say "[2/4] HTML-to-PDF renderer"
renderer=""
for c in google-chrome google-chrome-stable chromium chromium-browser brave-browser microsoft-edge wkhtmltopdf; do
  if command -v "$c" >/dev/null 2>&1; then renderer="$c"; break; fi
done
if [[ -z "$renderer" ]]; then
  for c \
    in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
       "/Applications/Chromium.app/Contents/MacOS/Chromium" \
       "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
       "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"; do
    [[ -x "$c" ]] && { renderer="$c"; break; }
  done
fi
if [[ -n "$renderer" ]]; then
  ok "found renderer: $renderer"
else
  warn "No HTML->PDF renderer found. PDFs that are direct .pdf links will still download,"
  warn "but HTML pages will be saved as text only. To capture web pages as PDFs, install one of:"
  if [[ "$OSTYPE" == darwin* ]]; then
    warn "    brew install --cask google-chrome     (recommended)"
    warn "    brew install --cask wkhtmltopdf"
  else
    warn "    sudo apt-get install -y chromium-browser   (or google-chrome / wkhtmltopdf)"
  fi
fi
say ""

# ---------------------------------------------------------------------------
# 3) Install the claude_immigration_attorney skills
# ---------------------------------------------------------------------------
say "[3/4] Immigration skills ($SKILLS_REPO)"
if ! command -v git >/dev/null 2>&1; then
  warn "git not found — cannot install the immigration skills. Install git and re-run."
  warn "The pipeline needs document-summary-arrangement and niw-national-importance-research."
else
  rm -rf "$TMP_CLONE"
  if git clone --depth 1 -q "$SKILLS_REPO" "$TMP_CLONE" 2>/dev/null; then
    # Seed knowledge/ without clobbering our curated/generalized files.
    [[ -d "$TMP_CLONE/knowledge" ]] && cp -Rn "$TMP_CLONE/knowledge/." "$ROOT/knowledge/" 2>/dev/null || true
    installed=0
    for d in "$TMP_CLONE"/*/; do
      name="$(basename "$d")"
      [[ -f "$d/SKILL.md" ]] || continue
      case "$name" in niw-federal-evidence-harvester|niw-future-endeavors) continue ;; esac
      rm -rf "$ROOT/.claude/skills/$name"
      cp -R "$d" "$ROOT/.claude/skills/$name"
      installed=$((installed+1))
    done
    ok "installed $installed skill(s) into .claude/skills/"
    rm -rf "$TMP_CLONE"
  else
    warn "Could not clone $SKILLS_REPO (offline?). The two niw-guru skills work, but the"
    warn "pipeline's intake (document-summary-arrangement) and source-research"
    warn "(niw-national-importance-research) stages need that repo. Re-run setup when online."
  fi
fi
say ""

# ---------------------------------------------------------------------------
# 4) Make scripts executable + CLI on PATH
# ---------------------------------------------------------------------------
say "[4/4] Permissions"
find "$ROOT/.claude/skills" -type f -name '*.sh' -exec chmod +x {} \; 2>/dev/null || true
ok "made skill scripts executable"

say ""
say "Setup complete — dependencies and skills are installed."
say ""
say "Next, BUILD the niw-guru command from source (see INSTALL.md):"
if command -v make >/dev/null 2>&1; then
  say "    make build              # renders src/niw-guru.in -> ./bin/niw-guru"
  say "    sudo make install       # (optional) put 'niw-guru' on your PATH"
else
  say "    mkdir -p bin && sed \"s|@NIW_GURU_HOME@|$ROOT|g\" src/niw-guru.in > bin/niw-guru && chmod +x bin/niw-guru"
fi
say ""
say "Then run it:    ./bin/niw-guru -s <your evidence dir>"
say "    (or, once on your PATH)    niw-guru -s <your evidence dir>"
say ""
if ! command -v claude >/dev/null 2>&1; then
  warn "Note: the 'claude' CLI is not on your PATH. Install Claude Code before running niw-guru:"
  warn "      npm install -g @anthropic-ai/claude-code   (https://docs.anthropic.com/en/docs/claude-code)"
fi
