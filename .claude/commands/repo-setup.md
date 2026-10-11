---
description: Prepare a service repo for the kit — audit its existing CLAUDE.md/AGENTS.md (or draft one if none), fill only the gaps in a personal CLAUDE.local.md without touching team files, and record its spec/lint commands for the hooks
argument-hint: "[repo name | path] [--update]"
---

# Repo setup

Arguments: `$ARGUMENTS`. A repo name from the registry (`$AWF_REPOS_FILE`), a path, or empty for the current repo. `--update` refreshes what an earlier `/repo-setup` wrote.

Run it once per repo, and again when the repo's setup changes.

**Read-only until I approve.** It writes, only after showing them: a personal `CLAUDE.local.md` (or a new `CLAUDE.md` if the repo has no instructions at all), and the hook commands file inside `.git/`. **It never edits a team-owned instruction file, and never commits.**

## Step 1 — Read the repo (don't guess)

Collect facts, citing the file each comes from:
- **Stack:** `Gemfile` / `Gemfile.lock` (Rails and Ruby versions, DB adapter, job backend, test framework), `.ruby-version`, `package.json` if present
- **How it runs:** `docker-compose*.yml` / `compose*.yml` (service names, which service runs the app, working dir, mounted paths), `Procfile*`, `bin/dev`, `bin/setup`, `Dockerfile`
- **How tests and checks actually run:** CI config (`.github/workflows/*`, `.gitlab-ci.yml`, `bitbucket-pipelines.yml`, `azure-pipelines.yml`, `config/ci.rb`), `bin/*` wrappers (`bin/rspec`, `bin/rubocop`), `.rspec`, `spec/rails_helper.rb`, `.rubocop.yml`, `config/brakeman.ignore`
- **Conventions:** folders under `app/` (services, interactors, serializers, policies), spec types present under `spec/`, naming patterns, API versioning, error format
- **Integrations:** HTTP clients and base URLs in config, event publishers and consumers, shared gems; cross-check against the registry descriptions of other repos
- **Existing docs:** `README*`, existing `CLAUDE.md`, `docs/`

If the service runs in Docker and the stack is up, you may run **read-only** checks to confirm a command works (e.g. `docker compose exec -T <service> bundle exec rspec --dry-run`, or the one-spec command on a single small spec). Don't start or stop containers, migrate, or install anything.

## Step 2 — What instructions already exist?

Look for every instruction file Claude Code loads for this repo: `CLAUDE.md`, `.claude/CLAUDE.md`, `.claude/rules/*.md`, `CLAUDE.local.md` and `AGENTS.md`. For each one, note whether git tracks it (`git ls-files --error-unmatch <file>`). A tracked file is **team-owned**.

Then take the path that fits:

### A. The team already has instructions (tracked `CLAUDE.md`, `.claude/rules/` or `AGENTS.md`)

1. **Audit them against Step 1's facts.** Classify what the kit needs:
   - **Present and correct:** leave it.
   - **Missing:** e.g. no test command, no Docker form of the commands, no integrations, no migration rule.
   - **Wrong or outdated:** e.g. says `bundle exec rspec` but the app only runs in Docker, or names a service that no longer exists.
   - **Conflicting:** two files disagree.
2. **Don't edit the team's files.** Put only the *missing* items, plus clearly labelled *corrections*, in a personal **`CLAUDE.local.md`**. Claude Code loads it right after `CLAUDE.md` at the same level, so it adds to the team's instructions without duplicating them. Keep it short; it isn't a copy of the team file.
   - Start it with a one-line note: `Personal additions for ai-dev-workflow; the team's instructions are in CLAUDE.md.`
   - Write each correction as `Correction (team CLAUDE.md says X): Y, because <evidence>`.
3. **If the repo only has `AGENTS.md`** (no `CLAUDE.md`): begin `CLAUDE.local.md` with an `@AGENTS.md` import line. Without it, adding a `CLAUDE.local.md` stops Claude Code from reading `AGENTS.md` by default.
4. **Corrections the whole team would benefit from:** also write them as a proposed patch to the team's file in `<repo>/.git/awf-claude-md.patch` (never committed). I can raise it with the team or open a PR myself. Don't apply it.
5. If the team's instructions already cover everything the kit needs, say so and write no `CLAUDE.local.md`.

### B. No instructions at all

Draft a `CLAUDE.md` from `$AWF_KIT/templates/repo-CLAUDE.md`. Every command must be one you found or confirmed, written exactly as it runs: with `docker compose exec -T <service>` where the app runs in Docker. Mark anything unconfirmed with `(unverified)`. Keep it under about 80 lines, covering what an engineer new to the repo would get wrong, not what the code shows in seconds.

### C. `--update` (re-run after the repo changed)

Re-audit as in A. Update only `CLAUDE.local.md`, or the `CLAUDE.md` this command created in B, as a diff. Drop local items the team's file now covers.

In every path, the opening description should match the repo's registry entry. If the registry description is a placeholder or wrong, propose a better one.

## Step 3 — Hook commands

The kit's hooks run specs, RuboCop, Brakeman and bundler-audit for this repo. By default they use `bundle exec …` on the host. If this repo needs something else (Docker, `bin/` wrappers), prepare `<git common dir>/awf.env`. Find the directory with `git -C <repo> rev-parse --path-format=absolute --git-common-dir`; it's inside `.git/`, so it's per-clone and never committed. Contents, only the keys that differ from the default:

```
AWF_RSPEC_CMD=docker compose exec -T web bundle exec rspec
AWF_RUBOCOP_CMD=docker compose exec -T web bundle exec rubocop
AWF_BRAKEMAN_CMD=docker compose exec -T web bundle exec brakeman
AWF_AUDIT_CMD=docker compose exec -T web bundle exec bundle-audit
```

The hooks run these **from the repo root** and append file paths relative to it, so the container's working directory must be the app root. Check that in the compose file.

## Step 4 — Approve and write

Show me:
- The audit (path A or C): present / missing / wrong / conflicting, one line each, with evidence
- The `CLAUDE.local.md` content, or the new `CLAUDE.md` (path B), as a diff where a file exists
- The `awf.env` contents, if any
- The team patch, if any, and the suggested registry description change

On approval:
- **`CLAUDE.local.md`:** write it, and add `CLAUDE.local.md` to `.git/info/exclude`, so it's ignored without changing the repo's `.gitignore`.
- **New `CLAUDE.md` (path B):** ask whether it's **shared** (to commit if the team agrees; you or I commit it in a task) or **local only** (also added to `.git/info/exclude`).
- Write `awf.env` and the patch file as shown. Don't commit anything.

Finish with what was written where, and anything marked `(unverified)` for me to check.

**Worktree mode:** `CLAUDE.local.md` is per checkout, so a new worktree won't have it. Copy it into the worktree, or rely on branch mode, where you work in the clone itself. `awf.env` is shared across worktrees automatically.
