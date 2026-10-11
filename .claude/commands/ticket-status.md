---
description: One-screen status of the whole ticket — tasks, reviews, AC coverage, repos and branches, and PR/MR review state across all repos. Read-only.
argument-hint: ""
model: haiku
effort: low
---

# Ticket status

Run this from the **ticket folder root**. **Read-only:** change nothing, commit nothing, post nothing.

Gather the following, then show it as one compact report.

## 1. Tasks
From `tasks.md`: a table of ID, title, repo, status, review verdict (from `reviews/T#.md`, last `Verdict:` line) and commits. Then:
- **Next available task:** the first `todo` whose dependencies are `done`
- **Blocked:** tasks waiting on something, and what
- **Problems:** a `done` task with no review file, or whose last verdict is `not ready`; a task `in-progress` or `review` for a long time (a session may have been interrupted)

## 2. Acceptance criteria
For each AC in `ticket.md`: the tasks covering it (from `tasks.md`), whether those tasks are `done`, the specs named for it, and e2e coverage from `e2e-plan.md`. Flag any AC with no task, or with all its tasks still open.

## 3. Repos and branches
As in `/ticket-repos status`: one row per repo with role, expected and actual branch, clean or dirty, ahead/behind its remote, and **behind its default branch** (`git rev-list --count <branch>..origin/<default>`, or the local default branch with no remote). Flag repos that need pushing, or a sync with the default branch (`/ticket-repos sync`).

## 4. PRs / MRs
For each `change` and `e2e` repo, using the code host's CLI (`$AWF_KIT/docs/code-hosts.md`): PR/MR link, draft or ready, CI state, review decision (approved / changes requested / pending), and the number of **unresolved** threads. With no usable CLI, say "not checked (manual mode)".

## 5. Evidence and docs
- Stakeholder test plan: `test-plan.md` exists? Every TP row has a result and an evidence file present in `evidence/`?
- Open questions still `open` in `open-questions.md`

## 6. Summary
End with **3–5 lines**: the phase the ticket is in, the next action (e.g. "`/build-task next` (T5)", "`/ticket-ship`", "`/resolve-review` on billing-service #42"), and anything blocking.
