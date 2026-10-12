# Models and effort

Each command and agent picks its own model and effort level in its frontmatter (`model:` and `effort:`), so heavy reasoning goes to the strongest model and routine work to cheaper ones.

## The tiers

| Tier | Model | Used for | Why |
|---|---|---|---|
| **Think** | `opus` | `/analyze-ticket`, `/plan-ticket`, `/investigate`, the **`task-reviewer`** agent | Mistakes here are the expensive kind. A missed dependency or a wrong plan costs a whole ticket, and the reviewer is the quality gate for everything built |
| **Do** | `sonnet` | `/build-task`, `/resolve-review`, `/e2e-plan`, `/repo-setup`, `/update-analysis`, `/ticket-repos`, `/ticket-ship`, `/pr-describe`, `/test-plan`, `/ticket-init`, and the **`repo-explorer`** agent | Strong at coding and following precise procedures, at a fraction of the cost. Most of a ticket's tokens are spent here |
| **Look** | `haiku` | `/ticket-status` | Reads files and reports; no judgment needed |
| — | `inherit` | `/review-task` | It only hands off to `task-reviewer`, which sets its own model |

**The key pattern is a cheap builder with a strong reviewer.** `/build-task` runs on Sonnet, and every task is checked by `task-reviewer` on Opus before it can be committed. That's cheaper than building on Opus, and the review gate catches what the builder misses.

**Effort** follows the same logic: `high` where reasoning depth matters (analysis, planning, building, review triage), `medium` for procedures, `low` for status.

## How the override behaves

- **Commands:** the `model` and `effort` apply to the **turn the command runs in**: all its tool calls up to where it stops and waits for you. When you reply (e.g. `approve`), the next turn uses your **session model** again. That's fine, because the heavy work happens in the command's turn and post-approval steps are mechanical (commit, write files).
- **Agents:** `task-reviewer` and `repo-explorer` always use their own model, whoever calls them.
- **Aliases** (`opus`, `sonnet`, `haiku`) follow the latest version of each model, so nothing needs updating when new versions ship.
- **Organization limits:** if your organization's allowed-models list excludes a model, that command quietly uses your session model instead.

## The better lever: your session model

Per-command models matter, but **your session model** decides everything outside the commands: follow-up questions, replies at the gates, ad-hoc requests. Two setups:

| Setup | How | Good for |
|---|---|---|
| **Economical (recommended)** | Session on `sonnet` (`/model sonnet`, or `"model": "sonnet"` in `~/.claude/settings.json`). The commands upgrade to Opus only where it pays off | Daily ticket work |
| **Maximum quality** | Session on `opus`. Commands set to `sonnet` still drop to Sonnet for their own turn | Hard or high-risk tickets |

Other habits that save more than any model choice:
- **`/clear` between steps and between tasks.** Context carried over is paid for again on every turn. The ticket files hold the state, so nothing is lost.
- **Let agents do the reading.** `repo-explorer` reads repos in parallel and returns a summary, so the main session never carries the file dumps.
- **Keep repo `CLAUDE.md` files short.** They're loaded into every session in that repo.

## Changing a tier

Edit the `model:` / `effort:` lines at the top of the command or agent file in `.claude/commands/` or `.claude/agents/`. The installer's symlinks make the change live in your next session. Examples:
- Building tricky code this week? Set `/build-task` to `model: opus` temporarily, or set `inherit` so it follows your session.
- Want exploration even cheaper? Set `repo-explorer` to `model: haiku`. Its summaries feed the analysis, so check they're still thorough.

Per-session overrides, via env vars in `~/.claude/settings.json` or when launching: `CLAUDE_CODE_SUBAGENT_MODEL` sets the model for agents that don't specify one, and `CLAUDE_CODE_EFFORT_LEVEL` overrides every effort level.

Check what's actually running with `/tasks` (agents) and the model shown in the status line.
