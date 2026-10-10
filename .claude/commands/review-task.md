---
description: Run an independent review of one task's changes against its ACs and scope, without changing code
argument-hint: "[T#]"
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

Don't change any code. Fixing is a separate step, either in `/build-task` or when I ask.
