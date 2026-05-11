#!/usr/bin/env bash
# release.sh — Cut a Variance release.
#
# Reads the canonical version from ./version, creates an annotated git tag
# (v<version>), and pushes the commit + tag to origin. Pushing the tag
# triggers the release workflow in .github/workflows/release.yml which
# builds the APK and creates the GitHub release automatically.
#
# Must be run after version.sh has already bumped the version and committed.
# Aborts if there are uncommitted changes (dirty working tree).
#
# Usage:
#   ./scripts/release.sh
#
# What it does:
#   1. Reads ./version
#   2. Checks the working tree is clean
#   3. Verifies the current commit message starts with "chore(release): bump to v<version>"
#   4. Creates annotated tag v<version>
#   5. Pushes branch + tag to origin → triggers CD
#
# Exit codes:
#   0  Success
#   1  Error (dirty tree, version mismatch, tag already exists, push failed)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="$REPO_ROOT/version"

if [[ ! -f "$VERSION_FILE" ]]; then
  echo "error: version file not found: $VERSION_FILE" >&2
  exit 1
fi

version=$(tr -d '[:space:]' < "$VERSION_FILE")
tag="v${version}"

# ---------------------------------------------------------------------------
# 1. Clean working tree
# ---------------------------------------------------------------------------
if [[ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]]; then
  echo "error: working tree is dirty — commit or stash changes before releasing" >&2
  git -C "$REPO_ROOT" status --short >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# 2. Verify HEAD commit is a version bump commit for this version
# ---------------------------------------------------------------------------
head_msg=$(git -C "$REPO_ROOT" log -1 --format="%s")
expected_prefix="chore(release): bump to v${version}"
if [[ "$head_msg" != "$expected_prefix"* ]]; then
  echo "error: HEAD commit is not a version bump for v${version}" >&2
  echo "  expected: ${expected_prefix}" >&2
  echo "  found:    ${head_msg}" >&2
  echo "" >&2
  echo "Run scripts/version.sh --patch (or --minor / --major) first." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# 3. Tag must not already exist
# ---------------------------------------------------------------------------
if git -C "$REPO_ROOT" rev-parse "$tag" &>/dev/null; then
  echo "error: tag ${tag} already exists" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# 4. Create annotated tag
# ---------------------------------------------------------------------------
git -C "$REPO_ROOT" tag -a "$tag" -m "Release ${tag}"
echo "tagged: ${tag}"

# ---------------------------------------------------------------------------
# 5. Push branch + tag — this triggers the release workflow
# ---------------------------------------------------------------------------
git -C "$REPO_ROOT" push origin HEAD
git -C "$REPO_ROOT" push origin "$tag"
echo "pushed: ${tag} → origin"
echo ""
echo "CD triggered. Monitor at: https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | sed 's/.*github.com[:/]\(.*\)/\1/')/actions"
