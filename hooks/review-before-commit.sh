#!/usr/bin/env bash
# PreToolUse (Bash): the per-task review is mandatory. Before a task commit
# (message contains "[KEY][T#]"), require <ticket folder>/reviews/T#.md to exist
# and not carry "Verdict: not ready". Review-fix commits from /resolve-review
# ("[KEY] Address review: …") aren't task commits and pass.
# Override for one session: AWF_SKIP_REVIEW_GATE=1.
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/common.sh"
[ "${AWF_SKIP_REVIEW_GATE:-0}" = "1" ] && exit 0

detect_commit || exit 0
cmd="$(input_get '.tool_input.command')"
ref="$(printf '%s' "$cmd" | grep -Eo '\[[A-Z][A-Z0-9]*-[0-9]+\]\[T[0-9]+\]' | head -1)"
[ -z "$ref" ] && exit 0
key="$(printf '%s' "$ref" | sed -E 's/^\[([^]]+)\]\[(T[0-9]+)\]$/\1/')"
task="$(printf '%s' "$ref" | sed -E 's/^\[([^]]+)\]\[(T[0-9]+)\]$/\2/')"

# Find the ticket folder: walk up from cwd looking for tasks.md, else $AWF_TICKETS_ROOT/<KEY>
ticket=""
d="$(input_get '.cwd')"
while [ -n "$d" ] && [ "$d" != "/" ]; do
  [ -f "$d/tasks.md" ] && [ -f "$d/ticket.md" ] && { ticket="$d"; break; }
  d="$(dirname "$d")"
done
[ -z "$ticket" ] && [ -n "${AWF_TICKETS_ROOT:-}" ] && [ -f "$AWF_TICKETS_ROOT/$key/tasks.md" ] && ticket="$AWF_TICKETS_ROOT/$key"
[ -z "$ticket" ] && exit 0   # not a kit ticket; nothing to enforce

review="$ticket/reviews/$task.md"
deny() {
  jq -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}
[ -f "$review" ] || deny "Mandatory review missing for $task: reviews/$task.md doesn't exist in the ticket folder. Run the task-reviewer (Step 6 of /build-task, or /review-task $task), save its output there, then commit."
last="$(grep -Ei '^Verdict:' "$review" | tail -1)"
printf '%s' "$last" | grep -Eiq '^Verdict:[[:space:]]*not ready' && deny "The review for $task says 'not ready' (reviews/$task.md). Fix the must-fix findings and re-run the review, or ask the user to override (AWF_SKIP_REVIEW_GATE=1)."
exit 0
