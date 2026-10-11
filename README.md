# ai-dev-workflow

A personal toolkit of Claude Code slash commands, agents, hooks and templates for taking a ticket (Jira or any tracker) from intake to merged PRs across one or more microservice repos.

## What's here

| Path | Purpose |
|---|---|
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

Run commands from the **ticket folder root** (e.g. `~/work/tickets/PROJ-123/`), with repo worktrees under `repos/`. Full procedure: [`docs/workflow.md`](docs/workflow.md).

| Phase | Command | What it does | Status |
|---|---|---|---|
| Once per repo | `/repo-setup [repo] [--update]` | Audits the repo's existing `CLAUDE.md`/`AGENTS.md` and fills only the gaps in a personal `CLAUDE.local.md` (or drafts a `CLAUDE.md` if there's none); records spec/lint commands for the hooks | drafting |
| Setup | `/ticket-init <KEY> [desc]` | Creates the ticket folder and `ticket.md` with numbered ACs; proposes candidate repos from the registry | in use |
| Analysis | `/analyze-ticket [notes]` | Parallel repo exploration, then `analysis.md`, `open-questions.md`, confirmed repos and roles, and paste-ready questions | in use |
| Clarify | `/update-analysis` | Applies the BA/PO's answers as a delta; mid-build, proposes the task and plan delta | in use |
| Branches | `/ticket-repos [setup \| add \| status \| sync \| release]` | Ticket branch in every `change`/`e2e` repo; `run` repos on latest default; stack check; sync with default; switch back when done | drafting |
| Plan | `/plan-ticket [notes]` | Proposes the plan and task breakdown in chat, then writes `plan.md` and `tasks.md` on approval | in use |
| Plan | `/e2e-plan [coverage notes]` | Playwright test plan with TP IDs, plus e2e tasks; you decide coverage | in use |
| Build | `/build-task [T# \| next]` | One task (app or Playwright): specs first, implement, verify, review loop, then stops for approval before committing | in use |
| Build | `/review-task [T#]` | Independent read-only review of one task, saved to `reviews/T#.md`; also retroactive | in use |
| Any time | `/ticket-status` | One screen: tasks, reviews, AC coverage, branches, PR state, next action | drafting |
| Evidence | `/test-plan [draft \| evidence] [format]` | Stakeholder test plan for the ticket (Markdown, Jira markup or HTML), sanitized; `evidence` captures one screenshot per test item | drafting |
| Ship | `/ticket-ship [check]` | Definition of Done, sync check, push all repos, all PRs/MRs cross-linked in deploy order, mark ready | drafting |
| Ship | `/pr-describe [repo\|PR] [--refresh]` | One PR/MR's title and description with real test results; `--refresh` updates only what changed | drafting |
| Review | `/resolve-review [PR]` | Triage, fix, verify, push, reply, then refresh the description, with approval at each gate | drafting |

At the approval step of `/build-task`, reply with:
- `approve`: commit this task's files
- `approve & push`: commit and push (creates a draft PR if there isn't one)
- `changes: …`: adjust and come back to the approval step

After each task: `/clear`, then `/build-task next`.

**Agents:** `task-reviewer` (fresh-context, read-only reviewer) and `repo-explorer` (read-only, one per repo in parallel, returns a summary).

**Hooks:** protected files, RuboCop on edit, specs and security checks before `git commit`. Details in [`hooks/README.md`](hooks/README.md).

**Templates:** `repo-CLAUDE.md` (per service repo, via `/repo-setup`); per ticket: `ticket.md`, `open-questions.md`, `analysis.md`, `plan.md`, `e2e-plan.md`, `test-plan.md`, `tasks.md`, `commit-message.md`, `pr-description.md`.

The full list of planned commands, agents and hooks is in [`docs/commands-inventory.md`](docs/commands-inventory.md).
