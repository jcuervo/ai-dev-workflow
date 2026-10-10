# Setup and next steps

A checklist for installing the kit on a machine, plus what's still to do. Tick things off as you go.

---

## 1. Install on a machine

Do this on **each** machine you use: personal and work.

### 1.1 Get the repo
- [ ] Personal machine: already at `~/dev-utilities/ai-dev-workflow`
- [ ] Push it to a **private** GitHub repo (it holds tooling only, no client content)
- [ ] Work machine: clone it to the same path, `~/dev-utilities/ai-dev-workflow`

### 1.2 Prerequisites
- [ ] `jq`: `brew install jq` (the hooks need it)
- [ ] `gh` installed and authenticated: `gh auth status` (for `/pr-describe` and `/resolve-review`)

### 1.3 Commands and agents
```bash
cd ~/dev-utilities/ai-dev-workflow
mkdir -p ~/.claude/commands ~/.claude/agents
ln -sf "$PWD"/.claude/commands/*.md ~/.claude/commands/
ln -sf "$PWD"/.claude/agents/*.md ~/.claude/agents/
```
- [ ] Done. **Re-run the two `ln` lines whenever a new command or agent file is added.**

### 1.4 Environment variables
Add to `~/.zshrc`, then open a new terminal:
```bash
export AWF_KIT="$HOME/dev-utilities/ai-dev-workflow"
export AWF_TICKETS_ROOT="$HOME/work/tickets"
```
- [ ] Done

### 1.5 Hooks
```bash
~/dev-utilities/ai-dev-workflow/hooks/install.sh
```
- [ ] Installed (it backs up `~/.claude/settings.json` first and is safe to re-run)
- [ ] Restart Claude Code, then run `/hooks` and confirm the four hooks are listed
- [ ] If repos run tests in Docker or via `bin/rspec`: set `AWF_RSPEC_CMD` (and `AWF_RUBOCOP_CMD`, `AWF_BRAKEMAN_CMD`) in `~/.zshrc`

### 1.6 Verify
- [ ] Type `/` in Claude Code and confirm the commands appear (`/build-task`, `/pr-describe`…)

---

## 2. Things to remember

**Hooks**
- They do nothing outside Rails repos, or when a gem isn't in that repo's `Gemfile.lock`. They're safe in the Playwright repo and in non-work projects.
- A tool that can't run never blocks. A missing `bundle` or gem shows a notice and the action proceeds.
- `AWF_SKIP_HOOKS=1 claude` disables all of them for one session.
- `AWF_RUBOCOP_AUTOCORRECT=1` lets RuboCop fix offenses itself instead of only reporting.
- The protected-files hook covers Claude's edit tools, **not** shell writes like `sed -i` or `>`.
- The spec lookup follows Rails naming (`app/x.rb` → `spec/x_spec.rb`, controllers → request specs). Specs elsewhere aren't found, and the commit is then allowed.
- Brakeman only blocks on warnings **in changed files**. A false positive goes in `config/brakeman.ignore`.

**Commands**
- Run ticket commands from the **ticket folder root** (`$AWF_TICKETS_ROOT/<KEY>/`). `/pr-describe` and `/resolve-review` also work from inside a repo without a ticket folder.
- One task per session: `/build-task next` → approve → `/clear` → repeat.
- Playwright runs **locally only**. A failing test is checked against `main` before it's treated as a regression.
- Screenshots and ticket content stay in the ticket folder, never in this repo or the Playwright repo.

**Maintaining the kit**
- A command misbehaves → edit its `.md` file. The change takes effect in the next session, thanks to the symlinks.
- Add a line to `CHANGELOG.md` for each change, so you know later why a command looks the way it does.
- Move a command's status in `docs/commands-inventory.md` from `drafting` → `in use` → `stable` as it proves itself.

---

## 3. First real use (to validate drafts)

Everything is **drafting** until it has been used on real work. Suggested order:

- [ ] **Hooks:** make one edit and one commit in a real Rails repo. Check RuboCop feedback appears and the specs gate runs the right specs.
- [ ] **`/pr-describe`:** on your next PR. Check the template, real test results and related PRs.
- [ ] **`/resolve-review`:** on the next PR with review comments. Check the triage table, replies and the `--refresh` of the description.
- [ ] **Full ticket:** `/ticket-init` → `/analyze-ticket` → `/update-analysis` → `/plan-ticket` → `/e2e-plan` → `/build-task` loop → `/jira-test-plan evidence` → `/pr-describe` → `/resolve-review`.
- [ ] **E2E on the work machine:** confirm `/e2e-plan` follows the Playwright repo's `CLAUDE.md`, and decide how evidence screenshots are captured (the repo's own mechanism, or env-gated `page.screenshot()`).

After each, note what to fix in `CHANGELOG.md` and update the command.

---

## 4. Still to build

| Priority | Item | What it's for |
|---|---|---|
| P2 | `/ticket-status` | Done, blocked, ACs without passing specs, branches ready to push |
| P2 | `/dod-check` | Definition of Done gate before marking PRs ready |
| P2 | `CLAUDE.md` starter for service repos | Short, current repo context: commands, conventions, gotchas |
| P3 | `/capture-learnings` | Turn recurring review findings into `CLAUDE.md` rules or review-skill references |
| P3 | `/ticket-retro` | Metrics per ticket: questions, review rounds, cycle time |
| P3 | `contract-checker` agent | Catch API and event contract mismatches across repos |

## 5. Open decisions

Tracked in [`workflow.md`](workflow.md#open-decisions). Still open:
- **D2:** Jira access, via a connector or by pasting
- **D3:** confirm the ticket workspace location (`~/work/tickets/` is the current default)
- **D4:** whether trivial tasks may skip the per-task approval
- **D5:** automated first-pass PR review in CI
- **D6:** how the org code review skill is referenced
- **D7:** who resolves review threads
- **D9:** Jira test plan format and posting

Decided:
- **D1:** symlinks for now
- **D8:** Playwright runs locally only
