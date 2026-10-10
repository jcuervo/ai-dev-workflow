#!/usr/bin/env bash
# Merge the ai-dev-workflow hooks into a Claude settings file (default ~/.claude/settings.json).
# Safe to re-run: handlers already present (same command) aren't added twice.
# Usage: hooks/install.sh [settings-file]   |   hooks/install.sh --uninstall [settings-file]
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
mode=install
[ "${1:-}" = "--uninstall" ] && { mode=uninstall; shift; }
target="${1:-$HOME/.claude/settings.json}"
snippet="$HERE/settings.hooks.json"

command -v jq >/dev/null || { echo "jq is required: brew install jq" >&2; exit 1; }
mkdir -p "$(dirname "$target")"
[ -f "$target" ] || echo '{}' > "$target"
jq -e . "$target" >/dev/null || { echo "$target isn't valid JSON; fix it first." >&2; exit 1; }

backup="$target.bak.$(date +%Y%m%d%H%M%S)"
cp "$target" "$backup"

if [ "$mode" = install ]; then
  jq --slurpfile s "$snippet" '
    .hooks = (.hooks // {})
    | reduce ($s[0].hooks | to_entries[]) as $ev (.;
        reduce $ev.value[] as $group (.;
          .hooks[$ev.key] = (.hooks[$ev.key] // [])
          | ([.hooks[$ev.key][] | .hooks[]? | .command]) as $existing
          | ($group | .hooks |= map(select(.command as $c | ($existing | index($c)) | not))) as $g
          | if ($g.hooks | length) > 0 then .hooks[$ev.key] += [$g] else . end))
  ' "$target" > "$target.tmp"
else
  jq '
    if .hooks then
      .hooks |= (with_entries(
        .value |= (map(.hooks |= map(select((.command // "") | test("ai-dev-workflow/hooks/|AWF_KIT") | not)))
                   | map(select((.hooks | length) > 0))))
        | with_entries(select((.value | length) > 0)))
    else . end
  ' "$target" > "$target.tmp"
fi
mv "$target.tmp" "$target"
echo "$mode done: $target (backup: $backup)"
