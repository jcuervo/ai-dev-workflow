# {{KEY}} — Analysis

- **Version:** 1
- **Last updated:** {{date}}
- **Status:** draft | awaiting answers | ready (Definition of Ready met)

## 1. Summary
Two or three sentences: what is being asked and why.

## 2. Scope
### In scope
- {{...}}
### Out of scope
- {{...}} (explicitly excluded, and why)

## 3. Acceptance criteria review
| AC | Testable? | Ambiguities / gaps | Question ref |
|---|---|---|---|
| AC1 | yes / no | {{...}} | Q1 |

## 4. Impact by repo
### {{repo}}
- **Modules / files likely touched:** {{...}}
- **Current behaviour:** {{how it works today}}
- **Required change:** {{...}}
- **Contracts affected:** API endpoints, events, shared schemas
- **Data / migrations:** {{new columns, backfills, locking concerns}}

## 5. Cross-repo interactions
- Data and call flow between services for this change
- Contract changes needed and who consumes them
- Deploy-order constraints

## 6. Edge cases and error states
- {{empty states, invalid input, retries, idempotency, concurrency, timeouts}}

## 7. Permissions and security
- {{who can do this, authorization changes, PII, secrets}}

## 8. Non-functional
- Performance (N+1s, large datasets, background jobs)
- Observability (logging, metrics, alerts)
- Backward compatibility

## 9. Risks and assumptions
| # | Risk / assumption | Impact | Mitigation |
|---|---|---|---|
| R1 | {{...}} | high / med / low | {{...}} |

## 10. Definition of Ready
- [ ] Every AC is testable and unambiguous
- [ ] Edge cases and error states are defined
- [ ] Affected repos and contracts are known
- [ ] Data migration needs are known
- [ ] No unanswered blocking questions

## Change log
| Version | Date | Change | Source |
|---|---|---|---|
| 1 | {{date}} | Initial analysis | `/analyze-ticket` |
