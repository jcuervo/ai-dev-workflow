#!/usr/bin/env bash
# PreToolUse (Bash): before `git commit` in a Rails repo, run the specs related to
# the changed files and block the commit if any fail.
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/common.sh"

detect_commit || exit 0
root="$(repo_root "$COMMIT_DIR")"
[ -n "$root" ] && [ -f "$root/Gemfile" ] || exit 0
has_gem "$root" rspec-core || exit 0

specs=""
add_spec() { [ -f "$root/$1" ] && specs="$specs
$1"; }

for f in $(changed_files "$root"); do
  case "$f" in
    spec/*_spec.rb) add_spec "$f" ;;
    app/controllers/*_controller.rb)
      p="${f#app/controllers/}"; p="${p%.rb}"
      add_spec "spec/controllers/${p}_spec.rb"
      add_spec "spec/requests/${p%_controller}_spec.rb"
      add_spec "spec/requests/${p}_spec.rb" ;;
    app/*.rb)
      p="${f#app/}"; p="${p%.rb}"
      add_spec "spec/${p}_spec.rb" ;;
    lib/*.rb)
      p="${f#lib/}"; p="${p%.rb}"
      add_spec "spec/lib/${p}_spec.rb" ;;
  esac
done

specs="$(printf '%s\n' "$specs" | sed '/^$/d' | sort -u)"
[ -z "$specs" ] && exit 0   # no related specs found; nothing to gate on

cd "$root" || exit 0
# shellcheck disable=SC2086
out="$($RSPEC_CMD $specs 2>&1)"; rc=$?
[ $rc -eq 0 ] && exit 0

{
  echo "Commit blocked by ai-dev-workflow: related specs fail in $(basename "$root")."
  echo "Specs run:"; printf '%s\n' "$specs" | sed 's/^/  /'
  echo; echo "Output (last 80 lines):"
  tail_lines 80 "$out"
  echo; echo "Fix the failures (or tell the user why they're unrelated) before committing."
} >&2
exit 2
