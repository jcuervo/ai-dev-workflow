# ai-dev-workflow

A personal toolkit of Claude Code slash commands, agents, hooks and templates for taking a ticket (Jira or any tracker) from intake to merged PRs across one or more microservice repos.

## What's here

| Path | Purpose |
|---|---|
| `docs/execution-flow.md` | **What to run, when:** the step-by-step runbook from new ticket to merged PRs, with a flow diagram and a cheat sheet |
| `docs/e2e-speed.md` | Why Playwright suites get slow, how the kit keeps new tests fast, `/e2e-audit`, and day-to-day commands for running less |
| `docs/models.md` | Which model and effort each command uses (Opus to think, Sonnet to do, Haiku to look), and how to save tokens |
| `docs/setup-and-next-steps.md` | **Start here.** Install checklist per machine, things to remember, first-use validation, what's left to build |
| `examples/dry-run.md` | Rehearsal of the full workflow on the sample todo app, with what to check at each step |
| `docs/workflow.md` | The working procedure: phases, gates, artifacts, conventions |
| `docs/commands-inventory.md` | Every command, agent, hook and template — purpose, inputs, outputs, status |
| `.claude/commands/` | Slash command files |
| `.claude/agents/` | Subagent definitions, e.g. reviewer, repo explorer |
| `hooks/` | Hook scripts, settings snippet and installer (see `hooks/README.md`) |
| `templates/` | Ticket, analysis, open questions, plan, e2e plan, task list and PR description templates |
| `CHANGELOG.md` | What changed in the kit and why |

## Principles

1. **Files are the source of truth, not sessions.** Every phase writes to the ticket folder so any fresh session can pick up from there.
2. **One task, one session, one repo, one commit set.**
3. **Specs before code.** Every acceptance criterion maps to a task and a passing spec.
4. **Deterministic checks run in hooks; judgment runs in commands.**
5. **Human gates at the points that matter:** open questions, plan approval, per-task commit, PR.
6. **The kit learns.** Recurring review findings become rules in `CLAUDE.md` or the review skill.

## Confidentiality

This repo holds **tooling only**. Ticket content, analysis documents and client code stay in the local ticket workspace (see `docs/workflow.md` → Folder layout) and are never committed here.

## Installing

| Platform | Supported | How |
|---|---|---|
| **macOS** (zsh or bash) | ✅ | [macOS](#macos) |
| **Ubuntu / Debian** (bash or zsh) | ✅ | [Ubuntu / Debian](#ubuntu--debian) |
| **Windows** | ✅ via **WSL 2** | [Windows (WSL 2)](#windows-wsl-2) |
| Windows native (PowerShell / Git Bash) | ❌ | The hooks and installer rely on Unix symlinks and tools; the installer stops and points to WSL |

Every platform needs **Claude Code**, **git** and **jq** (installer and hooks), plus the CLI for your code host: **gh** (GitHub), **glab** (GitLab) or **az** (Azure DevOps). Without one, the PR commands write files for you to paste. See [`docs/code-hosts.md`](docs/code-hosts.md), which also covers which account is used and how to switch. The kit's installer is the same `./install.sh` everywhere.

### macOS

```bash
# 1. Claude Code (skip if installed)
curl -fsSL https://claude.ai/install.sh | bash

# 2. Prerequisites
brew install jq gh
gh auth login

# 3. The kit
git clone <your private repo url> ~/dev-utilities/ai-dev-workflow
cd ~/dev-utilities/ai-dev-workflow
AWF_REPOS_ROOT=~/path/to/your/repos ./install.sh
```

### Ubuntu / Debian

```bash
# 1. Claude Code (skip if installed). An apt repository is also available: see the Claude Code setup docs
curl -fsSL https://claude.ai/install.sh | bash

# 2. Prerequisites
sudo apt update && sudo apt install -y git jq
sudo apt install -y gh        # Ubuntu 22.04+; for the newest gh use GitHub's apt repo (cli.github.com)
gh auth login

# 3. The kit
git clone <your private repo url> ~/dev-utilities/ai-dev-workflow
cd ~/dev-utilities/ai-dev-workflow
AWF_REPOS_ROOT=~/path/to/your/repos ./install.sh
```

### Windows (WSL 2)

Rails, Docker and the kit's bash hooks all work best inside WSL 2. Run **everything** there, Claude Code included.

1. In PowerShell (as Administrator): `wsl --install -d Ubuntu`, then restart and open **Ubuntu**.
2. Inside Ubuntu, follow the [Ubuntu / Debian](#ubuntu--debian) steps above.
3. Keep the kit, your repos and `~/work/tickets` in the **Linux home folder** (`~/…`), not under `/mnt/c/…`. That's much faster, and file permissions and symlinks behave. The installer warns if the kit is on the Windows drive.
4. For Docker, use Docker Desktop with WSL integration enabled for your Ubuntu distribution.
5. For VS Code, use the **WSL** extension and open folders from inside WSL (`code .`), so Claude Code runs in Linux.

### What `install.sh` does

- Symlinks the commands and agents into `~/.claude/`
- Writes the `AWF_*` settings to **Claude Code's `env` in `~/.claude/settings.json`**, so commands and hooks see them whichever shell you use and however Claude Code is started (terminal or VS Code). It mirrors them in `~/.config/ai-dev-workflow/env.sh` for your terminal, sourced from `~/.bashrc` and/or `~/.zshrc`.
- Creates the tickets folder (`~/work/tickets`) and builds the **repo registry** from `AWF_REPOS_ROOT` (`~/.config/ai-dev-workflow/repos.yml`; then edit its descriptions)
- Merges the hooks into `~/.claude/settings.json` (backed up first) and turns off Claude's commit and PR attribution
- Checks `jq`, `gh` and your git identity

Then **open a new terminal and restart Claude Code**. Run `/hooks` to see the six hooks, and type `/` to see the commands.

| Task | Command |
|---|---|
| Update after pulling kit changes (new commands, hooks) | `git pull && ./install.sh` |
| Change a setting | e.g. `AWF_BRANCH_MODE=worktree ./install.sh` (options are listed at the top of `install.sh`) |
| Add new clones to the registry | `bin/awf-repos-scan` |
| Remove the hooks only | `hooks/install.sh --uninstall` |
| Uninstall everything | `./install.sh --uninstall` (keeps `~/.config/ai-dev-workflow` and your tickets) |

The full per-machine checklist is in [`docs/setup-and-next-steps.md`](docs/setup-and-next-steps.md).

## Quick reference

Step-by-step runbook: [`docs/execution-flow.md`](docs/execution-flow.md) · rules and reasons: [`docs/workflow.md`](docs/workflow.md). Commands run from the **ticket folder** (`~/work/tickets/<KEY>/`) unless the table says otherwise. Each repo the ticket touches is reachable there as `repos/<name>`.

**Status:** **in use** means validated end to end in the dry run · **drafting** means built but not yet proven on real work.

| # | Step | Command | What it does | Status |
|---|---|---|---|---|
| 0 | Repo setup (once per repo, run inside the repo) | `/repo-setup [repo] [--update]` | Checks the repo's existing `CLAUDE.md` / `AGENTS.md` against the actual code and adds only what's missing to your personal `CLAUDE.local.md`; drafts a `CLAUDE.md` if there's none. Saves the repo's spec and lint commands for the hooks | drafting |
| 1 | Start (run from `~/work/tickets`) | `/ticket-init <KEY> [desc]` | Creates the ticket folder and `ticket.md` with numbered ACs, and suggests which repos are involved | in use |
| 2 | Analyse | `/analyze-ticket [notes]` | Explores the repos in parallel; writes `analysis.md`, `open-questions.md` and a paste-ready question list; confirms each repo's role | in use |
| 3 | Clarify | `/update-analysis` | Applies the BA/PO's answers as a delta. Mid-build, proposes the resulting task and plan changes | in use |
| 4 | Branches | `/ticket-repos [setup \| add \| status \| sync \| release]` | Creates the ticket branch in every repo being changed, puts repos that only need to run on their latest main, checks the local stack, syncs with main, and switches back when done | drafting |
| 5 | Plan | `/plan-ticket [notes]` | Proposes the plan and tasks in chat, then writes `plan.md` and `tasks.md` once you approve | in use |
| 6 | E2E plan | `/e2e-plan [coverage notes]` | Playwright test plan with test-item IDs (TP-01…), plus the e2e tasks. You decide the coverage | in use |
| 7 | Build | `/build-task [T# \| next]` | Builds one task (app or Playwright): specs first, implement, verify, review loop, then waits for your approval before committing | in use |
| 7 | Review one task | `/review-task [T#]` | Independent, read-only review of a task, saved to `reviews/T#.md`. Also works on finished tasks | in use |
| 8 | Evidence | `/test-plan [draft \| evidence] [format]` | Stakeholder test plan in plain language (Markdown, Jira markup or HTML). `evidence` runs the e2e tests and captures one screenshot per test item | drafting |
| 9 | Ship | `/ticket-ship [check]` | Definition of Done check, then pushes every repo and creates all the PRs/MRs, linked to each other in deploy order. `check` stops after the DoD report | drafting |
| 9 | One PR | `/pr-describe [repo \| PR] [--refresh]` | Writes one PR/MR's title and description with real test results. `--refresh` updates only what changed | drafting |
| 10 | Review feedback | `/resolve-review [PR]` | Triages reviewer comments, fixes, verifies, pushes, drafts replies and refreshes the description, with your approval at each step | drafting |
| — | E2E suite (run inside the Playwright repo) | `/e2e-audit [--run]` | Read-only audit of the existing Playwright suite: slowest tests, overlap and redundancy, slow patterns, and a prioritized speed-up plan | drafting |
| — | Any time | `/ticket-status` | One screen: tasks and reviews, AC coverage, branches, PR status, and the next action | drafting |

**At the approval step of `/build-task`**, reply with:
- `approve`: commit this task's files
- `approve & push`: commit and push (opens a draft PR/MR if there isn't one)
- `changes: …`: adjust, then come back to the approval step

After each task: `/clear`, then `/build-task next`.

**Agents:** `task-reviewer` (independent, read-only reviewer with a fresh context, on Opus) and `repo-explorer` (read-only, one per repo in parallel, returns a summary, on Sonnet). Both in use.

**Models:** each command sets its own model and effort: Opus for analysis, planning and review, Sonnet for building and procedures, Haiku for status. Run your session on Sonnet for the most economical setup. See [`docs/models.md`](docs/models.md).

**Hooks** (drafting): protected files · RuboCop on edit · no AI attribution in commit messages · mandatory review before a task commit · related specs pass · security scan. Details in [`hooks/README.md`](hooks/README.md).

**Templates:**
- Per repo: `repo-CLAUDE.md`
- Per ticket: `ticket.md`, `open-questions.md`, `analysis.md`, `plan.md`, `tasks.md`, `e2e-plan.md`, `test-plan.md`
- Conventions: `commit-message.md`, `pr-description.md`

Everything built and planned, with inputs, outputs and status: [`docs/commands-inventory.md`](docs/commands-inventory.md).
