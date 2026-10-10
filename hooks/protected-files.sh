#!/usr/bin/env bash
# PreToolUse (Edit|Write|MultiEdit|NotebookEdit): deny edits to secrets and generated files.
# Patterns live in hooks/protected-paths.txt.
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/common.sh"

file="$(input_get '.tool_input.file_path')"
[ -z "$file" ] && file="$(input_get '.tool_input.notebook_path')"
[ -z "$file" ] && exit 0
file="$(abs_path "$file")"

root="$(repo_root "$file")"
if [ -n "$root" ]; then rel="${file#$root/}"; else rel="$file"; fi
base="$(basename "$file")"

matched=""; reason=""
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in ''|'#'*) continue ;; esac
  pat="${line%%|*}"; why=""
  [ "$pat" != "$line" ] && why="${line#*|}"
  pat="$(printf '%s' "$pat" | sed -E 's/[[:space:]]+$//')"
  why="$(printf '%s' "$why" | sed -E 's/^[[:space:]]+//')"
  neg=0
  case "$pat" in '!'*) neg=1; pat="${pat#!}" ;; esac
  # shellcheck disable=SC2053
  if [[ "$rel" == $pat ]] || [[ "$base" == $pat ]]; then
    if [ $neg -eq 1 ]; then matched=""; reason=""; else matched="$pat"; reason="$why"; fi
  fi
done < "$HERE/protected-paths.txt"

[ -z "$matched" ] && exit 0

msg="$rel is protected by ai-dev-workflow (pattern: $matched)."
[ -n "$reason" ] && msg="$msg $reason"
jq -n --arg r "$msg" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
exit 0
