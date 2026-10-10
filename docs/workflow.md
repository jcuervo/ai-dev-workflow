# Workflow: Jira Ticket → Merged PRs

The working procedure for taking one ticket through Claude Code across one or more service repos. Commands referenced here are listed in [`commands-inventory.md`](commands-inventory.md).

> This is a living document. When the procedure changes, update this file and add a line to `CHANGELOG.md`.

---

## Overview

| # | Phase | Command(s) | Artifact | Gate (who approves) |
|---|---|---|---|---|
| 0 | Setup | `/ticket-init` | `ticket.md`, branches | — |
| 1 | Analysis | `/analyze-ticket` | `analysis.md`, `open-questions.md` | **G1** BA/PO answer questions |
| 2 | Clarify | `/update-analysis` | updated `analysis.md` | **G2** Definition of Ready met |
| 3 | Plan | `/plan-ticket` | `plan.md`, `tasks.md` | **G3** You approve plan |
| 4 | Build | `/build-task next` (repeat) | commits, `tasks.md` status | **G4** You approve each task commit |
| 5 | Ship | `/dod-check`, `/pr-describe` | PRs per repo | **G5** Definition of Done met |
| 6 | Review | `/resolve-review` | fix commits, replies | **G6** Reviewers approve |
| 7 | Close | `/capture-learnings`, `/ticket-retro` | rule updates, `retro.md` | — |

---

## Folder layout

The ticket workspace lives **outside** this repo and outside the service repos, so ticket content is never committed anywhere it shouldn't be.

```
~/work/tickets/PROJ-123/
├── ticket.md            # source ticket: description, requirements, ACs
├── analysis.md          # current analysis (versioned via change log section)
├── open-questions.md    # Q&A with BA/PO, answered inline
├── plan.md              # approved plan
├── tasks.md             # task list — source of truth during build
├── notes.md             # decisions, deviations, surprises (append-only)
├── retro.md             # metrics and learnings at close
└── repos/               # git worktrees, one per affected repo
    ├── billing-service/
    └── orders-service/
```

- Branch naming: `PROJ-123-short-description`, the same name in every affected repo.
- Each repo keeps its own `CLAUDE.md` (commands, conventions, gotchas). The ticket folder can hold a ticket-level `CLAUDE.md` describing how the services interact for this ticket.

---

## Phase 0 — Setup

1. Run `/ticket-init PROJ-123`. It pulls the ticket from Jira via MCP, or you paste it in.
2. Confirm the list of affected repos.
3. Worktrees and branches are created under `repos/`.

**Done when:** `ticket.md` exists and every affected repo has a branch.

## Phase 1 — Analysis

1. Run `/analyze-ticket`. It runs one `repo-explorer` agent per repo in parallel and synthesizes the results.
2. `analysis.md` covers scope, affected repos and modules, data and migration impact, edge cases, error states, permissions, non-functional needs, risks and assumptions.
3. `open-questions.md` lists each question with a reason it matters and an empty **Answer** field.
4. Send the questions to the BA/PO, ideally as a Jira comment.

**Gate G1:** questions answered, or explicitly deferred with an agreed assumption.

> For a large or fuzzy ticket, a short three-amigos call (dev, BA, QA) is often faster than written Q&A.

## Phase 2 — Clarify

1. Paste the answers inline into `open-questions.md`.
2. Run `/update-analysis`. It updates **only** the affected sections and appends a change log entry. It doesn't re-run the full analysis.

**Gate G2 — Definition of Ready:**
- [ ] Every AC is testable and unambiguous
- [ ] Edge cases and error states are defined
- [ ] Affected repos and contracts are known
- [ ] Data migration needs are known
- [ ] No unanswered blocking questions

## Phase 3 — Plan

1. Run `/plan-ticket` (in plan mode). It produces `plan.md` and `tasks.md` together.
2. The plan must state:
   - **Contracts first:** API payloads, events and schema changes, agreed before implementation.
   - **Deploy order** and **backward compatibility:** can each repo ship independently?
   - **Feature flags**, if any.
   - **Migration safety:** online migrations, backfills, locking.
   - **Rollback plan.**
   - **AC → task mapping:** every AC is covered by at least one task.

**Gate G3:** you review and approve. Edit the files directly if needed. Approved plans are not re-generated; changes go through `notes.md`.

### Task format (`tasks.md`)

Each task must be buildable in a fresh session with no conversation history.

```markdown
## T3 — Add refund webhook handler
- Repo: billing-service
- Status: todo            # todo | in-progress | review | done | blocked
- Depends on: T1, T2
- ACs: AC2, AC4
- Specs: spec/requests/webhooks/refunds_spec.rb (new)
- Plan section: plan.md#refund-webhooks
- Notes:
```

Rules:
- **One task = one repo.** Split a task that touches two repos.
- Small enough to review in one sitting (rough guide: under ~300 changed lines).
- Out-of-scope discoveries become new tasks; they don't get folded into the current one.

## Phase 4 — Build

Run in a loop, **one task per session:**

```
/build-task next      →  review & approve  →  /clear  →  repeat
```

What `/build-task` does:

1. Picks the given or next unblocked `todo` task and marks it `in-progress`.
2. Loads minimal context: the task, its plan section, and the repo's `CLAUDE.md`.
3. **Writes failing specs** for the task's ACs and confirms they fail for the right reason.
4. Implements until they pass, staying within task scope.
5. Verifies: related suite, RuboCop and Brakeman (also enforced by hooks).
6. Runs **independent review** with the `task-reviewer` agent in a fresh context, then fixes the findings.
7. Hands you a summary: diff overview, review findings, deviations from plan.
8. **Gate G4:** on your approval, commits only this task's changes, marks it `done` and stops.

Conventions:
- Commit message: `[PROJ-123][T3] Add refund webhook handler`
- **Push per task to a draft PR** so CI runs early. Don't wait until the end.
- Record any plan deviation in `notes.md`.
- Use `/ticket-status` any time to see progress, blockers and ACs without passing specs.

## Phase 5 — Ship

1. Run `/dod-check`.
2. Run `/pr-describe` for each repo, then mark the draft PRs ready for review.

**Gate G5 — Definition of Done:**
- [ ] Every AC traced to a passing spec
- [ ] CI green in every repo
- [ ] Lint and security scans clean
- [ ] Migrations reviewed for safety
- [ ] Docs, changelog and README updated where relevant
- [ ] Logging and monitoring added where relevant
- [ ] Cross-repo PRs link to each other, with deploy order stated

### PR description contents
Ticket link · short plan summary · AC → spec table · linked PRs in other repos · deploy order · risky areas for reviewers · rollback notes.

## Phase 6 — Review

1. Run `/resolve-review <pr>`. It pulls the comments and triages each: **fix**, **discuss**, or **decline with a reason**.
2. Fixes go in as small, separate commits.
3. Claude drafts replies; **you post them**.

**Gate G6:** reviewers approve.

## Phase 7 — Close

1. Run `/capture-learnings`. Repeated review findings become proposed `CLAUDE.md` rules or review-skill references, and you approve each.
2. Run `/ticket-retro` to record the metrics below.

---

## Metrics

Tracked per ticket in `retro.md`, plus a rolling log in this repo (`metrics.md`, no client details):

| Metric | Why |
|---|---|
| Open questions at G1 | Measures incoming ticket quality |
| Plan deviations | Measures analysis and plan accuracy |
| Review rounds per PR | Measures build and review quality |
| Repeat review findings | Shows whether learnings stick |
| Ticket start → merge time | Overall throughput |

---

## Context hygiene

- Start each phase and each task in a fresh session (`/clear`). Files carry the state.
- Keep repo `CLAUDE.md` files short and current.
- Ask for subagents explicitly when exploring several repos or reviewing, so the main context stays clean.

---

## Open decisions

| # | Decision | Options | Status |
|---|---|---|---|
| D1 | Packaging the kit | Copy into `~/.claude/` · symlink · plugin | open |
| D2 | Jira access | Atlassian MCP connector · paste in | open |
| D3 | Ticket workspace location | `~/work/tickets/` · elsewhere | open |
| D4 | Autonomy for trivial tasks | Always stop at G4 · allow chaining for flagged-trivial tasks | open |
| D5 | Automated first-pass PR review in CI | GitHub Action · none | open |
| D6 | Review skill integration | Reference the org skill · vendor a copy | open |
