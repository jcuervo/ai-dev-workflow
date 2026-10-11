---
description: Ship the ticket — Definition of Done check, sync with the default branch, push every change/e2e repo, create or update all PRs/MRs with cross-links and deploy order, then mark them ready. Approval at each gate.
argument-hint: "[check]"
---

# Ship the ticket

Run this from the **ticket folder root**. Argument: `$ARGUMENTS`. `check` runs Step 1 only (the Definition of Done report) and stops.

Nothing is pushed, created or marked ready without my approval.

## Step 1 — Definition of Done

Check each item and show a pass/fail checklist with evidence:

- [ ] **All tasks `done`**, each with a review whose last verdict isn't `not ready` (`reviews/T#.md`)
- [ ] **Every AC traced:** each AC in `ticket.md` maps to `done` tasks and to specs (and e2e scenarios where `e2e-plan.md` says so) that exist in the repos
- [ ] **Specs pass in every `change` repo:** run the specs for the files changed on the branch (`git diff --name-only <default>...HEAD`) plus every spec the tasks list, using each repo's `CLAUDE.md` commands (in Docker if the service runs there)
- [ ] **Lint and security clean:** RuboCop on changed files, Brakeman, and bundler-audit if `Gemfile.lock` changed
- [ ] **E2E passed** locally against the current branches, if the ticket has e2e tasks. Use the run recorded at the latest e2e task commit, or re-run if any app repo changed since.
- [ ] **Migrations reviewed:** list each new migration, and whether it's safe to run online and reversible
- [ ] **Stakeholder test plan** (`test-plan.md`) complete, with evidence for every TP row, if the ticket has one
- [ ] **No open blocking questions** in `open-questions.md`
- [ ] **Docs, changelog and README** updated where the plan says so
- [ ] **No stray changes:** each repo is clean, with no uncommitted or untracked files from the work

Mark an item **n/a** with a reason where it doesn't apply. **If anything fails, stop**, list what to fix, and suggest the command for each. With `check`, stop here either way.

## Step 2 — Up to date with the default branch

For each `change` and `e2e` repo, fetch and count the commits the default branch has that the ticket branch lacks. If any repo is behind, show the counts and offer `/ticket-repos sync` before continuing. Shipping a stale branch just moves the conflict to the reviewers. Continue without syncing only if I say so.

## Step 3 — Push

Show, per repo, the branch and the commits that will be pushed (`git log --oneline origin/<branch>..HEAD`, or all branch commits if it's never been pushed). **Wait for approval**, then push each repo (`git push -u origin <branch>`). Never force-push unless I explicitly approve it for that repo (e.g. after a rebase).

## Step 4 — PRs / MRs

For each `change` and `e2e` repo, in deploy order from `plan.md`:
1. Create a draft PR/MR if none exists, using the code host's CLI (`$AWF_KIT/docs/code-hosts.md`).
2. Run the **`/pr-describe`** procedure for that repo: real test results, AC table, risk and rollout.
3. Once every PR exists, make sure each one's **Related PRs and deploy order** section links all the others, with the order and the reason for it. Refresh any PR whose section is missing links (`/pr-describe --refresh`).

Show me all titles and bodies (or a summary, plus the full text on request), and **wait for approval** before updating the code host.

With no usable CLI: write each description to `out/<repo>-pr.md` and tell me which PRs to open by hand, in what order.

## Step 5 — Ready for review

Ask whether to mark the PRs ready for review (all of them, or name which). On approval, mark them ready. Then finish with:
- A table: repo · PR/MR link · CI · ready
- The **deploy order**, one line each
- A paste-ready message for the team or ticket, listing all the PR links in deploy order
- The next step: reviewers review, then `/resolve-review <PR>` per PR as comments come in. `/ticket-status` shows the review state across all PRs.
