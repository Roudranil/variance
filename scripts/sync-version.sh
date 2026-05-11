#!/usr/bin/env bash
# sync-version.sh — Propagates the canonical version (./version) into pubspec.yaml.
# The build number defaults to 1; pass it as $1 from CI (e.g. $GITHUB_RUN_NUMBER).
#
# Usage:
#   ./scripts/sync-version.sh [build_number]
#
# Exit codes:
#   0  Success
#   1  version file not found or pubspec.yaml not found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

VERSION_FILE="$REPO_ROOT/version"
PUBSPEC="$REPO_ROOT/pubspec.yaml"

if [[ ! -f "$VERSION_FILE" ]]; then
  echo "error: version file not found: $VERSION_FILE" >&2
  exit 1
fi
if [[ ! -f "$PUBSPEC" ]]; then
  echo "error: pubspec.yaml not found: $PUBSPEC" >&2
  exit 1
fi

version=$(tr -d '[:space:]' < "$VERSION_FILE")
build_number="${1:-1}"

# GNU sed (Linux) uses -i without argument; BSD sed (macOS) requires -i ''
if sed --version 2>&1 | grep -q GNU; then
  sed -i "s/^version: .*/version: ${version}+${build_number}/" "$PUBSPEC"
else
  sed -i '' "s/^version: .*/version: ${version}+${build_number}/" "$PUBSPEC"
fi

echo "synced: pubspec.yaml version → ${version}+${build_number}"
