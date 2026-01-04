# theme_provider

## Overview for `ThemeProvider`

### Description

Manages the theme state of the application.

 This provider handles handling the active [ThemeMode], the user's preferred
 accent color, and whether to use dynamic (wallpaper-based) colors.

### Dependencies

- ChangeNotifier

### Members

- **_themeMode**: `ThemeMode`
- **_accentColor**: `Color?`
- **_useDynamicColor**: `bool`


---

## Method: `setThemeMode`

### Description

Sets the theme mode.

### Return Type
`void`

### Parameters

- `mode`: `ThemeMode`


---

## Method: `toggleThemeMode`

### Description

Toggles between light and dark mode.

 If the current mode is system, it defaults to dark.

### Return Type
`void`



---

## Method: `useDynamicColor`

### Description

Whether to use dynamic colors from the system wallpaper.

### Return Type
`bool`



---

## Method: `accentColor`

### Description

The custom accent color selected by the user, if any.

 If null and [_useDynamicColor] is false, a default theme color will be used.

### Return Type
`Color?`



---

## Method: `themeMode`

### Description

The current theme mode (system, light, or dark).

### Return Type
`ThemeMode`



---

## Method: `toggleDynamicColor`

### Description

Toggles the usage of dynamic colors.

### Return Type
`void`

### Parameters

- `value`: `bool`


---

## Method: `setAccentColor`

### Description

Sets the custom accent color.

 This will automatically disable dynamic colors if a color is provided.

### Return Type
`void`

### Parameters

- `color`: `Color?`


---

