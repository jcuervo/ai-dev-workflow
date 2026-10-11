# Faster Playwright runs

Playwright suites slow down for a handful of reasons, mostly repeated work: logging in through the UI in every test, clicking through screens just to create data, every test on every browser, and coverage duplicated across tickets. This kit attacks it from three sides.

## 1. New tests are written fast (built in)

- **`/e2e-plan`** designs scenarios for speed: data set up through the API or seeds rather than the UI, reused login state, independent short tests, no duplicated coverage, and tags so a ticket's tests can run alone.
- **`/build-task`** runs only the task's specs, on one browser, never the whole suite.
- **`task-reviewer`** flags slow patterns in e2e code: UI setup, repeated logins, fixed waits, duplicated coverage.

## 2. The existing suite gets audited: `/e2e-audit`

Run it in the Playwright repo (`cd <e2e repo> && claude`, then `/e2e-audit`, or `/e2e-audit --run` to measure real timings). It's read-only and produces:
- an **inventory**: tests per feature, tag and browser, and total runs (tests × browsers)
- the **slowest tests** and time per file and tag, from a report or a measured run
- the **waste**: UI logins per test, UI data setup, fixed waits, needless serial runs, heavy traces and videos, **overlapping or redundant tests** (grouped, with which to keep), and dead `skip`/`fixme` tests
- a **prioritized plan** with estimated savings, and the expected before → after run times

Apply the plan as normal tickets or tasks, with the usual review.

## 3. Run less, day to day

| You want to… | Command (check `npx playwright test --help` for your version) |
|---|---|
| Run your ticket's tests | `npx playwright test --grep @PROJ-123 --project=chromium` |
| Run tests touching what you changed | `npx playwright test --only-changed` (Playwright 1.46+; also runs tests that import changed files) |
| Re-run only last run's failures | `npx playwright test --last-failed` |
| Quick confidence check | `npx playwright test --grep @smoke --project=chromium` |
| Full regression | The repo's full command (before shipping, or as CI does) |
| See why a test is slow | `npx playwright show-trace` on a trace with `trace: 'retain-on-failure'` |

## Biggest wins, typically

1. **Log in once** (setup project + `storageState`) instead of in every test. Often the single largest saving.
2. **Create test data through the API or seeds**, not the UI.
3. **One browser locally**; all browsers only in the full regression or CI.
4. **Parallel:** `fullyParallel: true` with independent tests and enough `workers`.
5. **Prune the suite:** remove duplicated coverage, and move logic checks to request or model specs, which run in milliseconds.
6. **Light artifacts locally:** `trace: 'retain-on-failure'`, `video: 'off'`.
