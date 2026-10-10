---
description: Write the Playwright test plan for this ticket (coverage, scenarios, data, selectors) and add e2e tasks to tasks.md
argument-hint: "[coverage notes, e.g. \"refund happy path and partial refund only\"]"
---

# Plan the e2e (Playwright) tests

Run this from the **ticket folder root**, after `plan.md` is approved. The Playwright repo should be checked out under `repos/` on the ticket branch.

Coverage notes from me: `$ARGUMENTS`

**I decide what gets covered.** If I gave coverage notes, they override your judgment about which ACs need e2e tests. If I didn't, propose coverage and let me confirm it in Step 5.

## Step 1 — Load context

Read:
- `ticket.md` (ACs), `plan.md` (approach, contracts, e2e coverage notes) and `tasks.md`
- The Playwright repo's `CLAUDE.md` and any guideline docs it points to. **These are the rules for structure, naming, fixtures, page objects, tags and test data. Follow them over anything in this command or the template.**
- Existing specs in the Playwright repo for the same area of the app, so new scenarios match how similar flows are already tested

If there's no Playwright repo under `repos/`, ask me for its folder name before going further.

## Step 2 — Decide coverage

For each AC, decide **e2e: yes / no**:
- **Yes** for user-visible flows, especially ones that cross pages or services
- **No** for logic, validation details and edge cases that specs already cover well. Give the reason.

Apply my coverage notes first. Don't add scenarios I've excluded.

## Step 3 — Write `e2e-plan.md`

Use `$AWF_KIT/templates/e2e-plan.md`. Fill in:

1. **Coverage decision** table, every AC listed
2. **Environment and data:** the target is the **local stack** running the ticket branches. Include the base URL and how to start it, from the Playwright repo's `CLAUDE.md`. Also list flags, users and roles, seed data, and cleanup.
3. **Selectors the app must provide:** prefer roles and accessible names, per the repo's guidelines. For each `data-testid` needed, name the feature task that will add it.
4. **Scenarios:** one per user flow, each with the ACs covered, tags (using the repo's tag conventions), preconditions, steps, expected results and target spec file path. Reuse existing page objects and fixtures where they exist and name them.
5. **Test items:** give each scenario one or more TP IDs (sequential: TP-01, TP-02…), each with a plain-language check and an **evidence point**, the moment a screenshot proves it. These become the rows of the Jira test plan (`/jira-test-plan`). Never renumber existing IDs.
6. **Manual test items:** ACs the BA/PO will want evidence for that aren't automated. Give them TP IDs too.
7. **Out of scope** and **Risks** (flaky areas: async jobs, emails, third-party sandboxes)

## Step 4 — Prepare the task changes (don't write them yet)

1. **E2E tasks:** one per spec file, or per tight group of scenarios. Each is:
   - **Repo:** the Playwright repo · **Category:** `e2e`
   - **Depends on:** the feature tasks whose behaviour or selectors it needs
   - **ACs:** the ACs its scenarios cover
   - **Plan section:** `e2e-plan.md#<scenario>`
   - **Specs:** the Playwright spec file path(s)
2. **Selector additions:** for each feature task that must add selectors, a line to append to its **Scope**. Don't change any task that's already `done`; if a done task lacks a selector, propose a small follow-up task instead.

## Step 5 — Confirm with me

Show:
- The coverage table
- A one-line list of scenarios, with their TP IDs and any manual items
- The e2e tasks you'll add, and the selector additions to existing tasks

Then **wait**. On approval, write `e2e-plan.md`, append the e2e tasks to `tasks.md` (section and summary table), apply the selector additions, and set the plan status to `approved`.
