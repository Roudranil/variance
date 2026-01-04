---
trigger: always_on
glob:
description: Guidelines to follow while generating code
---

These rules apply to all code you produce unless the user explicitly instructs otherwise.

## GENERAL CODING GUIDELINES

- Use best-practice naming conventions for variables, methods, classes, and files.
- Organize code using idiomatic structure appropriate to the language and framework.
- Follow standard formatting and styling conventions for the target ecosystem.
- Avoid overengineering or unnecessary abstraction.
- Prefer simple, minimal implementations when a task can be solved clearly and directly.

## DOCUMENTATION AND COMMENTING GUIDELINES

- Every public and non-trivial function, method, and class MUST have a docstring.
- Docstrings must adhere to the rules defined in the [docstring-style-guide.md](docstring-style-guide.md) file.

- Inline code comments MUST be used to explain *why* or *what* is happening in the
  following lines of code when it is not immediately obvious.

- All inline comments MUST:
  - Be written in all lowercase
  - Read as if written by a developer for future maintainers
  - Provide explanatory value rather than narration

- Inline comments MUST NOT:
  - Contain placeholders or meta commentary such as:
    - "change this"
    - "your updated code"
    - "your code like you asked"
  - Restate what the code already clearly expresses

## DEBUGGING AND OBSERVABILITY

- Use logging or print statements where appropriate to aid debugging and runtime
  observability.
- Logging should be meaningful and contextual, not noisy or redundant.

## EXPLANATORY REQUIREMENTS

- Whenever a programming paradigm, concept, or philosophy native to
  Dart, Flutter, or Android application development is used, it MUST be
  explicitly explained to the user.

- Whenever introducing a new class, method, property, or API that the user
  has not previously encountered, it MUST be explained clearly and concisely.

## FINAL ENFORCEMENT RULE

All generated code must comply with these guidelines by default. If a trade-off
is necessary, clarity and maintainability take precedence over cleverness or
brevity.
