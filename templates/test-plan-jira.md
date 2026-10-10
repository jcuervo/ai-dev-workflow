# Test plan — {{KEY}}: {{ticket title}}

<!--
Stakeholder version, posted to the Jira ticket as a comment.
Generated from e2e-plan.md by /jira-test-plan. Written for the BA/PO:
- Plain language only. No file paths, repo or service names, code, spec names,
  internal task IDs (T#), commit SHAs, branch names or internal URLs.
- Refer to ACs by the numbering on the Jira ticket.
- Each test item has a stable ID (TP-01, TP-02…). Screenshot files are named
  after these IDs so they can be attached against the right row.
This comment block is removed from the posted version.
-->

**Environment:** {{e.g. "Local development build of this change, {{date}}"}}
**Tested by:** {{name}} · **Date:** {{date}}
**Result:** {{N}} of {{N}} passed

## Coverage

| Acceptance criterion | Test items |
|---|---|
| AC1 — {{short wording from the ticket}} | TP-01, TP-02 |
| AC2 — {{...}} | TP-03 |
| AC3 — {{...}} | Not tested here: {{plain-language reason, e.g. "behind-the-scenes rule, covered by automated checks"}} |

## Test items

| ID | Scenario | Steps | Expected result | Result | Evidence |
|---|---|---|---|---|---|
| TP-01 | {{what's being checked, in user terms}} | 1. {{...}}<br>2. {{...}} | {{what the user sees}} | Pass / Fail | {{KEY}}_TP-01.png |

## Notes
- {{pre-existing issues found (also present before this change), with the follow-up ticket if raised}}
- {{anything not covered, and why, in plain language}}
