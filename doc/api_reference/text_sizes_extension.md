# text_sizes_extension

## Overview for `TextSizesExtension`

### Description

Defines standardized text sizes used across the application.

 This extension implements a scaling mechanism via [scaleFactor] to allow
 global resizing of text elements. Sizes are inspired by Tailwind CSS.

### Dependencies

- ThemeExtension

### Members

- **scaleFactor**: `double`
  The global scaling factor for text sizes.

### Constructors

#### Unnamed Constructor
Creates a new instance of [TextSizesExtension].

 The [scaleFactor] defaults to 1.0 and is clamped between 0.5 and 1.5.



---

## Method: `xl8`

### Description

8x Extra large text size.

 Base value: 96.0.

### Return Type
`double`



---

## Method: `xl4`

### Description

4x Extra large text size.

 Base value: 36.0.

### Return Type
`double`



---

## Method: `sm`

### Description

Small text size.

 Base value: 14.0.

### Return Type
`double`



---

## Method: `lg`

### Description

Large text size.

 Base value: 18.0.

### Return Type
`double`



---

## Method: `xl9`

### Description

9x Extra large text size.

 Base value: 128.0.

### Return Type
`double`



---

## Method: `xl6`

### Description

6x Extra large text size.

 Base value: 60.0.

### Return Type
`double`



---

## Method: `xl3`

### Description

3x Extra large text size.

 Base value: 30.0.

### Return Type
`double`



---

## Method: `xl7`

### Description

7x Extra large text size.

 Base value: 72.0.

### Return Type
`double`



---

## Method: `lerp`

### Description



### Return Type
`ThemeExtension<TextSizesExtension>`

### Parameters

- `other`: `ThemeExtension<TextSizesExtension>?`
- `t`: `double`


---

## Method: `base`

### Description

Base text size.

 Base value: 16.0.

### Return Type
`double`



---

## Method: `xl`

### Description

Extra large text size.

 Base value: 20.0.

### Return Type
`double`



---

## Method: `xl2`

### Description

2x Extra large text size.

 Base value: 24.0.

### Return Type
`double`



---

## Method: `copyWith`

### Description



### Return Type
`ThemeExtension<TextSizesExtension>`

### Parameters

- ``: `dynamic`


---

## Method: `xl5`

### Description

5x Extra large text size.

 Base value: 48.0.

### Return Type
`double`



---

## Method: `xs`

### Description

Extra small text size.

 Base value: 12.0.

### Return Type
`double`



---

