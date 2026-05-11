#!/usr/bin/env bash
# =============================================================================
# version.sh — Variance version manager
# =============================================================================
#
# DESCRIPTION
#   Reads, bumps, and tags the project version stored in ./version (repo root).
#   That file is the single source of truth for the current semver string and
#   is consumed by scripts, CI, and documentation tooling.
#
#   The version format is:  MAJOR.MINOR.PATCH[-TAG]
#   Examples:               1.2.3   /   0.4.0-beta   /   2.0.0-rc1
#
# USAGE
#   scripts/version.sh [--major] [--minor] [--patch] [--tag <string>] [--no-tag]
#   scripts/version.sh --help
#
# FLAGS
#   --major          Increment the MAJOR component by 1.
#                    Resets MINOR and PATCH to 0.
#                    Any existing tag is cleared unless --tag is also passed.
#
#   --minor          Increment the MINOR component by 1.
#                    Resets PATCH to 0.
#                    Any existing tag is cleared unless --tag is also passed.
#
#   --patch          Increment the PATCH component by 1.
#                    Any existing tag is cleared unless --tag is also passed.
#
#   --tag <string>   Append -<string> as a pre-release / build tag.
#                    Can be combined with a bump flag to bump and tag in one
#                    step (e.g. --minor --tag beta -> 0.3.0 becomes 0.4.0-beta).
#                    If used alone (no bump flag) it replaces or sets the tag
#                    on the current version without changing the numbers.
#
#   --no-tag         Remove the tag from the current version without changing
#                    the version numbers. No-op if there is no existing tag.
#                    Mutually exclusive with --tag.
#
#   --help, -h       Print this help message and exit.
#
# BUMP PRECEDENCE
#   When multiple bump flags are supplied, only the highest-precedence one
#   takes effect:  --major > --minor > --patch
#
# TAG RULES
#   - If a bump flag is provided without --tag, any existing tag is cleared.
#   - If --tag is provided (with or without a bump flag), the new tag is set.
#   - If --no-tag is provided, the tag is removed.
#   - If neither a bump flag nor a tag flag is provided, the version is
#     unchanged and the script exits with "Version unchanged".
#
# EXAMPLES
#   # Bump the patch component:        0.3.0 -> 0.3.1
#   scripts/version.sh --patch
#
#   # Bump minor, clear tag:           0.3.1-beta -> 0.4.0
#   scripts/version.sh --minor
#
#   # Bump major with a tag:           0.4.0 -> 1.0.0-rc1
#   scripts/version.sh --major --tag rc1
#
#   # Add a tag without bumping:       1.0.0 -> 1.0.0-hotfix
#   scripts/version.sh --tag hotfix
#
#   # Clear tag without bumping:       1.0.0-hotfix -> 1.0.0
#   scripts/version.sh --no-tag
#
# FILES
#   ./version   Plain-text file at the repo root containing only the semver
#               string with no trailing newline. This script always writes
#               without a trailing newline so the file stays clean.
#
# EXIT CODES
#   0   Success (version written, or version already at target state)
#   1   Usage error or missing/corrupt version file
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/../version"

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------
help() {
  awk 'NR==1{next} /^#/{sub(/^# ?/, ""); print; next} {exit}' "$0"
  exit 0
}

# ---------------------------------------------------------------------------
# Pre-flight: verify version file
# ---------------------------------------------------------------------------
if [[ ! -f "$VERSION_FILE" ]]; then
  echo "Error: version file not found at $VERSION_FILE" >&2
  exit 1
fi

current="$(cat "$VERSION_FILE")"

# Parse current version: major.minor.patch[-tag]
if [[ "$current" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)(-(.+))?$ ]]; then
  major="${BASH_REMATCH[1]}"
  minor="${BASH_REMATCH[2]}"
  patch="${BASH_REMATCH[3]}"
  current_tag="${BASH_REMATCH[5]:-}"
else
  echo "Error: version file contains invalid semver: '$current'" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
bump_major=0
bump_minor=0
bump_patch=0
new_tag=""
clear_tag=0
tag_provided=0

# ---------------------------------------------------------------------------
# Usage (short form printed on error)
# ---------------------------------------------------------------------------
usage() {
  echo "Usage: $(basename "$0") [--major] [--minor] [--patch] [--tag <string>] [--no-tag]" >&2
  echo "Run '$(basename "$0") --help' for full documentation." >&2
  exit 1
}

if [[ $# -eq 0 ]]; then
  usage
fi

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      help
      ;;
    --major)
      bump_major=1
      shift
      ;;
    --minor)
      bump_minor=1
      shift
      ;;
    --patch)
      bump_patch=1
      shift
      ;;
    --tag)
      if [[ $# -lt 2 || -z "$2" ]]; then
        echo "Error: --tag requires a non-empty string value" >&2
        exit 1
      fi
      new_tag="$2"
      tag_provided=1
      shift 2
      ;;
    --no-tag)
      clear_tag=1
      shift
      ;;
    *)
      echo "Error: unknown flag '$1'" >&2
      usage
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------
if [[ $clear_tag -eq 1 && $tag_provided -eq 1 ]]; then
  echo "Error: --tag and --no-tag are mutually exclusive" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Apply version bumps (precedence: major > minor > patch)
# ---------------------------------------------------------------------------
if [[ $bump_major -eq 1 ]]; then
  major=$((major + 1))
  minor=0
  patch=0
elif [[ $bump_minor -eq 1 ]]; then
  minor=$((minor + 1))
  patch=0
elif [[ $bump_patch -eq 1 ]]; then
  patch=$((patch + 1))
fi

# ---------------------------------------------------------------------------
# Determine final tag
# ---------------------------------------------------------------------------
final_tag=""
if [[ $tag_provided -eq 1 ]]; then
  # Explicit tag always wins
  final_tag="$new_tag"
elif [[ $clear_tag -eq 1 ]]; then
  # Explicit clear
  final_tag=""
elif [[ $bump_major -eq 1 || $bump_minor -eq 1 || $bump_patch -eq 1 ]]; then
  # Version bumped without a tag instruction — clear any pre-release tag
  final_tag=""
else
  # No bump, no tag instruction — preserve whatever was there
  final_tag="$current_tag"
fi

# ---------------------------------------------------------------------------
# Assemble and write new version
# ---------------------------------------------------------------------------
new_version="$major.$minor.$patch"
if [[ -n "$final_tag" ]]; then
  new_version="$new_version-$final_tag"
fi

if [[ "$new_version" == "$current" ]]; then
  echo "Version unchanged: $current"
  exit 0
fi

printf '%s' "$new_version" > "$VERSION_FILE"
echo "$current -> $new_version"

# ---------------------------------------------------------------------------
# Sync pubspec.yaml and commit
# ---------------------------------------------------------------------------
SYNC_SCRIPT="$SCRIPT_DIR/sync-version.sh"
if [[ ! -x "$SYNC_SCRIPT" ]]; then
  echo "warning: sync-version.sh not found or not executable — pubspec.yaml not updated" >&2
else
  "$SYNC_SCRIPT"
fi

git add "$VERSION_FILE" "$SCRIPT_DIR/../pubspec.yaml"
git commit -m "$(cat <<EOF
chore(release): bump to v${new_version}

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
echo "committed: chore(release): bump to v${new_version}"
