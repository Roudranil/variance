# Variance

**Variance** is a highly opinionated, local-first personal finance application for Android, built with Flutter.

Does it support Double-Entry Bookkeeping? **Yes.**
Does it sell your data? **No.**

## 🚀 Key Features
*   **Double-Entry Core**: Strict ledger integrity. Every expense withdraws from an asset; every income deposits into one.
*   **Local Persistence**: Powered by [Drift](https://drift.simonbinder.eu/) (SQLite). Your data never leaves your device.
*   **Feature-First Architecture**: Modular codebase designed for maintainability and scalability.
*   **Material 3 Expressive**: Modern, vibrant UI (Coming in Phase 3).

## 📚 Documentation
We maintain detailed documentation in the `doc/` directory.

*   **[Getting Started & Setup](doc/setup.md)**: How to install dependencies, generate code, and run the app.
*   **[Project Structure](doc/structure.md)**: Understanding the Feature-First architecture.
*   **[Database Schema & Logic](doc/database.md)**: Deep dive into Double-Entry logic, Tables (Accounts, Transactions), and ER diagrams.
*   **[API Overview](doc/api_overview.md)**: High-level reference for Repositories and key classes.
*   **[Conventions](doc/conventions.md)**: Coding style, Provider usage, and design philosophies.

## 🛠️ Development

### Quick Start
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Generated Documentation
This project uses standard Dart docstrings. You can generate a browseable HTML reference by running:
```bash
flutter pub add dev:dartdoc # One time setup
dart doc
```
Then open `doc/api/index.html` in your browser.

## 🧪 Testing
Run the comprehensive unit test suite for the database layer:
```bash
flutter test test/database_test.dart
```

---
*Built with ❤️ (and strict accounting principles) by Antigravity.*
