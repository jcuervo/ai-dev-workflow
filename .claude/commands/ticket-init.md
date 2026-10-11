---
description: Set up a ticket folder — pull or paste the Jira ticket, number the ACs, and propose candidate repos from the registry (branches come later, via /ticket-repos)
argument-hint: "<JIRA-KEY> [short-description]"
---

# Initialise a ticket

Run this from `$AWF_TICKETS_ROOT`, or anywhere except the home folder. Every later command runs from the ticket folder this creates.

Arguments: `$ARGUMENTS`. The Jira key (required) and an optional short description for the branch name.

**This command creates no branches.** Which repos are really affected is settled by `/analyze-ticket`; `/ticket-repos` then creates the branches.

## Step 1 — Folder

1. Ticket folder: `$AWF_TICKETS_ROOT/<KEY>/` (if `AWF_TICKETS_ROOT` is unset, ask me where).
2. If the folder already exists, show what's in it and stop. Don't overwrite anything.
3. Create the folder with `repos/` and `evidence/` inside it.

## Step 2 — Ticket content

- If a Jira or Atlassian tool is available, fetch the ticket by key: summary, description, acceptance criteria, attachments, links.
- Otherwise ask me to paste the ticket **or give a file path** to read it from (e.g. a ticket saved from Jira). If the file has a note above a `---` line, use only what's below it.

Write `ticket.md` from `$AWF_KIT/templates/ticket.md`. Replace the placeholders, and drop the template's guidance comments:
- Keep the description and requirements **verbatim**.
- Number the acceptance criteria **AC1, AC2…** in the ticket's order. If the ticket's ACs aren't clearly separated, split them sensibly and tell me how you numbered them, since these IDs are used everywhere after this.
- Branch name: `<KEY>-<short-description>`, lowercase with hyphens. Derive the description from the ticket title if I didn't give one.
- Mode: `$AWF_BRANCH_MODE` (default `branch`).

## Step 3 — Candidate repos

1. Read the repo registry: `$AWF_REPOS_FILE` (default `~/.config/ai-dev-workflow/repos.yml`).
   - If it doesn't exist, tell me to run `$AWF_KIT/bin/awf-repos-scan <folder with my repos>`, and ask me to name the candidate repos and their paths for now.
2. From the ticket and the registry descriptions, propose **candidates** with a tentative role and a one-line reason each:
   - `change`: likely needs code changes
   - `e2e`: the Playwright repo (registry `kind: e2e`), if the ticket has user-visible behaviour
   - `run`: likely needs to be running for the flow to work or be checked, without changes
   - `reference`: worth reading for context only
3. Show the list and let me add, remove or re-role repos. Then fill in the **Affected repos** table, marking it `candidates — confirmed by /analyze-ticket`, with an empty Branch column.

## Step 4 — Hand over

Tell me in a few lines: the folder path, the number of ACs, the candidate repos, and the next step:
`cd <ticket folder> && claude`, then `/analyze-ticket`.
