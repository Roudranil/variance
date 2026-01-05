# category_repository

## Overview for `CategoryRepository`

### Description

Manages [Categories] entities and their linked nominal accounts.

 In double-entry bookkeeping, each category is backed by a hidden nominal
 account. When a category is created, this repository automatically creates
 the corresponding account with the appropriate [AccountNature].

### Members

- **_db**: `AppDatabase`
### Constructors

#### Unnamed Constructor
Creates a new instance of [CategoryRepository].

 Parameters:
 - [db]: The database instance to use.



---

## Method: `watchCategoriesByKind`

### Description

Watches categories filtered by kind (expense or income).

 Excludes deleted categories.

 Returns a [Stream] of [Category] lists that updates when data changes.

 Parameters:
 - [kind]: The category kind to filter by.

### Return Type
`Stream<List<Category>>`

### Parameters

- `kind`: `CategoryKind`


---

## Method: `createCategory`

### Description

Creates a new category with its linked nominal account.

 This method performs the following in a single transaction:
 1. Creates a hidden nominal account with [AccountNature.expense] or
    [AccountNature.income] based on [kind].
 2. Creates the category record linking to that account.

 Returns the unique identifier of the newly created category.

 Parameters:
 - [name]: The display name of the category.
 - [kind]: The category kind (expense or income).
 - [parentId]: Optional parent category ID for sub-categories.
 - [iconData]: Optional icon identifier (codePoint or asset path).
 - [color]: Optional ARGB color value for UI styling.

### Return Type
`Future<int>`

### Parameters

- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`


---

## Method: `watchAllCategories`

### Description

Watches all categories ordered by name.

 Excludes deleted categories.

 Returns a [Stream] of [Category] lists that updates when data changes.

### Return Type
`Stream<List<Category>>`



---

## Method: `softDeleteCategory`

### Description

Soft deletes a category.

 The category and its linked account are hidden from the UI but kept for
 historical integrity.

 Parameters:
 - [id]: The unique identifier of the category to delete.

### Return Type
`Future<void>`

### Parameters

- `id`: `int`


---

## Method: `getCategory`

### Description

Gets a single category by ID.

 Returns null if the category does not exist.

 Parameters:
 - [id]: The unique identifier of the category.

### Return Type
`Future<Category?>`

### Parameters

- `id`: `int`


---

## Method: `updateCategory`

### Description

Updates an existing category's metadata.

 Updates the category name, icon, color, and parent. Also updates the
 display name of the linked nominal account.

 Parameters:
 - [id]: The unique identifier of the category to update.
 - [name]: The new display name.
 - [parentId]: The new parent category ID (null for top-level).
 - [iconData]: The new icon identifier.
 - [color]: The new ARGB color value.

### Return Type
`Future<void>`

### Parameters

- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`
- ``: `dynamic`


---

