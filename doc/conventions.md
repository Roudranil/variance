# Conventions & Philosophies

## Architecture: Feature-First
We organize code by **feature**, not layer.
*   **DO**: Put `UserProfileScreen` and `UserRepository` inside `features/user/`.
*   **DON'T**: Put all screens in `views/` and all repositories in `data/`.

Why? It makes features modular and easier to extract or refactor.

## State Management: Provider
We use `Provider` + `ChangeNotifier` for its simplicity and adequacy for this scale.
*   **Repositories** are provided at the root (`MultiProvider` in `app.dart`).
*   **View Models / Controllers** (optional): If a screen has complex logic, create a `ChangeNotifier` specific to that screen.
*   **Consumers**: Use `context.read<Repo>()` for functions and `Consumer<Repo>` (or `StreamProvider`) for rebuilding UI.

## Coding Style
*   **Docstrings**: All public classes and methods **must** have docstrings explaining *what* they do and *why*.
*   **Immutability**: Prefer `final` fields. Use `copyWith` methods for updates.
*   **Small Functions**: Break down large build methods into smaller widgets or helper methods.
*   **Types**: Avoid `dynamic`. Use strict typing everywhere.

## Design Philosophy
1.  **Functionality First**: Logic integrity (Double Entry) > UI Aesthetics (for now).
2.  **Explicit over Implicit**: Write verbose code if it makes the business logic clearer.
3.  **Local Only**: No cloud dependencies. Privacy is paramount.

## Database Pattern
*   **Repositories** own the database queries. UI should never call `_db.select` directly.
*   **Streams**: Prefer exposure via `Stream` so the UI reacts automatically to database changes.

## API Design Patterns
*   **Encapsulation**: Public repository methods must **NOT** expose database-specific objects (like Drift's `Companions` or `Value` wrappers).
    *   *Bad*: `createAccount(AccountsCompanion companion)`
    *   *Good*: `createAccount({required String name, required AccountType type, ...})`
*   **Named Parameters**: Use named parameters for all repository methods with more than 1 argument. This improves readability at the call site.

