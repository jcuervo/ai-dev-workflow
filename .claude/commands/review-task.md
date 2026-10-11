---
description: Run an independent review of one task's changes against its ACs and scope, without changing code
argument-hint: "[T#]"
model: inherit
---

# Review one task

Run this from the **ticket folder root**.

Argument: `$ARGUMENTS`. A task ID. If empty, use the task currently `in-progress` or `review` in `tasks.md`; if there's none, ask me which task.

1. Find the task's repo in `tasks.md`.
2. Work out what to review:
   - Uncommitted changes in `repos/<repo>` if there are any
   - Otherwise the commits listed under the task's **Commits**
3. Use the **task-reviewer** agent with the ticket folder path, task ID, repo path and what to diff.
4. Show me its findings exactly as returned, grouped by severity.
5. **Save** them to `reviews/T#.md` in the ticket folder. If a review already exists there, append this one under a dated `## Re-review` heading instead of overwriting it. The latest `Verdict:` line is the one that counts.
6. If the task is already `done` (a retroactive review), fill in its **Review** field in `tasks.md`. Any must-fix findings become a proposed follow-up task; don't fix them here.

Don't change any code. Fixing is a separate step, either in `/build-task` or when I ask.
