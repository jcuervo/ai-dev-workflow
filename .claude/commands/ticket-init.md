---
description: Set up a ticket folder — pull or paste the Jira ticket, then create branches and worktrees in every affected repo
argument-hint: "<JIRA-KEY> [short-description]"
---

# Initialise a ticket

Arguments: `$ARGUMENTS`. The Jira key (required) and an optional short description for the branch name.

## Step 1 — Folder

1. Ticket folder: `$AWF_TICKETS_ROOT/<KEY>/` (if `AWF_TICKETS_ROOT` is unset, ask me where).
2. If the folder already exists, show what's in it and stop. Don't overwrite anything.
3. Create the folder with `repos/` and `evidence/` inside it.

## Step 2 — Ticket content

- If a Jira or Atlassian tool is available, fetch the ticket by key: summary, description, acceptance criteria, attachments, links.
- Otherwise ask me to paste the ticket.

Write `ticket.md` from `$AWF_KIT/templates/ticket.md`:
- Keep the description and requirements **verbatim**.
- Number the acceptance criteria **AC1, AC2…** in the ticket's order. If the ticket's ACs aren't clearly separated, split them sensibly and tell me how you numbered them, since these IDs are used everywhere after this.

## Step 3 — Repos

Ask me which repos are affected, including the Playwright repo if e2e tests apply, and where each lives locally. Then propose:
- **Branch name:** `<KEY>-<short-description>`, lowercase with hyphens, the same in every repo. Derive the description from the ticket title if I didn't give one.
- **Base:** each repo's default branch.
  - With a remote: `git -C <repo> symbolic-ref refs/remotes/origin/HEAD`, and base the branch on `origin/<default>`.
  - **No remote** (`git -C <repo> remote` prints nothing): use the local default branch (`main`, else `master`), and skip the fetch.
  - If the repo has **no commits yet**, stop and tell me; a worktree needs a commit to branch from.

Show the plan and **wait for approval**. Then, for each repo:
```bash
git -C <repo path> fetch origin                     # only if the repo has a remote
git -C <repo path> worktree add <ticket folder>/repos/<repo name> -b <branch> <base>
```
`<base>` is `origin/<default>` with a remote, or the local default branch without one.
If the branch already exists, use it instead of creating it, and tell me.

Fill in the **Affected repos** table in `ticket.md`.

## Step 4 — Hand over

Tell me in a few lines: the folder path, the number of ACs, repos and branches created, and the next step:
`cd <ticket folder> && claude`, then `/analyze-ticket`.
