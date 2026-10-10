---
description: Turn a ready analysis into plan.md and a prioritised, categorised tasks.md — proposed in chat first, written after approval
argument-hint: "[planning notes]"
---

# Plan the ticket

Run this from the **ticket folder root**. Notes from me: `$ARGUMENTS`

## Step 1 — Check readiness

Read `ticket.md`, `analysis.md`, `open-questions.md` and `notes.md` if present.
- If the analysis status isn't **ready**, list what's missing and ask whether to plan anyway, recording assumptions for the gaps.
- If `plan.md` exists and is **approved**, stop. Changes to an approved plan go in `notes.md` and the plan's change log, not a regenerated plan.

## Step 2 — Design

Work out the approach. For anything the analysis didn't settle, check the code yourself, or use **repo-explorer** agents in parallel for several repos. Settle, in order:
1. **Contracts first:** every API, event or shared-schema change, with its shape and compatibility
2. **Changes by repo**
3. **Data and migrations:** online safety, backfills, locking
4. **Deploy order:** can each repo ship alone?
5. **Feature flags**, if needed
6. **Rollback** per repo
7. **Testing strategy**, including which ACs are likely to need e2e coverage (details come in `/e2e-plan`)

## Step 3 — Break into tasks

Rules (from `$AWF_KIT/templates/tasks.md`):
- **One task = one repo.** Each task has a single category: `contract` · `migration` · `backend` · `frontend` · `job` · `config` · `test` · `docs`.
- **Order is build order:** contracts and migrations before the code that uses them; providers before consumers.
- **Size:** reviewable in one sitting (rough guide: under ~300 changed lines). Split anything bigger.
- Each task lists its ACs, plan section, specs (paths where you can predict them), scope (what it does **and doesn't** change) and "Done when".
- **Every AC maps to at least one task.** Check this explicitly.

## Step 4 — Propose in chat

Show me, before writing any files:
1. The approach in a short paragraph, plus the alternatives you rejected
2. Contracts, deploy order and rollback, briefly
3. The task summary table: ID, title, repo, category, depends on, ACs
4. AC coverage (AC → tasks), and anything uncovered
5. Assumptions you made

**Wait for approval or changes.**

## Step 5 — Write

On approval:
1. Write `plan.md` from `$AWF_KIT/templates/plan.md` (status **approved**, with today's date), with anchors for each repo section that tasks can point to.
2. Write `tasks.md` from `$AWF_KIT/templates/tasks.md`: the summary table and full sections, all `todo`.
3. Tell me the next step: `/e2e-plan` if any ACs need e2e coverage, otherwise `/build-task next` (after `/clear`).
