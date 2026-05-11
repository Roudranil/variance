# Variance

Personal expense tracker for Android. Local-first, double-entry bookkeeping under the hood, Material You UI.

## Platform

- Android only — minimum API 31 (Android 12)
- Offline-first — zero internet required for any v1 feature

## Tech stack

- Flutter / Dart (SDK `>=3.4.0 <4.0.0`)
- Riverpod (state management + DI)
- Drift + SQLite3MultipleCiphers (encrypted local database)
- GoRouter (navigation)
- Freezed / json_serializable (code generation)
- Material Design 3

## Prerequisites

- Flutter SDK (stable channel) with Dart `>=3.4.0`
- Android SDK with a connected device or emulator (API 31+)

Verify setup:

```sh
flutter doctor
```

## Setup

```sh
git clone <repo>
cd variance
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Running

```sh
flutter run
```

## Testing

```sh
flutter test            # unit and widget tests
make domain-check       # verify domain layer has no Flutter imports
make analyze            # full static analysis
```

## Building a release APK

The canonical version lives in `./version`. Sync it to `pubspec.yaml` before building:

```sh
./scripts/sync-version.sh          # defaults build number to 1
./scripts/sync-version.sh 42       # pass a specific build number
flutter build apk --release --obfuscate --split-debug-info=build/debug-info/
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Versioning and releases

- The `version` file at the repo root is the canonical version source — do not edit `pubspec.yaml` directly.
- To cut a release, update `version`, commit, then push a matching tag:

```sh
echo "0.24.0" > version
git add version && git commit -m "chore(release): bump to v0.24.0"
git tag v0.24.0
git push && git push --tags
```

The release workflow picks up the tag, verifies it matches `version`, builds the APK, and creates a GitHub release automatically.

## CI

| Workflow | Trigger | Jobs |
|---|---|---|
| `ci.yml` | Push / PR to `main` | Format check, analyze, domain purity, tests |
| `release.yml` | Push of `v*` tag | All CI checks + release APK build + GitHub release |
