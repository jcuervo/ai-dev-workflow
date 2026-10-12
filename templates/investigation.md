# {{KEY}} — Investigation

- **Status:** planning | in progress | concluded
- **Timebox:** {{e.g. 2 days}} · **Started:** {{date}}
- **Read-only:** no ticket branches, no commits to service repos. Experiments only on a local spike branch, if approved.

## 1. Questions to answer
From `ticket.md` (IQ1, IQ2…). Each must end with an answer, or "can't be determined" plus what would determine it.

| ID | Question | Status | Answer (one line) |
|---|---|---|---|
| IQ1 | {{…}} | open / answered / partly / can't determine | |

## 2. Hypotheses
| ID | Hypothesis | For IQ | Test | Result |
|---|---|---|---|---|
| H1 | {{e.g. timeouts come from N+1 queries on /orders}} | IQ1 | {{query log on local repro; compare query counts}} | confirmed / rejected / inconclusive |

## 3. Method
- **Repos read:** {{repo: branch read}}
- **Sources:** {{code, git history, logs, metrics, local DB, local repro, docs, vendor docs}}
- **Experiments:** {{none / what, where (local spike branch), and why}}
- **Limits:** {{no prod access, sample data only, …}}

## 4. Log (append-only)
- {{date time}} · {{what was checked}} → {{what was found}} · evidence: {{file:line, command + output excerpt, link}}

## 5. Findings
### F1 — {{short title}}
- **Answers:** IQ1
- **Finding:** {{what is true, stated plainly}}
- **Evidence:** {{file:line, query result, log excerpt, reproduction steps}}
- **Confidence:** high / medium / low, because {{…}}

## 6. Recommendations
| ID | Recommendation | Based on | Effort | Risk | Follow-up |
|---|---|---|---|---|---|
| R1 | {{…}} | F1 | S / M / L | {{…}} | new ticket / this ticket becomes delivery / no action |

## 7. Follow-up tickets (drafts)
### {{Proposed title}}
- **Why:** {{finding}}
- **Proposed ACs:** AC1 … AC2 …
- **Repos likely involved:** {{…}}
