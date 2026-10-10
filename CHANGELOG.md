# Changelog

What changed in the kit and why. Newest first.

## 2026-10-10
- **Docs:** `docs/setup-and-next-steps.md`: install checklist, things to remember, first-use validation, remaining work.
- **Hooks:** protected files, RuboCop on edit, specs and security gates before `git commit`, with an installer that merges into `~/.claude/settings.json`. The tests gate runs on commit rather than on Stop, to avoid slowing down or looping on ordinary replies.
- **Commands:** `/ticket-init`, `/analyze-ticket`, `/update-analysis`, `/plan-ticket`, `/pr-describe`, `/resolve-review`, plus the `repo-explorer` agent.
- **Jira test plan:** `/jira-test-plan` with TP IDs and per-item screenshot evidence, sanitized for the BA/PO.
- **E2E:** the Playwright repo is treated as an affected repo; `/e2e-plan` and an e2e variant of `/build-task`. Runs are local only, with failures checked against `main`.
- **PR template:** standard sections with `awf:` markers for refresh; no screenshots, by team convention.
- **Core:** `/build-task`, `/review-task`, `task-reviewer`; ticket, analysis, open questions, plan and tasks templates; workflow and inventory docs.
