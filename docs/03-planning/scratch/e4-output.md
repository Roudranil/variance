## Stories

## E4-S1 — Category Domain Entity, Repository Interface, and DAO

**Parent Epic:** E-4 — Categories Domain

**Story:** As an engineer, I want the `Category` domain entity, `ICategoryRepository` interface, `CategoryDao`, and `CategoryRepositoryImpl` to exist so that all higher-level category use cases have a fully wired persistence layer to build on.

### Objectives

- Define the `Category` freezed entity in `lib/domain/entities/category.dart` with all columns from data model §3.5 (`id`, `parentId`, `treeType`, `name`, `iconRef`, `isDeleted`, `deletedAt`, `isProtected`, `sortOrder`, `createdAt`, `updatedAt`)
- Define `ICategoryRepository` in `lib/domain/repositories/category_repository.dart` with the four methods: `watchAll()`, `create()`, `update()`, `softDelete(id, replacementId?)`
- Define the `CategoryDto` in `lib/data/models/category_dto.dart` with `fromRow` / `toEntity` mappers
- Implement `CategoryDao` as a Drift `DatabaseAccessor` in `lib/data/datasources/` with tree queries (`watchAll`, by tree type, by parent, protected guard)
- Implement `CategoryRepositoryImpl` in `lib/data/repositories/` wrapping the DAO; `softDelete` checks child count > 0 and returns `Err(BusinessRuleFailure)` if blocked
- Composite index `(tree_type, parent_id, name)` confirmed present (non-unique; case check is app-layer)

### Definition of Done

- `Category` entity compiles; all fields present; `freezed` codegen passes
- `ICategoryRepository` defines all four method signatures
- `CategoryDao` unit-tested with Drift in-memory DB: CRUD round-trips pass
- `CategoryRepositoryImpl` unit-tested: `softDelete` on parent with children returns `BusinessRuleFailure`
- `watchAll()` emits updated stream on any categories table write

### References

- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)
- `2.4 Categories` (`docs/02-technical/api-contracts.md`)
- `3.5 categories` (`docs/02-technical/data-model.md`)
- `1.5.1 Folder Structure` (`docs/02-technical/sds.md`)
- `2.3.4 DAO Structure` (`docs/02-technical/sds.md`)

---

## E4-S2 — Category CRUD Use Cases and Riverpod Wiring

**Parent Epic:** E-4 — Categories Domain

**Story:** As an engineer, I want `CreateCategoryUseCase`, `UpdateCategoryUseCase`, and `DeleteCategoryUseCase` implemented and Riverpod-wired so that the presentation layer can drive all category mutations through type-safe, validated use cases.

### Objectives

- Implement `CreateCategoryUseCase`: validates name uniqueness (case-insensitive, within same `tree_type` + `parent_id`, including soft-deleted rows), enforces two-level-max depth (parent_id must itself be a root), delegates to `ICategoryRepository.create()`
- Implement `UpdateCategoryUseCase`: validates same uniqueness constraint on rename; returns `Err(ValidationFailure)` on conflict
- Implement `DeleteCategoryUseCase`: calls `ICategoryRepository.softDelete()`; propagates `BusinessRuleFailure` from repo when child count > 0
- Register `CategoryListNotifier` as a Riverpod `AsyncNotifier` emitting `AsyncValue<List<Category>>`; expose via auto-generated providers
- Wire `ICategoryRepository` → `CategoryRepositoryImpl` in the DI provider file

### Definition of Done

- All three use cases unit-tested with fake `ICategoryRepository`
- Name uniqueness test: duplicate name in same tree+parent returns `Err(ValidationFailure)`
- Name uniqueness test: duplicate name under different parent succeeds
- Name uniqueness test: name matching a soft-deleted category in same tree+parent returns `Err(ValidationFailure)`
- `CategoryListNotifier` widget-tested: provider override propagates list to `AsyncValue.data`
- DI wiring: `CategoryRepositoryImpl` is returned by the Riverpod repository provider

### References

- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)
- `2.4.2 Use Cases` (`docs/02-technical/api-contracts.md`)
- `2.4.3 Notifiers` (`docs/02-technical/api-contracts.md`)
- `2.9 Error Handling Patterns` (`docs/02-technical/sds.md`)
- `1.3.2.2 Use Cases` (`docs/02-technical/sds.md`)

---

## E4-S3 — Category Management Screen (Settings)

**Parent Epic:** E-4 — Categories Domain

**Story:** As a user, I want a Category Management screen in Settings that shows all my categories in tabbed Expense / Income trees so that I can see, add, edit, and delete categories from a single screen.

### Objectives

- Implement `/settings/categories` screen with `TabBar` ("Expense" / "Income"), `ListView` of parent category rows (icon + name + child count), FAB "Add Category"
- Implement all four screen states: Loading (shimmer), Loaded-empty (empty state + FilledButton), Loaded-populated (tabbed list), Error (inline banner + Retry)
- Long-press contextual menu: Edit, Delete (disabled with tooltip if children exist), Add Child Category
- "Balance Adjustment" parent categories (`is_protected = 1`) filtered out entirely from this screen
- FAB navigates to Category Detail screen in create mode (tree pre-selected by active tab)
- Delete action on a leaf parent (no children) opens deletion wizard flow (CAT-03 prerequisite — placeholder navigation only in this story)

### Definition of Done

- Widget test: Loading state renders shimmer list
- Widget test: Loaded-populated state renders two tabs; Expense tab shows correct category rows
- Widget test: `is_protected = 1` rows absent from both tabs
- Widget test: Delete menu item is disabled and shows tooltip when category has children
- Golden tests for empty, loading, and populated states on both tabs
- Route `/settings/categories` resolves correctly in GoRouter

### References

- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)
- `9.8 Screen: Category Management` (`docs/02-technical/ux-flows.md`)
- `9.8 Category Management` (`docs/02-technical/ui-spec.md`)
- `9.22.1 From Settings` (`docs/02-technical/ux-flows.md`)

---

## E4-S4 — Category Detail / Edit Screen

**Parent Epic:** E-4 — Categories Domain

**Story:** As a user, I want a Category Detail screen where I can create or edit a category (name and icon), and for parent categories also manage subcategories, so that my category library stays accurate and well-organised.

### Objectives

- Implement `/settings/categories/:id` screen (create and edit modes) with name `OutlinedTextField`, icon picker row, Save in AppBar
- Parent category view: subcategory section with list rows, "Add subcategory" button, "No subcategories" empty state
- Child category view: read-only parent label row; no subcategory section
- Real-time name uniqueness validation: `TextField` error text "Name already in use" on conflict
- Icon picker `ModalBottomSheet`: `GridView` of ~250 `material_symbols_icons`; search `TextField` at top; 48 dp touch targets
- Save enabled only when form is dirty and name passes validation
- Inline category creation from Settings flow: tree selector at top on create screen; subcategory creation pre-sets parent

### Definition of Done

- Widget test: Save button disabled when name is empty
- Widget test: Save button disabled when name matches existing category (same tree + parent)
- Widget test: parent category view renders subcategory section; child view does not
- Widget test: icon picker sheet opens on icon row tap; selection updates icon preview
- Golden tests for loading, parent-loaded, child-loaded, dirty, and name-conflict states
- Successful save calls `CreateCategoryUseCase` or `UpdateCategoryUseCase` and navigates back

### References

- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)
- `9.9 Screen: Category Detail / Edit` (`docs/02-technical/ux-flows.md`)
- `9.9 Category Detail / Edit` (`docs/02-technical/ui-spec.md`)
- `9.22 Flow: Category Creation — Inline vs. From Settings` (`docs/02-technical/ux-flows.md`)

---

## E4-S5 — Category Soft-Delete Wizard

**Parent Epic:** E-4 — Categories Domain

**Story:** As a user, I want a guided multi-step wizard when deleting a category so that my recurring templates and historical transactions are handled correctly before the category disappears.

### Objectives

- Implement four-step deletion flow in exact order: (1) template handling dialog if templates reference the category, (2) usage count info dialog if N > 0 active transactions, (3) migration choice dialog (No migration / Migrate all / Choose specific), (4) soft-delete execution
- Step 1a: template migration picker (category picker filtered to same tree; or archive option)
- Step 3a: "Migrate all" → destination category picker (same tree filter)
- Step 3b: "Choose specific" → multi-select transaction `BottomSheet` with checkbox rows
- Step 4: batch > 50 transactions triggers additional `AlertDialog` confirmation; progress dialog for N > 10
- Batch migration executes in a single Drift DB transaction; rolls back to pre-deletion state on app kill
- Performance target: ≤ 5 s for N = 500 transactions on mid-range Android device
- Soft-deleted category: hidden from pickers; visible in filter dropdowns; historical transactions retain old label

### Definition of Done

- Unit test: step sequence is always 1 → 2 → 3 → 4; no step is skipped or reordered
- Unit test: template handling fires before transaction migration when both apply
- Unit test: batch migration rolls back atomically on simulated failure mid-transaction
- Widget test: "No migration" option always available as default in step 3
- Widget test: migration destination picker filters to same `tree_type` only
- Widget test: batch > 50 renders extra confirmation dialog with correct transaction count
- Soft-deleted category does not appear in category picker sheet after deletion completes

### References

- `CAT-03 — Category Soft-Delete + Migration Flow` (`docs/02-technical/feature-dag.md`)
- `9.9.4 Category Deletion Flow` (`docs/02-technical/ux-flows.md`)
- `9.9.3 Deletion Flow Components` (`docs/02-technical/ui-spec.md`)
- `3.5 categories` (`docs/02-technical/data-model.md`)

---

## E4-S6 — Default Category Seeding

**Parent Epic:** E-4 — Categories Domain

**Story:** As a new user, I want all default income and expense categories pre-loaded on first install so that I can start entering transactions immediately without any category setup.

### Objectives

- Implement first-install seeding migration: inserts all default categories from PRD §5.6.1 into the `categories` table using `INSERT OR IGNORE` for idempotency
- Seed `Balance Adjustment` (income parent + BAI child) and `Balance Adjustment` (expense parent + BAE child) with `is_protected = 1` and icon `balance`
- Seed `Financial` (expense parent, `is_protected = 0`) and `Fees & Charges` (child of Financial, `is_protected = 1`)
- All default category icons drawn from the curated ~250-icon subset (TC-014 founder-approved set)
- Seeding runs only on fresh install (guarded by `schema_migrations` version check); re-run is safe
- `sort_order` is NULL for all seeded rows (v1 — alphabetical display)

### Definition of Done

- Unit test: after `onCreate` migration, `categories` table contains all expected default rows
- Unit test: idempotency — running seeding migration twice produces no duplicate rows
- Unit test: `Balance Adjustment` income and expense parent rows have `is_protected = 1`
- Unit test: BAI and BAE child rows have `is_protected = 1`
- Unit test: `Fees & Charges` child row has `is_protected = 1`
- Unit test: all seeded rows have `sort_order = NULL`

### References

- `CAT-02 — Default Category Seeding` (`docs/02-technical/feature-dag.md`)
- `3.5 categories` (`docs/02-technical/data-model.md`)
- `2.3.3 Migration Strategy` (`docs/02-technical/sds.md`)

---

## E4-S7 — Protected Category Guards and Category Picker Sheet

**Parent Epic:** E-4 — Categories Domain

**Story:** As a user, I want protected "Balance Adjustment" categories to be invisible in transaction entry and category management, and I want a functional Category Picker bottom sheet for transaction forms, so that system categories are never accidentally used or modified.

### Objectives

- Implement the Category Picker `ModalBottomSheet` (`DraggableScrollableSheet`, 0.6 initial / 0.92 max extent) for use in transaction entry (income and expense only; not transfer)
- Sheet states: Loading (shimmer), Populated (search + recents strip + two-level list), Empty (no categories), Search results (flat filtered list), Inline create
- Recents: up to 5 most recently used categories for the active `tree_type`, ordered by recency
- Inline create within picker: parent category only; icon picker sub-sheet + name field + real-time uniqueness check; calls `CreateCategoryUseCase`
- `is_protected = 1` categories filtered out from picker at application layer (not DB constraint)
- Category management screen already filters `is_protected = 1` rows (validated in E4-S3)
- Soft-deleted categories hidden from picker except when editing a transaction that already references one (shown as special "current" entry at top)

### Definition of Done

- Widget test: `is_protected = 1` categories absent from picker list
- Widget test: soft-deleted category absent from picker in create mode; present as "current" entry in edit mode when transaction references it
- Widget test: inline create path calls `CreateCategoryUseCase` and auto-selects new category on success
- Widget test: empty tree shows "No categories yet" + "Create category" CTA; Save button on transaction form is disabled with message "No categories available. Create a category in Settings."
- Widget test: search filters parent and child rows; "No results" state shows inline create
- Golden tests for loading, populated, empty, search-active, and inline-create states

### References

- `CAT-04 — Protected "Balance Adjustment" System Category` (`docs/02-technical/feature-dag.md`)
- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)
- `1.1 Category Picker (UX-11)` (`docs/02-technical/ux-flows.md`)
- `8.1 Category Picker Sheet` (`docs/02-technical/ui-spec.md`)

---

## Tasks

## E4-T1 — Define `Category` Freezed Domain Entity

**Parent Epic:** E-4
**Parent Story:** E4-S1

### Todo

- [ ] Create `lib/domain/entities/category.dart`
- [ ] Add `@freezed` annotation; declare all fields: `id` (String), `parentId` (String?), `treeType` (enum `CategoryTreeType` with `income`/`expense`), `name` (String), `iconRef` (String), `isDeleted` (bool), `deletedAt` (DateTime?), `isProtected` (bool), `sortOrder` (int?), `createdAt` (DateTime), `updatedAt` (DateTime)
- [ ] Define `CategoryTreeType` sealed enum in same file or adjacent file
- [ ] Run `build_runner`; verify generated `category.freezed.dart` compiles with zero errors
- [ ] Write unit test: `Category.copyWith` preserves unchanged fields; two instances with identical field values are equal (`==`)

### References

- `3.5 categories` (`docs/02-technical/data-model.md`)
- `2.5.1 Freezed — Domain Entities` (`docs/02-technical/sds.md`)
- `1.3.2 Domain Layer` (`docs/02-technical/sds.md`)

---

## E4-T2 — Define `ICategoryRepository` Interface

**Parent Epic:** E-4
**Parent Story:** E4-S1

### Todo

- [ ] Create `lib/domain/repositories/category_repository.dart`
- [ ] Declare abstract interface `ICategoryRepository` with four methods: `watchAll()` → `Stream<List<Category>>`, `create(Category)` → `Future<Result<Category>>`, `update(Category)` → `Future<Result<Category>>`, `softDelete(String id, {String? replacementId})` → `Future<Result<void>>`
- [ ] Import `Result` from `lib/domain/core/result.dart`; ensure zero Flutter imports in this file
- [ ] Write unit test: `FakeCategoryRepository implements ICategoryRepository` compiles and satisfies the interface contract

### References

- `2.4.1 ICategoryRepository` (`docs/02-technical/api-contracts.md`)
- `1.6.3 Domain Layer Must Have Zero Flutter Dependency` (`docs/02-technical/sds.md`)
- `2.9.2 Result Type Definition` (`docs/02-technical/sds.md`)

---

## E4-T3 — Implement `CategoryDto` with Drift Row Mapper

**Parent Epic:** E-4
**Parent Story:** E4-S1

### Todo

- [ ] Create `lib/data/models/category_dto.dart`
- [ ] Declare `CategoryDto` with a `fromRow(CategoriesData row)` factory and a `toEntity()` method returning `Category`
- [ ] Map `tree_type` TEXT column to `CategoryTreeType` enum via custom converter
- [ ] Map `is_deleted` / `is_protected` INTEGER columns to `bool` via Drift `BoolConverter`
- [ ] Map `created_at` / `updated_at` / `deleted_at` INTEGER epoch columns to `DateTime` via `IntToDateTimeConverter`
- [ ] Write unit test: `CategoryDto.fromRow(mockRow).toEntity()` round-trips all fields without data loss

### References

- `3.5 categories` (`docs/02-technical/data-model.md`)
- `12.2 Custom Type Converters` (`docs/02-technical/data-model.md`)
- `2.5.2 json_serializable — Data Transfer Objects` (`docs/02-technical/sds.md`)

---

## E4-T4 — Implement `CategoryDao`

**Parent Epic:** E-4
**Parent Story:** E4-S1

### Todo

- [ ] Create `lib/data/datasources/category_dao.dart` as a Drift `DatabaseAccessor`
- [ ] Implement `watchAllCategories()` → `Stream<List<CategoriesData>>` filtering `is_deleted = 0`; ordered alphabetically by `name`
- [ ] Implement `watchByTreeType(String treeType)` → filtered stream for one tree
- [ ] Implement `insertCategory(CategoriesCompanion)` → `Future<void>`
- [ ] Implement `updateCategory(CategoriesCompanion)` → `Future<bool>`
- [ ] Implement `softDeleteCategory(String id, DateTime deletedAt)` → `Future<void>` (sets `is_deleted = 1`, `deleted_at`)
- [ ] Implement `countChildren(String parentId)` → `Future<int>` (counts non-deleted children)
- [ ] Implement `existsNameInScope(String name, String treeType, String? parentId, {String? excludeId})` → `Future<bool>` for uniqueness check (case-insensitive, including soft-deleted rows)
- [ ] Unit-test all methods using `NativeDatabase.memory()` in-memory Drift DB

### References

- `3.5 categories` (`docs/02-technical/data-model.md`)
- `3.5.1 Indexes` (`docs/02-technical/data-model.md`)
- `2.3.4 DAO Structure` (`docs/02-technical/sds.md`)
- `2.3.1 Drift ORM` (`docs/02-technical/sds.md`)

---

## E4-T5 — Implement `CategoryRepositoryImpl`

**Parent Epic:** E-4
**Parent Story:** E4-S1

### Todo

- [ ] Create `lib/data/repositories/category_repository_impl.dart` implementing `ICategoryRepository`
- [ ] `watchAll()`: delegates to `CategoryDao.watchAllCategories()`; maps rows via `CategoryDto.toEntity()`
- [ ] `create(category)`: delegates to `CategoryDao.insertCategory()`; wraps `DriftDatabaseException` in `Err(DatabaseFailure)`
- [ ] `update(category)`: delegates to `CategoryDao.updateCategory()`; returns `Err(NotFoundFailure)` if no row updated
- [ ] `softDelete(id, replacementId?)`: calls `countChildren(id)`; returns `Err(BusinessRuleFailure("Cannot delete a category with subcategories."))` if count > 0; otherwise calls `softDeleteCategory()`
- [ ] Unit-test: `softDelete` with children → `BusinessRuleFailure`; `softDelete` leaf → success; `update` missing row → `NotFoundFailure`

### References

- `2.4.1 ICategoryRepository` (`docs/02-technical/api-contracts.md`)
- `2.9.3 Layer-Boundary Rules` (`docs/02-technical/sds.md`)
- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)

---

## E4-T6 — Implement `CreateCategoryUseCase`

**Parent Epic:** E-4
**Parent Story:** E4-S2

### Todo

- [ ] Create `lib/domain/usecases/category/create_category_use_case.dart`
- [ ] Constructor: `ICategoryRepository repository`
- [ ] Validate `name` is non-empty; return `Err(ValidationFailure("Name cannot be empty."))` if blank
- [ ] Validate two-level depth: if `parentId` is non-null, call `repository` to confirm parent's own `parentId` is null; return `Err(ValidationFailure("Categories cannot be nested more than two levels."))` if violated
- [ ] Call `CategoryDao.existsNameInScope(name, treeType, parentId)` via repository; return `Err(ValidationFailure("Name already in use."))` on conflict
- [ ] Assign `id = Uuid().v4()`, `createdAt = DateTime.now()`, `updatedAt = DateTime.now()`
- [ ] Delegate to `repository.create(category)`
- [ ] Unit-test: empty name, depth violation, duplicate name (including soft-deleted conflict), happy path

### References

- `2.4.2 Use Cases` (`docs/02-technical/api-contracts.md`)
- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)
- `1.3.2.2 Use Cases` (`docs/02-technical/sds.md`)

---

## E4-T7 — Implement `UpdateCategoryUseCase`

**Parent Epic:** E-4
**Parent Story:** E4-S2

### Todo

- [ ] Create `lib/domain/usecases/category/update_category_use_case.dart`
- [ ] Constructor: `ICategoryRepository repository`
- [ ] Validate `name` is non-empty
- [ ] Validate `isProtected == false` on the existing entity; return `Err(BusinessRuleFailure("System categories cannot be modified."))` if `isProtected` is true
- [ ] Call name uniqueness check excluding the category's own `id` from the conflict search
- [ ] Set `updatedAt = DateTime.now()` on the updated entity
- [ ] Delegate to `repository.update(category)`
- [ ] Unit-test: protected category update blocked; rename to own name succeeds; rename to conflicting name fails

### References

- `2.4.2 Use Cases` (`docs/02-technical/api-contracts.md`)
- `CAT-04 — Protected "Balance Adjustment" System Category` (`docs/02-technical/feature-dag.md`)
- `2.9 Error Handling Patterns` (`docs/02-technical/sds.md`)

---

## E4-T8 — Implement `DeleteCategoryUseCase`

**Parent Epic:** E-4
**Parent Story:** E4-S2

### Todo

- [ ] Create `lib/domain/usecases/category/delete_category_use_case.dart`
- [ ] Constructor: `ICategoryRepository repository`
- [ ] Fetch existing entity; return `Err(NotFoundFailure)` if absent
- [ ] Guard: `isProtected == true` → return `Err(BusinessRuleFailure("System categories cannot be deleted."))`
- [ ] Delegate to `repository.softDelete(id, replacementId: replacementId?)`; propagate `BusinessRuleFailure` from repo if child count > 0
- [ ] Unit-test: protected category delete blocked; parent with children blocked; leaf category deleted successfully

### References

- `2.4.2 Use Cases` (`docs/02-technical/api-contracts.md`)
- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)
- `CAT-04 — Protected "Balance Adjustment" System Category` (`docs/02-technical/feature-dag.md`)

---

## E4-T9 — Implement `CategoryListNotifier` and Riverpod DI Wiring

**Parent Epic:** E-4
**Parent Story:** E4-S2

### Todo

- [ ] Create `lib/presentation/providers/category_providers.dart`
- [ ] Define `categoryRepositoryProvider` as a Riverpod `Provider<ICategoryRepository>` returning `CategoryRepositoryImpl`
- [ ] Define `CategoryListNotifier extends AsyncNotifier<List<Category>>` that calls `ref.watch(categoryRepositoryProvider).watchAll()` and converts the stream to `AsyncValue` via `AsyncValue.guard`
- [ ] Annotate with `@riverpod`; run `build_runner`; verify generated provider file
- [ ] Widget-test `CategoryListNotifier`: override provider with fake repository; verify `AsyncValue.data` contains expected list on stream emission
- [ ] Widget-test error path: fake repository emits error → notifier exposes `AsyncValue.error`

### References

- `2.4.3 Notifiers` (`docs/02-technical/api-contracts.md`)
- `2.2.3 Dependency Injection Strategy` (`docs/02-technical/sds.md`)
- `2.2.2 Provider Patterns in Use` (`docs/02-technical/sds.md`)

---

## E4-T10 — Implement Category Management Screen Scaffold and Loading / Error States

**Parent Epic:** E-4
**Parent Story:** E4-S3

### Todo

- [ ] Create `lib/presentation/features/settings/categories/category_management_screen.dart`
- [ ] Scaffold: `SmallTopAppBar` "Categories", `TabBar` with "Expense" / "Income" tabs, `TabBarView`
- [ ] Register route `/settings/categories` in `app_router.dart`
- [ ] Loading state: render `ShimmerWidget` × 6 rows per tab
- [ ] Error state: M3 `Banner` with `errorContainer` fill + "Retry" `TextButton`; retry re-triggers provider
- [ ] Empty state (no user categories): abstract geometric illustration + "No categories yet" text + `FilledButton` "Add Category"
- [ ] Widget-test loading state, error state, and empty state independently via provider overrides

### References

- `9.8 Category Management` (`docs/02-technical/ui-spec.md`)
- `3.1 Route Map` (`docs/02-technical/ux-flows.md`)
- `2.4 Navigation` (`docs/02-technical/sds.md`)

---

## E4-T11 — Implement Category Management Screen Populated State and Row Actions

**Parent Epic:** E-4
**Parent Story:** E4-S3

### Todo

- [ ] Render populated tab: `ListView` of `ListTile` rows (leading: category `Icon`; title: category name; trailing: child count `Text`)
- [ ] Filter `is_protected = 1` rows out of the list at the notifier/screen level before rendering
- [ ] `FloatingActionButton` with `add` icon always visible; taps navigate to `/settings/categories/new?tree=<active-tab-tree>`
- [ ] Long-press on row: `ModalBottomSheet` with contextual menu items: Edit, Delete, Add Child Category
- [ ] Delete menu item: disabled with `Tooltip` "Remove all subcategories first." when `childCount > 0`
- [ ] Delete menu item enabled: navigates to deletion wizard (placeholder navigation to E4-S5 screen)
- [ ] Edit menu item: navigates to `/settings/categories/:id`
- [ ] Add Child Category: navigates to `/settings/categories/new?parent=:id`
- [ ] Widget-test: `is_protected` rows absent; Delete disabled when childCount > 0; correct navigation targets called

### References

- `9.8 Category Management` (`docs/02-technical/ui-spec.md`)
- `9.8.1 States` (`docs/02-technical/ux-flows.md`)
- `9.8.2 Category Row Actions (long-tap contextual menu)` (`docs/02-technical/ux-flows.md`)
- `9.8.3 "Balance Adjustment" Category` (`docs/02-technical/ux-flows.md`)

---

## E4-T12 — Implement Category Detail Screen — Create Mode

**Parent Epic:** E-4
**Parent Story:** E4-S4

### Todo

- [ ] Create `lib/presentation/features/settings/categories/category_detail_screen.dart`
- [ ] Register routes: `/settings/categories/new` (create) and `/settings/categories/:id` (edit) in `app_router.dart`
- [ ] Create mode: `AppBar` title "New Category"; tree selector (`SegmentedButton` Income/Expense) at top; pre-selectable via query param `?tree=income|expense`
- [ ] Name `OutlinedTextField` with label "Category name"; real-time uniqueness validation on change; error text "Name already in use"
- [ ] Icon picker row: `ListTile` with current icon preview (32 dp); tap opens icon picker `ModalBottomSheet`
- [ ] Icon picker sheet: `GridView` of ~250 `material_symbols_icons`; `TextField` search at top; 48 dp touch targets per icon
- [ ] AppBar trailing `FilledButton` "Save": enabled only when name non-empty, no conflict, form dirty
- [ ] On save: calls `CreateCategoryUseCase`; on `Ok` navigates back; on `Err` shows snackbar "Failed to save."
- [ ] Widget-test: Save disabled when name empty; Save disabled when name conflicts; icon picker opens and selection updates preview

### References

- `9.9 Category Detail / Edit` (`docs/02-technical/ui-spec.md`)
- `9.9.1 States` (`docs/02-technical/ux-flows.md`)
- `9.22.1 From Settings` (`docs/02-technical/ux-flows.md`)

---

## E4-T13 — Implement Category Detail Screen — Edit Mode, Parent/Child Views, Subcategory Section

**Parent Epic:** E-4
**Parent Story:** E4-S4

### Todo

- [ ] Edit mode: load existing category; `AppBar` title "Edit Category"; pre-fill name and icon
- [ ] Parent category view: subcategory section below name/icon; `Text` section header; `ListTile` rows for each subcategory (icon + name); long-press → Edit / Delete contextual menu on subcategory row
- [ ] Subcategory section empty state: "No subcategories" `Text` + `OutlinedButton` "Add first subcategory"
- [ ] "Add subcategory" `OutlinedButton` navigates to `/settings/categories/new?parent=:id` (tree inherited from parent)
- [ ] Child category view: read-only parent label `ListTile` (`bodySmall` "Parent: [name]"); no subcategory section
- [ ] On save: calls `UpdateCategoryUseCase`; propagates errors via snackbar
- [ ] Shimmer loading state while category loads
- [ ] Widget-test: parent view renders subcategory section; child view does not; read-only parent label displays correct parent name

### References

- `9.9.2 Fields` (`docs/02-technical/ux-flows.md`)
- `9.9.3 Subcategory Section (parent category view only)` (`docs/02-technical/ux-flows.md`)
- `9.9.1 Components` (`docs/02-technical/ui-spec.md`)

---

## E4-T14 — Implement Category Deletion Wizard — Steps 1 and 2 (Template Handling + Usage Count)

**Parent Epic:** E-4
**Parent Story:** E4-S5

### Todo

- [ ] Create a `DeleteCategoryWizardController` (Riverpod `Notifier`) that owns wizard state: current step, template count, transaction count, migration choice, destination category, selected transactions
- [ ] Step 1 check: query recurring/installment templates referencing the category; if count > 0 → show template handling `AlertDialog` with "Migrate" / "Archive" / "Cancel" actions
- [ ] Step 1a (Migrate templates): open category picker `ModalBottomSheet` filtered to same `tree_type`; on selection store `templateMigrationTarget`
- [ ] Step 2: after template handling resolves (or if no templates), count active transactions referencing category; if N > 0 show info `AlertDialog` "This category is used by [N] transaction(s)."
- [ ] "Cancel" at any dialog step aborts the entire wizard without any mutations
- [ ] Unit-test: wizard always executes step 1 before step 2; wizard skips step 1 if no templates; cancel at step 1 → no DB writes

### References

- `CAT-03 — Category Soft-Delete + Migration Flow` (`docs/02-technical/feature-dag.md`)
- `9.9.4 Category Deletion Flow` (`docs/02-technical/ux-flows.md`)
- `9.9.3 Deletion Flow Components` (`docs/02-technical/ui-spec.md`)

---

## E4-T15 — Implement Category Deletion Wizard — Steps 3 and 4 (Migration + Soft-Delete)

**Parent Epic:** E-4
**Parent Story:** E4-S5

### Todo

- [ ] Step 3: transaction migration `AlertDialog` with `RadioListTile` choices: "No migration" / "Migrate all" / "Choose specific"
- [ ] Step 3a ("Migrate all"): category picker `ModalBottomSheet` (same tree filter); selection stored as `transactionMigrationTarget`
- [ ] Step 3b ("Choose specific"): multi-select `BottomSheet` with `Checkbox` per transaction row; selected IDs stored
- [ ] Step 4: if `totalMigrationCount > 50`, show `AlertDialog` "Re-categorise [N] transactions?" with Confirm / Cancel; show progress `CircularProgressIndicator` dialog while migrating
- [ ] Batch migration: single Drift `database.transaction(() {...})` call; re-categorises all affected transactions via ledger correction writes; soft-deletes category at end of same transaction
- [ ] Performance: target ≤ 5 s for N = 500 transactions; do not block UI thread (use `Isolate.run` or background `compute` for batch)
- [ ] Unit-test: atomic rollback — if soft-delete write throws, all category re-categorisations rolled back; category `is_deleted` remains 0
- [ ] Widget-test: progress dialog renders for N > 10; extra confirmation renders for N > 50
- [ ] Verify: soft-deleted category `watchAll()` stream no longer emits the category; picker excludes it; filter dropdowns still include it

### References

- `CAT-03 — Category Soft-Delete + Migration Flow` (`docs/02-technical/feature-dag.md`)
- `9.9.4 Category Deletion Flow` (`docs/02-technical/ux-flows.md`)
- `11.2 Soft Delete Policy` (`docs/02-technical/data-model.md`)
- `2.9.4 Ledger Operation Failure Modes` (`docs/02-technical/sds.md`)

---

## E4-T16 — Implement Default Category Seeding Migration

**Parent Epic:** E-4
**Parent Story:** E4-S6

### Todo

- [ ] Create `lib/data/database/migrations/seed_default_categories.dart` containing the seed data list (one `CategoriesCompanion` per default category row)
- [ ] Map PRD §5.6.1 default category tables into income-tree and expense-tree parent/child structures; assign UUID v4 for each row's `id`
- [ ] Seed `Balance Adjustment` income parent + BAI child with `is_protected = 1`, `icon_ref = 'balance'`
- [ ] Seed `Balance Adjustment` expense parent + BAE child with `is_protected = 1`, `icon_ref = 'balance'`
- [ ] Seed `Financial` expense parent (`is_protected = 0`) and `Fees & Charges` child (`is_protected = 1`)
- [ ] All other default categories: `is_protected = 0`; `sort_order = NULL`
- [ ] Wire seeding into `MigrationStrategy.onCreate` in `app_database.dart` using `INSERT OR IGNORE`
- [ ] Unit-test with in-memory Drift DB: verify all expected rows present after `onCreate`; verify idempotency (run twice → no duplicates)

### Notes

- Icon `icon_ref` values for non-protected categories are placeholders until the founder approves the TC-014 curated icon list; use `'category'` as the placeholder icon ref for all non-BAI/BAE rows until then

### References

- `CAT-02 — Default Category Seeding` (`docs/02-technical/feature-dag.md`)
- `3.5 categories` (`docs/02-technical/data-model.md`)
- `2.3.3 Migration Strategy` (`docs/02-technical/sds.md`)
- `11.1 schema_migrations` (`docs/02-technical/data-model.md`)

---

## E4-T17 — Protected Category Guard — Widget Tests for Picker and Management Screen

**Parent Epic:** E-4
**Parent Story:** E4-S7

### Todo

- [ ] Write widget test: `CategoryListNotifier` seeded with `is_protected = 1` and `is_protected = 0` rows; verify category management screen renders zero `is_protected = 1` rows
- [ ] Write widget test: category picker sheet seeded with `is_protected = 1` and `is_protected = 0` rows; verify `is_protected = 1` rows absent from picker list
- [ ] Write widget test: `UpdateCategoryUseCase` called with a `is_protected = 1` entity returns `Err(BusinessRuleFailure)` and picker/management screen shows no edit option for those rows
- [ ] Write widget test: `DeleteCategoryUseCase` called with a `is_protected = 1` entity returns `Err(BusinessRuleFailure)`
- [ ] Verify filter dropdown (transaction filter sheet): soft-deleted categories visible; `is_protected` categories also visible in filter context (they can appear on historical transactions)

### References

- `CAT-04 — Protected "Balance Adjustment" System Category` (`docs/02-technical/feature-dag.md`)
- `8.1.3 Rules` (`docs/02-technical/ui-spec.md`)
- `9.8.3 "Balance Adjustment" Category` (`docs/02-technical/ux-flows.md`)
- `2.11.3 Widget Testing` (`docs/02-technical/sds.md`)

---

## E4-T18 — Implement Category Picker Sheet

**Parent Epic:** E-4
**Parent Story:** E4-S7

### Todo

- [ ] Create `lib/presentation/widgets/category_picker_sheet.dart` as a `DraggableScrollableSheet` with `initialChildSize: 0.6`, `maxChildSize: 0.92`
- [ ] Sheet chrome: drag handle; title "Select Category — [Income|Expense]"
- [ ] M3 `SearchBar` (docked, auto-focused on open); on query change filter list to parents then children, fuzzy match
- [ ] Recents chip strip: horizontal scroll of up to 5 `SuggestionChip`s with category icon; recents sourced from a `RecentCategoriesNotifier` keyed by `tree_type`
- [ ] Two-level list: `ListTile` per parent; chevron if has children; tapping parent with children expands inline child rows (16 dp indent); tapping any row applies selection and dismisses sheet
- [ ] Empty state: "No categories yet" + `TextButton` "Create category" (invokes inline create)
- [ ] No-results state: "No results for '[query]'" + `TextButton` "+ Create '[query]'"
- [ ] Inline create row: animated expansion at list bottom; icon picker chip (opens icon sub-sheet) + name `OutlinedTextField` + `FilledTonalIconButton` confirm; confirm calls `CreateCategoryUseCase`; on success auto-selects new category and dismisses
- [ ] Filter `is_protected = 1` rows; show soft-deleted "current" entry only in edit mode when transaction already references it
- [ ] Widget-test all eight states listed in UI spec §8.1.2

### References

- `8.1 Category Picker Sheet` (`docs/02-technical/ui-spec.md`)
- `1.1 Category Picker (UX-11)` (`docs/02-technical/ux-flows.md`)
- `1.1.3 Rules` (`docs/02-technical/ux-flows.md`)
- `CAT-01 — Category CRUD (Two-Level, Income/Expense)` (`docs/02-technical/feature-dag.md`)

---
