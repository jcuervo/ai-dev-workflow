---
description: Build one task from tasks.md — specs first, implement, verify, independent review, then stop for approval before committing
argument-hint: "[T# | next]"
model: sonnet
effort: high
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
- `repos/<repo>/`'s instruction files: `CLAUDE.md`, `CLAUDE.local.md`, `.claude/CLAUDE.md`, `.claude/rules/*.md`, and `AGENTS.md` if there's no `CLAUDE.md`. Below, "the repo's `CLAUDE.md`" means all of these. If there are none, or they have no test commands, say so and suggest `/repo-setup <repo>` before continuing; guessing commands costs more than setting them up once.

Then explore only the code the task touches. If you need a broad search across the repo, use a subagent and ask for a summary.

Before writing code, state in 3–5 lines: what you'll change, which specs you'll write, and anything that looks inconsistent between the task, plan and code. **If there's a real inconsistency, stop and ask me** rather than guessing.

## E2E tasks

If the task's category is `e2e`, it's in the Playwright repo and these rules **replace Steps 3 and 5**:

- **Run the branch check from Step 3 first.** The Playwright repo must be on the ticket branch too.
- **Follow the Playwright repo's `CLAUDE.md` and guidelines** for structure, page objects, fixtures, tags and naming. They take priority over this command.
- Read the task's scenarios in `e2e-plan.md`. Build exactly those, and don't add scenarios I didn't approve.
- **Write the spec, then run it locally.** Playwright runs only against the local stack on the ticket branches.
  1. **Check the stack matches the ticket**, as in `/ticket-repos status`: every `change` and `e2e` repo is on the ticket branch, and every `run` repo is on its expected branch and not behind its remote. Then check the base URL from `e2e-plan.md` is reachable. If anything is off, **stop and tell me what to fix**: switch a repo, pull it, restart or rebuild a Docker service, or run migrations. Don't run Docker commands or start servers unless I ask.
  2. Run only this task's specs, using the repo's own command.
  3. Run them a second time to catch flakiness.
- **If a test fails, triage before fixing:**
  - **Test bug** (wrong selector, timing, bad data): fix the test.
  - **App bug from this ticket:** stop and tell me which feature task it belongs to. Don't patch the app from an e2e task.
  - **Possibly pre-existing:** ask me to run the stack on `main` and re-run the failing spec. If it also fails on `main`, it's pre-existing: record it in `notes.md`, mark the test as the repo's guidelines say (e.g. `test.fixme` with a reason), and propose a separate ticket. Don't fix it in this ticket.
- If the stack can't run at all, the minimum is `npx playwright test --list` plus the repo's type check or lint. Report the tests as **not executed**; they can't be marked `done` until they've run.
- Add the run result (passed, failed, not executed; and whether the second run matched) to the Step 7 summary, in place of rubocop and brakeman.

## Step 3 — Specs first

Work inside `repos/<repo>/` on the ticket branch. In branch mode that's a link to your normal clone; in worktree mode it's a separate checkout. **Before changing anything, check the repo:**

1. Get the expected branch and the repo's role from the **Affected repos** table in `ticket.md`.
2. Run `git -C repos/<repo> branch --show-current` and `git -C repos/<repo> status --short`.
3. **Stop and tell me**, without changing anything, if:
   - `repos/<repo>` doesn't exist, or the Branch column is empty: suggest `/ticket-repos setup` (or `/ticket-repos add <repo>`)
   - the repo's role isn't `change` or `e2e`. A `run` or `reference` repo must not get commits; the plan needs updating instead.
   - the current branch is the default branch (`main`, `master`, `develop`) or anything other than the expected branch
   - there are uncommitted changes that don't belong to this task

Never create, switch or reset branches yourself, and never commit to the default branch.

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

If the service runs in Docker (`runs_in: docker` in the registry), use the commands from its `CLAUDE.md`. Specs may need to run inside the container (e.g. `docker compose exec <service> bundle exec rspec`).

## Step 6 — Independent review loop (mandatory)

This step can't be skipped, for any task category, including config, docs and e2e. A commit hook refuses task commits without a saved review.

**Maximum rounds:** `$AWF_REVIEW_MAX_ROUNDS` (default **3**). A round is one review by a fresh `task-reviewer`, plus the fixes that follow it.

### Round 1: full review
Use the **task-reviewer** agent. Give it:
- The ticket folder path and the task ID
- The repo path `repos/<repo>`
- That the changes are uncommitted (diff against `HEAD`, including untracked files)

### Triage each finding
- **must-fix:** fix it.
- **should-fix:** fix it, unless it's out of scope or wrong. Then mark it **left**, with the reason.
- **nit:** fix if trivial, otherwise **left**. Nits never cause another round.
- If you disagree with a finding (it's incorrect, or conflicts with the plan or ACs), don't fix it. Mark it **disputed** with your reasoning, for me to decide at Step 7.

After fixing, **re-run Step 5** (specs, RuboCop, Brakeman) before any re-review.

### Another round?
Run another round **only if code changed in response to a must-fix or should-fix finding.** Nit-only fixes don't need one.

Rounds 2 and up are **verification reviews**, by a new `task-reviewer`. Give it the previous review and your resolution for each finding, and ask it to:
1. Confirm each **fixed** finding is actually resolved.
2. Review **only what changed since the last round**, for problems the fixes introduced.
3. Not re-raise findings marked **left** or **disputed**. Those are decided at Step 7.

### Stop when any of these holds
- **Converged:** the latest round has no must-fix and no new should-fix findings. Verdict `ready`, or `ready after fixes`.
- **Cap reached:** the round limit is hit with must-fix findings still open. Stop fixing, keep the verdict `not ready`, and escalate to me at Step 7 with the open items. Don't keep looping. The commit gate blocks until I decide: fix by hand, change the plan, or override.
- **Not converging:** the same finding comes back after being fixed, or each round's fixes cause new must-fix findings. Stop early and escalate. That usually means the task or plan is unclear, which more rounds won't fix.

### Save the review
Save to `reviews/T#.md` in the ticket folder (create `reviews/` if needed):
- Each round's reviewer output, verbatim, under `## Round N` headings. Each starts with its `Verdict:` line.
- At the end, a `### Resolution` section:
  - every finding marked **fixed**, **left (reason)**, **disputed (reasoning)** or **not applicable (reason)**
  - **Rounds:** N, and why it stopped: converged, cap reached, or not converging
  - **Final verdict:** the latest round's verdict, on its own line as `Verdict: <verdict>`. The commit gate reads the last `Verdict:` line. Never edit a verdict by hand.

## Step 7 — Hand over and stop

Set the task's status to `review`, then give me this summary and **wait**:

```
## T# — <title>  (<repo>)
Changes:     <3–6 bullets, files and what changed>
Specs:       <added / changed, all passing: yes/no>
Checks:      rubocop ✓/✗ · brakeman ✓/✗/n.a.
Review:      <final verdict> · <rounds> round(s), stopped: <converged | cap | not converging> · fixed: <…> · left: <…> · disputed: <… — your call> · saved: reviews/T#.md
Deviations:  <from the plan, or "none">
Follow-ups:  <proposed new tasks, or "none">
Commit msg:  [<KEY>] <imperative summary>   (format: $AWF_KIT/templates/commit-message.md)
```

Reply with one of:
- **approve**: commit
- **approve & push**: commit and push
- **changes: …**: I'll adjust and come back to this step

## Step 8 — On approval

1. Stage **only this task's files** by explicit path. Never use `git add -A` or `git add .`. Confirm with `git status` that nothing unrelated is staged.
2. Commit with the agreed message, following `$AWF_KIT/templates/commit-message.md`: `[<KEY>] <imperative summary>`, an optional body explaining why, **no task number**, and no `Co-Authored-By` or other trailers. The commit is authored by the configured git user. Keep T#'s status `review` until the commit succeeds; the commit gate uses it to find the review.
3. If I said **approve & push**: push the branch. If there's no PR/MR for this branch yet, create a **draft** with the code host's CLI (`$AWF_KIT/docs/code-hosts.md`; e.g. `gh pr create --draft`), using a minimal placeholder body. `/pr-describe` fills it in later. With no usable CLI, just push and tell me to open the draft by hand.
4. In `tasks.md`: set status to `done` in the section and the summary table, record the short SHA under **Commits**, and fill in **Review** with the verdict and `reviews/T#.md`.
5. Add any deviations to `notes.md` (create it if needed), prefixed with the task ID and date.
6. Append proposed follow-ups as new `todo` tasks at the end of `tasks.md` **only if I accepted them**.
7. Finish with one line: what's next (the next available task ID), and remind me to `/clear` before `/build-task next`.
