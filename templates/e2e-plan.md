# {{KEY}} — E2E test plan (Playwright)

- **E2E repo:** {{repo}} · **Branch:** {{KEY}}-{{short-desc}}
- **Based on:** ticket.md ACs · plan.md (approved {{date}})
- **Status:** draft | approved | implemented

This file replaces the separate hand-over document. It's the brief for the e2e tasks in `tasks.md`.

## 1. Coverage decision
Not every AC needs an e2e test. Use e2e for user-visible flows across pages or services; leave logic and edge cases to specs.

| AC | E2E? | Scenario(s) | Reason if not |
|---|---|---|---|
| AC1 | yes | E1, E2 | |
| AC2 | no | — | Covered by request specs; no UI |

## 2. Environment and data
- **Target environment:** local stack · base URL {{http://localhost:...}}
- **Stack required** (checked before every run; see `/ticket-repos status`):
  | Repo | Role | Must be on | Runs in |
  |---|---|---|---|
  | {{repo}} | change | ticket branch | docker |
  | {{repo}} | run | main (latest) | docker |
- **How to start it:** {{from the Playwright repo's CLAUDE.md}}
- **Feature flags:** {{flag: state needed}}
- **Users / roles:** {{fixtures or accounts used}}
- **Seed / setup data:** {{what must exist, and how it's created: API, factory, fixture}}
- **Cleanup:** {{how test data is removed or isolated}}

## 3. Selectors the app must provide
Agreed up front so the feature tasks add them. Prefer roles and accessible names; use `data-testid` where those aren't stable.

| Selector | Element | Added by task |
|---|---|---|
| `data-testid="{{...}}"` | {{refund button}} | T3 |

## 4. Scenarios

### E1 — {{scenario name}}
- **Covers:** AC1
- **Tags:** @smoke | @regression · {{feature tag}}
- **Preconditions:** {{state before the test}}
- **Steps:**
  1. {{user action}}
  2. {{...}}
- **Expected:**
  - {{visible outcome, with the assertion to make}}
- **Test items (for the Jira test plan):**
  | TP ID | Checks | Evidence point |
  |---|---|---|
  | TP-01 | {{plain-language check}} | {{the moment to capture: after step 3, success message visible}} |
- **Spec file:** `tests/{{area}}/{{name}}.spec.ts`
- **E2E task:** T{{#}}

## 5. Manual test items
ACs the BA/PO expects to see evidence for that aren't automated. These still get TP IDs and appear in the Jira test plan, and their screenshots are captured by hand or by a one-off browser session.

| TP ID | AC | Check | Evidence point |
|---|---|---|---|

## 6. Out of scope
- {{flows deliberately not covered, and why}}

## 7. Risks
- {{flaky areas: async jobs, emails, third-party sandboxes, timing}}
