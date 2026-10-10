# Commands Inventory

Status key: `planned` → `drafting` → `in use` → `stable`
Priority: **P1** build first (core loop) · **P2** next · **P3** later or nice-to-have

## Slash commands

### Phase 1 — Intake & analysis

| Command | Purpose | Inputs | Outputs | Priority | Status |
|---|---|---|---|---|---|
| `/ticket-init <KEY>` | Create the ticket folder. Pull the ticket from Jira (MCP), or take it pasted. Record affected repos and create branches/worktrees. | Jira key or pasted ticket | `ticket.md`, folder skeleton, branches | P1 | drafting |
| `/analyze-ticket` | Full analysis against the Definition of Ready: scope, impacted repos, risks, assumptions, edge cases. Uses parallel explorer agents per repo. | `ticket.md`, repos | `analysis.md`, `open-questions.md` | P1 | drafting |
| `/update-analysis` | Apply BA/PO answers as a **delta**: update only affected sections and log the changes. | `open-questions.md` with answers | Updated `analysis.md`, change log entry | P1 | drafting |

### Phase 2 — Planning

| Command | Purpose | Inputs | Outputs | Priority | Status |
|---|---|---|---|---|---|
| `/plan-ticket` | Plan plus task breakdown in one pass: contracts first, deploy order, backward compatibility, flags, migration safety, rollback, AC → task mapping. | `analysis.md` | `plan.md`, `tasks.md` | P1 | drafting |
| `/e2e-plan` | Write the Playwright test plan from the ACs and approved plan: which ACs get e2e coverage, scenarios, test data, required selectors (fed back into feature tasks), then append `e2e` tasks for the Playwright repo to `tasks.md`. Replaces the manual hand-over doc. Can run right after plan approval, before any code. You decide coverage; notes passed as arguments override its proposal. | `ticket.md`, `plan.md`, Playwright repo `CLAUDE.md` | `e2e-plan.md`, e2e tasks in `tasks.md` | P1 | drafting |
| `/jira-test-plan [draft\|evidence]` | Generate the **stakeholder** test plan from `e2e-plan.md`: plain language, sanitized of file paths, repo names, task IDs, SHAs and internal URLs (with a mechanical check). `draft` is for early coverage confirmation with the BA/PO. `evidence` runs the e2e specs locally, captures one screenshot per test item into the ticket folder (`<KEY>_TP-01.png`…), and fills in Result and Evidence. | `e2e-plan.md`, `ticket.md`, local stack | `test-plan-jira.md`, `evidence/*.png` | P1 | drafting |

### Phase 3 — Build

| Command | Purpose | Inputs | Outputs | Priority | Status |
|---|---|---|---|---|---|
| `/build-task [id\|next]` | The core loop: pick task → minimal context → failing specs → implement → verify → independent review → human approval → commit → mark done → stop. | `tasks.md`, plan section | Commits, updated `tasks.md`. **E2E variant:** for `e2e` tasks, writes the Playwright spec per the repo's guidelines, runs it locally twice, and triages failures (test bug / app bug / pre-existing, checked against `main`). | P1 | drafting |
| `/review-task [id]` | Run the independent review on its own (also called by `/build-task`). Checks against the task's ACs plus the review skill. | Task diff, task entry | Review findings | P1 | drafting |
| `/ticket-status` | Show done, blocked, ACs without passing specs, and branches ready to push. | `tasks.md`, repos | Status report | P2 | planned |

### Phase 4 — Ship

| Command | Purpose | Inputs | Outputs | Priority | Status |
|---|---|---|---|---|---|
| `/dod-check` | Definition of Done gate: every AC traced to a passing spec, lint/security clean, docs/changelog, monitoring where relevant. | Ticket folder, repos | Pass/fail checklist | P2 | planned |
| `/pr-describe [repo] [--refresh]` | Create the PR description from `templates/pr-description.md` (or the repo's own PR template, filled first). Runs specs, RuboCop and Brakeman for the **Test results** section, and records the SHA they're for. `--refresh` regenerates only the sections the latest changes affect, appends a **Revisions** entry, and keeps human edits outside the section markers. Shows the result for approval before updating the PR. | Ticket folder, repo, PR | PR title and body (via `gh pr edit`) | P2 | drafting |

### Phase 5 — Review & close

| Command | Purpose | Inputs | Outputs | Priority | Status |
|---|---|---|---|---|---|
| `/resolve-review [pr]` | Pull unresolved review threads, review summaries and PR comments (including bot reviews) via `gh`. Triage each as fix / discuss / decline with reason, and **wait for approval of the triage**. Fix as small commits, run checks, push on approval, then draft one reply per thread citing the fix SHA and **wait for approval before posting**. Finally, run `/pr-describe --refresh` if the fixes changed what the description says. | PR review threads | Commits, posted replies, refreshed description | P1 | drafting |
| `/capture-learnings` | Turn recurring review findings and surprises into `CLAUDE.md` rules or review-skill references. Proposes diffs for approval. | Review history, ticket notes | Proposed rule changes | P3 | planned |
| `/ticket-retro` | Record metrics: open questions count, review rounds, cycle time, plan deviations. | Ticket folder, PRs | `retro.md`, metrics log entry | P3 | planned |

## Agents (subagents)

| Agent | Purpose | Used by | Priority | Status |
|---|---|---|---|---|
| `task-reviewer` | Fresh-context reviewer. Didn't write the code. Uses the org review skill and checks the task's ACs. | `/build-task`, `/review-task` | P1 | drafting |
| `repo-explorer` | Read-only investigation of one repo; returns a summary, not file dumps. Run one per affected repo in parallel. | `/analyze-ticket`, `/plan-ticket` | P1 | drafting |
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
| `ticket.md` | `/ticket-init` | P1 | drafting |
| `analysis.md` (doubles as the Definition of Ready checklist) | `/analyze-ticket` | P1 | drafting |
| `open-questions.md` (answerable inline by BA/PO) | `/analyze-ticket` | P1 | drafting |
| `plan.md` | `/plan-ticket` | P1 | drafting |
| `tasks.md` (machine-friendly task format) | `/plan-ticket`, `/build-task` | P1 | drafting |
| `e2e-plan.md` (replaces the manual hand-over doc) | `/e2e-plan`, `/build-task` | P1 | drafting |
| `test-plan-jira.md` (stakeholder test plan for the Jira comment) | `/jira-test-plan` | P1 | drafting |
| `pr-description.md` (sections wrapped in `awf:` markers so `--refresh` can update them in place) | `/pr-describe` | P2 | drafting |
| `CLAUDE.md` starter for service repos | Manual | P2 | planned |

## Suggested build order

1. **Templates:** `tasks.md`, `analysis.md`, `plan.md`. Everything else reads or writes these.
2. **Core loop:** `/build-task` (including the e2e variant), `task-reviewer`, `/e2e-plan`, and the lint and tests hooks.
3. **PR loop:** `/pr-describe` (with `--refresh`) and `/resolve-review`. You already do this daily, and it doesn't need the rest of the kit to be useful.
4. **Front of the pipeline:** `/ticket-init`, `/analyze-ticket`, `/update-analysis`, `/plan-ticket`, `repo-explorer`.
5. **Shipping gate:** `/dod-check`.
6. **Learning loop:** `/capture-learnings`, `/ticket-retro`.

Start with the templates and the core loop, because the build phase is where most of your hours go. Test them on one real ticket before building the rest.
