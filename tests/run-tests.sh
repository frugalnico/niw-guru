#!/usr/bin/env bash
#
# niw-guru offline test suite.
#   - static checks: bash -n, shellcheck (if present), skill frontmatter, settings.json validity
#   - launcher behavior: -h, missing-arg, --dry-run
#   - helper scripts: pdf-locate-quote guards, and an offline render+locate round-trip
#     (headless browser on a local file:// fixture — no network needed)
#
# A full end-to-end run uses the `claude` CLI and the web and is NOT part of this suite;
# exercise it manually:  ./bin/niw-guru -s ./examples/sample-run/input -o /tmp/niw-smoke --yes
#
# Exit code: 0 if no required test failed, 1 otherwise. Skips do not fail the suite.

set -uo pipefail

ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
cd "$ROOT"

# Ensure helper scripts are executable (a fresh checkout in CI may not preserve exec bits yet).
chmod +x .claude/skills/*/scripts/*.sh 2>/dev/null || true

PASS=0; FAIL=0; SKIP=0
pass() { printf '  \033[32mok\033[0m   %s\n' "$*"; PASS=$((PASS+1)); }
fail() { printf '  \033[31mFAIL\033[0m %s\n' "$*"; FAIL=$((FAIL+1)); }
skip() { printf '  \033[33mskip\033[0m %s\n' "$*"; SKIP=$((SKIP+1)); }
section() { printf '\n== %s ==\n' "$*"; }

TMP="$(mktemp -d 2>/dev/null || echo /tmp/niw-tests-$$)"
trap 'rm -rf "$TMP"' EXIT

FETCH=".claude/skills/niw-federal-evidence-harvester/scripts/fetch-to-pdf.sh"
LOCATE=".claude/skills/niw-federal-evidence-harvester/scripts/pdf-locate-quote.sh"

# ---------------------------------------------------------------------------
section "Static: shell syntax (bash -n)"
SCRIPTS=(src/niw-guru.in setup.sh tests/run-tests.sh)
while IFS= read -r s; do SCRIPTS+=("$s"); done < <(find .claude/skills -name '*.sh' 2>/dev/null)
for f in "${SCRIPTS[@]}"; do
  [[ -f "$f" ]] || continue
  if bash -n "$f" 2>/dev/null; then pass "bash -n $f"; else fail "bash -n $f"; fi
done

# ---------------------------------------------------------------------------
section "Static: shellcheck (optional)"
if command -v shellcheck >/dev/null 2>&1; then
  for f in "${SCRIPTS[@]}"; do
    [[ -f "$f" ]] || continue
    if shellcheck -S warning "$f" >/dev/null 2>&1; then pass "shellcheck $f"; else fail "shellcheck $f"; fi
  done
else
  skip "shellcheck not installed"
fi

# ---------------------------------------------------------------------------
section "Static: authored skills have frontmatter"
for sk in niw-federal-evidence-harvester niw-future-endeavors; do
  f=".claude/skills/$sk/SKILL.md"
  if [[ -f "$f" ]] && grep -q '^name:' "$f" && grep -q '^description:' "$f"; then
    pass "frontmatter $sk"
  else
    fail "frontmatter $sk ($f missing or malformed)"
  fi
done

# ---------------------------------------------------------------------------
section "Static: settings.json is valid JSON"
if command -v python3 >/dev/null 2>&1; then
  if python3 -c 'import json,sys; json.load(open(".claude/settings.json"))' 2>/dev/null; then
    pass "settings.json parses"; else fail "settings.json invalid JSON"; fi
elif command -v plutil >/dev/null 2>&1; then
  if plutil -lint .claude/settings.json >/dev/null 2>&1; then pass "settings.json parses"; else fail "settings.json invalid"; fi
else
  skip "no JSON validator (python3/plutil) available"
fi

# ---------------------------------------------------------------------------
section "Build the launcher from source"
LAUNCHER="$TMP/niw-guru"
if sed "s|@NIW_GURU_HOME@|$ROOT|g" src/niw-guru.in > "$LAUNCHER" && chmod +x "$LAUNCHER"; then
  pass "built launcher from src/niw-guru.in"
  bash -n "$LAUNCHER" && pass "built launcher is syntactically valid" || fail "built launcher syntax"
  grep -q '@NIW_GURU_HOME@' "$LAUNCHER" && fail "placeholder not substituted" || pass "NIW_GURU_HOME baked in"
else
  fail "could not build launcher from src/niw-guru.in"; LAUNCHER=""
fi

section "Launcher behavior"
if [[ -z "${LAUNCHER:-}" || ! -x "$LAUNCHER" ]]; then
  skip "launcher not built — skipping behavior tests"
else
  "$LAUNCHER" -h >/dev/null 2>&1 && pass "niw-guru -h exits 0" || fail "niw-guru -h"
  ( "$LAUNCHER" >/dev/null 2>&1 ); [[ $? -eq 2 ]] && pass "no-arg exits 2" || fail "no-arg exit code"
  if "$LAUNCHER" -s examples/sample-run/input -o "$TMP/dry" --dry-run >/dev/null 2>&1; then
    pass "--dry-run exits 0"; else fail "--dry-run"; fi
fi

# ---------------------------------------------------------------------------
section "pdf-locate-quote.sh guards"
if command -v pdftotext >/dev/null 2>&1; then
  out="$("$LOCATE" README.md "anything" 2>/dev/null)"
  [[ "$out" == "not-a-pdf" ]] && pass "non-PDF input -> not-a-pdf" || fail "non-PDF input -> '$out' (want not-a-pdf)"
  out="$("$LOCATE" "$TMP/nope.pdf" "anything" 2>/dev/null)"
  [[ "$out" == "not-a-pdf" ]] && pass "missing file -> not-a-pdf" || fail "missing file -> '$out'"
else
  skip "pdftotext not installed"
fi

# ---------------------------------------------------------------------------
section "Offline render + locate round-trip (needs a renderer)"
if ! command -v pdftotext >/dev/null 2>&1; then
  skip "pdftotext not installed"
else
  FIX="$ROOT/tests/fixtures/locator.html"
  line="$("$FETCH" "file://$FIX" "$TMP/fix.pdf" 2>/dev/null || true)"
  status="$(printf '%s' "$line" | sed -n 's/.*STATUS=\([a-z-]*\).*/\1/p')"
  case "$status" in
    pdf|rendered)
      pass "fetch-to-pdf rendered file:// fixture ($status)"
      page="$("$LOCATE" "$TMP/fix.pdf" "niw guru offline locator fixture phrase alpha bravo" 2>/dev/null)"
      [[ "$page" =~ ^[0-9]+$ ]] && pass "pdf-locate-quote found phrase on page $page" \
                                 || fail "pdf-locate-quote returned '$page' (want a page number)"
      ;;
    *)
      skip "no HTML->PDF renderer (Chrome/Chromium/wkhtmltopdf) — render test skipped (status='$status')"
      ;;
  esac
fi

# ---------------------------------------------------------------------------
printf '\n----------------------------------------\n'
printf 'Results: \033[32m%d passed\033[0m, \033[31m%d failed\033[0m, \033[33m%d skipped\033[0m\n' "$PASS" "$FAIL" "$SKIP"
[[ $FAIL -eq 0 ]] && { echo "OK"; exit 0; } || { echo "FAILED"; exit 1; }
