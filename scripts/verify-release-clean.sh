#!/usr/bin/env bash
# scripts/verify-release-clean.sh
#
# Verifies that the DebugErrorOverlay is eliminated from a release APK.
#
# Usage:
#   ./scripts/verify-release-clean.sh
#
# Expected output when clean:
#   [OK] DebugErrorOverlay not found in release APK.
#
# Fails with exit code 1 if the overlay symbol is found (kDebugMode guard
# is missing or incorrect in main_dev.dart / debug_error_overlay.dart).
#
# Spec reference: T-216 — Release build verification.
#
# Notes:
#   - Must be run after `flutter build apk --release --flavor prod`.
#   - The `strings` command extracts printable strings from the APK binary.
#   - A zero-match result confirms the Dart tree-shaker eliminated the
#     debug overlay code path.

set -euo pipefail

APK_PATH="build/app/outputs/flutter-apk/app-prod-release.apk"

if [[ ! -f "$APK_PATH" ]]; then
  echo "[ERROR] Release APK not found at: $APK_PATH"
  echo "        Run: flutter build apk --release --flavor prod"
  exit 1
fi

MATCH_COUNT=$(strings "$APK_PATH" | grep -ic "DebugErrorOverlay" || true)

if [[ "$MATCH_COUNT" -eq 0 ]]; then
  echo "[OK] DebugErrorOverlay not found in release APK. Tree-shaking verified."
  exit 0
else
  echo "[FAIL] DebugErrorOverlay found $MATCH_COUNT time(s) in release APK."
  echo "       Check that kDebugMode guards are correctly placed."
  exit 1
fi
