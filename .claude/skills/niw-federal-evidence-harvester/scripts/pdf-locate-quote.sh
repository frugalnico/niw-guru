#!/usr/bin/env bash
#
# pdf-locate-quote.sh <pdf> "<quote or distinctive phrase>"
#
# Print the 1-based PDF page number where the phrase first appears. Matching is
# whitespace-collapsed, lowercased, and punctuation-insensitive, so quotes that
# wrap across lines or differ in curly/straight quotes still match. To survive
# small wording differences it also retries with the first ~12 words.
#
# Output (one token on stdout):
#   <page-number> | not-found | not-a-pdf | no-pdftotext
# Use it to fill the "PDF p. N" location in national_importance_quotes.md.

set -uo pipefail

PDF="${1:-}"
QUOTE="${2:-}"

if [[ -z "$PDF" || -z "$QUOTE" ]]; then
  echo "usage: pdf-locate-quote.sh <pdf> \"<quote>\"" >&2
  echo "not-found"; exit 2
fi
if ! command -v pdftotext >/dev/null 2>&1 || ! command -v pdfinfo >/dev/null 2>&1; then
  echo "no-pdftotext"; exit 0
fi
if ! head -c 5 "$PDF" 2>/dev/null | grep -q '%PDF'; then
  echo "not-a-pdf"; exit 0
fi

# Normalize: lowercase, non-alphanumeric -> space, collapse spaces.
normalize() { tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' ' ' | tr -s ' '; }

NEEDLE_FULL="$(printf '%s' "$QUOTE" | normalize | sed 's/^ //; s/ $//')"
# A shorter, distinctive needle = first 12 normalized words.
NEEDLE_SHORT="$(printf '%s' "$NEEDLE_FULL" | cut -d' ' -f1-12)"

PAGES="$(pdfinfo "$PDF" 2>/dev/null | awk '/^Pages:/{print $2}')"
[[ -z "${PAGES:-}" ]] && { echo "not-a-pdf"; exit 0; }

search() {
  local needle="$1" p hay
  [[ -z "$needle" ]] && return 1
  for ((p=1; p<=PAGES; p++)); do
    hay="$(pdftotext -layout -f "$p" -l "$p" "$PDF" - 2>/dev/null | normalize)"
    if printf '%s' "$hay" | grep -qF "$needle"; then
      echo "$p"; return 0
    fi
  done
  return 1
}

search "$NEEDLE_FULL" && exit 0
search "$NEEDLE_SHORT" && exit 0
echo "not-found"
