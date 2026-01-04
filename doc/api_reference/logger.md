# logger

## Overview for `VarianceLogger`

### Description

A global logger that asserts strict formatting and color requirements.

 This logger outputs messages in the format:
 `[Time] [File:Line] [Level] Message`

 Colors:
 - Time: Green
 - File:Line: Violet
 - Debug: Grey
 - Info: Blue
 - Warning: Orange
 - Error: Red

### Members

- **_reset**: `String`
- **_green**: `String`
- **_violet**: `String`
- **_grey**: `String`
- **_blue**: `String`
- **_orange**: `String`
- **_red**: `String`


---

## Method: `_log`

### Description

Internal log handler that constructs the formatted string.

### Return Type
`void`

### Parameters

- `level`: `LogLevel`
- `message`: `String`


---

## Method: `debug`

### Description

Logs a message at the [LogLevel.debug] level.

 Parameters:
 - [message]: The message to log.

### Return Type
`void`

### Parameters

- `message`: `String`


---

## Method: `info`

### Description

Logs a message at the [LogLevel.info] level.

 Parameters:
 - [message]: The message to log.

### Return Type
`void`

### Parameters

- `message`: `String`


---

## Method: `error`

### Description

Logs a message at the [LogLevel.error] level.

 Parameters:
 - [message]: The message to log.

### Return Type
`void`

### Parameters

- `message`: `String`


---

## Method: `_getLevelColor`

### Description



### Return Type
`String`

### Parameters

- `level`: `LogLevel`


---

## Method: `warning`

### Description

Logs a message at the [LogLevel.warning] level.

 Parameters:
 - [message]: The message to log.

### Return Type
`void`

### Parameters

- `message`: `String`


---

