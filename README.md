# ai-dev-workflow

A personal toolkit of Claude Code slash commands, agents, hooks and templates for taking a Jira ticket from intake to merged PRs across one or more microservice repos.

## What's here

| Path | Purpose |
|---|---|
| `docs/workflow.md` | The working procedure: phases, gates, artifacts, conventions |
| `docs/commands-inventory.md` | Every command, agent, hook and template — purpose, inputs, outputs, status |
| `.claude/commands/` | Slash command files |
| `.claude/agents/` | Subagent definitions, e.g. reviewer, repo explorer |
| `hooks/` | Hook scripts and settings snippets *(to be built)* |
| `templates/` | Ticket, analysis, open questions, plan, e2e plan, task list and PR description templates |
| `CHANGELOG.md` | What changed in the kit and why *(to be added)* |

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

Symlink the commands and agents into your personal Claude config. They then work in any Claude Code session, and edits in this repo take effect immediately.

```bash
cd ~/dev-utilities/ai-dev-workflow
mkdir -p ~/.claude/commands ~/.claude/agents
ln -sf "$PWD"/.claude/commands/*.md ~/.claude/commands/
ln -sf "$PWD"/.claude/agents/*.md ~/.claude/agents/
```

Re-run the two `ln` lines whenever a new command or agent file is added. Check with:

```bash
ls -l ~/.claude/commands ~/.claude/agents
```

To uninstall, remove only the symlinks that point here:

```bash
find ~/.claude/commands ~/.claude/agents -lname "$HOME/dev-utilities/ai-dev-workflow/*" -print -delete
```

Packaging as a plugin is still an option for later (decision D1 in `docs/workflow.md`).

## Quick reference

Run commands from the **ticket folder root** (e.g. `~/work/tickets/PROJ-123/`), with repo worktrees under `repos/`. Full procedure: [`docs/workflow.md`](docs/workflow.md).

| Command | What it does | Status |
|---|---|---|
| `/build-task [T# \| next]` | Builds one task (app or Playwright): specs first, implement, verify, independent review, then stops for your approval before committing | drafting |
| `/review-task [T#]` | Independent read-only review of one task's changes | drafting |
| `/e2e-plan [coverage notes]` | Writes the Playwright test plan and adds e2e tasks to `tasks.md`; you decide coverage | drafting |
| `/jira-test-plan [draft \| evidence]` | Stakeholder test plan for the Jira comment, sanitized; `evidence` captures one screenshot per test item | drafting |

At the approval step of `/build-task`, reply with:
- `approve`: commit this task's files
- `approve & push`: commit and push (creates a draft PR if there isn't one)
- `changes: …`: adjust and come back to the approval step

After each task: `/clear`, then `/build-task next`.

**Agents:** `task-reviewer`, a fresh-context, read-only reviewer used by both commands.

**Templates** (copy into a ticket folder): `ticket.md`, `open-questions.md`, `analysis.md`, `plan.md`, `e2e-plan.md`, `test-plan-jira.md`, `tasks.md`, `pr-description.md`.

The full list of planned commands, agents and hooks is in [`docs/commands-inventory.md`](docs/commands-inventory.md).
