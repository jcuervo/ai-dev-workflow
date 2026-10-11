# Commands Inventory

Status key: `planned` → `drafting` → `in use` → `stable`
Priority: **P1** build first (core loop) · **P2** next · **P3** later or nice-to-have

## Slash commands

### Per repo (once)

| Command | Purpose | Inputs | Outputs | Priority | Status |
|---|---|---|---|---|---|
| `/repo-setup [repo] [--update]` | Read the repo (Gemfile, compose files, CI, bin wrappers, specs). If the team has instructions (`CLAUDE.md`, `.claude/rules/`, `AGENTS.md`), audit them and put only the gaps and corrections in a personal, git-ignored `CLAUDE.local.md`, with an optional patch to propose to the team. If not, draft a `CLAUDE.md`. Writes per-repo hook commands to `.git/awf.env`. | Repo, registry | `CLAUDE.local.md` or `CLAUDE.md`, `.git/awf.env`, optional team patch | P1 | drafting |

### Phase 1 — Intake & analysis

| Command | Purpose | Inputs | Outputs | Priority | Status |
|---|---|---|---|---|---|
| `/ticket-init <KEY>` | Create the ticket folder and `ticket.md` (Jira via MCP, paste or file), number the ACs, and propose **candidate repos** with roles from the registry. Creates no branches. | Jira key, ticket text, repo registry | `ticket.md`, folder skeleton | P1 | in use |
| `/ticket-repos [setup\|add\|status\|sync\|release]` | Create the ticket branch in every `change`/`e2e` repo (branch mode: in your clones; worktree mode: separate checkouts), put `run` repos on their latest default branch, add a repo mid-ticket, sync branches with the default (rebase or merge, conflicts with approval), check stack state before e2e, and switch clones back when done. Never stashes or discards. | `ticket.md`, repo registry | Branches, `repos/` links, updated table | P1 | drafting |
| `/analyze-ticket` | Explores candidate repos read-only, follows dependencies to other services, confirms repos and roles (`change`/`e2e`/`run`/`reference`). Full analysis against the Definition of Ready: scope, impacted repos, risks, assumptions, edge cases. Uses parallel explorer agents per repo. | `ticket.md`, repos | `analysis.md`, `open-questions.md` | P1 | in use |
| `/update-analysis` | Apply BA/PO answers as a **delta**: update only affected sections and log the changes. Mid-build (plan approved), propose the task, contract and e2e delta for approval. | `open-questions.md` with answers | Updated `analysis.md`, change log entry | P1 | in use |

### Phase 2 — Planning

| Command | Purpose | Inputs | Outputs | Priority | Status |
|---|---|---|---|---|---|
| `/plan-ticket` | Plan plus task breakdown in one pass: contracts first, deploy order, backward compatibility, flags, migration safety, rollback, AC → task mapping. | `analysis.md` | `plan.md`, `tasks.md` | P1 | in use |
| `/e2e-plan` | Write the Playwright test plan from the ACs and approved plan: which ACs get e2e coverage, scenarios, test data, required selectors (fed back into feature tasks), then append `e2e` tasks for the Playwright repo to `tasks.md`. Replaces the manual hand-over doc. Can run right after plan approval, before any code. You decide coverage; notes passed as arguments override its proposal. | `ticket.md`, `plan.md`, Playwright repo `CLAUDE.md` | `e2e-plan.md`, e2e tasks in `tasks.md` | P1 | in use |
| `/test-plan [draft\|evidence] [markdown\|jira\|html]` | Generate the **stakeholder** test plan from `e2e-plan.md`: plain language, sanitized of file paths, repo names, task IDs, SHAs and internal URLs (with a mechanical check). `draft` is for early coverage confirmation with the BA/PO. `evidence` runs the e2e specs locally, captures one screenshot per test item into the ticket folder (`<KEY>_TP-01.png`…), and fills in Result and Evidence. | `e2e-plan.md`, `ticket.md`, local stack | `test-plan.md`, `evidence/*.png` | P1 | drafting |

### Phase 3 — Build

| Command | Purpose | Inputs | Outputs | Priority | Status |
|---|---|---|---|---|---|
| `/build-task [id\|next]` | The core loop: pick task → minimal context → failing specs → implement → verify → independent review → human approval → commit → mark done → stop. | `tasks.md`, plan section | Commits, updated `tasks.md`. **E2E variant:** for `e2e` tasks, writes the Playwright spec per the repo's guidelines, runs it locally twice, and triages failures (test bug / app bug / pre-existing, checked against `main`). | P1 | in use |
| `/review-task [id]` | Run the independent review on its own (also called by `/build-task`), against the task's ACs plus the review skill, and save it to `reviews/T#.md`. Also for retroactive reviews of done tasks. | Task diff, task entry | Review findings | P1 | in use |
| `/ticket-status` | One read-only screen: tasks and review verdicts, AC coverage, repos and branches (including behind default), PR/MR state across repos (CI, review decision, unresolved threads), evidence completeness, and the next action. | Ticket folder, repos, code host | Status report | P2 | drafting |

### Phase 4 — Ship

| Command | Purpose | Inputs | Outputs | Priority | Status |
|---|---|---|---|---|---|
| `/ticket-ship [check]` | Definition of Done across all repos (`check` stops there), then sync check, push every `change`/`e2e` repo, create or update all PRs/MRs via `/pr-describe` in deploy order with cross-links, and mark them ready. Replaces the planned `/dod-check`. | Ticket folder, repos, code host | Pushed branches, cross-linked PRs | P1 | drafting |
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
| `task-reviewer` | Fresh-context reviewer. Didn't write the code. Uses the org review skill and checks the task's ACs. | `/build-task`, `/review-task` | P1 | in use |
| `repo-explorer` | Read-only investigation of one repo; returns a summary, not file dumps. Run one per affected repo in parallel. | `/analyze-ticket`, `/plan-ticket` | P1 | in use |
| `contract-checker` | Compares API/event contracts across repos for mismatches and compatibility breaks. | `/plan-ticket`, `/ticket-ship` | P3 | planned |

## Hooks

| Hook | Trigger | Action | Priority | Status |
|---|---|---|---|---|
| Lint & format (`rubocop-on-edit.sh`) | After each edit | RuboCop on the edited Ruby file; offenses fed back to Claude. Autocorrect opt-in | P1 | drafting |
| Tests gate (`specs-before-commit.sh`) | Before `git commit` | Run specs related to changed files; block on failure | P1 | drafting |
| Security scan (`security-before-commit.sh`) | Before `git commit` | Brakeman (warnings in changed files only), bundler-audit when `Gemfile.lock` changed | P2 | drafting |
| Commit message (`commit-message-check.sh`) | Before `git commit` | Deny AI attribution (Co-Authored-By, "Generated with Claude") in commit messages | P1 | drafting |
| Review gate (`review-before-commit.sh`) | Before `git commit` | Task commits need `reviews/T#.md` with a verdict other than `not ready` | P1 | drafting |
| Protected files (`protected-files.sh`) | Before edit | Deny edits to secrets and generated files (`protected-paths.txt`), with what to do instead | P2 | drafting |

## Reference docs

| Doc | Purpose |
|---|---|
| `docs/models.md` | Model and effort tier per command and agent, override behaviour, session-model strategy, token-saving habits |
| `docs/code-hosts.md` | Host detection (GitHub, GitLab, Azure DevOps, other), CLI commands per operation, manual mode, and which account is used |

## Scripts

| Script | Purpose | Status |
|---|---|---|
| `install.sh` | Per-machine setup: links, env vars, tickets folder, registry, hooks. Safe to re-run | drafting |
| `bin/awf-repos-scan` | Build or extend the repo registry from a folder of clones; keeps existing entries | drafting |

## Templates

| Template | Used by | Priority | Status |
|---|---|---|---|
| `ticket.md` | `/ticket-init` | P1 | in use |
| `analysis.md` (doubles as the Definition of Ready checklist) | `/analyze-ticket` | P1 | in use |
| `open-questions.md` (answerable inline by BA/PO) | `/analyze-ticket` | P1 | in use |
| `plan.md` | `/plan-ticket` | P1 | in use |
| `tasks.md` (machine-friendly task format) | `/plan-ticket`, `/build-task` | P1 | in use |
| `e2e-plan.md` (replaces the manual hand-over doc) | `/e2e-plan`, `/build-task` | P1 | in use |
| `test-plan.md` (stakeholder test plan for the Jira comment) | `/test-plan` | P1 | drafting |
| `commit-message.md`: `<KEY>: <imperative summary>`, optional why-body, no task number, no trailers | `/build-task`, `/resolve-review` | P1 | drafting |
| `pr-description.md` (sections wrapped in `awf:` markers so `--refresh` can update them in place) | `/pr-describe` | P2 | drafting |
| `repo-CLAUDE.md`: starter for service repos (stack, exact commands, conventions, integrations, gotchas) | `/repo-setup` | P2 | drafting |

## Suggested build order

1. **Templates:** `tasks.md`, `analysis.md`, `plan.md`. Everything else reads or writes these.
2. **Core loop:** `/build-task` (including the e2e variant), `task-reviewer`, `/e2e-plan`, and the lint and tests hooks.
3. **PR loop:** `/pr-describe` (with `--refresh`) and `/resolve-review`. You already do this daily, and it doesn't need the rest of the kit to be useful.
4. **Front of the pipeline:** `/ticket-init`, `/analyze-ticket`, `/update-analysis`, `/plan-ticket`, `repo-explorer`.
5. **Shipping:** `/ticket-ship`, `/ticket-status`.
6. **Learning loop:** `/capture-learnings`, `/ticket-retro`.

Start with the templates and the core loop, because the build phase is where most of your hours go. Test them on one real ticket before building the rest.
