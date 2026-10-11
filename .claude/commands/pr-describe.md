---
description: Write or refresh a PR/MR title and description from the standard template, with real test results — shown for approval before updating GitHub, GitLab or Azure DevOps (or written to a file to paste)
argument-hint: "[repo | PR number] [--refresh]"
model: sonnet
effort: medium
---

# PR description

Arguments: `$ARGUMENTS`

- **Where to run:** from the **ticket folder root** (best, since it has the full ticket context), or from inside a repo for a PR without a ticket folder.
- **Repo:** a repo name under `repos/`, a PR number, or empty for the current repo's branch PR.
- **`--refresh`:** update an existing description after new commits, typically after `/resolve-review`.

Nothing is changed on the code host until I approve it.

**Code host:** detect it from `git remote get-url origin` and use the matching CLI and commands from `$AWF_KIT/docs/code-hosts.md` (GitHub `gh`, GitLab `glab`, Azure DevOps `az repos`). The `gh` commands below are the GitHub versions; translate them for other hosts. If no CLI fits or it isn't logged in, use **manual mode** from that file. Call it a merge request (MR) on GitLab.

## Step 1 — Find the PR and context

1. Locate the PR: `gh pr view <number or branch> --json number,url,title,body,headRefName,baseRefName,isDraft`. If there's no PR for the branch, say so and offer to create a draft with `gh pr create --draft`.
2. If you're in a ticket folder, read `ticket.md`, `plan.md` (the sections for this repo), `tasks.md` (this repo's tasks), `notes.md` and `e2e-plan.md` if present.
3. Read the change itself: `git log --oneline <base>..HEAD` and `git diff <base>...HEAD --stat`, then the diff for the files that matter.
4. **Template choice:** if the repo has `.github/pull_request_template.md` (or `docs/` or root, or a `PULL_REQUEST_TEMPLATE/` folder), use it as the base and fill its sections first. Then add sections from `$AWF_KIT/templates/pr-description.md` that it lacks: at minimum Acceptance criteria, Test results, Risk and rollout, and Revisions. Otherwise use our template.
5. **Related PRs:** find the other PRs for this ticket in the other `change` and `e2e` repos (roles in `ticket.md`), including the Playwright repo, with `gh pr list --head <branch> --json number,url` in each repo.

## Step 2 — Run the checks (for Test results)

In the repo, using the commands from its `CLAUDE.md` if they differ:
- The full spec suite if it runs in reasonable time; otherwise the specs for changed files plus every spec the ticket's tasks list. **State which.**
- `bundle exec rubocop` on changed files and `bundle exec brakeman -q --no-pager` (Rails repos)
- For the Playwright repo: the ticket's e2e specs, run locally (ask me to start the stack if it isn't up)
- The CI status: `gh pr checks <number>`

Record the short SHA the results are for. **Never report results you didn't get from an actual run.** If something couldn't run, say "not run" and why.

## Step 3 — Write

### New description
Fill every section between `<!-- awf:… -->` markers:
- **Title:** `[KEY] <imperative summary>`, specific enough to stand alone in `git log`
- **Summary:** what and why, readable without Jira
- **Changes:** grouped by area, with reasons for non-obvious choices
- **Acceptance criteria:** every AC this PR touches, mapped to specs or e2e specs
- **Test results:** from Step 2, with the SHA
- **How to test:** concrete steps a reviewer can follow locally
- **Risk and rollout:** migrations, flags, config, rollback, monitoring
- **Notes for reviewers:** where to focus, what's safe to skim, follow-ups
- **Revisions:** leave the heading with "None yet"

No screenshots, by team convention. Remove any section that genuinely doesn't apply instead of writing "N/A" (Revisions always stays).

### `--refresh`
1. Find the SHA in the current **Test results** section, then read what changed since: `git log --oneline <sha>..HEAD` and `git diff <sha>..HEAD`.
2. Decide which sections those changes make **untrue or incomplete**. Typically: Changes, Acceptance criteria, Risk, How to test. Test results always changes.
3. Regenerate **only** those sections, inside their markers. **Leave everything outside the markers exactly as it is**, since that's where human edits live. If a section has lost its markers, don't rewrite it; tell me it needs a manual check.
4. Re-run Step 2 and update Test results with the new SHA.
5. Add a **Revisions** entry at the top: date, short SHAs, and one line on what changed and why (e.g. "Moved refund validation into the model, per review").

## Step 4 — Approve, then update

1. Write the body to a temp file and show me the title and body. For `--refresh`, show **only the changed sections**, as before/after.
2. Wait for **approve**, or for changes.
3. On approval: `gh pr edit <number> --title "<title>" --body-file <file>`.
4. If this is the first full description and the PR is a draft, ask whether to mark it ready: `gh pr ready <number>`.
5. Give me the PR URL in one line.
