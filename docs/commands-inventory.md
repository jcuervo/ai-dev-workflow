# Commands Inventory

Status key: `planned` → `drafting` → `in use` → `stable`
Priority: **P1** build first (core loop) · **P2** next · **P3** later or nice-to-have

## Slash commands

### Phase 1 — Intake & analysis

| Command | Purpose | Inputs | Outputs | Priority | Status |
|---|---|---|---|---|---|
| `/ticket-init <KEY>` | Create the ticket folder. Pull the ticket from Jira (MCP), or take it pasted. Record affected repos and create branches/worktrees. | Jira key or pasted ticket | `ticket.md`, folder skeleton, branches | P1 | planned |
| `/analyze-ticket` | Full analysis against the Definition of Ready: scope, impacted repos, risks, assumptions, edge cases. Uses parallel explorer agents per repo. | `ticket.md`, repos | `analysis.md`, `open-questions.md` | P1 | planned |
| `/update-analysis` | Apply BA/PO answers as a **delta**: update only affected sections and log the changes. | `open-questions.md` with answers | Updated `analysis.md`, change log entry | P1 | planned |

### Phase 2 — Planning

| Command | Purpose | Inputs | Outputs | Priority | Status |
|---|---|---|---|---|---|
| `/plan-ticket` | Plan plus task breakdown in one pass: contracts first, deploy order, backward compatibility, flags, migration safety, rollback, AC → task mapping. | `analysis.md` | `plan.md`, `tasks.md` | P1 | planned |

### Phase 3 — Build

| Command | Purpose | Inputs | Outputs | Priority | Status |
|---|---|---|---|---|---|
| `/build-task [id\|next]` | The core loop: pick task → minimal context → failing specs → implement → verify → independent review → human approval → commit → mark done → stop. | `tasks.md`, plan section | Commits, updated `tasks.md` | P1 | planned |
| `/review-task [id]` | Run the independent review on its own (also called by `/build-task`). Checks against the task's ACs plus the review skill. | Task diff, task entry | Review findings | P1 | planned |
| `/ticket-status` | Show done, blocked, ACs without passing specs, and branches ready to push. | `tasks.md`, repos | Status report | P2 | planned |

### Phase 4 — Ship

| Command | Purpose | Inputs | Outputs | Priority | Status |
|---|---|---|---|---|---|
| `/dod-check` | Definition of Done gate: every AC traced to a passing spec, lint/security clean, docs/changelog, monitoring where relevant. | Ticket folder, repos | Pass/fail checklist | P2 | planned |
| `/pr-describe [repo]` | Generate the PR description per repo: ticket link, plan summary, AC → spec table, cross-repo PR links, risky areas, deploy order. | Ticket folder | PR body (via `gh`) | P2 | planned |

### Phase 5 — Review & close

| Command | Purpose | Inputs | Outputs | Priority | Status |
|---|---|---|---|---|---|
| `/resolve-review [pr]` | Pull PR review comments (`gh`), triage them (fix / discuss / decline with reason), fix as task-scoped commits, draft replies for you to post. | PR comments | Commits, reply drafts | P2 | planned |
| `/capture-learnings` | Turn recurring review findings and surprises into `CLAUDE.md` rules or review-skill references. Proposes diffs for approval. | Review history, ticket notes | Proposed rule changes | P3 | planned |
| `/ticket-retro` | Record metrics: open questions count, review rounds, cycle time, plan deviations. | Ticket folder, PRs | `retro.md`, metrics log entry | P3 | planned |

## Agents (subagents)

| Agent | Purpose | Used by | Priority | Status |
|---|---|---|---|---|
| `task-reviewer` | Fresh-context reviewer. Didn't write the code. Uses the org review skill and checks the task's ACs. | `/build-task`, `/review-task` | P1 | planned |
| `repo-explorer` | Read-only investigation of one repo; returns a summary, not file dumps. Run one per affected repo in parallel. | `/analyze-ticket`, `/plan-ticket` | P1 | planned |
| `contract-checker` | Compares API/event contracts across repos for mismatches and compatibility breaks. | `/plan-ticket`, `/dod-check` | P3 | planned |

## Hooks

| Hook | Trigger | Action | Priority | Status |
|---|---|---|---|---|
| Lint & format | After edits / before stop | RuboCop (autocorrect safe cops) on changed files | P1 | planned |
| Tests gate | Before commit / stop | Run related specs and block on failure | P1 | planned |
| Security scan | Before commit | Brakeman, bundler-audit | P2 | planned |
| Protected files | Before edit | Block edits to secrets, credentials, `schema.rb` hand-edits, etc. | P2 | planned |

## Templates

| Template | Used by | Priority | Status |
|---|---|---|---|
| `ticket.md` | `/ticket-init` | P1 | planned |
| `analysis.md` (doubles as the Definition of Ready checklist) | `/analyze-ticket` | P1 | planned |
| `open-questions.md` (answerable inline by BA/PO) | `/analyze-ticket` | P1 | planned |
| `plan.md` | `/plan-ticket` | P1 | planned |
| `tasks.md` (machine-friendly task format) | `/plan-ticket`, `/build-task` | P1 | planned |
| `pr-description.md` | `/pr-describe` | P2 | planned |
| `CLAUDE.md` starter for service repos | Manual | P2 | planned |

## Suggested build order

1. **Templates:** `tasks.md`, `analysis.md`, `plan.md`. Everything else reads or writes these.
2. **Core loop:** `/build-task`, `task-reviewer`, and the lint and tests hooks.
3. **Front of the pipeline:** `/ticket-init`, `/analyze-ticket`, `/update-analysis`, `/plan-ticket`, `repo-explorer`.
4. **Shipping:** `/pr-describe`, `/dod-check`, `/resolve-review`.
5. **Learning loop:** `/capture-learnings`, `/ticket-retro`.

Start with the templates and the core loop, because the build phase is where most of your hours go. Test them on one real ticket before building the rest.
