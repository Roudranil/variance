---
name: GitHub MCP — Standard Operating Procedures
description: Role-based workflow reference covering every dev and TPM task, with the recommended tool (git/gh-cc-var/MCP) and exact steps for each
type: reference
---

# GitHub MCP — Standard Operating Procedures

Repo: `Roudranil/variance` (SSH alias: `github.com-personal`)

---

## 1. Tool Decision Rule

| Layer | Use | For |
|-------|-----|-----|
| `git` | Local code operations | branches, commits, push, pull, merge, rebase |
| `MCP` | Remote writes | issues, PRs, project board item writes, sub-issue linking, reviews |
| `gh-cc-var` | Remote reads + project scope | project board reads, branch listing, anything MCP 403s |

**Never use plain `gh`.** Always `gh-cc-var`.
**Never touch project #2 (Lattice).** Only `variance` (#3, ID: `PVT_kwHOA51EZs4BUfV9`).

---

## 2. Developer Workflows

### 2.1 Create a Feature Branch

**Tool: `git`**

```bash
git checkout main && git pull
git checkout -b feat/my-feature
```

No MCP or CLI equivalent — branch creation is local git.

---

### 2.2 Stage, Commit, Push

**Tool: `git`**

```bash
git add <files>
git commit -m "feat: description"
git push -u origin feat/my-feature
```

---

### 2.3 List All Remote Branches

**Tool: `gh-cc-var`** (no MCP tool for branch listing)

```bash
gh-cc-var api repos/Roudranil/variance/branches --jq '.[].name'
```

To confirm a single branch exists via MCP: call `get_repository_tree(tree_sha: "branch-name")` — returns data if it exists, errors if not.

---

### 2.4 Create a Pull Request

**Tool: MCP** (`create_pull_request`)

```
create_pull_request(
  owner, repo,
  title, body,
  head: "feat/my-feature",
  base: "main"
)
```

Include `Closes #N` in body to auto-link the issue and auto-populate the `Linked pull requests` project field.

CLI alternative: `gh-cc-var pr create --base main --head feat/my-feature --title "..." --body "..."`

---

### 2.5 Read PR Details

**Tool: MCP** (`pull_request_read`) or `gh-cc-var pr view <number>`

MCP gives structured JSON. CLI gives human-readable output. Either works — use MCP when you need to extract specific fields programmatically.

---

### 2.6 Update a PR (title, body, state)

**Tool: MCP** (`update_pull_request`)

```
update_pull_request(owner, repo, pull_number: N, title, body)
```

---

### 2.7 Update PR Branch (sync with base)

**Tool: MCP** (`update_pull_request_branch`)

```
update_pull_request_branch(owner, repo, pull_number: N)
```

This rebases/merges `main` into the PR branch. CLI: `gh-cc-var pr update-branch <number>`.

---

### 2.8 Review a PR

**Tool: MCP** (`pull_request_review_write`)

```
pull_request_review_write(
  owner, repo, pull_number: N,
  event: "APPROVE" | "REQUEST_CHANGES" | "COMMENT",
  body: "..."
)
```

For inline comments on specific lines: `add_comment_to_pending_review`.

---

### 2.9 Reply to a PR Comment Thread

**Tool: MCP** (`add_reply_to_pull_request_comment`)

```
add_reply_to_pull_request_comment(owner, repo, pull_number: N, comment_id: X, body: "...")
```

---

### 2.10 Merge a PR

**Tool: MCP** (`merge_pull_request`)

```
merge_pull_request(owner, repo, pull_number: N, merge_method: "squash" | "merge" | "rebase")
```

---

### 2.11 View CI/CD Workflow Runs

**Tool: MCP** (`actions_list`)

```
actions_list(method: "list_workflow_runs", owner, repo)
actions_list(method: "list_workflow_runs", owner, repo, resource_id: "ci.yaml")
```

Filter by status: `workflow_runs_filter: { status: "completed" | "in_progress" }`.

---

### 2.12 View Job Logs

**Tool: MCP** (`get_job_logs`)

```
get_job_logs(owner, repo, job_id: <id>)
```

Get job ID first from `actions_list(method: "list_workflow_jobs", resource_id: <run_id>)`.

---

### 2.13 Trigger a Workflow Manually

**Tool: MCP** (`actions_run_trigger`)

```
actions_run_trigger(owner, repo, workflow_id: "ci.yaml", ref: "main")
```

---

### 2.14 Create a Bug Issue

**Tool: MCP** (`issue_write`)

```
issue_write(method: "create", owner, repo,
  title: "Bug: ...",
  body: "...",
  labels: ["bug"]
)
```

Ensure the `bug` label exists first — call `list_label` to check, `label_write` to create if missing.

---

### 2.15 Comment on an Issue

**Tool: MCP** (`add_issue_comment`)

```
add_issue_comment(owner, repo, issue_number: N, body: "...")
```

---

### 2.16 View Issue Details

**Tool: MCP** (`issue_read`)

```
issue_read(owner, repo, issue_number: N)
```

Returns full issue including node ID, which is needed for sub-issue linking.

---

### 2.17 Search Issues or PRs

**Tool: MCP** (`search_issues` / `search_pull_requests`)

```
search_issues(owner, repo, query: "label:bug is:open")
```

For PRs by author, use `search_pull_requests` (not `list_pull_requests` — the latter does not support author filtering).

---

## 3. TPM / Scrum Master Workflows

### 3.1 Bootstrap Labels

**Tool: MCP** (`label_write` + `list_label`)

Run once at project start. Check existing first, then create missing ones:

```
list_label(owner, repo)

label_write(owner, repo, name: "epic",     color: "8B5CF6", description: "Top-level epic")
label_write(owner, repo, name: "story",    color: "3B82F6", description: "User story")
label_write(owner, repo, name: "task",     color: "10B981", description: "Implementation task")
label_write(owner, repo, name: "bug",      color: "EF4444", description: "Something is broken")
label_write(owner, repo, name: "p0",       color: "DC2626", description: "Critical priority")
label_write(owner, repo, name: "p1",       color: "F97316", description: "High priority")
label_write(owner, repo, name: "p2",       color: "FACC15", description: "Medium priority")
label_write(owner, repo, name: "p3",       color: "6B7280", description: "Low priority")
```

---

### 3.2 Create an EPIC

**Tool: MCP** (`issue_write`)

```
issue_write(method: "create", owner, repo,
  title: "EPIC: Feature Area Name",
  body: "## Goal\n...\n## Stories\n- [ ] ...",
  labels: ["epic"]
)
```

Note the returned `number` and `node_id` — needed for linking stories underneath.

---

### 3.3 Create a STORY under an EPIC

**Tool: MCP** (`issue_write` + `sub_issue_write`)

Step 1 — create the story issue:
```
issue_write(method: "create", owner, repo,
  title: "Story: As a user I want...",
  labels: ["story"]
)
→ returns { number: N, node_id: "..." }
```

Step 2 — link it as a child of the EPIC:
```
sub_issue_write(method: "add",
  owner, repo,
  issue_number: <EPIC number>,
  sub_issue_id: <story node_id as integer>
)
```

**Note:** `sub_issue_id` is the numeric part of the node ID, not the issue number. Extract from the `issue_write` create response — no extra read needed.

---

### 3.4 Create a TASK under a STORY

**Tool: MCP** — same pattern as §3.3, parent is the story instead of the epic.

```
issue_write(method: "create", ..., labels: ["task"])
sub_issue_write(method: "add", issue_number: <story number>, sub_issue_id: <task node_id>)
```

---

### 3.5 Reprioritize / Reorder Sub-Issues

**Tool: MCP** (`sub_issue_write`)

```
sub_issue_write(method: "reprioritize",
  owner, repo,
  issue_number: <parent>,
  sub_issue_id: <child to move>,
  before_id: <sibling to place before>   # or after_id
)
```

---

### 3.6 Add an Issue to the Project Board

**Tool: MCP** (`projects_write`)

```
projects_write(method: "add_project_item",
  owner: "Roudranil", owner_type: "user", project_number: 3,
  item_owner: "Roudranil", item_repo: "variance",
  item_type: "issue", issue_number: N
)
→ returns item_id (needed for all subsequent field updates on this item)
```

---

### 3.7 Set Status on Board (Kanban column)

**Tool: MCP** (`projects_write`)

```
projects_write(method: "update_project_item",
  owner: "Roudranil", owner_type: "user", project_number: 3,
  item_id: <item_id>,
  updated_field: {
    id: "PVTSSF_lAHOA51EZs4BUfV9zhBnGqE",   # Status field
    value: "f75ad846"    # Todo
          "47fc9ee4"    # In Progress
          "98236657"    # Done
  }
)
```

---

### 3.8 Set Start Date / Target Date (Roadmap)

**Tool: MCP** (`projects_write`)

```
# Start date
projects_write(method: "update_project_item", ...,
  updated_field: { id: "PVTF_lAHOA51EZs4BUfV9zhBnHAA", value: "2026-05-01" }
)

# Target date
projects_write(method: "update_project_item", ...,
  updated_field: { id: "PVTF_lAHOA51EZs4BUfV9zhBnHAE", value: "2026-05-31" }
)
```

---

### 3.9 Assign to Iteration (Sprint)

**Tool: MCP** (`projects_write`)

```
projects_write(method: "update_project_item", ...,
  updated_field: { id: "PVTIF_lAHOA51EZs4BUfV9zhBnG_4", value: "<iteration_id>" }
)
```

Get iteration IDs from: `gh-cc-var project field-list 3 --owner Roudranil --format json` — iteration options are nested under the field.

---

### 3.10 Assign to Quarter

**Tool: MCP** (`projects_write`) — same as §3.9 but with Quarter field ID `PVTIF_lAHOA51EZs4BUfV9zhBnG_8`.

---

### 3.11 Link a PR to the Project Board

**Tool: MCP** (`projects_write`)

```
projects_write(method: "add_project_item",
  owner: "Roudranil", owner_type: "user", project_number: 3,
  item_owner: "Roudranil", item_repo: "variance",
  item_type: "pull_request", pull_request_number: N
)
```

If the PR body already contains `Closes #N`, the `Linked pull requests` field on the issue's project item auto-populates — no manual step needed.

---

### 3.12 View Project Board State

**Tool: `gh-cc-var`** (MCP reads are 403)

```bash
# All items on board
gh-cc-var project item-list 3 --owner Roudranil

# Items with field values
gh-cc-var project item-list 3 --owner Roudranil --format json

# Board summary
gh-cc-var project view 3 --owner Roudranil

# Fields + option IDs
gh-cc-var project field-list 3 --owner Roudranil --format json
```

---

### 3.13 List Open Issues (by label / sprint)

**Tool: MCP** (`list_issues`)

```
list_issues(owner, repo, state: "OPEN")
list_issues(owner, repo, state: "OPEN", labels: ["epic"])
list_issues(owner, repo, state: "OPEN", labels: ["bug", "p0"])
```

Response shape: `{ issues[], totalCount, pageInfo }`. Paginate with `after: pageInfo.endCursor`.

---

### 3.14 Search Issues

**Tool: MCP** (`search_issues`)

```
search_issues(owner, repo, query: "label:story is:open sprint:2")
search_issues(owner, repo, query: "is:open assignee:Roudranil label:task")
```

---

### 3.15 Post a Project Status Update

**Tool: MCP** (`projects_write`)

```
projects_write(method: "create_project_status_update",
  owner: "Roudranil", owner_type: "user", project_number: 3,
  status: "ON_TRACK",           # ON_TRACK / AT_RISK / OFF_TRACK / COMPLETE / INACTIVE
  start_date: "2026-05-01",
  target_date: "2026-05-31",
  body: "Sprint 1 on track. Auth module complete, ledger in progress."
)
```

---

### 3.16 Close or Reopen an Issue

**Tool: MCP** (`issue_write`)

```
# Close
issue_write(method: "update", owner, repo, issue_number: N,
  state: "closed", state_reason: "completed"  # or "not_planned" / "duplicate"
)

# Reopen
issue_write(method: "update", owner, repo, issue_number: N, state: "open")
```

---

### 3.17 Remove an Item from the Project Board

**Tool: MCP** (`projects_write`)

```
projects_write(method: "delete_project_item",
  owner: "Roudranil", owner_type: "user", project_number: 3,
  item_id: <item_id>
)
```

---

## 4. variance Project — Field Reference

Project ID: `PVT_kwHOA51EZs4BUfV9` | Project number: `3`

| Field | Type | ID | Notes |
|-------|------|----|-------|
| Title | ProjectV2Field | `PVTF_lAHOA51EZs4BUfV9zhBnGp8` | |
| Assignees | ProjectV2Field | `PVTF_lAHOA51EZs4BUfV9zhBnGqA` | |
| Status | SingleSelect | `PVTSSF_lAHOA51EZs4BUfV9zhBnGqE` | Todo `f75ad846` / In Progress `47fc9ee4` / Done `98236657` |
| Labels | ProjectV2Field | `PVTF_lAHOA51EZs4BUfV9zhBnGqI` | |
| Linked pull requests | ProjectV2Field | `PVTF_lAHOA51EZs4BUfV9zhBnGqM` | Auto-populated via `Closes #N` |
| Milestone | ProjectV2Field | `PVTF_lAHOA51EZs4BUfV9zhBnGqQ` | |
| Repository | ProjectV2Field | `PVTF_lAHOA51EZs4BUfV9zhBnGqU` | |
| Reviewers | ProjectV2Field | `PVTF_lAHOA51EZs4BUfV9zhBnGqY` | |
| Parent issue | ProjectV2Field | `PVTF_lAHOA51EZs4BUfV9zhBnGqc` | |
| Sub-issues progress | ProjectV2Field | `PVTF_lAHOA51EZs4BUfV9zhBnGqg` | |
| Team | SingleSelect | `PVTSSF_lAHOA51EZs4BUfV9zhBnG_0` | Squad 1 `9282166a` / Squad 2 `8a5d08e5` / Squad 3 `478d0b17` |
| Iteration | IterationField | `PVTIF_lAHOA51EZs4BUfV9zhBnG_4` | Sprint-level; get option IDs via `field-list` |
| Quarter | IterationField | `PVTIF_lAHOA51EZs4BUfV9zhBnG_8` | Quarter-level; get option IDs via `field-list` |
| Start date | ProjectV2Field | `PVTF_lAHOA51EZs4BUfV9zhBnHAA` | YYYY-MM-DD |
| Target date | ProjectV2Field | `PVTF_lAHOA51EZs4BUfV9zhBnHAE` | YYYY-MM-DD |

---

## 5. Known Hard Limits

| Limit | Detail |
|-------|--------|
| No branch listing via MCP | Use `gh-cc-var api repos/Roudranil/variance/branches --jq '.[].name'` |
| All project reads = 403 via MCP | Use `gh-cc-var project ...` for all reads |
| Issue types unavailable | Personal account — org-only GitHub feature |
| View layout changes | GitHub UI only |
| `projects_list` without `owner_type` | Returns misleading "not found" — always pass `owner_type: "user"` |

---

## 6. Response Shape Reference

| Tool | Shape | Pagination |
|------|-------|-----------|
| `list_issues` | `{ issues[], totalCount, pageInfo }` | `after: pageInfo.endCursor` |
| `list_pull_requests` | `[ ...pr ]` plain array | `page` + `perPage` |
| `actions_list` | `{ total_count, workflows[] / runs[] / ... }` | `page` + `per_page` |

---

## 7. Repo State (as of 2026-04-19)

- **Branches**: `main` only
- **Open Issues**: None
- **Open PRs**: None
- **GitHub Actions**: None configured
- **Projects on account**: `variance` (#3) ✅ | `Lattice` (#2) ❌ OFF LIMITS — never touch
