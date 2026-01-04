---
trigger: always_on
glob:
description: Set of guidelines to be followed when writing docstrings
---

# Introduction

Following are rules for writing docstrings (and templates) that align with Flutter SDK and Dartdoc conventions. Your output MUST adhere to the rules and templates defined below. These rules are mandatory and override stylistic freedom.

## General Rules

- Use `///` for all documentation comments.
- Write in third-person, present tense (e.g., “Creates”, “Returns”, “Represents”).
- Use complete, grammatically correct sentences.
- Keep the first line to a single concise summary sentence.
- Use short paragraphs separated by blank `///` lines.
- Do NOT use Markdown headings (`#`, `##`, etc.) inside doc comments.
- Avoid redundant type restatement unless it adds semantic value.
- Reference parameters, fields, methods, and types using square brackets
  (e.g., [value], [AccountType]).
- Documentation must be safe for Dartdoc HTML generation.
- Inline parameter comments MAY be used for IDE support but MUST NOT replace
  method-level parameter documentation for public APIs.
- Prefer clarity and explicitness over brevity for public-facing APIs.

## Method / Function Docstring Template

/// <One-sentence summary of what the method does.>
///
/// <Optional paragraph describing behavior, side effects, lifecycle, or
/// invariants. Reference parameters using [parameterName] where relevant.>
///
/// Returns <description of the return value>.
///
/// Parameters:
/// - [paramName]: <Description>.
/// - [paramName]: <Description>. Defaults to `<defaultValue>`.
/// - [paramName]: <Description>. Valid range: <constraints>.

Example:

/// Creates a new account and persists it to the database.
///
/// The account is initialized with [initialBalance], which is also used as the
/// initial value for the current balance.
///
/// Returns the unique identifier of the newly created account.
///
/// Parameters:
/// - [name]: The display name of the account.
/// - [type]: The type of account.
/// - [initialBalance]: The starting balance.
/// - [currencyCode]: ISO 4217 currency code. Defaults to `'INR'`.

## Class Docstring Template

Template:

/// <One-sentence summary describing the responsibility of the class.>
///
/// <Optional paragraph describing usage context, lifecycle, or invariants.>
///
/// <Optional paragraph describing interactions with other components.>

Example:

/// Represents a financial account tracked by the application.
///
/// An account maintains balances, currency information, and metadata used for
/// reporting and net worth calculations.

## Constructor Docstring Template

Template:

/// Creates a new instance of [ClassName].
///
/// <Optional description of initialization behavior or constraints.
///
/// Parameters:
/// - [paramName]: <Description>.
/// - [paramName]: <Description>. Must not be null.

## Property / Field Docstring Template

Template:

/// <Description of what this field represents.>
///
/// <Optional constraints, units, or lifecycle notes.>

Example:

/// The current balance of the account.
///
/// This value is updated as transactions are applied.

## Enum Docstring Template

Template:

/// <One-sentence description of what the enum represents.>
enum EnumName {
  /// <Description of this value.>
  valueOne,

  /// <Description of this value.>
  valueTwo,
}

## Getter Docstring Template

Template:

/// <Description of the derived or exposed value.>
///
/// <Optional explanation of how the value is computed.>

## Setter Docstring Template

Template:

/// Sets the <property name>.
///
/// <Optional validation rules or side effects.>

## Mixin Docstring Template

Template:

/// <Description of shared behavior provided by this mixin.>
///
/// <Optional constraints on classes that may apply this mixin.>

## Extension Docstring Template

Template:

/// <Description of the functionality added by this extension.>
///
/// <Optional usage notes or examples.>

## Top-Level Constant / Variable Docstring Template

Template:

/// <Description of the constant or variable.>
///
/// <Optional usage notes or constraints.>

## Final Enforcement Rule

If a public API element (class, method, constructor, field, enum, extension,
mixin, or constant) can have a docstring, it MUST have one written using the
appropriate template above. Failure to do so is considered incorrect output.

