#!/usr/bin/env bash
# read-references.sh — Read a Story or Task work item and expand its
# ### References section: fetches the full content of every referenced
# file section and concatenates them with source annotations.
#
# No character or line limit is applied when reading referenced sections
# (MAX_CHARS and MAX_LINES are overridden to effectively unlimited values).
#
# Epics are NOT supported — reading epic references via this script is
# prohibited. Use read-work-item.sh to inspect an epic body directly.
#
# Usage:
#   ./scripts/read-references.sh --story <id>    e.g. S-3
#   ./scripts/read-references.sh --task  <id>    e.g. T-7
#
# Exit codes:
#   0  Success
#   1  Invalid arguments or --epic used
#   2  Planning file not found (propagated from read-work-item.sh)
#   4  Work item ID not found (propagated from read-work-item.sh)
#   5  A referenced file was not found on disk

set -euo pipefail

# ---------------------------------------------------------------------------
# Resolve sibling scripts
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
READ_WORK_ITEM="$SCRIPT_DIR/read-work-item.sh"
READ_MD="$SCRIPT_DIR/read-md.sh"

# ---------------------------------------------------------------------------
# Exit codes
# ---------------------------------------------------------------------------
ERR_INVALID_ARGS=1
ERR_FILE_NOT_FOUND=2
ERR_ITEM_NOT_FOUND=4
ERR_REF_FILE_NOT_FOUND=5

# Effectively unlimited — override read-md.sh defaults
export MAX_CHARS=999999999
export MAX_LINES=9999999

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
  cat >&2 <<'EOF'
read-references.sh — Expand the ### References section of a Story or Task

Reads the work item, extracts each URL from ### References, then fetches
and concatenates the full content of each referenced section. Output is
annotated with the source reference. No size limit is applied.

Usage:
  ./scripts/read-references.sh --story <id>    e.g. S-3
  ./scripts/read-references.sh --task  <id>    e.g. T-7

Arguments:
  --story  Read a story from docs/03-planning/stories.md
  --task   Read a task from docs/03-planning/tasks.md

Note:
  --epic is explicitly not supported. Use read-work-item.sh for epics.

Exit codes:
  0  Success
  1  Invalid arguments or --epic used
  2  Planning file not found
  4  Work item ID not found
  5  A referenced file not found on disk

Examples:
  ./scripts/read-references.sh --story S-3
  ./scripts/read-references.sh --task  T-7
EOF
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
if [[ $# -lt 2 ]]; then
  usage
  exit $ERR_INVALID_ARGS
fi

flag="$1"
id="$2"

case "$flag" in
  --epic)
    echo "error: --epic is not supported by read-references.sh" >&2
    echo "       Use read-work-item.sh --epic $id to read an epic directly." >&2
    exit $ERR_INVALID_ARGS
    ;;
  --story|--task)
    ;;
  --help|-h)
    usage
    exit 0
    ;;
  *)
    echo "error: unrecognised flag '$flag'" >&2
    echo "" >&2
    usage
    exit $ERR_INVALID_ARGS
    ;;
esac

# Validate ID format
if [[ ! "$id" =~ ^[ST]-[0-9]+$ ]]; then
  echo "error: invalid ID format '$id' — expected S-N or T-N" >&2
  exit $ERR_INVALID_ARGS
fi

# Flag / ID type consistency check
if [[ "$flag" == "--story" && ! "$id" =~ ^S- ]]; then
  echo "error: --story expects an S-N id, got '$id'" >&2
  exit $ERR_INVALID_ARGS
fi
if [[ "$flag" == "--task" && ! "$id" =~ ^T- ]]; then
  echo "error: --task expects a T-N id, got '$id'" >&2
  exit $ERR_INVALID_ARGS
fi

# ---------------------------------------------------------------------------
# Step 1: Read the full work item
# ---------------------------------------------------------------------------
work_item_text=$("$READ_WORK_ITEM" "$flag" "$id")
wi_exit=$?

if [[ $wi_exit -eq 2 ]]; then
  exit $ERR_FILE_NOT_FOUND
elif [[ $wi_exit -eq 4 ]]; then
  exit $ERR_ITEM_NOT_FOUND
elif [[ $wi_exit -ne 0 ]]; then
  echo "error: read-work-item.sh exited with code $wi_exit" >&2
  exit $wi_exit
fi

# ---------------------------------------------------------------------------
# Step 2: Extract the ### References block
# ---------------------------------------------------------------------------
# Capture all lines matching "- [..." that appear after the "### References"
# heading, stopping at the next ## or ### heading (or EOF).
references_block=$(
  echo "$work_item_text" | awk '
    /^### References/ { in_refs=1; next }
    in_refs && /^##/ { exit }
    in_refs && /^- `/ { print }
  '
)

if [[ -z "$references_block" ]]; then
  echo "warning: no references found in work item $id" >&2
  exit 0
fi

# ---------------------------------------------------------------------------
# Step 3: Parse each reference line and fetch content
# ---------------------------------------------------------------------------
# Reference line format: - `Exact Heading Text` (`docs/path/to/file.md`)
# We need to extract: heading_text, file_path

any_error=0

while IFS= read -r ref_line; do
  # Skip blank lines
  [[ -z "$ref_line" ]] && continue

  # Match format: - `Heading Text` (`path/to/file.md`)
  # Use sed to extract: first backtick-quoted token = heading, second = file path
  heading_text=$(echo "$ref_line" | sed -n 's/^- `\([^`]*\)`.*/\1/p')
  file_path=$(echo "$ref_line" | sed -n 's/^- `[^`]*` (`\([^`]*\)`)/\1/p')

  if [[ -z "$heading_text" || -z "$file_path" ]]; then
    # Skip lines that don't match the expected format
    continue
  fi

  # Resolve to absolute path
  abs_file_path="$REPO_ROOT/$file_path"

  # Verify file exists
  if [[ ! -f "$abs_file_path" ]]; then
    echo "error: referenced file not found: $file_path" >&2
    any_error=$ERR_REF_FILE_NOT_FOUND
    continue
  fi

  # Print annotation header
  echo ""
  echo "=== ${heading_text} (${file_path}) ==="
  echo ""

  # Fetch section content: three-step fallback chain
  # 1. Exact match — heading text copied verbatim from TOC
  section_content=$(
    "$READ_MD" section "$abs_file_path" "$heading_text" \
      --exact \
      --with-subsections \
      2>/dev/null
  ) || true

  if [[ -z "$section_content" ]]; then
    # 2. Grep match — useful for headings with special chars (em-dashes etc.)
    section_content=$(
      "$READ_MD" section "$abs_file_path" "$heading_text" \
        --grep \
        --with-subsections \
        2>/dev/null
    ) || true
  fi

  if [[ -z "$section_content" ]]; then
    # 3. Fuzzy match via fzf
    section_content=$(
      "$READ_MD" section "$abs_file_path" "$heading_text" \
        --with-subsections \
        2>/dev/null
    ) || true
  fi

  if [[ -z "$section_content" ]]; then
    echo "(warning: could not locate section '${heading_text}' in $file_path)" >&2
  else
    echo "$section_content"
  fi

  echo ""
  echo "=== end: ${heading_text} ==="
  echo ""

done <<< "$references_block"

# ---------------------------------------------------------------------------
# Exit
# ---------------------------------------------------------------------------
if [[ $any_error -ne 0 ]]; then
  exit $ERR_REF_FILE_NOT_FOUND
fi

exit 0
