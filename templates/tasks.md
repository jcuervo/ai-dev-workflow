# {{KEY}} — Tasks

- **Plan:** plan.md (approved {{date}})
- **Branch:** {{KEY}}-{{short-desc}} (same name in every repo)

## Conventions
- **Statuses:** `todo` · `in-progress` · `review` · `done` · `blocked`
- **One task = one repo.** Split anything that touches two.
- **Size:** reviewable in one sitting (rough guide: under ~300 changed lines).
- **Priority:** order in this file is build order. Tasks are picked top-down, skipping blocked or unmet dependencies.
- **Categories:** `contract` · `migration` · `backend` · `frontend` · `job` · `config` · `test` · `e2e` · `docs`
- **Out-of-scope discoveries** become new tasks at the end; they don't get folded into the current task.
- **E2E tasks** live in the Playwright repo, depend on the feature tasks they cover, and use the scenarios in `e2e-plan.md`.
- **Every task is reviewed** by the independent `task-reviewer` before its commit; the review is saved to `reviews/T#.md`, and a commit hook enforces it.
- **Commit format:** `{{KEY}}: <summary>` (see `templates/commit-message.md`). The task number isn't in the message; **Commits** below links each task to its SHAs.

## Summary
| ID | Title | Repo | Category | Status | Depends on | ACs |
|---|---|---|---|---|---|---|
| T1 | {{...}} | {{repo}} | contract | todo | — | AC1 |

---

## T1 — {{title}}
- **Repo:** {{repo}}
- **Category:** {{category}}
- **Status:** todo
- **Depends on:** —
- **ACs:** AC1
- **Plan section:** plan.md#{{anchor}}
- **Specs:** {{spec/path_spec.rb (new | existing)}}
- **Scope:** {{one to three sentences on what this task changes and what it doesn't}}
- **Done when:** {{specific observable outcome beyond specs passing, if any}}
- **Review:** {{filled in by /build-task: verdict · reviews/T#.md}}
- **Commits:** {{filled in by /build-task: short SHAs}}
- **Notes:** {{filled in during build: deviations, follow-ups}}

---
