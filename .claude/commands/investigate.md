---
description: Run an investigation ticket (spike) — plan the questions and hypotheses, investigate read-only with evidence, then produce findings, recommendations, follow-up ticket drafts and a stakeholder report. No ticket branches, no code changes.
argument-hint: "[plan | run | report [markdown | jira | html] | convert]"
model: opus
effort: high
---

# Investigate

Run this from the **ticket folder root** of a ticket with `Kind: investigation` in `ticket.md`. Action: `$ARGUMENTS`. If empty, take the next step: `plan` if there's no `investigation.md` yet, `run` while questions are open, then `report`.

**Read-only by default.** Read code, git history, logs, docs and local data; run read-only commands, queries and local reproductions. **Don't** create ticket branches, commit, push, or change service repos. Experiments that need code changes happen only on a **local spike branch** I approve (Step 2), are never pushed, and are recorded in the log.

## plan

1. Read `ticket.md` (questions IQ1…, expected outputs, timebox), `analysis.md` and `open-questions.md` if present.
2. Write `investigation.md` from `$AWF_KIT/templates/investigation.md`:
   - **Questions to answer:** from the ticket. If the ticket has none, derive them from its description and ask me to confirm.
   - **Hypotheses:** for each question, what might be true, and the cheapest test that would confirm or reject it
   - **Method:** repos and branches to read (usually each repo's default branch; use `repo-explorer` agents in parallel), sources, needed `run` repos (the stack, for a local reproduction), experiments if any, and limits
   - **Timebox:** from the ticket, or ask
3. Show the plan and **wait for approval**.

## run

Work through the hypotheses, cheapest test first:
1. Gather evidence with read-only tools: `repo-explorer` agents for broad code questions, `git log -S` / `git blame` for history, read-only queries against **local** data, local reproductions with the stack up (check it as in `/ticket-repos status`, and ask me to start it if needed).
2. **Experiments with code changes:** propose them first, with what, where, why, and what they would prove. On approval: in that repo, switch to a local branch `<KEY>-spike` from its default branch, make the change, measure, and record the result. **Never push it.** Commits there are optional and use `<KEY>: Spike: <summary>`. Afterwards, switch the repo back to its default branch.
3. **Log every step** in `investigation.md` §4: what was checked, what was found, and the evidence (file:line, command plus an output excerpt). Update hypothesis results and question statuses as you go.
4. Write **findings** (§5), each with evidence and a confidence level. A finding without evidence is a hypothesis; keep it in §2.
5. **Stop and check in with me** when a question is answered, when a hypothesis is rejected and the next step isn't obvious, when you need access you don't have (production data, logs, a person), or when the timebox is running out.
6. Never present guesses as findings. "Can't be determined with what's available" is a valid answer; say what would determine it.

## report

1. Fill in **Recommendations** (§6), each tied to findings, with effort, risk and follow-up type.
2. Draft **follow-up tickets** (§7) for recommendations that need work: title, why, proposed ACs and likely repos. They should be ready to paste into the tracker.
3. Write the stakeholder report **`findings-report.md`** from `$AWF_KIT/templates/findings-report.md`, in the requested format (`markdown` default, `jira`, `html`):
   - Plain language for the BA/PO. **Sanitize** as `/test-plan` does: no file paths, code, branch names, commit IDs or internal URLs. Check mechanically and report what you fixed.
   - Every answer and recommendation must trace to a finding in `investigation.md`.
4. Set `investigation.md` status to `concluded`. Tell me:
   - the paths to `findings-report.md` and `investigation.md`
   - the follow-up drafts
   - any spike branches to delete (`git branch -D <KEY>-spike` in each repo; I run it myself)

## convert

Use this when the investigation concludes that the work should be done **in this same ticket**, not a new one:
1. Confirm with me.
2. In `ticket.md`, set `Kind: delivery`, and turn the chosen recommendation's proposed ACs into the ticket's numbered **Acceptance criteria**, keeping the questions and a link to the findings.
3. Add a `notes.md` entry, then tell me the delivery path from here: `/analyze-ticket` (to refresh the analysis for the change, reusing the findings), then `/ticket-repos setup`, `/plan-ticket` and so on.
