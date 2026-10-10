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
| 3 | Plan | `/plan-ticket`, `/e2e-plan` | `plan.md`, `e2e-plan.md`, `tasks.md` | **G3** You approve plan and e2e plan |
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
├── e2e-plan.md          # internal Playwright test plan (replaces the hand-over doc)
├── test-plan-jira.md    # stakeholder test plan, posted to Jira as a comment
├── evidence/            # screenshots per test item: PROJ-123_TP-01.png…
├── tasks.md             # task list — source of truth during build
├── notes.md             # decisions, deviations, surprises (append-only)
├── retro.md             # metrics and learnings at close
└── repos/               # git worktrees, one per affected repo
    ├── billing-service/
    ├── orders-service/
    └── e2e-tests/       # the Playwright repo, same branch name
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

3. Run `/e2e-plan`. It decides which ACs need Playwright coverage, writes the scenarios, and lists the selectors and seed data the app must provide. It then appends `e2e` tasks for the Playwright repo to `tasks.md`.
   - Selectors are agreed **before** coding, so the feature tasks add them and the e2e tests don't depend on fragile DOM paths.
   - The Playwright repo is treated as one more affected repo: same branch name, its own worktree under `repos/`.

**Gate G3:** you review and approve the plan and the e2e plan. Edit the files directly if needed. Approved plans are not re-generated; changes go through `notes.md`.

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

E2E tasks run through the same loop, in the Playwright repo:
- The deliverable is the Playwright spec; there's no separate "failing spec first" step.
- The Playwright repo's own `CLAUDE.md` and guidelines govern structure and conventions.
- Verification is a **local** run against the stack on the ticket branches, run twice to catch flakiness. If the stack can't run, the minimum is `npx playwright test --list` plus a type check, and the task stays open until the tests have run.
- **Failure triage:** a failure is either a test bug (fix the test), an app bug from this ticket (goes back to its feature task), or possibly pre-existing. For the last, re-run the spec with the stack on `main`. If it fails there too, it's recorded in `notes.md`, marked per the repo's guidelines, and raised as a separate ticket rather than fixed here.
- You decide coverage. `/e2e-plan` proposes it, and your coverage notes override its judgment.

### Jira test plan and evidence

There's one source and two outputs. `e2e-plan.md` is the internal plan. `test-plan-jira.md` is generated from it for the BA/PO and posted to the ticket as a comment.

- **Test items have stable IDs** (TP-01, TP-02…), assigned in `e2e-plan.md`, including manual items with no automation. IDs are never renumbered.
- **`/jira-test-plan draft`** can go to the BA/PO as soon as the e2e plan is approved, to confirm coverage before the tests are written.
- **`/jira-test-plan evidence`** runs the e2e specs locally and captures one screenshot per test item at its evidence point. It fills in Result and Evidence. Screenshots are named `<KEY>_TP-NN.png`, so attaching them in Jira is a straight match against the Evidence column.
- **Sanitization is checked mechanically:** no file paths, repo or service names, task IDs, SHAs or internal URLs in the posted version.
- **Screenshots stay in the ticket folder,** never in the Playwright repo, because they can contain client data.
- How screenshots are captured follows the Playwright repo's conventions. If it has no evidence mechanism, adding one (e.g. env-gated `page.screenshot()` calls) needs your approval, so the shared suite isn't changed silently.
- E2E tasks depend on the feature tasks they cover, so they're built last. They can also be built earlier against an agreed UI if the selectors are settled.

Conventions:
- Commit message: `[PROJ-123][T3] Add refund webhook handler`
- **Push per task to a draft PR** so CI runs early. Don't wait until the end.
- Record any plan deviation in `notes.md`.
- Use `/ticket-status` any time to see progress, blockers and ACs without passing specs.

## Phase 5 — Ship

1. Run `/dod-check`.
2. Run `/pr-describe` for each repo. It:
   - Uses the repo's own `.github/pull_request_template.md` if there is one, then adds any of our sections it lacks
   - Runs the checks itself for the **Test results** section and records the SHA the results are for
   - Shows the title and body for your approval, then updates the draft PR and marks it ready for review

**Gate G5 — Definition of Done:**
- [ ] Every AC traced to a passing spec
- [ ] CI green in every repo
- [ ] Lint and security scans clean
- [ ] Migrations reviewed for safety
- [ ] Docs, changelog and README updated where relevant
- [ ] Logging and monitoring added where relevant
- [ ] Playwright PR included in the batch, covering every AC marked for e2e, with run results
- [ ] Jira test plan posted with evidence attached for every test item (`/jira-test-plan evidence`)
- [ ] Cross-repo PRs link to each other, with deploy order stated

### PR description standard
Template: [`templates/pr-description.md`](../templates/pr-description.md).

- **Title:** `[KEY] <imperative summary>`, specific enough to stand alone in `git log`. Not "Fix bug" or "Phase 1".
- **Sections:** Summary (what and why) · Related PRs and deploy order (including the Playwright PR) · Changes · Acceptance criteria → specs and e2e specs · Test results · How to test · Risk and rollout · Notes for reviewers · Revisions. No screenshots by team convention.
- **Readable without Jira.** Links can rot or be inaccessible to reviewers; the description should carry the essential context itself.
- **Test results are a snapshot.** Always state the SHA. Put long output in a collapsed `<details>` block; link CI instead of pasting full logs.
- **Keep it true.** The description must match the code at merge time. That's what the Revisions section and `--refresh` are for.

## Phase 6 — Review

Run `/resolve-review <pr>`, once per review round:

1. **Pull** unresolved review threads, review summaries and general PR comments, including bot or Claude reviews, via `gh`.
2. **Triage.** Each item becomes a table row: **fix** / **discuss** / **decline (with reason)** / **already addressed**. Related comments are grouped.
   **Gate:** you approve or adjust the triage before any code changes.
3. **Fix** each fix item as a small commit in its own repo. Commit message format: `[KEY] Address review: <summary>`.
4. **Verify:** related specs, RuboCop and Brakeman.
5. **Push.** **Gate:** you approve the push.
6. **Draft replies,** one per thread: what changed and the fix SHA, or the reasoning for discuss and decline items.
   **Gate:** you approve, edit or drop each reply before anything is posted.
7. **Post** the approved replies to their threads. Threads are **not** resolved by default; the reviewer resolves them (decision D7).
8. **Refresh the description.** If the fixes changed behaviour, approach, scope, risk or test results, run `/pr-describe --refresh`. It rewrites only the affected sections, updates Test results with the new SHA, and adds a Revisions entry. **Gate:** you approve the updated description.

**Gate G6:** reviewers approve.

Notes:
- If a review item reveals a gap in the plan, record it in `notes.md`. If it's a recurring kind of finding, tag it for `/capture-learnings`.
- If the PR spans several repos, run it per PR. Check whether a fix in one repo affects the others' descriptions or deploy order.

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
| D7 | Who resolves review threads | Reviewer (default) · author after reply · configurable per repo | open |
| D8 | How Playwright runs against a branch | **Local stack only**; `main` used to check whether a failure is pre-existing | decided |
| D9 | Jira test plan format and posting | Markdown pasted by hand · Jira wiki markup · posted via Atlassian MCP (see D2) | open |
