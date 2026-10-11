#!/usr/bin/env bash
# PreToolUse (Bash): deny `git commit` commands whose message carries AI attribution
# (Co-Authored-By trailers, "Generated with Claude Code"). Commits should read as
# yours. Set AWF_ALLOW_ATTRIBUTION=1 to allow them.
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/common.sh"
[ "${AWF_ALLOW_ATTRIBUTION:-0}" = "1" ] && exit 0

detect_commit || exit 0
cmd="$(input_get '.tool_input.command')"
if printf '%s' "$cmd" | grep -Eiq 'co-authored-by:|generated with \[?claude|🤖 generated'; then
  reason="Commit message contains AI attribution (Co-Authored-By / Generated with Claude). Remove it and commit again with only the message, e.g. KEY: <summary> (templates/commit-message.md)."
  jq -n --arg r "$reason" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
fi
exit 0
