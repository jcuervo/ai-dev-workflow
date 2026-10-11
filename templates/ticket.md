# {{KEY}} — {{Title}}

- **Jira:** {{link}}
- **Type:** feature | bug | chore | spike
- **Reporter (BA/PO):** {{names}}
- **Created:** {{date}}

## Description
{{verbatim from ticket}}

## Requirements
{{verbatim from ticket}}

## Acceptance criteria
<!-- Number every AC. These IDs are used everywhere else (tasks, specs, PRs). Remove this comment. -->

- **AC1:** {{...}}
- **AC2:** {{...}}

## Affected repos
<!-- Filled in by /ticket-repos. Roles:
  change     — code changes here: ticket branch, tasks, PR
  e2e        — the Playwright repo: ticket branch, e2e tasks, PR
  run        — no changes, but must be running (prerequisite or cross-check); stays on its default branch, up to date
  reference  — read during analysis only; nothing to run or change
Mode: branch (ticket branch in your normal clone; repos/<name> links to it) or worktree (separate checkout under repos/). -->

- **Branch:** {{KEY}}-{{short-desc}}
- **Mode:** branch | worktree

| Repo | Role | Branch | Clone path | Runs in | Notes |
|---|---|---|---|---|---|
| {{repo}} | change | {{KEY}}-{{short-desc}} | {{~/work/repos/repo}} | docker | {{why it's involved}} |
| {{repo}} | run | main (latest) | {{...}} | docker | {{e.g. issues the auth token the e2e flow needs}} |
| {{e2e repo}} | e2e | {{KEY}}-{{short-desc}} | {{...}} | local | |

## Attachments / links
- {{designs, docs, related tickets}}
