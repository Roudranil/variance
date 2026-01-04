# Project Structure

Variance adopts a **Feature-First Architecture** to ensure detailed separation of concerns while keeping related code co-located.

## Directory Tree

```text
lib/
├── core/                       # Shared components used across features
│   ├── theme/                  # Design system configurations
│   │   ├── extensions/         # Theme Extensions (Semantic Colors, Text Sizes)
│   │   ├── app_theme.dart      # Main Theme Data generator
│   │   └── theme_provider.dart # State Management for Theme switching
│   ├── utils/                  # formatting logic (Currency, Dates) & logger.dart
│   └── widgets/                # Generic, dumb UI components (Buttons, Cards)
│
├── database/                   # The centralized Data Layer
│   ├── setup/                  # Platform-specific database opening logic
│   ├── database.dart           # Main Drift Database class and connection
│   └── schema.dart             # Drift Table definitions (Entities)
│
├── features/                   # Application Modules
│   ├── accounts/               # Account Management Module
│   │   ├── data/               # Repositories & DAOs for Accounts
│   │   └── screens/            # UI widgets for Accounts
│   ├── categories/             # Category Management Module
│   ├── transactions/           # Transaction Management Module
│   │   ├── logic/              # (Optional) Complex business logic files
│   │   ├── data/               # Transaction Repository
│   │   └── screens/            # Add Transaction, History
│   └── dashboard/              # Home Screen / Analytics Module
│
├── app.dart                    # Root Widget (MaterialApp configuration)
└── main.dart                   # Application Entry Point
```

## Philosophy
*   **Encapsulation**: Code that is only used by the "Transactions" feature lives inside `features/transactions`. It is not spread across a global `views` or `controllers` folder.
*   **Core**: Only truly generic utilities (like date formatting) live in `core`.
*   **Database**: While repositories are feature-specific, the Schema and Database Connection are centralized because they represent the single source of truth and relational integrity.
