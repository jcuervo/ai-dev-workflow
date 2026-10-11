# Code hosts

The kit isn't tied to one account or one host. Commands work out where each repo lives and which account to use **at run time**.

## Which account is used

| What | Comes from | Per-machine or per-folder |
|---|---|---|
| **Commit author** | `git config user.name` / `user.email` | Global, per repo, or per folder with `includeIf` (see below) |
| **Push / pull** | Git credentials for the remote (SSH key or credential helper) | Per host; SSH host aliases allow several accounts on one host |
| **PR / MR operations** (`/pr-describe`, `/resolve-review`, draft PRs from `/build-task`) | The host CLI's logged-in account: `gh`, `glab` or `az` | `gh auth switch` / `gh auth login --hostname <ghe host>`; `glab auth login --hostname <host>` |

Nothing in the kit stores an account. Switch accounts with git and the host CLIs, and the commands follow.

Personal and work identities on one machine, in `~/.gitconfig`:

```ini
[includeIf "gitdir:~/work/"]
  path = ~/.gitconfig-work      # contains [user] name/email for work
```

## Detecting the host

Commands run `git -C <repo> remote get-url origin` and match the host:

| Remote host | Platform | CLI | Term |
|---|---|---|---|
| `github.com`, or a GitHub Enterprise host where `gh auth status` lists it | GitHub | `gh` | pull request (PR) |
| `gitlab.com`, or a self-hosted GitLab | GitLab | `glab` | merge request (MR) |
| `dev.azure.com`, `*.visualstudio.com` | Azure DevOps | `az repos` (Azure CLI with the azure-devops extension) | pull request |
| `bitbucket.org`, anything else, or no remote | Other | none | — |

If the matching CLI isn't installed or isn't logged in, commands fall back to **manual mode**.

## Operations by platform

| Operation | GitHub (`gh`) | GitLab (`glab`) | Azure DevOps (`az repos pr`) |
|---|---|---|---|
| Find the PR/MR for a branch | `gh pr view <branch> --json number,url,title,body,isDraft` | `glab mr view <branch> -F json` | `az repos pr list --source-branch <branch>` |
| Create a draft | `gh pr create --draft --title … --body-file …` | `glab mr create --draft --title … --description …` | `az repos pr create --draft --source-branch … --title … --description …` |
| Update title and body | `gh pr edit <n> --title … --body-file …` | `glab mr update <n> --title … --description …` | `az repos pr update --id <n> --title … --description …` |
| Mark ready | `gh pr ready <n>` | `glab mr update <n> --ready` | `az repos pr update --id <n> --draft false` |
| CI status | `gh pr checks <n>` | `glab ci status` (on the branch) | `az pipelines runs list --branch <branch>` |
| Unresolved review threads | `gh api graphql` → `reviewThreads` (`isResolved`) | `glab api projects/:id/merge_requests/<n>/discussions` (`resolved: false`) | `az repos pr thread list --id <n>` (REST: threads with `status: active`) |
| Reply in a thread | `gh api graphql` → `addPullRequestReviewThreadReply` | `glab api -X POST projects/:id/merge_requests/<n>/discussions/<discussion_id>/notes -f body=…` | REST: `POST …/pullRequests/<n>/threads/<threadId>/comments` |
| General comment | `gh pr comment <n> --body-file …` | `glab mr note <n> -m …` | REST: new thread on the PR |

CLI flags change between versions. If one fails, check `<cli> <command> --help` and adapt; don't guess.

## Manual mode

When no CLI can do an operation, commands do everything except the remote action:
- Write the PR/MR **title and description** to `<ticket>/out/<repo>-pr.md`, ready to paste
- For reviews: ask me to paste the review comments (or export them), then triage and fix as usual, and write the **replies** to `<ticket>/out/<repo>-replies.md`, one per comment, ready to post
- Say plainly which step I need to do by hand
