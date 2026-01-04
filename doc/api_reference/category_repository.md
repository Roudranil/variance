# category_repository

## Overview for `CategoryRepository`

### Description

**Category Repository**

 Manages classification entities ([Categories]).

 **Responsibilities:**
 *   CRUD for Categories.
 *   Managing Hierarchy (Parents/Children).

### Members

- **_db**: `AppDatabase`
### Constructors

#### Unnamed Constructor




---

## Method: `watchCategoriesByKind`

### Description

Watches categories by type (Expense/Income).

### Return Type
`Stream<List<Category>>`

### Parameters

- `kind`: `CategoryKind`


---

## Method: `createCategory`

### Description

Creates a new category.

### Return Type
`Future<int>`

### Parameters

- `category`: `CategoriesCompanion`


---

## Method: `watchAllCategories`

### Description

Watches all categories.
 TODO: Add sorting or tree-traversal logic for UI display.

### Return Type
`Stream<List<Category>>`



---

## Method: `deleteCategory`

### Description

Deletes a category.
 TODO: Add logic to prevent deleting if it has children or transactions.

### Return Type
`Future<int>`

### Parameters

- `id`: `int`


---

