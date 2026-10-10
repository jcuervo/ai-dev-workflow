---
description: Build one task from tasks.md — specs first, implement, verify, independent review, then stop for approval before committing
argument-hint: "[T# | next]"
---

# Build one task

Run this from the **ticket folder root** (e.g. `~/work/tickets/PROJ-123/`). It contains `ticket.md`, `plan.md`, `tasks.md`, and the repo worktrees under `repos/`.

Argument: `$ARGUMENTS`. A task ID like `T3`, or `next` / empty for the next available task.

Build **exactly one task**, then stop. Don't start another task in this session.

## Step 1 — Pick the task

1. Read `tasks.md`. If it doesn't exist, stop and tell me to run `/plan-ticket` first.
2. Choose the task:
   - If an ID was given, use it.
   - Otherwise, if any task is `in-progress` or `review`, **resume that one** (a previous session was interrupted) and say so.
   - Otherwise take the first `todo` task whose dependencies are all `done`.
3. If the task's dependencies aren't all `done`, or nothing is available, stop and show what's blocking (one line per blocked task).
4. Set the task's status to `in-progress` in both its section and the summary table.

## Step 2 — Load minimal context

Read only:
- The task's section in `tasks.md`
- The plan section it points to (not the whole plan, unless the section is unclear without it)
- The ACs it lists, from `ticket.md`
- `notes.md` entries mentioning this task ID, if the file exists
- `repos/<repo>/CLAUDE.md`, if it exists

Then explore only the code the task touches. If you need a broad search across the repo, use a subagent and ask for a summary.

Before writing code, state in 3–5 lines: what you'll change, which specs you'll write, and anything that looks inconsistent between the task, plan and code. **If there's a real inconsistency, stop and ask me** rather than guessing.

## E2E tasks

If the task's category is `e2e`, it's in the Playwright repo and these rules **replace Steps 3 and 5**:

- **Follow the Playwright repo's `CLAUDE.md` and guidelines** for structure, page objects, fixtures, tags and naming. They take priority over this command.
- Read the task's scenarios in `e2e-plan.md`. Build exactly those, and don't add scenarios I didn't approve.
- **Write the spec, then run it locally.** Playwright runs only against the local stack on the ticket branches.
  1. Check the base URL from `e2e-plan.md` is reachable. If it isn't, **stop and ask me to start the stack**. Don't start servers unless the Playwright repo's `CLAUDE.md` says how.
  2. Run only this task's specs, using the repo's own command.
  3. Run them a second time to catch flakiness.
- **If a test fails, triage before fixing:**
  - **Test bug** (wrong selector, timing, bad data): fix the test.
  - **App bug from this ticket:** stop and tell me which feature task it belongs to. Don't patch the app from an e2e task.
  - **Possibly pre-existing:** ask me to run the stack on `main` and re-run the failing spec. If it also fails on `main`, it's pre-existing: record it in `notes.md`, mark the test as the repo's guidelines say (e.g. `test.fixme` with a reason), and propose a separate ticket. Don't fix it in this ticket.
- If the stack can't run at all, the minimum is `npx playwright test --list` plus the repo's type check or lint. Report the tests as **not executed**; they can't be marked `done` until they've run.
- Add the run result (passed, failed, not executed; and whether the second run matched) to the Step 7 summary, in place of rubocop and brakeman.

## Step 3 — Specs first

Work inside `repos/<repo>/` on the ticket branch. Confirm the branch is correct with `git branch --show-current` before changing anything.

1. Write or extend specs that express the task's ACs and its "Done when". Use the spec paths listed in the task when given.
2. Run them and confirm they **fail for the right reason** (missing behaviour, not a typo or a load error).
3. If the task doesn't suit spec-first (pure config, docs, a migration with no behaviour), say why in one line and skip to Step 4.

## Step 4 — Implement

1. Make the specs pass with the smallest change that fits the plan.
2. Follow the repo's conventions from its `CLAUDE.md` and the surrounding code.
3. Stay within the task's **Scope**. If you find something else that needs doing, don't do it. Note it for Step 7 as a proposed new task.
4. If you must deviate from the plan, keep going only if the deviation is small and local. Otherwise stop and ask me.

## Step 5 — Verify

Run, in the repo:
1. The new and changed specs, then the specs for every file you touched (or the wider suite if the change is cross-cutting)
2. `bundle exec rubocop` on changed Ruby files
3. `bundle exec brakeman -q --no-pager` if controllers, models, views or SQL changed

Use the repo's own commands from `CLAUDE.md` if they differ. Fix failures before moving on. If something unrelated to this task fails, note it but don't fix it.

## Step 6 — Independent review

Use the **task-reviewer** agent. Give it:
- The ticket folder path and the task ID
- The repo path `repos/<repo>`
- That the changes are uncommitted (diff against `HEAD`, including untracked files)

Then for each finding:
- **must-fix:** fix it and re-run Step 5
- **should-fix:** fix it unless it's out of scope, and say which you left
- **nit:** fix if trivial

If you fixed must-fix items, run the reviewer once more. Don't loop more than twice; report anything still open.

## Step 7 — Hand over and stop

Set the task's status to `review`, then give me this summary and **wait**:

```
## T# — <title>  (<repo>)
Changes:     <3–6 bullets, files and what changed>
Specs:       <added / changed, all passing: yes/no>
Checks:      rubocop ✓/✗ · brakeman ✓/✗/n.a.
Review:      <findings fixed, findings left open and why>
Deviations:  <from the plan, or "none">
Follow-ups:  <proposed new tasks, or "none">
Commit msg:  [<KEY>][T#] <summary>
```

Reply with one of:
- **approve**: commit
- **approve & push**: commit and push
- **changes: …**: I'll adjust and come back to this step

## Step 8 — On approval

1. Stage **only this task's files** by explicit path. Never use `git add -A` or `git add .`. Confirm with `git status` that nothing unrelated is staged.
2. Commit with the agreed message.
3. If I said **approve & push**: push the branch. If there's no PR for this branch yet, create a **draft** PR with `gh pr create --draft` using a minimal placeholder body; `/pr-describe` fills it in later.
4. In `tasks.md`: set status to `done` in the section and the summary table, and record the short SHA under **Commits**.
5. Add any deviations to `notes.md` (create it if needed), prefixed with the task ID and date.
6. Append proposed follow-ups as new `todo` tasks at the end of `tasks.md` **only if I accepted them**.
7. Finish with one line: what's next (the next available task ID), and remind me to `/clear` before `/build-task next`.
