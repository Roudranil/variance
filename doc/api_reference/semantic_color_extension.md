# semantic_color_extension

## Overview for `SemanticColorsExtension`

### Description

Defines the semantic colors used across the application.

 This extension provides a consistent way to access colors that have specific
 meanings in the context of the application, such as [income], [expense],
 and [transfer], as well as the full Catppuccin palette.

### Dependencies

- ThemeExtension

### Members

- **flavor**: `Flavor`
  The Catppuccin flavor used for this theme (Latte or Mocha).

- **general**: `Color`
  The general accent color for the application.

### Constructors

#### Unnamed Constructor
Creates a new instance of [SemanticColorsExtension].

 The [flavor] parameter determines the specific Catppuccin palette used.
 The [general] color is the primary accent color.



---

## Method: `sapphire`

### Description

The 'sapphire' color of the current flavor.

### Return Type
`Color`



---

## Method: `maroon`

### Description

The 'maroon' color of the current flavor.

### Return Type
`Color`



---

## Method: `green`

### Description

The 'green' color of the current flavor.

### Return Type
`Color`



---

## Method: `sky`

### Description

The 'sky' color of the current flavor.

### Return Type
`Color`



---

## Method: `blue`

### Description

The 'blue' color of the current flavor.

### Return Type
`Color`



---

## Method: `income`

### Description

Color representing income, assets, and positive financial flows.

 Maps to the 'green' color of the current flavor.

### Return Type
`Color`



---

## Method: `lavender`

### Description

The 'lavender' color of the current flavor.

### Return Type
`Color`



---

## Method: `rosewater`

### Description

The 'rosewater' color of the current flavor.

### Return Type
`Color`



---

## Method: `teal`

### Description

The 'teal' color of the current flavor.

### Return Type
`Color`



---

## Method: `transfer`

### Description

Color representing transfers and neutral financial actions.

 Maps to the 'overlay2' color of the current flavor.

### Return Type
`Color`



---

## Method: `lerp`

### Description



### Return Type
`ThemeExtension<SemanticColorsExtension>`

### Parameters

- `other`: `ThemeExtension<SemanticColorsExtension>?`
- `t`: `double`


---

## Method: `mauve`

### Description

The 'mauve' color of the current flavor.

### Return Type
`Color`



---

## Method: `yellow`

### Description

The 'yellow' color of the current flavor.

### Return Type
`Color`



---

## Method: `copyWith`

### Description



### Return Type
`ThemeExtension<SemanticColorsExtension>`

### Parameters

- ``: `dynamic`
- ``: `dynamic`


---

## Method: `red`

### Description

The 'red' color of the current flavor.

### Return Type
`Color`



---

## Method: `expense`

### Description

Color representing expenses, liabilities, and negative financial flows.

 Maps to the 'red' color of the current flavor.

### Return Type
`Color`



---

## Method: `pink`

### Description

The 'pink' color of the current flavor.

### Return Type
`Color`



---

## Method: `flamingo`

### Description

The 'flamingo' color of the current flavor.

### Return Type
`Color`



---

## Method: `peach`

### Description

The 'peach' color of the current flavor.

### Return Type
`Color`



---

