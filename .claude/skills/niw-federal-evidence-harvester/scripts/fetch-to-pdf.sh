#!/usr/bin/env bash
#
# fetch-to-pdf.sh <url> <outfile.pdf>
#
# Capture a web source as a PDF on disk.
#   - Direct PDF link  -> download with curl.
#   - HTML page        -> render to PDF with headless Chrome/Chromium/Edge/Brave,
#                         falling back to wkhtmltopdf.
#   - If no renderer   -> save readable text (.txt) and report text-only.
#
# Prints exactly one status line to stdout (parse this):
#   STATUS=pdf|rendered|text-only|failed  FILE=<path-written>
# Diagnostics go to stderr.

set -uo pipefail

URL="${1:-}"
OUT="${2:-}"

if [[ -z "$URL" || -z "$OUT" ]]; then
  echo "usage: fetch-to-pdf.sh <url> <outfile.pdf>" >&2
  echo "STATUS=failed FILE="
  exit 2
fi

# Absolutize OUT (Chrome --print-to-pdf needs an absolute path) and ensure dir.
mkdir -p "$(dirname "$OUT")"
case "$OUT" in
  /*) : ;;
  *)  OUT="$(pwd)/$OUT" ;;
esac

UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"

is_pdf() { [[ -s "$1" ]] && head -c 5 "$1" 2>/dev/null | grep -q '%PDF'; }

emit() { echo "STATUS=$1 FILE=$2"; exit 0; }

# Run a command under a wall-clock cap so a stuck renderer/download can never hang.
# Uses `timeout`/`gtimeout` if present; otherwise a pure-bash watchdog (macOS ships neither).
run_capped() { # run_capped <seconds> <cmd...>
  local secs="$1"; shift
  if   command -v timeout  >/dev/null 2>&1; then timeout  "$secs" "$@"; return $?
  elif command -v gtimeout >/dev/null 2>&1; then gtimeout "$secs" "$@"; return $?
  fi
  "$@" &
  local cmd_pid=$!
  ( sleep "$secs"; kill -TERM "$cmd_pid" 2>/dev/null; sleep 2; kill -KILL "$cmd_pid" 2>/dev/null ) &
  local wd_pid=$!
  wait "$cmd_pid" 2>/dev/null; local rc=$?
  kill -TERM "$wd_pid" 2>/dev/null; wait "$wd_pid" 2>/dev/null
  return $rc
}

# ---------------------------------------------------------------------------
# 1) Is it (or does it serve) a PDF? Try a direct download.
# ---------------------------------------------------------------------------
ctype="$(curl -sIL --max-time 40 -A "$UA" "$URL" 2>/dev/null | tr -d '\r' | awk -F': ' 'tolower($1)=="content-type"{print tolower($2)}' | tail -1)"
looks_pdf=0
[[ "$ctype" == *application/pdf* ]] && looks_pdf=1
case "${URL%%\?*}" in *.pdf|*.PDF) looks_pdf=1 ;; esac

if [[ $looks_pdf -eq 1 ]]; then
  # Try curl, then wget, as direct downloaders.
  if curl -sL --fail --max-time 120 -A "$UA" -o "$OUT" "$URL" 2>/dev/null && is_pdf "$OUT"; then
    emit pdf "$OUT"
  fi
  if command -v wget >/dev/null 2>&1; then
    run_capped 120 wget -q -U "$UA" -O "$OUT" "$URL" 2>/dev/null || true
    is_pdf "$OUT" && emit pdf "$OUT"
  fi
  # A real PDF URL won't render as HTML — don't waste a browser on it; fall to text capture.
  echo "fetch-to-pdf: PDF download failed (host blocked or moved). Capturing text instead…" >&2
  rm -f "$OUT" 2>/dev/null || true
  TXT="${OUT%.pdf}.txt"
  if curl -sL --fail --max-time 90 -A "$UA" "$URL" 2>/dev/null | pdftotext -q - "$TXT" 2>/dev/null && [[ -s "$TXT" ]]; then
    emit text-only "$TXT"
  fi
  emit failed ""
fi

# ---------------------------------------------------------------------------
# 2) Render HTML -> PDF with a headless browser.
# ---------------------------------------------------------------------------
find_chrome() {
  local c
  for c in google-chrome google-chrome-stable chromium chromium-browser brave-browser microsoft-edge; do
    command -v "$c" >/dev/null 2>&1 && { echo "$c"; return 0; }
  done
  for c \
    in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
       "/Applications/Chromium.app/Contents/MacOS/Chromium" \
       "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
       "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"; do
    [[ -x "$c" ]] && { echo "$c"; return 0; }
  done
  return 1
}

CHROME="$(find_chrome || true)"
if [[ -n "$CHROME" ]]; then
  TMPPROF="$(mktemp -d 2>/dev/null || echo /tmp/niw-chrome-$$)"
  run_capped 60 "$CHROME" --headless=new --disable-gpu --no-sandbox --no-first-run --no-default-browser-check \
    --hide-scrollbars --user-agent="$UA" --user-data-dir="$TMPPROF" \
    --virtual-time-budget=15000 --run-all-compositor-stages-before-draw \
    --print-to-pdf-no-header --print-to-pdf="$OUT" "$URL" >/dev/null 2>&1 || true
  rm -rf "$TMPPROF" 2>/dev/null || true
  is_pdf "$OUT" && emit rendered "$OUT"
  echo "fetch-to-pdf: headless browser render failed, trying wkhtmltopdf…" >&2
fi

if command -v wkhtmltopdf >/dev/null 2>&1; then
  run_capped 60 wkhtmltopdf -q "$URL" "$OUT" >/dev/null 2>&1 || true
  is_pdf "$OUT" && emit rendered "$OUT"
  echo "fetch-to-pdf: wkhtmltopdf failed, falling back to text…" >&2
fi

# ---------------------------------------------------------------------------
# 3) Last resort: save readable text so the source is still captured.
# ---------------------------------------------------------------------------
TXT="${OUT%.pdf}.txt"
if curl -sL --fail --max-time 90 -A "$UA" "$URL" 2>/dev/null \
     | sed -e 's/<script[^>]*>.*<\/script>//gI' \
           -e 's/<style[^>]*>.*<\/style>//gI' \
           -e 's/<[^>]*>/ /g' \
           -e 's/&nbsp;/ /g' -e 's/&amp;/\&/g' -e 's/&#39;/'"'"'/g' -e 's/&quot;/"/g' \
     | tr -s ' \t' ' ' > "$TXT" 2>/dev/null && [[ -s "$TXT" ]]; then
  echo "fetch-to-pdf: saved text only (no PDF renderer available). Install Chrome or wkhtmltopdf for PDFs." >&2
  emit text-only "$TXT"
fi

emit failed ""
