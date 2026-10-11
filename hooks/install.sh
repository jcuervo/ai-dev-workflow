#!/usr/bin/env bash
# Merge the ai-dev-workflow hooks into a Claude settings file (default ~/.claude/settings.json).
# Re-running replaces this kit's hook entries (old or new form) and keeps everyone else's.
# Usage: hooks/install.sh [settings-file]   |   hooks/install.sh --uninstall [settings-file]
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd -P)"
mode=install
[ "${1:-}" = "--uninstall" ] && { mode=uninstall; shift; }
target="${1:-$HOME/.claude/settings.json}"
command -v jq >/dev/null || { echo "jq is required (brew install jq / sudo apt install jq)" >&2; exit 1; }
mkdir -p "$(dirname "$target")"; [ -f "$target" ] || echo '{}' > "$target"
jq -e . "$target" >/dev/null || { echo "$target isn't valid JSON; fix it first." >&2; exit 1; }
cp "$target" "$target.bak.$(date +%Y%m%d%H%M%S)"

# Anything whose command points at one of this kit's hook scripts counts as ours.
names="$(cd "$HERE" && ls *.sh | grep -v '^install.sh$' | sed 's/\.sh$//' | paste -sd'|' -)"
strip='
  def ours: ((.command // "") | test("(ai-dev-workflow/hooks/|AWF_KIT|/hooks/)(" + $names + ")\\.sh"));
  if .hooks then
    .hooks |= (with_entries(.value |= (map(.hooks |= map(select(ours | not))) | map(select((.hooks | length) > 0))))
               | with_entries(select((.value | length) > 0)))
  else . end'

if [ "$mode" = uninstall ]; then
  jq --arg names "$names" "$strip" "$target" > "$target.tmp"
else
  # Snippet with absolute paths to this checkout of the kit
  snippet="$(sed "s#\${AWF_KIT:-\$HOME/dev-utilities/ai-dev-workflow}#$(dirname "$HERE")#g" "$HERE/settings.hooks.json")"
  jq --arg names "$names" --argjson s "$snippet" "$strip"' 
    | .hooks = (.hooks // {})
    | reduce ($s.hooks | to_entries[]) as $ev (.; .hooks[$ev.key] = ((.hooks[$ev.key] // []) + $ev.value))
  ' "$target" > "$target.tmp"
fi
mv "$target.tmp" "$target"
echo "  hooks $mode: $target"
