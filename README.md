# ai-dev-workflow

A personal toolkit of Claude Code slash commands, agents, hooks and templates for taking a Jira ticket from intake to merged PRs across one or more microservice repos.

## What's here

| Path | Purpose |
|---|---|
| `docs/workflow.md` | The working procedure: phases, gates, artifacts, conventions |
| `docs/commands-inventory.md` | Every command, agent, hook and template — purpose, inputs, outputs, status |
| `.claude/commands/` | Slash command files *(to be built)* |
| `.claude/agents/` | Subagent definitions, e.g. reviewer, repo explorer *(to be built)* |
| `hooks/` | Hook scripts and settings snippets *(to be built)* |
| `templates/` | Analysis, plan, task list and PR templates *(to be built)* |
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

## Installing *(TBD)*

Packaging is an open decision. The options are to copy into `~/.claude/` for personal use, symlink, or package as a plugin. See the open decisions in `docs/workflow.md`.
