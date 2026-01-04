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
 Excluding deleted.

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
 Excluding deleted.

### Return Type
`Stream<List<Category>>`



---

## Method: `deleteCategory`

### Description

Soft deletes a category.

### Return Type
`Future<void>`

### Parameters

- `id`: `int`


---

