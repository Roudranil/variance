# Environment & Setup Guide

## Prerequisites
*   **Flutter SDK**: Stable channel (Recommend 3.22+).
*   **Dart SDK**: Included with Flutter.
*   **IDE**: VS Code (Recommended) or Android Studio.

## Getting Started

1.  **Clone the repository**:
    ```bash
    git clone <repo_url>
    cd variance
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Generate Database Code**:
    *   This project uses `drift` which requires code generation.
    *   **One-time build**:
        ```bash
        dart run build_runner build --delete-conflicting-outputs
        ```
    *   **Watch mode (Development)**:
        ```bash
        dart run build_runner watch --delete-conflicting-outputs
        ```
    > **Note**: If you see compilation errors related to `AppDatabase` or `Value`, closely check `pubspec.yaml` versions. We use Drift `2.24.0` for stability.

4.  **Run the App**:
    ```bash
    flutter run
    ```

## Development Tools

### Database Inspection
Since the database is SQLite, you can inspect it by:
1.  Running the app on a simulator/emulator.
2.  Using the `drift_db_viewer` package (if added) or extracting the `.sqlite` file from the device storage.

### Testing
Run unit tests for database logic:
```bash
flutter test test/database_test.dart
```

## Troubleshooting
*   **Build Runner Failures**: Try `flutter clean`, `flutter pub get`, then run the build command again.
*   **Drift Versioning**: We locked Drift to `2.24.0` due to issues with `2.30`'s code generator. Do not upgrade unless you verify compatibility.
