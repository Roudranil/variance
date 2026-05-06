#!/usr/bin/env bash
# read-work-item.sh — Read a single work item by ID from the appropriate
# planning file in docs/03-planning/.
#
# Uses read-md.sh internally to extract the full work item content
# (all subsections) via grep-based section matching.
#
# Usage:
#   ./scripts/read-work-item.sh --epic  <id>    e.g. E-1
#   ./scripts/read-work-item.sh --story <id>    e.g. S-3
#   ./scripts/read-work-item.sh --task  <id>    e.g. T-7
#
# Exit codes:
#   0  Success
#   1  Invalid arguments (missing or unrecognised flag, missing ID)
#   2  Planning file not found
#   4  Work item ID not found in file

set -euo pipefail

# ---------------------------------------------------------------------------
# Resolve script directory so we can call sibling scripts regardless of cwd
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
READ_MD="$SCRIPT_DIR/read-md.sh"

# ---------------------------------------------------------------------------
# Exit codes
# ---------------------------------------------------------------------------
ERR_INVALID_ARGS=1
ERR_FILE_NOT_FOUND=2
ERR_ITEM_NOT_FOUND=4

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
  cat >&2 <<'EOF'
read-work-item.sh — Read a work item from docs/03-planning/

Usage:
  ./scripts/read-work-item.sh --epic  <id>    e.g. E-1
  ./scripts/read-work-item.sh --story <id>    e.g. S-3
  ./scripts/read-work-item.sh --task  <id>    e.g. T-7

Arguments:
  --epic   Read from docs/03-planning/epics.md
  --story  Read from docs/03-planning/stories.md
  --task   Read from docs/03-planning/tasks.md
  <id>     Work item ID (e.g. E-1, S-3, T-7)

Exit codes:
  0  Success
  1  Invalid arguments
  2  Planning file not found
  4  Work item ID not found in file

Examples:
  ./scripts/read-work-item.sh --epic  E-1
  ./scripts/read-work-item.sh --story S-3
  ./scripts/read-work-item.sh --task  T-7
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

# Determine target file based on flag
case "$flag" in
  --epic)
    planning_file="docs/03-planning/epics.md"
    ;;
  --story)
    planning_file="docs/03-planning/stories.md"
    ;;
  --task)
    planning_file="docs/03-planning/tasks.md"
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

# Validate ID looks plausible (E-N, S-N, T-N where N is one or more digits)
if [[ ! "$id" =~ ^[EST]-[0-9]+$ ]]; then
  echo "error: invalid ID format '$id' — expected E-N, S-N, or T-N" >&2
  exit $ERR_INVALID_ARGS
fi

# ---------------------------------------------------------------------------
# Resolve planning file path relative to repo root
# ---------------------------------------------------------------------------
# The scripts/ directory is one level below the repo root
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
abs_file="$REPO_ROOT/$planning_file"

if [[ ! -f "$abs_file" ]]; then
  echo "error: planning file not found: $planning_file" >&2
  exit $ERR_FILE_NOT_FOUND
fi

# ---------------------------------------------------------------------------
# Extract the work item
# ---------------------------------------------------------------------------
# Work item headings follow the format:  ## E-1 — Title
# We grep for the heading line anchored at the start of the line.
# --with-subsections ensures all ### subsections are included in the output.
grep_pattern="^## ${id} "

"$READ_MD" section "$abs_file" "$id" --grep "$grep_pattern" --with-subsections
exit_code=$?

# read-md.sh exit code 4 means section not found — propagate as our exit 4
if [[ $exit_code -eq 4 ]]; then
  echo "error: work item '$id' not found in $planning_file" >&2
  exit $ERR_ITEM_NOT_FOUND
fi

exit $exit_code
