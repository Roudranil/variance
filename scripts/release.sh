#!/usr/bin/env bash
# release.sh — Cut a Variance release.
#
# Reads the canonical version from ./version, runs the full local test suite
# (unit, widget, integration), and — only if everything passes — creates an
# annotated git tag and pushes it to origin. Pushing the tag triggers the
# release workflow in .github/workflows/release.yml which builds the APK and
# creates the GitHub release automatically.
#
# Must be run after version.sh has already bumped the version and committed.
# Aborts if there are uncommitted changes (dirty working tree).
#
# On any test failure, a human-readable report is written to
# release-failure.md at the repo root and the script exits non-zero.
# release-failure.md is gitignored — it is for local diagnosis only.
#
# Usage:
#   ./scripts/release.sh
#
# What it does:
#   1. Reads ./version
#   2. Checks the working tree is clean
#   3. Verifies HEAD is a version-bump commit for this version
#   4. Runs: dart format check
#   5. Runs: flutter analyze
#   6. Runs: domain purity check (make domain-check)
#   7. Runs: flutter test  (unit + widget)
#   8. Runs: flutter test integration_test/  (if the directory exists)
#   9. Creates annotated tag v<version>
#  10. Pushes branch + tag → triggers CD
#
# On failure at steps 4-8: writes release-failure.md and exits 1.
#
# Exit codes:
#   0  Success — tag pushed, CD triggered
#   1  Pre-flight or test failure

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="$REPO_ROOT/version"
FAILURE_REPORT="$REPO_ROOT/release-failure.md"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

# Write failure report and exit.
# Usage: fail_with_report <stage> <output>
fail_with_report() {
  local stage="$1"
  local output="$2"
  local version="${version:-unknown}"
  local ts
  ts=$(timestamp)

  cat > "$FAILURE_REPORT" <<EOF
# Release Failure Report

**Version:** ${version}
**Stage:** ${stage}
**Time:** ${ts}

## What failed

\`${stage}\` did not pass. The release was aborted before tagging or pushing.
No tag was created. No CD pipeline was triggered.

## Output

\`\`\`
${output}
\`\`\`

## Next steps

1. Fix the issue above.
2. If you need to re-bump the version, run \`scripts/version.sh\` again.
3. Re-run \`scripts/release.sh\`.
EOF

  echo "" >&2
  echo "FAILED: ${stage}" >&2
  echo "Report written to: release-failure.md" >&2
  echo "" >&2
  echo "--- output ---" >&2
  echo "$output" >&2
  exit 1
}

# Run a command, capture combined stdout+stderr, call fail_with_report on non-zero exit.
run_check() {
  local label="$1"
  shift
  echo "  running: $label"
  local output
  output=$("$@" 2>&1) && return 0
  fail_with_report "$label" "$output"
}

# ---------------------------------------------------------------------------
# Pre-flight: version file
# ---------------------------------------------------------------------------
if [[ ! -f "$VERSION_FILE" ]]; then
  echo "error: version file not found: $VERSION_FILE" >&2
  exit 1
fi

version=$(tr -d '[:space:]' < "$VERSION_FILE")
tag="v${version}"

echo "=== Variance release: ${tag} ==="
echo ""

# ---------------------------------------------------------------------------
# 1. Clean working tree
# ---------------------------------------------------------------------------
echo "--- pre-flight ---"
if [[ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]]; then
  echo "error: working tree is dirty — commit or stash changes before releasing" >&2
  git -C "$REPO_ROOT" status --short >&2
  exit 1
fi
echo "  clean working tree: ok"

# ---------------------------------------------------------------------------
# 2. Verify HEAD is a version bump commit for this version
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
echo "  HEAD commit: ok"

# ---------------------------------------------------------------------------
# 3. Tag must not already exist
# ---------------------------------------------------------------------------
if git -C "$REPO_ROOT" rev-parse "$tag" &>/dev/null; then
  echo "error: tag ${tag} already exists" >&2
  exit 1
fi
echo "  tag ${tag}: available"
echo ""

# ---------------------------------------------------------------------------
# 4-8. Test suite
# ---------------------------------------------------------------------------
echo "--- test suite ---"

run_check "dart format" \
  dart format --set-exit-if-changed "$REPO_ROOT/lib/" "$REPO_ROOT/test/"

run_check "flutter analyze" \
  flutter analyze "$REPO_ROOT/lib/"

run_check "domain purity check" \
  make -C "$REPO_ROOT" domain-check

run_check "unit + widget tests" \
  flutter test --reporter=compact

if [[ -d "$REPO_ROOT/integration_test" ]]; then
  run_check "integration tests" \
    flutter test "$REPO_ROOT/integration_test/"
else
  echo "  integration tests: skipped (integration_test/ not found)"
fi

echo ""
echo "  all checks passed."
echo ""

# ---------------------------------------------------------------------------
# 9. Create annotated tag
# ---------------------------------------------------------------------------
echo "--- tagging ---"
git -C "$REPO_ROOT" tag -a "$tag" -m "Release ${tag}"
echo "  tagged: ${tag}"

# ---------------------------------------------------------------------------
# 10. Push branch + tag — triggers release.yml
# ---------------------------------------------------------------------------
echo "--- pushing ---"
git -C "$REPO_ROOT" push origin HEAD
git -C "$REPO_ROOT" push origin "$tag"
echo "  pushed: ${tag} → origin"

# Clean up any stale failure report from a previous run
rm -f "$FAILURE_REPORT"

echo ""
remote_url=$(git -C "$REPO_ROOT" remote get-url origin)
repo_path=$(echo "$remote_url" | sed 's/.*github\.com[:/]\(.*\)\.git$/\1/' | sed 's/.*github\.com[:/]\(.*\)$/\1/')
echo "CD triggered. Monitor: https://github.com/${repo_path}/actions"
