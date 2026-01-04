# database

## Overview for `AppDatabase`

### Description

The main database class for the application.

 Configures tables and provides access to the underlying SQLite database.

### Dependencies

- _$AppDatabase

### Constructors

#### Unnamed Constructor
Creates a new instance of [AppDatabase].

 Initializes the database connection using the native platform implementation.

#### forTesting
Creates a new instance of [AppDatabase] for testing purposes.

 Parameters:
 - [e]: The query executor to use (e.g., in-memory).

##### Parameters

- ``: `dynamic`


---

## Method: `schemaVersion`

### Description



### Return Type
`int`



---

