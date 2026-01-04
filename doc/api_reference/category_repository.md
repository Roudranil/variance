# category_repository

## Overview for `CategoryRepository`

### Description

Manages classification entities [Categories].

 Responsibilities:
 - CRUD for Categories.
 - Managing Hierarchy (Parents/Children).

### Members

- **_db**: `AppDatabase`
### Constructors

#### Unnamed Constructor




---

## Method: `watchCategoriesByKind`

### Description

Watches categories by type (Expense/Income).

 Excludes deleted categories.

 Parameters:
 - [kind]: The category kind to filter by.

### Return Type
`Stream<List<Category>>`

### Parameters

- `kind`: `CategoryKind`


---

## Method: `createCategory`

### Description

Creates a new category and persists it to the database.

 Categories can optionally be hierarchical by specifying a [parentId].

 Returns the unique identifier of the newly created category.

 Parameters:
 - [name]: The display name of the category.
 - [kind]: The category kind (expense/income).
 - [parentId]: Optional parent category ID for nesting.
 - [iconData]: Optional icon identifier.
 - [color]: Optional ARGB color value.

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

Watches all categories.

 Excludes deleted categories.

### Return Type
`Stream<List<Category>>`



---

## Method: `deleteCategory`

### Description

Soft deletes a category.

 Parameters:
 - [id]: The ID of the category to delete.

### Return Type
`Future<void>`

### Parameters

- `id`: `int`


---

