---
description: Produce the stakeholder test plan for the Jira ticket from e2e-plan.md — sanitized for the BA/PO, with screenshots captured per test item
argument-hint: "[draft | evidence]"
---

# Jira test plan

Run this from the **ticket folder root**. Mode: `$ARGUMENTS` (`draft` if empty).

- **draft:** write the stakeholder test plan with Result and Evidence empty. Share it with the BA/PO early to confirm coverage.
- **evidence:** run the tests locally, capture a screenshot per test item, and fill in Result and Evidence.

There are two documents, with one source of truth:
- `e2e-plan.md` is the **internal** plan. It stays in the ticket folder.
- `test-plan-jira.md` is the **stakeholder** version, generated from it and posted to Jira.

If they disagree, fix `e2e-plan.md` and regenerate. Don't hand-edit the Jira version.

## Step 1 — Check the source

1. Read `ticket.md` (AC numbering and wording), `e2e-plan.md` and `tasks.md`.
2. Every scenario and manual item in `e2e-plan.md` must have **TP IDs** with an evidence point. If any are missing, propose them (sequential: TP-01, TP-02…), show them, and add them to `e2e-plan.md` once I confirm. **Never renumber existing TP IDs.** Screenshots and earlier Jira comments refer to them.

## Step 2 — Write `test-plan-jira.md`

Use `$AWF_KIT/templates/test-plan-jira.md`. Write for the **BA/PO**:
- Describe scenarios and steps in user terms ("Open an order and click Refund"), not test terms ("navigate to /orders/:id, click data-testid refund-btn").
- Reference ACs with the same numbering and short wording as the Jira ticket.
- For every AC not tested here, say why in plain language.
- Remove the template's HTML comment block.

### Sanitization (required)

The posted version must not contain:
- File paths, file names (other than evidence screenshot names), spec names, code or selectors
- Repo, service or branch names; internal task IDs (`T1`…); commit SHAs
- Internal or localhost URLs, credentials, tokens, real customer data

After writing, **check the file mechanically**. Search it for:
- Path and file patterns: `/`-separated paths, `.rb`, `.ts`, `.js`, `spec`, `tests/`
- Internal IDs and versions: `\bT[0-9]+\b`, 7–40 character hex strings
- Environment details: `localhost`, `127.0.0.1`, `http`
- Names: each repo name listed in `ticket.md`

Report each hit and fix it. Hits inside screenshot file names (`<KEY>_TP-01.png`) are fine.

## Step 3 — Evidence (evidence mode only)

1. **Check the local stack is up** at the base URL in `e2e-plan.md`. If it isn't, stop and ask me to start it.
2. **Capture screenshots without changing the shared test suite unless I agree.**
   - If the Playwright repo's `CLAUDE.md` or helpers define an evidence or screenshot mechanism, use it.
   - Otherwise, propose how to capture at each test item's evidence point. For example, `page.screenshot()` calls gated by an env var such as `EVIDENCE_DIR`, so normal runs produce nothing. Use names from the TP IDs. **Wait for my approval before adding anything to the Playwright repo.**
3. Save screenshots to `evidence/` in the **ticket folder**, named `<KEY>_TP-01.png`, `<KEY>_TP-02.png`, etc. Never save or commit them in the Playwright repo; they can contain client data.
4. Run the e2e specs for this ticket once, in evidence mode.
5. For **manual items**, list the TP IDs with their evidence points so I can capture them. Leave their Result empty until I tell you the outcome.
6. Check that every automated TP ID has a screenshot. List any that are missing.

## Step 4 — Fill in and report

1. Fill in **Result** (Pass / Fail) and **Evidence** (file name) per row, the summary line (`N of N passed`), environment and date.
2. Pre-existing failures (the test also fails on `main`, per `/build-task` triage) are marked **Fail** and explained in Notes as existing before this change, with the follow-up ticket if one was raised.
3. Look at a few screenshots to confirm they show what the Expected result says. Not just a loaded page, and no visible credentials or personal data. Report any that don't.
4. Re-run the sanitization check from Step 2.
5. Tell me in a few lines:
   - Path to `test-plan-jira.md` and the `evidence/` folder
   - Pass / fail counts, missing screenshots, manual items still open
   - That it's ready to paste as a Jira comment, with the screenshots attached against the Evidence column
