---
description: Analyse a ticket across its repos (parallel repo-explorer agents) and write analysis.md and open-questions.md for the BA/PO
argument-hint: "[focus notes]"
---

# Analyse the ticket

Run this from the **ticket folder root**. Notes from me: `$ARGUMENTS`

If `analysis.md` already exists, stop and suggest `/update-analysis` instead. Don't overwrite it.

## Step 1 — Read the ticket

Read `ticket.md`. For each AC, note anything ambiguous, untestable or missing (error states, permissions, edge cases, data).

## Step 2 — Explore the repos in parallel

Run one **repo-explorer** agent per repo under `repos/` (except the Playwright repo, unless the ticket is about tests), **all at once**. Give each:
- The repo path
- A short summary of the ticket and the ACs relevant to that repo
- What to find out: current behaviour in the affected areas, likely files and modules, contracts (APIs, events, shared schemas), data and migration impact, existing specs, and risks

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

## Step 5 — Report

Tell me in a few lines:
- Repos affected and the size of the change (small, medium, large), with one line on why
- Number of questions (blocking / non-blocking)
- Top risks

Then give me the questions in a **plain-language, paste-ready block** for the Jira comment: numbered, with no file paths, code or repo names.
