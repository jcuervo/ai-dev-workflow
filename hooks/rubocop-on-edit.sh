#!/usr/bin/env bash
# PostToolUse (Edit|Write|MultiEdit): run RuboCop on the Ruby file just edited and
# feed any offenses back to Claude. Reports only, unless AWF_RUBOCOP_AUTOCORRECT=1,
# because autocorrecting changes the file underneath Claude.
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/common.sh"

file="$(input_get '.tool_input.file_path')"
[ -z "$file" ] && exit 0
case "$file" in
  *.rb|*.rake|*.ru|*.gemspec|*/Gemfile|*/Rakefile|*.jbuilder) ;;
  *) exit 0 ;;
esac
file="$(abs_path "$file")"
[ -f "$file" ] || exit 0

root="$(repo_root "$file")"
[ -n "$root" ] && [ -f "$root/Gemfile" ] || exit 0
has_gem "$root" rubocop || exit 0

cd "$root" || exit 0
args="--format simple --force-exclusion"
[ "${AWF_RUBOCOP_AUTOCORRECT:-0}" = "1" ] && args="$args --autocorrect"

# shellcheck disable=SC2086
out="$($RUBOCOP_CMD $args "$file" 2>&1)"; rc=$?

case $rc in
  0) exit 0 ;;
  1)
    rel="${file#$root/}"
    reason="RuboCop offenses in $rel. Fix them before moving on:
$(tail_lines 60 "$out")"
    jq -n --arg r "$reason" '{decision:"block", reason:$r}'
    exit 0 ;;
  *)
    echo "RuboCop couldn't run in $root (exit $rc): $(tail_lines 5 "$out")" >&2
    exit 1 ;;   # non-blocking notice
esac
