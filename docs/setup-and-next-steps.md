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
- [ ] `jq`: `brew install jq` (macOS) or `sudo apt install jq` (Ubuntu). The installer and hooks need it.
- [ ] `gh` installed and authenticated: `gh auth status` (for `/pr-describe` and `/resolve-review`). On Ubuntu, install it from GitHub's apt repository (see cli.github.com).

### 1.3 Run the installer
```bash
cd ~/dev-utilities/ai-dev-workflow
AWF_REPOS_ROOT=~/work/repos ./install.sh    # the folder holding your service repos
```
It works on macOS and Ubuntu, with zsh or bash. It links the commands and agents into `~/.claude/`, and writes the settings to two places: Claude Code's `env` in `~/.claude/settings.json` (what commands and hooks use, however Claude Code is launched) and `~/.config/ai-dev-workflow/env.sh` (for your terminal, sourced from `~/.bashrc` and/or `~/.zshrc`). It also creates `~/work/tickets`, builds the repo registry, merges the hooks into `~/.claude/settings.json` (backed up first), and turns off Claude's commit attribution.
- [ ] Done. **Re-run it whenever a new command or agent is added to the kit.**
- [ ] Open `~/.config/ai-dev-workflow/repos.yml` and **write a one-line description for each service** (what it owns, its main APIs and events). Commands use these to propose repos, so accuracy matters. Fix `kind` and `runs_in` where the scan guessed wrong. Run `bin/awf-repos-scan` again when you clone a new repo.
- [ ] Branch mode is the default (the ticket branch goes in your normal clones, which suits Docker). Use `AWF_BRANCH_MODE=worktree ./install.sh` to switch.
- [ ] Open a new terminal, then restart Claude Code
- [ ] **Commit identity:** commits are authored by your git identity, and the installer turns off Claude's `Co-Authored-By` and PR attribution (setting `attribution` in `~/.claude/settings.json`; a hook also blocks it). Check `git config user.name` and `git config user.email`. On the work machine, if work repos need a different identity from your personal one, use `includeIf` (see section 2).
- [ ] Run `/hooks` and confirm the six hooks are listed
- [ ] If repos run tests in Docker or via `bin/rspec`: set `AWF_RSPEC_CMD` (and `AWF_RUBOCOP_CMD`, `AWF_BRAKEMAN_CMD`) in the `env` block of `~/.claude/settings.json`, so the hooks see them

### 1.6 Verify
- [ ] Type `/` in Claude Code and confirm the commands appear (`/build-task`, `/pr-describe`…)

---

## 2. Things to remember

**Commit identity**
- Commits use your git identity (`git config user.name/email`). No Claude attribution: `attribution` is off in `~/.claude/settings.json`, and `commit-message-check.sh` denies any commit message carrying it.
- For different identities per folder (e.g. personal vs work), add to `~/.gitconfig`:
  ```ini
  [includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work
  ```
  with the work `[user]` name and email in `~/.gitconfig-work`.

**Hooks**
- They do nothing outside Rails repos, or when a gem isn't in that repo's `Gemfile.lock`. They're safe in the Playwright repo and in non-work projects.
- A tool that can't run never blocks. A missing `bundle` or gem shows a notice and the action proceeds.
- `AWF_SKIP_HOOKS=1 claude` disables all of them for one session.
- `AWF_RUBOCOP_AUTOCORRECT=1` lets RuboCop fix offenses itself instead of only reporting.
- The protected-files hook covers Claude's edit tools, **not** shell writes like `sed -i` or `>`.
- The spec lookup follows Rails naming (`app/x.rb` → `spec/x_spec.rb`, controllers → request specs). Specs elsewhere aren't found, and the commit is then allowed.
- Brakeman only blocks on warnings **in changed files**. A false positive goes in `config/brakeman.ignore`.

**Commands**
- Repo roles: `change` and `e2e` get the ticket branch; `run` repos stay on their latest default branch but must be running; `reference` is read only.
- In branch mode a clone holds one ticket at a time. `/ticket-repos release` before switching tickets, and `/ticket-repos status` before e2e or evidence runs.
- Run ticket commands from the **ticket folder root** (`$AWF_TICKETS_ROOT/<KEY>/`). `/pr-describe` and `/resolve-review` also work from inside a repo without a ticket folder.
- One task per session: `/build-task next` → approve → `/clear` → repeat.
- Playwright runs **locally only**. A failing test is checked against `main` before it's treated as a regression.
- Screenshots and ticket content stay in the ticket folder, never in this repo or the Playwright repo.

**Changing settings**
- Re-run the installer with the new value, e.g. `AWF_BRANCH_MODE=worktree ./install.sh`. It updates both `~/.claude/settings.json` and `env.sh`. Don't edit only one of them.

**Maintaining the kit**
- A command misbehaves → edit its `.md` file. The change takes effect in the next session, thanks to the symlinks.
- Add a line to `CHANGELOG.md` for each change, so you know later why a command looks the way it does.
- Move a command's status in `docs/commands-inventory.md` from `drafting` → `in use` → `stable` as it proves itself.

---

## 3. First real use (to validate drafts)

Everything is **drafting** until it has been used on real work. Rehearse first with [`examples/dry-run.md`](../examples/dry-run.md) if you like, then:

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
