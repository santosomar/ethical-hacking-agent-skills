#!/usr/bin/env bash
# validate.sh — Nuclei template validation helper
#
# Usage:
#   ./validate.sh <template.yaml>            Validate a single template
#   ./validate.sh <directory/>               Validate all templates in a directory
#   ./validate.sh -u https://host <tpl.yaml> Validate + dry-run against a host
#
# Requirements: nuclei v3+ on PATH

set -euo pipefail

TEMPLATE="${1:-}"
TARGET_HOST=""
DRY_RUN=false

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--url)
      TARGET_HOST="$2"
      DRY_RUN=true
      shift 2
      ;;
    -h|--help)
      sed -n '2,10p' "$0" | sed 's/^# //'
      exit 0
      ;;
    *)
      TEMPLATE="$1"
      shift
      ;;
  esac
done

# ── Preflight ──────────────────────────────────────────────────────────────────

if [[ -z "$TEMPLATE" ]]; then
  echo "ERROR: No template path provided." >&2
  echo "Usage: $0 <template.yaml|directory/> [-u https://host]" >&2
  exit 1
fi

if ! command -v nuclei &>/dev/null; then
  echo "ERROR: 'nuclei' not found on PATH." >&2
  echo "Install: go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest" >&2
  exit 1
fi

NUCLEI_VERSION=$(nuclei -version 2>&1 | head -1)
echo "nuclei: $NUCLEI_VERSION"
echo ""

# ── Static validation ──────────────────────────────────────────────────────────

echo "=== Static validation: $TEMPLATE ==="
if nuclei -t "$TEMPLATE" -validate 2>&1; then
  echo "PASS: no schema errors"
else
  echo "FAIL: schema or syntax errors detected (see above)"
  exit 1
fi
echo ""

# ── Lint checks (heuristic, no network) ───────────────────────────────────────

echo "=== Lint checks ==="
ISSUES=0

check_file() {
  local file="$1"

  # Check for deprecated 'requests:' key
  if grep -q '^requests:' "$file" 2>/dev/null; then
    echo "  WARN [$file] Uses deprecated 'requests:' key — replace with 'http:'"
    ISSUES=$((ISSUES + 1))
  fi

  # Check for missing max-request metadata
  if ! grep -q 'max-request:' "$file" 2>/dev/null; then
    echo "  WARN [$file] Missing metadata.max-request — add the correct request count"
    ISSUES=$((ISSUES + 1))
  fi

  # Check for overly generic id
  local id
  id=$(grep '^id:' "$file" | head -1 | awk '{print $2}')
  if [[ "$id" =~ ^(test|vuln|template|scan|check)$ ]]; then
    echo "  WARN [$file] Generic template id '$id' — use vendor-product-issue format"
    ISSUES=$((ISSUES + 1))
  fi

  # Check that id matches filename (basename without extension)
  local filename
  filename=$(basename "$file" .yaml)
  if [[ "$id" != "$filename" ]]; then
    echo "  WARN [$file] id '$id' does not match filename '$filename'"
    ISSUES=$((ISSUES + 1))
  fi

  # Check for missing severity
  if ! grep -q 'severity:' "$file" 2>/dev/null; then
    echo "  WARN [$file] Missing info.severity"
    ISSUES=$((ISSUES + 1))
  fi

  # Check for missing author
  if ! grep -q 'author:' "$file" 2>/dev/null; then
    echo "  WARN [$file] Missing info.author"
    ISSUES=$((ISSUES + 1))
  fi

  # Warn if matchers-condition is absent but multiple matchers are defined
  local matcher_count
  matcher_count=$(
    awk '
      function indent_level(line) {
        match(line, /^[[:space:]]*/)
        return RLENGTH
      }

      {
        if ($0 ~ /^[[:space:]]*matchers:[[:space:]]*$/) {
          in_matchers = 1
          matchers_indent = indent_level($0)
          next
        }

        if (in_matchers) {
          if ($0 ~ /^[[:space:]]*$/) {
            next
          }

          current_indent = indent_level($0)
          if (current_indent <= matchers_indent && $0 !~ /^[[:space:]]*-/) {
            in_matchers = 0
          }
        }

        if (in_matchers && $0 ~ /^[[:space:]]*-[[:space:]]*type:[[:space:]]*/) {
          count++
        }
      }

      END {
        print count + 0
      }
    ' "$file" 2>/dev/null || true
  )
  if [[ "$matcher_count" -gt 1 ]] && ! grep -q 'matchers-condition:' "$file" 2>/dev/null; then
    echo "  WARN [$file] Multiple matchers but no 'matchers-condition' — defaulting to OR (may cause false positives)"
    ISSUES=$((ISSUES + 1))
  fi
}

if [[ -d "$TEMPLATE" ]]; then
  while IFS= read -r -d '' f; do
    check_file "$f"
  done < <(find "$TEMPLATE" -name '*.yaml' -print0)
else
  check_file "$TEMPLATE"
fi

if [[ "$ISSUES" -eq 0 ]]; then
  echo "  PASS: no lint issues"
else
  echo "  $ISSUES lint issue(s) found"
fi
echo ""

# ── Dry-run against target host ────────────────────────────────────────────────

if [[ "$DRY_RUN" == "true" ]]; then
  if [[ -z "$TARGET_HOST" ]]; then
    echo "ERROR: -u flag requires a target URL" >&2
    exit 1
  fi
  echo "=== Dry-run: $TEMPLATE against $TARGET_HOST ==="
  echo "(Full request/response debug output follows)"
  echo ""
  nuclei -t "$TEMPLATE" -u "$TARGET_HOST" -debug -stats
fi

echo ""
echo "Done."
