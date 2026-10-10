# Dry run: the full workflow on a sample app

Rehearse the kit end to end on a throwaway app before relying on it at work. Expect it to take an hour or two. **Note what goes wrong**; that's the point.

## The setup

| Thing | Path |
|---|---|
| App repo (Rails 8.1, RSpec) | `~/dev-utilities/sample-app/todo-list` |
| Playwright repo | `~/dev-utilities/sample-app/todo-e2e` |
| Sample ticket | `examples/TODO-1-ticket.md` (6 ACs, deliberately with a few gaps for the open questions step) |
| Ticket folder (created by `/ticket-init`) | `$AWF_TICKETS_ROOT/TODO-1/` |

## 0. One-off setup

```bash
# Kit installed? (see docs/setup-and-next-steps.md §1)
ls -l ~/.claude/commands | head; echo $AWF_KIT $AWF_TICKETS_ROOT

# App: adds RSpec, makes the first commit
cd ~/dev-utilities/sample-app/todo-list && bin/awf-setup

# Playwright repo: installs Playwright, makes the first commit
cd ~/dev-utilities/sample-app/todo-e2e && ./setup.sh
```

Neither repo has a git remote, which also tests `/ticket-init` on local-only repos. `/pr-describe` and `/resolve-review` need a GitHub PR, so they're optional. See step 9.

## 1. Setup — `/ticket-init`
```bash
cd ~ && claude
```
`/ticket-init TODO-1 todo-lists`, then paste the ticket from `examples/TODO-1-ticket.md` and give both repo paths.

**Check:**
- [ ] `ticket.md` has AC1–AC6
- [ ] `repos/todo-list` and `repos/todo-e2e` exist, both on branch `TODO-1-todo-lists`

## 2. Analysis — `/analyze-ticket`
```bash
cd $AWF_TICKETS_ROOT/TODO-1 && claude
```
**Check:**
- [ ] Ran `repo-explorer` agents (in parallel)
- [ ] `open-questions.md` raises the real gaps. A good analysis should ask about at least:
  - Overdue: is "today" overdue? Which time zone?
  - Is there one list for everyone, or per user? (There's no auth.)
  - Are deletes confirmed? Are titles length-limited?
  - Ordering of todos with no due date
- [ ] The paste-ready question block has no file paths or code

## 3. Clarify — `/update-analysis`
Answer as the PO would, inline in `open-questions.md`. For example: single shared list, no auth; due today is **not** overdue; app time zone only; confirm deletes; no-due-date todos sort last; title max 200 characters.

**Check:**
- [ ] Only affected sections changed; change log updated
- [ ] Status is now **ready**

## 4. Plan — `/plan-ticket`, then `/e2e-plan`
**Check:**
- [ ] Plan proposed in chat **before** any files were written
- [ ] Tasks are one repo each: migration, model, controller and views in todo-list; e2e in todo-e2e
- [ ] Every AC maps to a task
- [ ] `/e2e-plan` followed `todo-e2e/CLAUDE.md` (page objects in `pages/`, tags in titles, ticket key in describe)
- [ ] It listed `data-testid`s and added them to the feature tasks' scope
- [ ] TP IDs assigned (TP-01…)

Try `/e2e-plan "happy path, validation and overdue only"` to check your coverage notes override its proposal.

## 5. Build — `/build-task next` (repeat, with `/clear` in between)
**Check, per task:**
- [ ] Failing spec written first and run
- [ ] RuboCop hook feedback appeared on any offense
- [ ] `task-reviewer` ran in a fresh context with real findings
- [ ] Stopped for approval; commit staged only the task's files
- [ ] Specs hook ran on commit (try a deliberately failing spec once, to see it block)
- [ ] `tasks.md` updated with status and SHA

**Protected-files hook:** ask Claude to "just edit db/schema.rb to add the column". It should be denied with the migration hint.

## 6. E2E tasks
Start the app in another terminal first: `cd $AWF_TICKETS_ROOT/TODO-1/repos/todo-list && bin/rails db:migrate && bin/rails server`.

**Check:**
- [ ] It asked you to start the stack if it wasn't up
- [ ] Specs follow the repo guidelines; ran twice
- [ ] Break a selector on purpose once. Did it triage as a test bug?

## 7. Evidence — `/jira-test-plan evidence`
**Check:**
- [ ] Proposed a screenshot mechanism and **waited** before changing todo-e2e
- [ ] `evidence/TODO-1_TP-01.png`… in the ticket folder, not in the repo
- [ ] `test-plan-jira.md`: plain language, every row filled
- [ ] Sanitization check reported clean (no paths, `T#`, SHAs, localhost)

## 8. Ship check
- [ ] Every AC has a passing spec (and e2e where planned)

## 9. Optional — PR loop
Create two private GitHub repos, add them as remotes and push the branches. Then:
- `/pr-describe todo-list`: check the template, real test results, and the related Playwright PR
- Leave yourself a few review comments on GitHub, then `/resolve-review`: check the triage, fixes, replies and `--refresh`

## 10. Write it up
For everything that went wrong or felt slow, add a line to `CHANGELOG.md` and fix the command. Move commands that behaved well from `drafting` to `in use` in `docs/commands-inventory.md`.
