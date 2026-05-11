---
name: git-commit
description: Enforces conventional commits, atomic commit discipline, PR title format, and co-author attribution. Use whenever creating commits or pull requests in this project.
---

# Git Commit Discipline

## 1. Conventional Commits — Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

Every commit **must** conform to this structure. No exceptions.

---

## 2. Types

| Type       | When to use                                           |
| ---------- | ----------------------------------------------------- |
| `feat`     | New feature or behavior visible to the user or system |
| `fix`      | Bug fix — corrects incorrect behavior                 |
| `refactor` | Code restructure with no behavior change              |
| `test`     | Add or modify tests only                              |
| `docs`     | Documentation only                                    |
| `chore`    | Tooling, deps, config — no production code change     |
| `style`    | Formatting, whitespace — no logic change              |
| `perf`     | Performance improvement                               |
| `ci`       | CI pipeline changes                                   |
| `build`    | Build system or external dependency changes           |
| `revert`   | Revert a prior commit — reference it in the body      |

**Never invent types.** If none fit, use the closest and note it in the body.

---

## 3. Scope

- Scope is **optional but encouraged** when the change is domain-specific.
- Use short lowercase identifiers: `db`, `auth`, `ui`, `ledger`, `router`, `settings`, `sync`.
- Omit scope only when the change is truly cross-cutting.

---

## 4. Subject Line Rules

These are **hard rules**, not suggestions:

- **Imperative mood**: "add", "fix", "remove" — not "added", "fixes", "removing"
- **No capital first letter** after the colon
- **No trailing period**
- **50 characters max** (hard limit — rewrite if over)
- **No filler**: avoid "just", "actually", "some", "various", "minor"
- Describe **what changes**, not why (why goes in body)

**Good:**

```
feat(ledger): add multi-currency posting support
fix(router): redirect unauthenticated users to login
test(settings): cover AppSettingsNotifier update path
```

**Bad:**

```
Fixed some stuff
feat: Added new feature for the ledger thing.
update things
```

---

## 5. Body Rules

- Separate from subject with a **blank line**
- Explain **why**, not what — the diff shows what
- Wrap at **72 characters per line**
- Use bullet points for multi-point rationale
- Reference ticket IDs: `Closes T-42`, `Part of T-99`
- Only include a body when the subject line is insufficient

---

## 6. Footer Rules

- `BREAKING CHANGE: <description>` — mandatory for any breaking change; triggers major version bump
- `Co-authored-by: Name <email>` — for attributions (see §8)
- `Refs: T-42` — for non-closing ticket references
- One footer entry per line

---

## 7. Atomic Commit Principles — Non-Negotiable

An atomic commit is a single, complete, self-contained unit of change.

### Rules

- **One work item per commit. Hard stop.** A commit may reference exactly one task ID (T-N). If files from two different tasks are staged together, unstage and split — no exceptions, no "they're related."
- **One logical change per commit.** One fix, one feature slice, one refactor — scoped entirely within that work item.
- **All files in a commit must belong to the same topic.** No mixing UI, DB, and tests from different features in one commit.
- **Never bundle unrelated fixes.** If you notice a separate bug while working, fix it in a separate commit under its own task.
- **Tests for a change travel with the change.** Don't commit a feature without its tests, or tests without the code they cover.
- **Do not commit broken states.** Every commit must leave the codebase compilable and tests passing.

### Size Heuristics (treat as warnings, not limits)

| Signal                     | Action                        |
| -------------------------- | ----------------------------- |
| > 10 files changed         | Ask: is this truly one topic? |
| > 100 lines changed        | Ask: can this be split?       |
| Commit message needs "and" | Split it                      |

### Splitting a large change

If a task requires 300+ lines across multiple concerns, break it into a stack:

```
feat(db): add expense_tags schema migration        <- schema only
feat(ledger): wire tag selection to posting flow   <- business logic
test(ledger): cover tag posting edge cases         <- tests
```

---

## 8. Co-Author Attribution — Mandatory

Every commit made with AI assistance **must** include the co-author footer:

```
Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

### Model-to-footer mapping

| Model in use      | Footer value                                |
| ----------------- | ------------------------------------------- |
| Claude Sonnet 4.6 | `Claude Sonnet 4.6 <noreply@anthropic.com>` |
| Claude Opus 4.7   | `Claude Opus 4.7 <noreply@anthropic.com>`   |
| Claude Haiku 4.5  | `Claude Haiku 4.5 <noreply@anthropic.com>`  |

Always use the model that **authored the code**, not whichever is orchestrating.

### HEREDOC commit template

Always pass commit messages via HEREDOC to avoid shell escaping issues:

```bash
git commit -m "$(cat <<'EOF'
feat(ledger): add multi-currency posting

Supports posting in any configured currency independent of home currency.
EQ entries auto-generated per posting pair.

Closes T-42
Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

---

## 9. PR Title Discipline

PR titles are the permanent record. They must be exact and scannable.

### Format

```
<type>(<scope>): <subject>  [T-N, T-M]
```

- Follow all subject line rules from §4
- Append task IDs at the end in brackets: `[T-42]` or `[T-42, T-43]`
- For multi-task PRs, list all IDs — do not summarize with "T-42 et al."
- Never include branch name in the PR title
- Keep the full title under **72 characters**

**Good:**

```
feat(settings): AppSettingsNotifier + UpdateAppSettingsUseCase [T-173]
fix(router): redirect loop on cold start [T-88]
```

**Bad:**

```
T-173: settings notifier stuff
WIP: ledger changes + router fix + some tests
feat: a bunch of stuff for this sprint
```

### PR Description is not optional

A PR title alone is not sufficient. The description must include:

- **What**: one-line summary of the change
- **Why**: motivation or ticket context
- **Changes**: bullet list of files/components touched
- **Tests**: what was tested and how
- **Checklist**: `dart analyze`, golden tests, manual smoke test

---

## 10. Pre-Commit Checklist

Before every commit, verify:

- [ ] Type and scope are correct
- [ ] Subject is imperative, <=50 chars, no trailing period
- [ ] Body explains _why_ (if included)
- [ ] All changed files belong to the same logical topic
- [ ] Tests travel with the change they cover
- [ ] No debug prints, commented-out code, or TODOs snuck in
- [ ] Co-author footer present
- [ ] `dart analyze` passes (for Dart/Flutter changes)

---

## 11. What Never Belongs in a Commit

- Secrets, API keys, tokens — ever
- `.DS_Store`, `*.g.dart` output files that aren't tracked by convention
- `pubspec.lock` changes caused by unrelated dep drift
- Reformatting of files you didn't logically touch
- Multiple unrelated bug fixes bundled as "misc fixes"
