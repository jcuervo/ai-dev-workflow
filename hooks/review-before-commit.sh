#!/usr/bin/env bash
# PreToolUse (Bash): the per-task review is mandatory.
# For a ticket commit (message contains "[KEY]"), find that ticket's tasks.md and
# require every task with status `in-progress` or `review` to have
# reviews/T#.md whose last `Verdict:` line isn't "not ready".
# Review-fix commits from /resolve-review ("Address review:") pass.
# Override for one session: AWF_SKIP_REVIEW_GATE=1.
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/common.sh"
[ "${AWF_SKIP_REVIEW_GATE:-0}" = "1" ] && exit 0

detect_commit || exit 0
cmd="$(input_get '.tool_input.command')"
key="$(printf '%s' "$cmd" | grep -Eo '\[[A-Z][A-Z0-9]*-[0-9]+\]' | head -1 | tr -d '[]')"
[ -z "$key" ] && exit 0
printf '%s' "$cmd" | grep -q 'Address review:' && exit 0

# Ticket folder: walk up from cwd looking for tasks.md + ticket.md, else $AWF_TICKETS_ROOT/<KEY>
ticket=""
d="$(input_get '.cwd')"
while [ -n "$d" ] && [ "$d" != "/" ]; do
  [ -f "$d/tasks.md" ] && [ -f "$d/ticket.md" ] && { ticket="$d"; break; }
  d="$(dirname "$d")"
done
[ -z "$ticket" ] && [ -n "${AWF_TICKETS_ROOT:-}" ] && [ -f "$AWF_TICKETS_ROOT/$key/tasks.md" ] && ticket="$AWF_TICKETS_ROOT/$key"
[ -z "$ticket" ] && exit 0   # not a kit ticket; nothing to enforce

# Tasks being worked on, from the summary table: | T3 | title | repo | category | status | …
active="$(awk -F'|' '$2 ~ /^[[:space:]]*T[0-9]+[[:space:]]*$/ {
            id=$2; st=$6; gsub(/[[:space:]`]/,"",id); gsub(/[[:space:]`]/,"",st)
            if (st=="in-progress" || st=="review") print id }' "$ticket/tasks.md" | sort -u)"
[ -z "$active" ] && exit 0

deny() {
  jq -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}
for task in $active; do
  review="$ticket/reviews/$task.md"
  [ -f "$review" ] || deny "Mandatory review missing for $task (status in-progress/review in tasks.md): reviews/$task.md doesn't exist in the ticket folder. Run the task-reviewer (Step 6 of /build-task, or /review-task $task), save its output there, then commit."
  last="$(grep -Ei '^Verdict:' "$review" | tail -1)"
  printf '%s' "$last" | grep -Eiq '^Verdict:[[:space:]]*not ready' && deny "The latest review for $task says 'not ready' (reviews/$task.md). Fix the must-fix findings and re-run the review, or ask the user to override (AWF_SKIP_REVIEW_GATE=1)."
done
exit 0
