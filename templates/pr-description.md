<!--
PR description template for ai-dev-workflow.

Title format:  {{KEY}}: <imperative summary of what this PR does>
               e.g. "PROJ-123: Add refund webhook handler to billing service"

If the target repo has its own .github/pull_request_template.md, that template
wins: fill in its sections first, then add any sections below that it lacks.

The "awf:<section>" comment markers let /pr-describe --refresh regenerate a section
without touching anything a human edited outside the markers. Keep them.
-->

<!-- awf:summary -->
## Summary
{{One or two short paragraphs. WHAT this PR changes and WHY: the problem, and why this approach. Readable without opening Jira.}}

- **Ticket:** [{{KEY}}]({{jira link}})
<!-- /awf:summary -->

<!-- awf:related -->
## Related PRs and deploy order
| Order | Repo | PR | Notes |
|---|---|---|---|
| 1 | {{repo}} | {{#123 or link}} | {{must deploy first: adds field consumers read}} |
| 2 | **this repo** | this PR | {{...}} |
| — | {{e2e repo}} | {{#456}} | Playwright specs for this ticket; merge after the code PRs |

Can this PR ship on its own? **{{yes / no — why}}**
<!-- /awf:related -->

<!-- awf:changes -->
## Changes
Grouped by area, with the reasoning behind non-obvious choices.

- **{{area}}:** {{what changed and why}}
- **{{area}}:** {{...}}

**Alternatives considered:** {{only if a reviewer would reasonably ask "why not X?"}}
<!-- /awf:changes -->

<!-- awf:acceptance -->
## Acceptance criteria
| AC | Description | Covered by |
|---|---|---|
| AC1 | {{short}} | `spec/path_spec.rb` |
| AC2 | {{short}} | {{spec}} · e2e: `{{tests/path.spec.ts}}` |
| AC3 | {{short}} | {{manual — see How to test}} |
<!-- /awf:acceptance -->

<!-- awf:tests -->
## Test results
As of {{short SHA}} · {{date}}

| Check | Result |
|---|---|
| RSpec | {{N examples, 0 failures}} |
| New / changed specs | {{N}} |
| RuboCop | {{no offenses}} |
| Brakeman | {{no warnings / n.a.}} |
| CI | {{link to run}} · {{passing}} |

<details>
<summary>New and changed specs</summary>

```
{{rspec --format documentation output for the new/changed specs only}}
```
</details>
<!-- /awf:tests -->

<!-- awf:how-to-test -->
## How to test
Steps a reviewer can follow to see the change working.

1. {{setup: seed data, flag to enable, env var}}
2. {{action}}
3. {{expected result}}
<!-- /awf:how-to-test -->

<!-- awf:risk -->
## Risk and rollout
- **Migrations:** {{none / list, and whether safe to run online}}
- **Feature flags:** {{none / flag name, default state}}
- **Config / env changes:** {{none / list}}
- **Rollback:** {{revert is safe / steps needed, irreversible migration?}}
- **Monitoring:** {{what to watch after deploy}}
<!-- /awf:risk -->

<!-- awf:reviewer-notes -->
## Notes for reviewers
- **Focus on:** {{the parts that need careful eyes}}
- **Safe to skim:** {{generated files, renames, mechanical changes}}
- **Out of scope / follow-ups:** {{known gaps and tickets or tasks for them}}
<!-- /awf:reviewer-notes -->

<!-- awf:revisions -->
## Revisions
Added after review rounds. Newest first.

- {{date}} · {{short SHAs}}: {{what changed in response to review and why}}
<!-- /awf:revisions -->
