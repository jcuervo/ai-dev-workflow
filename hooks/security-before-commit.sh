#!/usr/bin/env bash
# PreToolUse (Bash): before `git commit` in a Rails repo,
# - run Brakeman and block on warnings in the changed files only (existing
#   warnings elsewhere in the app don't block), and
# - run bundler-audit if Gemfile.lock changed.
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/common.sh"

detect_commit || exit 0
root="$(repo_root "$COMMIT_DIR")"
[ -n "$root" ] && [ -f "$root/Gemfile" ] || exit 0
load_repo_cmds "$root"
cd "$root" || exit 0

changed="$(changed_files "$root")"
problems=""

# Brakeman
if has_gem "$root" brakeman && printf '%s\n' "$changed" | grep -Eq '^(app|config|lib)/.*\.(rb|erb|haml|slim)$'; then
  json="$($BRAKEMAN_CMD -q --no-pager --no-exit-on-warn --no-exit-on-error -f json 2>/dev/null)"
  if [ -n "$json" ] && printf '%s' "$json" | jq -e . >/dev/null 2>&1; then
    hits="$(printf '%s' "$json" | jq -r --arg changed "$changed" '
      ($changed | split("\n")) as $files
      | .warnings[]
      | select(.file as $f | $files | index($f))
      | "  \(.file):\(.line // "?")  \(.warning_type) (\(.confidence)): \(.message)"')"
    [ -n "$hits" ] && problems="$problems
Brakeman warnings in changed files:
$hits"
  else
    echo "Brakeman couldn't run in $root; skipping." >&2
  fi
fi

# bundler-audit
if printf '%s\n' "$changed" | grep -qx 'Gemfile.lock' && has_gem "$root" bundler-audit; then
  out="$($AUDIT_CMD check 2>&1)"; rc=$?
  [ $rc -ne 0 ] && problems="$problems
bundler-audit found vulnerable gems:
$(tail_lines 40 "$out")"
fi

[ -z "$problems" ] && exit 0
{
  echo "Commit blocked by ai-dev-workflow: security checks failed in $(basename "$root")."
  printf '%s\n' "$problems"
  echo
  echo "Fix these. If a warning is a false positive, tell the user; they can add it to config/brakeman.ignore."
} >&2
exit 2
