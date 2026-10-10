# {{KEY}} — Plan

- **Based on:** analysis.md v{{N}}
- **Status:** draft | approved
- **Approved by / on:** {{name, date}}

> Once approved, this plan isn't regenerated. Deviations go in `notes.md`, and significant ones get an entry in the change log below.

## 1. Approach
A short paragraph on the overall solution and why this approach over alternatives.

### Alternatives considered
| Option | Why not |
|---|---|
| {{...}} | {{...}} |

## 2. Contracts (agree these first)
Define every API, event and shared-schema change before implementation starts.

### {{contract name}}
- **Owner repo:** {{repo}} · **Consumers:** {{repos}}
- **Change:** new | modified | removed
- **Shape:**
```json
{ }
```
- **Compatibility:** additive / breaking. If breaking, how consumers migrate.

## 3. Changes by repo
<a id="{{repo-anchor}}"></a>
### {{repo}}
- {{change}} → tasks T1, T2

## 4. Data and migrations
- Migration list, whether each is safe online, backfill strategy, lock risk
- Strong_migrations-style concerns (adding indexes concurrently, column defaults, etc.)

## 5. Deploy order and compatibility
1. {{repo}}: can ship first because {{reason}}
2. {{repo}}: depends on 1

Can each step ship alone without breaking production? **yes / no**, and why.

## 6. Feature flags
- {{flag name}}: guards {{what}} · default {{off}} · removal plan

## 7. Rollback
- Per repo: what rolling back means, and whether any migration is irreversible

## 8. Testing strategy
- Unit / request / system specs per repo
- Cross-service: contract tests or a manual check list

### E2E coverage
- Which ACs get Playwright coverage, and which are covered by specs alone (see `e2e-plan.md`)
- `data-testid`s and seed data the feature tasks must add for the e2e tests

## 9. AC coverage
| AC | Tasks | Specs | E2E scenario |
|---|---|---|---|
| AC1 | T1, T3 | {{spec paths}} | E1 / — |

Every AC must have at least one task. An AC with no task is a planning bug.

## Change log
| Date | Change | Reason |
|---|---|---|
