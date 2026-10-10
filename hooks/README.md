# Hooks

Deterministic checks that run on their own. Commands can skip a step; hooks can't.

| Script | Event | What it does | Blocks? |
|---|---|---|---|
| `protected-files.sh` | PreToolUse: Edit, Write, MultiEdit, NotebookEdit | Denies edits to secrets and generated files listed in `protected-paths.txt` (`.env*`, credentials, keys, `db/schema.rb`, lock files…), with a reason saying what to do instead | Yes, denies the edit |
| `rubocop-on-edit.sh` | PostToolUse: Edit, Write, MultiEdit | Runs RuboCop on the Ruby file just edited and feeds offenses back to Claude | Feedback only (the edit already happened) |
| `specs-before-commit.sh` | PreToolUse: Bash (`git commit`) | Finds specs related to the changed files (`app/x.rb` → `spec/x_spec.rb`, controllers → request specs, changed specs themselves) and runs them | Yes, if any fail |
| `security-before-commit.sh` | PreToolUse: Bash (`git commit`) | Brakeman, reporting only warnings **in changed files** so existing warnings don't block; bundler-audit when `Gemfile.lock` changed | Yes, on findings |

## Behaviour

- **Works from the ticket folder.** Each script finds the git repo of the file or commit (`git -C repos/x commit`, `cd repos/x && git commit`).
- **No-ops outside Rails repos**, or when the gem isn't in that repo's `Gemfile.lock` (rubocop, rspec-core, brakeman, bundler-audit). They're safe to install globally.
- **Related specs are a superset:** staged, unstaged and untracked changes. That covers `git add x && git commit` in one command, where nothing is staged yet when the hook runs.
- **Missing tools never block.** If jq, bundle or a gem can't run, you get a non-blocking hook notice and the action proceeds.

## Install

Needs `jq` (`brew install jq`).

```bash
~/dev-utilities/ai-dev-workflow/hooks/install.sh             # merges into ~/.claude/settings.json
~/dev-utilities/ai-dev-workflow/hooks/install.sh --uninstall # removes only these hooks
```

The installer backs up the settings file first, keeps your existing hooks, and is safe to re-run. Restart Claude Code (or open `/hooks` to check) after installing.

## Configuration

Environment variables, read when Claude starts:

| Variable | Default | Use |
|---|---|---|
| `AWF_SKIP_HOOKS=1` | unset | Disable all these hooks for a session |
| `AWF_RUBOCOP_AUTOCORRECT=1` | unset | Let RuboCop autocorrect instead of only reporting |
| `AWF_RSPEC_CMD` | `bundle exec rspec` | e.g. `bin/rspec`, or a Docker wrapper |
| `AWF_RUBOCOP_CMD` | `bundle exec rubocop` | |
| `AWF_BRAKEMAN_CMD` | `bundle exec brakeman` | |
| `AWF_AUDIT_CMD` | `bundle exec bundle-audit` | |

Add patterns to `protected-paths.txt` as needed. A leading `!` re-allows a path, and later lines win.

## Limits

- `protected-files.sh` covers Claude's edit tools, not shell writes (`sed -i`, `>`).
- Related-spec lookup is by naming convention. Specs in unusual locations won't be found, so the gate then allows the commit.
- The tests gate runs on commit, not on every stop, to avoid slowing down or looping on ordinary replies.
- Scripts target macOS's default bash 3.2, so they also run on newer bash.
