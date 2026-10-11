---
description: Audit an existing Playwright repo for size, speed and overlap — slowest tests, redundant or overlapping coverage, slow patterns, and a prioritized plan to make the suite faster. Read-only; changes nothing.
argument-hint: "[path to Playwright repo] [--run]"
model: sonnet
effort: high
---

# E2E audit

Arguments: `$ARGUMENTS`. The Playwright repo (a registry name or path; default: the current folder). `--run` also runs the suite once to measure real timings, and needs the local stack up.

**Read-only.** Don't change, delete or commit anything. The output is a report and a proposal.

## Step 1 — Inventory

1. Read the repo's instruction files (`CLAUDE.md`, `CLAUDE.local.md`, `.claude/rules/`, `AGENTS.md`), `playwright.config.*`, `package.json` and the Playwright version.
2. List every test without running it: `npx playwright test --list --reporter=json` (fall back to `--list` and parse the text). Count:
   - tests per file, per folder or feature, per tag (`@smoke`, `@regression`, …), and per project (browser)
   - the **total runs = tests × projects**. Each extra browser project multiplies the suite
   - tests with a ticket key in the title or describe, and the oldest ones
3. Config facts that drive speed: `workers`, `fullyParallel`, `retries`, the projects list, `use.trace` / `video` / `screenshot`, `webServer`, any `globalSetup` or setup projects, and whether `storageState` is used.

## Step 2 — Timings

Use, in order of preference:
- An existing JSON or HTML report from a recent full run (`playwright-report/`, `test-results/`, or ask me for a CI artifact)
- With `--run`: run once with `--reporter=json,list` and the repo's normal command, against the local stack. Ask me to start it if it isn't up.
- Neither available: estimate from code (number of page loads, UI logins, fixed waits) and say it's an estimate.

Report: total wall time, the **20 slowest tests** with durations, time per file and per tag, and flaky tests (passed on retry) if the report shows retries.

## Step 3 — Find the waste

Search the code and classify findings, each with a `file:line` example and a count:

| Pattern | Look for |
|---|---|
| **Login through the UI in every test** | `beforeEach` that fills a login form, instead of a setup project plus `storageState` |
| **Data setup through the UI** | Tests that click through several pages only to create the record they then test; candidates for API or seed setup (`request` fixture, app endpoints, factories) |
| **Fixed waits** | `waitForTimeout`, `setTimeout`, `sleep` |
| **Serial where it needn't be** | `test.describe.serial`, `workers: 1`, `fullyParallel: false` without a stated reason; tests that depend on each other's data |
| **Over-broad projects** | Every test on every browser locally, when one browser would do for development |
| **Heavy artifacts** | `trace: 'on'`, `video: 'on'`, screenshots on every test |
| **Redundant coverage** | Tests that assert the same flow and outcome (same pages, same assertions) in different files or tickets; tests that only check logic a request or model spec could check |
| **Dead tests** | `test.skip` / `test.fixme` left for a long time, or tests for features or flows that no longer exist |
| **Bloated journeys** | Very long tests that cover many ACs in one flow, so one failure hides the rest and they can't parallelize |

For **redundant coverage**, group the candidates: which tests overlap, what each uniquely asserts, and which one to keep. Never call a test redundant unless every assertion it makes is covered elsewhere.

## Step 4 — Proposal

A prioritized plan, **highest time saved first**. For each item: the change, the estimated saving (with your reasoning), the risk, and the files affected.

1. **Quick wins (config only):** e.g. one browser project for local runs, `fullyParallel: true` plus a sensible `workers`, `trace: 'retain-on-failure'`, `video: 'off'` locally, `reuseExistingServer`
2. **Structural:** a login setup project with `storageState`, API or seed data setup, splitting serial journeys into independent tests
3. **Suite shape:** a tag strategy (a small `@smoke` set for every change, `@regression` for the full run, feature tags so `--grep` can target an area), consolidating or deleting redundant tests (listed), and moving logic-only checks down to request or model specs
4. **How to run day to day:** commands for "my ticket only", "what I changed" (`--only-changed`), "what failed last time" (`--last-failed`), "smoke" and "full", as they apply to this repo's Playwright version

Finish with the expected **before → after** run time for the common local runs, and the order to apply the changes. Each change becomes a normal ticket or task, done with the usual workflow and review.
