---
description: Create or check the ticket's branches across all involved repos (branch or worktree mode), add a repo later, bring branches up to date with the default branch, or release the clones when done
argument-hint: "[setup | add <repo> [role] | status | sync | release]"
model: sonnet
effort: medium
---

# Ticket repos

Run this from the **ticket folder root**. Action: `$ARGUMENTS` (`setup` if empty).

Read `ticket.md` (the **Affected repos** table, branch name and mode) and the repo registry (`$AWF_REPOS_FILE`, default `~/.config/ai-dev-workflow/repos.yml`) for clone paths and default branches.

**Never discard work.** Never stash, reset, force-checkout or delete anything. When a repo isn't in a safe state, stop and tell me what to do.

## Safety checks (every action, every repo it touches)

For each repo, run `git -C <clone> status --short` and `git -C <clone> branch --show-current`. Then:
- **Uncommitted changes:** stop for that repo and show them. I decide (commit, stash, or leave them).
- **On another ticket's branch** (branch mode): stop and tell me which ticket. A clone can only be on one branch at a time.
- `git -C <clone> fetch origin` is fine where there's a remote. Skip it for repos without one.

## setup

Creates branches for every `change` and `e2e` repo, and prepares every `run` repo. Use it after `/analyze-ticket` has confirmed the list.

1. Show the plan, one line per repo: role, what will happen, and its current branch. **Wait for approval.**
   - **`Kind: investigation`:** create **no ticket branches**. Only prepare `run` repos (default branch, latest) so a local reproduction runs current code. Spike branches for experiments are created by `/investigate`, case by case. Usually you don't need `setup` at all for an investigation; say so.
2. **`change` and `e2e` repos:**
   - **branch mode** (default):
     1. Pull the default branch: `git -C <clone> switch <default>`, then `git -C <clone> pull --ff-only` if there's a remote.
     2. Create or switch to the ticket branch: `git -C <clone> switch -c <branch>` (or `switch <branch>` if it exists).
     3. Link it into the ticket folder: `ln -s <clone> repos/<name>`.
   - **worktree mode:**
     1. Create the worktree: `git -C <clone> worktree add <ticket>/repos/<name> -b <branch> <base>`, where `<base>` is `origin/<default>`, or the local default branch without a remote.
     2. Copy git-ignored config the service needs (`.env*`, `config/master.key`, `config/database.yml`, etc.) from the clone. List what you copied.
     3. Remind me that Docker services run from the clone path, so they won't see worktree changes. Branch mode suits Docker better.
3. **`run` repos:** no branch. Make sure each is on its default branch and up to date (`switch <default>` and `pull --ff-only`), then link it as `repos/<name>` for reference.
   - If it's deliberately on another branch (e.g. a teammate's unmerged change this ticket depends on), ask me. If I confirm, record it in the table's Notes.
4. **`reference` repos:** nothing to do. They're read in place.
5. Fill in the table's **Branch** column, and remove the "candidates" marker.
6. **Docker reminder:** list the `runs_in: docker` repos whose branch just changed. Their containers may need a restart, plus `bundle install`, migrations or an image rebuild, before the stack reflects the new code. Use each repo's `CLAUDE.md` for the exact commands. **Don't run Docker commands unless I ask.**

## add <repo> [role]

For a repo discovered after setup. Default role: `change`.
1. Confirm the repo from the registry. If it isn't in the registry, ask for its path, and suggest adding it there.
2. Run the safety checks and the matching setup steps for that repo only.
3. Add it to the **Affected repos** table, with a note in `notes.md` on why it was added. If the plan is approved, tell me which plan section and tasks need updating. Don't change an approved plan yourself.

## status

Show a table, one row per repo: role, expected branch, actual branch, clean or dirty, ahead/behind its remote, and the last commit. Flag:
- `change` or `e2e` repos not on the ticket branch
- `run` repos not on their expected branch, or behind their remote
- uncommitted changes anywhere

Use this before e2e runs and evidence capture, since the local stack must match the ticket.

## sync

Bring each `change` and `e2e` ticket branch up to date with its default branch, and pull `run` repos to latest. Use it for multi-day tickets, before `/ticket-ship`, or when a reviewer asks for it.

1. Run the safety checks, then fetch. For each repo, show how many commits the ticket branch is behind its default branch, and whether the branch has been pushed.
2. **Strategy:** use `$AWF_SYNC_STRATEGY` if set (`rebase` or `merge`). Otherwise ask, recommending:
   - **rebase** for branches not pushed yet, or not yet reviewed (a clean history)
   - **merge** once a PR is under review (no force-push, and reviewers keep their place)
3. **Wait for approval**, then per repo: `git rebase origin/<default>` or `git merge origin/<default>` (the local default branch without a remote).
4. **Conflicts:** stop at the first conflicted repo. Show the conflicted files and what each side changed, and propose a resolution. **Resolve only with my approval**, then continue (`git rebase --continue`, or commit the merge). If it's not clear-cut, `git rebase --abort` / `git merge --abort` and tell me.
5. After each repo: run its specs for the files the ticket changed, plus the files the default branch changed that overlap them. Report failures; don't fix them here. A fix is a task, or a `/build-task` follow-up.
6. **Pushing:** a merged branch can be pushed normally once I approve. A rebased branch that was already pushed needs `git push --force-with-lease`. Ask explicitly per repo, and never use a plain `--force`.
7. `run` repos: `switch <default>` and `pull --ff-only`, as in setup.
8. Remind me which Docker services changed and may need a restart, migrations or a rebuild. Record the sync in `notes.md` (date, repos, strategy, conflicts).

## release

When the ticket is merged, or paused to work on another ticket:
1. Run the safety checks. Show which `change`, `e2e` and `run` clones are on the ticket branch or ahead of their remote. **Don't release a repo with unpushed commits;** list them for me.
2. On approval: in branch mode, switch each clean clone back to its default branch. In worktree mode, `git worktree remove` each clean worktree.
3. Don't delete branches. Leave the `repos/` links in place, since they still point at the clones.
4. Remind me which Docker services changed branch again.
