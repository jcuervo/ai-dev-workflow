---
description: Analyse a ticket across its repos (parallel repo-explorer agents) and write analysis.md and open-questions.md for the BA/PO
argument-hint: "[focus notes]"
model: opus
effort: high
---

# Analyse the ticket

Run this from the **ticket folder root**. Notes from me: `$ARGUMENTS`

This command only reads. It creates no branches and changes no repos.

If `analysis.md` already exists, stop and suggest `/update-analysis` instead. Don't overwrite it.

## Step 1 — Read the ticket

Read `ticket.md`. For each AC, note anything ambiguous, untestable or missing (error states, permissions, edge cases, data).

## Step 2 — Explore the candidate repos in parallel

The candidates are in `ticket.md` (**Affected repos**). Clone paths come from the registry (`$AWF_REPOS_FILE`, default `~/.config/ai-dev-workflow/repos.yml`). If a repo already has a ticket branch, its `repos/<name>` link or worktree is fine to read too.

1. For each candidate, note the clone's current branch. If it isn't the default branch, tell the explorer, so it reads the default branch's version of files (`git -C <clone> show <default>:<path>`) or flags that it's reading something else.
2. Run one **repo-explorer** agent per candidate (`change`, `run` and `reference` alike; the e2e repo only if the ticket is about tests), **all at once**. Give each:
   - The clone path and the branch to read
   - A short summary of the ticket and the ACs relevant to that repo
   - What to find out: current behaviour in the affected areas, likely files and modules, contracts (APIs, events, shared schemas), data and migration impact, existing specs, risks. Also ask: **does this flow depend on any other service** (calls, events, auth, shared data) that isn't in the candidate list?
3. If explorers point to services that aren't candidates, look them up in the registry and explore them too.

Use their summaries. Read code yourself only to settle a specific question.

## Step 3 — Write `analysis.md`

Use `$AWF_KIT/templates/analysis.md` and fill in every section. Be concrete: name modules and endpoints, not "the relevant code". Mark the status:
- **awaiting answers** if there are blocking questions
- **ready** only if every Definition of Ready box is genuinely ticked

## Step 4 — Write `open-questions.md`

Use `$AWF_KIT/templates/open-questions.md`. Each question:
- Is answerable by the BA/PO: about behaviour and business rules, not code
- Says **why it matters**: what would change in the build
- Offers **options and a proposed default**, so a short answer works
- Is marked **blocking** only if planning can't proceed without it

Don't ask what the code or the ticket already answers. Merge overlapping questions.

## Step 5 — Confirm the repos

Propose the final **Affected repos** list, one line per repo with its role and why:
- `change`: has code changes in this ticket
- `e2e`: the Playwright repo, if any AC needs e2e coverage
- `run`: no changes, but must be running for the flow or for cross-checking. Say what it provides (e.g. "issues the auth token", "receives the refund.created event").
- `reference`: read only

Call out repos **added or dropped** compared with the candidates, and why. Update the table in `ticket.md` when I agree, keeping the Branch column empty until `/ticket-repos setup`.

## Step 6 — Report

Tell me in a few lines:
- Repos by role, and the size of the change (small, medium, large), with one line on why
- Number of questions (blocking / non-blocking)
- Top risks

Then give me the questions in a **plain-language, paste-ready block** for the Jira comment: numbered, with no file paths, code or repo names.

Next step: answer the questions, then `/update-analysis`. Branches are created with `/ticket-repos setup` whenever you're ready, at the latest before `/build-task`.
