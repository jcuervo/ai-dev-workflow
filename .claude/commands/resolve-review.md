---
description: Work through a PR/MR's review comments (GitHub, GitLab, Azure DevOps, or pasted) — triage, fix, verify, push, reply and refresh the description, with approval at each gate
argument-hint: "[PR number | URL]"
model: sonnet
effort: high
---

# Resolve PR review

Arguments: `$ARGUMENTS`. A PR number or URL, or empty for the PR on the current branch.

Run this from the repo, or from the ticket folder root (then `cd` into `repos/<repo>` for git work). **Nothing is pushed or posted without my approval.**

**Code host:** detect it from `git remote get-url origin` and use the matching CLI and commands from `$AWF_KIT/docs/code-hosts.md`. The `gh` commands below are the GitHub versions. On GitLab use `glab` and MR discussions; on Azure DevOps use `az repos pr` threads. With no usable CLI, use **manual mode**: I paste the comments, and you write the replies to a file for me to post.

## Step 1 — Pull everything

1. Find the PR: `gh pr view <pr> --json number,url,title,headRefName,baseRefName,author`.
2. Make sure you're on the PR's branch (`headRefName`), not the default branch. If you aren't, stop and tell me.
3. Make sure the local branch is current: `git fetch` and confirm the branch isn't behind its remote. If it is, stop and tell me rather than pulling over local changes.
4. Fetch **unresolved review threads** (inline comments) with GraphQL:
   ```bash
   gh api graphql -F owner='{owner}' -F repo='{repo}' -F pr=<number> -f query='
   query($owner:String!,$repo:String!,$pr:Int!){
     repository(owner:$owner,name:$repo){ pullRequest(number:$pr){
       reviewThreads(first:100){ nodes{
         id isResolved isOutdated path line
         comments(first:50){ nodes{ author{login} body createdAt url } }
       }}
     }}
   }'
   ```
   Keep only threads with `isResolved: false`. Read every comment in each thread, not just the first.
5. Fetch **review summaries and general PR comments**: `gh pr view <pr> --json reviews,comments`. Include bot reviews (Claude, CI bots). Ignore ones that only say approved or LGTM.
6. Skip anything I've already replied to, unless the reviewer replied after me.

## Step 2 — Triage

For each item, read the code it refers to; for outdated threads, the current version. Then propose one of:
- **fix:** the reviewer is right; say what you'll change
- **discuss:** reasonable people could disagree, or it needs a decision; say what the question is
- **decline:** give a concrete reason (out of scope, conflicts with the plan or ACs, incorrect)
- **already addressed:** point to the commit or line

Group items that are the same issue.

Show me a table and **wait**:

| # | Reviewer | Where | Comment (short) | Proposal | Plan |
|---|---|---|---|---|---|

I may change proposals. Don't touch code until I approve the triage.

## Step 3 — Fix

For each approved **fix** (or group):
1. Make the smallest change that addresses it, staying within this PR's scope. If a fix would grow the PR noticeably, stop and suggest a follow-up ticket instead.
2. Add or adjust specs where behaviour changed.
3. Commit separately, staging by explicit path (never `git add -A`):
   `[KEY] Address review: <summary>` (KEY from the branch name or ticket folder), per `$AWF_KIT/templates/commit-message.md`. No `Co-Authored-By` or other trailers.
4. Note the short SHA against the item.

## Step 4 — Verify

Run the specs for changed files, `bundle exec rubocop` on changed files, and Brakeman if relevant. Use the repo's commands from `CLAUDE.md` if they differ. Fix failures before going on. For the Playwright repo, run the affected e2e specs locally.

If a fix changes behaviour covered by e2e tests in another repo, tell me so we can update them.

## Step 5 — Push

Show the commits (`git log --oneline origin/<branch>..HEAD`) and **wait for approval**. Then `git push`.

## Step 6 — Draft replies

One reply per thread or item. Keep them short and specific, in a neutral, collegial tone:
- **fix:** what changed, plus the commit SHA ("Moved this into `Refund#validate_amount` — abc1234")
- **discuss:** the question or trade-off, plus your suggested option
- **decline:** the reason, politely and specifically
- **already addressed:** where

Don't thank reviewers in every reply, and never claim something was fixed that wasn't.

Show all drafts numbered and **wait**. I'll approve, edit or drop each one.

## Step 7 — Post

Post only the approved replies:
- **Review threads:**
  ```bash
  gh api graphql -f query='mutation($id:ID!,$body:String!){
    addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$id, body:$body}){ comment{ url } }
  }' -F id=<thread id> -F body=@<file>
  ```
- **General comments or review summaries:** one `gh pr comment <pr> --body-file <file>` that addresses each point.

**Don't resolve threads.** The reviewer resolves them, unless I say otherwise for this PR.

## Step 8 — Refresh the description

If the fixes changed behaviour, approach, scope, risk or how to test, run the `/pr-describe --refresh` procedure for this PR. If they only touched naming, style or tests, say so; Test results still change, so ask whether to refresh anyway.

Finish with a short summary: items fixed, discussed, declined; commits pushed; replies posted; description refreshed (yes/no); anything still open.

If you're in a ticket folder, add any plan-level learnings to `notes.md`. If a kind of finding has come up before, tag it `[learning]` for `/capture-learnings`.
