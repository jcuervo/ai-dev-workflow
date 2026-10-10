---
description: Apply the BA/PO's answers to the analysis as a delta — update only affected sections and log the change
argument-hint: ""
---

# Update the analysis

Run this from the **ticket folder root**.

1. Read `open-questions.md` and find questions with status `answered` (or with text under **Answer** while still marked `open`).
2. If there are none, say so and stop.
3. Read `analysis.md`.
4. For each answer, work out which sections it affects: scope, AC review, impact by repo, edge cases, risks, Definition of Ready.
   - If an answer **contradicts** an earlier assumption or changes scope noticeably, tell me before editing.
   - If it needs a closer look at code, use a **repo-explorer** agent for that repo only.
5. Edit **only** the affected sections. Don't regenerate the whole document, and don't reword sections the answers didn't touch.
6. Set each applied question's status to `applied`. Add any **new** questions the answers raise, with the next number.
7. Bump the version, and add a change log row listing the question numbers applied and the sections changed.
8. Re-check the Definition of Ready and update the status.

Report: the sections changed (one line each), new questions if any, and whether the ticket is now **ready** for `/plan-ticket`.
