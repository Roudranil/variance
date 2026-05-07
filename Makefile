# Makefile
# Convenience targets for Variance development.
# CI and local quality gates.

.PHONY: domain-check analyze format test

# ---------------------------------------------------------------------------
# T-11: Domain purity gate
# Verifies that lib/domain/ has zero Flutter imports and zero analyzer errors.
# Fails the build if any `package:flutter` import is found in the domain layer.
# ---------------------------------------------------------------------------
domain-check:
	@echo "--- Checking domain layer for Flutter imports ---"
	@if grep -r "package:flutter" lib/domain/ \
	    --include="*.dart" \
	    --exclude="*.freezed.dart" \
	    --exclude="*.g.dart"; then \
	  echo "ERROR: Flutter import(s) found in lib/domain/ — domain must be pure Dart."; \
	  exit 1; \
	fi
	@echo "OK: No Flutter imports in lib/domain/"
	@echo "--- Running dart analyze on lib/domain/ ---"
	flutter analyze lib/domain/
	@echo "Domain purity check passed."

# ---------------------------------------------------------------------------
# General targets
# ---------------------------------------------------------------------------
analyze:
	flutter analyze lib/

format:
	dart format lib/ test/

test:
	flutter test
