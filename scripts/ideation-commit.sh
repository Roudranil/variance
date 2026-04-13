#!/usr/bin/env bash
# =============================================================================
# ideation-commit.sh — Variance ideation phase commit helper
# =============================================================================
#
# DESCRIPTION
#   Stages all modified files inside the ideation docs folders (docs/01 through
#   docs/06) and creates a single git commit with a standardised message that
#   includes the current project version and an optional diff summary.
#
#   This script is the canonical way to commit ideation-phase documentation
#   changes so that every commit follows the same format and is traceable back
#   to a version stamp.
#
# USAGE
#   scripts/ideation-commit.sh <commit-title>
#   scripts/ideation-commit.sh --help
#
# ARGUMENTS
#   <commit-title>   A short, imperative-mood description of the change.
#                    Wrap in quotes if it contains spaces.
#                    Example: "resolve Q45 through Q50 in PRD"
#
# COMMIT MESSAGE FORMAT
#   The generated commit message follows this template:
#
#     ideation: <commit-title>. bump to v<version>
#
#     <contents of docs/06-helpers/ideation-diff.md>
#
#   The body (ideation-diff.md) is included only if the file exists and is
#   non-empty. If the file does not exist the commit message is header-only.
#
# SCANNED FOLDERS
#   The script checks for changes (both staged and unstaged tracked/untracked
#   modifications) in the following paths relative to the repo root:
#
#     docs/01-product/
#     docs/02-technical/
#     docs/03-planning/
#     docs/04-implementation/
#     docs/05-quality/
#     docs/06-helpers/
#
#   If none of these folders contain any changes the script exits with a
#   non-zero status and prints an informational message — nothing is committed.
#
# DIFF FILE
#   docs/06-helpers/ideation-diff.md is an optional companion file. When it
#   exists its full contents are appended as the commit body. It is intended to
#   hold a human-readable summary of what changed in this ideation session
#   (decisions made, questions resolved, doc sections updated, etc.).
#
#   The file is NOT automatically cleared after the commit — update or clear it
#   manually between sessions as needed.
#
# VERSION SOURCE
#   The version string is read from ./version at the repo root. That file is
#   the single source of truth for the project version. Use version.sh to
#   bump the version before committing if this commit represents a version
#   change.
#
# EXAMPLES
#   # Simple commit with just a title:
#   scripts/ideation-commit.sh "add UX flows for onboarding wizard"
#
#   # Commit after writing ideation-diff.md:
#   echo "Resolved Q71–Q76. All PRD questions closed." > docs/06-helpers/ideation-diff.md
#   scripts/ideation-commit.sh "close all remaining PRD open questions"
#
#   # Bump version first, then commit:
#   scripts/version.sh --minor
#   scripts/ideation-commit.sh "PRD v0.4.0 — SDS pre-work complete"
#
# FILES
#   ./version                          Project version (read-only by this script)
#   docs/06-helpers/ideation-diff.md   Optional commit body (read-only)
#
# EXIT CODES
#   0   Commit created successfully
#   1   Usage error, missing version file, or no ideation changes found
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="$REPO_ROOT/version"
DIFF_FILE="$REPO_ROOT/docs/06-helpers/ideation-diff.md"

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------
help() {
  awk 'NR==1{next} /^#/{sub(/^# ?/, ""); print; next} {exit}' "$0"
  exit 0
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
if [[ $# -eq 0 ]]; then
  echo "Error: commit title is required." >&2
  echo "Usage: $(basename "$0") <commit-title>" >&2
  echo "Run '$(basename "$0") --help' for full documentation." >&2
  exit 1
fi

case "$1" in
  --help|-h) help ;;
esac

title="$1"

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
if [[ ! -f "$VERSION_FILE" ]]; then
  echo "Error: version file not found at $VERSION_FILE" >&2
  exit 1
fi

version="$(cat "$VERSION_FILE")"

# ---------------------------------------------------------------------------
# Collect changes in ideation folders
# ---------------------------------------------------------------------------
ideation_paths=(
  "docs/01-product"
  "docs/02-technical"
  "docs/03-planning"
  "docs/04-implementation"
  "docs/05-quality"
  "docs/06-helpers"
)

cd "$REPO_ROOT"

changed_files=()
for path in "${ideation_paths[@]}"; do
  if [[ -d "$path" ]]; then
    while IFS= read -r file; do
      [[ -n "$file" ]] && changed_files+=("$file")
    done < <(git status --porcelain "$path" 2>/dev/null | awk '{print $2}')
  fi
done

if [[ ${#changed_files[@]} -eq 0 ]]; then
  echo "No changes found in ideation folders (docs/01 through docs/06). Nothing to commit." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Stage files
# ---------------------------------------------------------------------------
echo "Staging ${#changed_files[@]} file(s):"
for f in "${changed_files[@]}"; do
  echo "  $f"
done
echo ""

git add "${changed_files[@]}"

# ---------------------------------------------------------------------------
# Build commit message
# ---------------------------------------------------------------------------
diff_body=""
if [[ -f "$DIFF_FILE" ]]; then
  diff_body="$(cat "$DIFF_FILE")"
fi

commit_message="ideation: $title. bump to v$version"
if [[ -n "$diff_body" ]]; then
  commit_message="$commit_message

$diff_body"
fi

# ---------------------------------------------------------------------------
# Commit
# ---------------------------------------------------------------------------
git commit -m "$commit_message"

echo ""
echo "Committed: ideation: $title. bump to v$version"
