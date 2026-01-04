# app_theme

## Overview for `AppTheme`

### Description

Defines the configuration for the application theme.

 This class provides static methods to generate [ThemeData] based on
 brightness, seed color, and configured extensions.

### Constructors

#### _




---

## Method: `define`

### Description

Generates the [ThemeData] for the application.

 The [brightness] determines if the theme is light or dark.
 The [seedColor] is used to generate the [ColorScheme]. If null, a default
 Catppuccin color is used (Mauve).

 Returns a configured [ThemeData] instance with:
 - Material 3 enabled.
 - [SemanticColorsExtension] configured with the appropriate Catppuccin flavor.
 - [TextSizesExtension] with default scaling.

### Return Type
`ThemeData`

### Parameters

- ``: `dynamic`
- ``: `dynamic`


---

