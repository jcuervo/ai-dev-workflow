# Changelog

What changed in the kit and why. Newest first.

## 2026-10-11
- **Shell-independent install (macOS and Ubuntu, zsh and bash):** settings now go to Claude Code's `env` in `~/.claude/settings.json` (seen by commands and hooks however Claude Code is launched) and to `~/.config/ai-dev-workflow/env.sh`, which is sourced from `~/.bashrc` and/or `~/.zshrc`. Old `.zshrc` blocks are migrated with their values. Hooks are registered with absolute paths and replaced, not duplicated, on re-run. apt hints on Linux; hook PATH covers asdf, mise and Linuxbrew.
- **Review loop:** a cap of 3 rounds (`AWF_REVIEW_MAX_ROUNDS`). Re-review whenever must-fix or should-fix fixes changed code (T3 fixed a should-fix with no re-review); nits never trigger a round. Rounds 2+ are verification reviews (fixes plus new changes only; no re-raising *left* or *disputed* items). Stops on converged, cap (escalate, verdict stays `not ready`) or not converging. A *disputed* status lets the user arbitrate. The reviewer is told not to invent findings. The gate reads the last `Verdict:` line.
- **Mandatory review is now enforced and recorded:** `/build-task` saves each review to `reviews/T#.md` with a resolution section; new hook `review-before-commit.sh` refuses `[KEY][T#]` commits without it or with `Verdict: not ready`; `/review-task` saves too and supports retroactive reviews. (Found in the dry run: T1/T2 left no trace of their reviews.)
- **No AI attribution in commits:** the installer sets `attribution` (commit and PR) to empty in `~/.claude/settings.json`; new hook `commit-message-check.sh` denies Co-Authored-By trailers; `/build-task` and `/resolve-review` say so explicitly (found in the dry run, T1).
- **Multi-repo tickets:** a repo registry (`bin/awf-repos-scan`, `~/.config/ai-dev-workflow/repos.yml`); repo roles per ticket (`change`, `e2e`, `run`, `reference`); new `/ticket-repos` (setup, add, status, release). Branch mode is the default, since services run in Docker from the clone paths. `/ticket-init` now only proposes candidates; `/analyze-ticket` confirms the repo list, including `run` repos; branches are created after analysis. `/build-task`, `/e2e-plan` and `/jira-test-plan` check that the whole local stack is on the right branches before running.
- **Hooks:** paths resolved through symlinks, so protected-file patterns match in branch mode.
- **Installer:** sets `AWF_REPOS_ROOT`, `AWF_REPOS_FILE` and `AWF_BRANCH_MODE`, builds the registry, and keeps existing values on re-run.
- **`/build-task`:** explicit branch guard. Stops if the worktree is missing, on the default branch or the wrong branch, or has unrelated changes; never switches branches itself. `/resolve-review` checks it's on the PR branch.

## 2026-10-10
- **Templates:** guidance in `ticket.md` is now an HTML comment that `/ticket-init` drops (it leaked into the dry-run ticket).
- **`/ticket-init`:** accepts a file path for the ticket as well as a paste; start sessions from `$AWF_TICKETS_ROOT`, not `~` (found in the dry run).
- **Installer:** `install.sh` does the whole per-machine setup (symlinks, env vars, tickets folder, hooks) and is safe to re-run.
- **Dry run:** `examples/dry-run.md` and the `TODO-1` sample ticket, against `~/dev-utilities/sample-app` (todo-list + todo-e2e).
- **Fix:** `/ticket-init` now handles repos with no remote (found while preparing the dry run).
- **Docs:** `docs/setup-and-next-steps.md`: install checklist, things to remember, first-use validation, remaining work.
- **Hooks:** protected files, RuboCop on edit, specs and security gates before `git commit`, with an installer that merges into `~/.claude/settings.json`. The tests gate runs on commit rather than on Stop, to avoid slowing down or looping on ordinary replies.
- **Commands:** `/ticket-init`, `/analyze-ticket`, `/update-analysis`, `/plan-ticket`, `/pr-describe`, `/resolve-review`, plus the `repo-explorer` agent.
- **Jira test plan:** `/jira-test-plan` with TP IDs and per-item screenshot evidence, sanitized for the BA/PO.
- **E2E:** the Playwright repo is treated as an affected repo; `/e2e-plan` and an e2e variant of `/build-task`. Runs are local only, with failures checked against `main`.
- **PR template:** standard sections with `awf:` markers for refresh; no screenshots, by team convention.
- **Core:** `/build-task`, `/review-task`, `task-reviewer`; ticket, analysis, open questions, plan and tasks templates; workflow and inventory docs.
