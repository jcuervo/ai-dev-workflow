#!/usr/bin/env bash
# Install ai-dev-workflow for the current user on macOS or Linux (zsh or bash).
# Safe to re-run: picks up new commands/agents/hooks and keeps your settings.
#
#   ./install.sh                                 install or update
#   ./install.sh --no-hooks                      skip the hooks
#   AWF_REPOS_ROOT=~/work/repos ./install.sh     also build the repo registry from that folder
#   AWF_BRANCH_MODE=worktree ./install.sh        use worktrees instead of branches in your clones
#   AWF_TICKETS_ROOT=~/tickets ./install.sh      put ticket folders somewhere else
#   AWF_REVIEW_MAX_ROUNDS=2 ./install.sh         change the review-loop cap (default 3)
#   AWF_KEEP_ATTRIBUTION=1 ./install.sh          keep Claude's Co-Authored-By / PR attribution
#
# Where settings go:
#   ~/.claude/settings.json  "env"   what Claude Code, its commands and hooks see (any shell, any launcher)
#   ~/.config/ai-dev-workflow/env.sh  the same values for your terminal; sourced from ~/.bashrc / ~/.zshrc
set -euo pipefail
KIT="$(cd "$(dirname "$0")" && pwd -P)"
CONF_DIR="$HOME/.config/ai-dev-workflow"
ENV_FILE="$CONF_DIR/env.sh"
SETTINGS="$HOME/.claude/settings.json"
WITH_HOOKS=1
[ "${1:-}" = "--no-hooks" ] && WITH_HOOKS=0

say()  { printf '\033[1m%s\033[0m\n' "$*"; }
warn() { printf '\033[33m%s\033[0m\n' "$*" >&2; }
case "$(uname -s)" in Darwin) PKG="brew install" ;; *) PKG="sudo apt install" ;; esac
command -v jq >/dev/null 2>&1 || { warn "jq is required: $PKG jq"; exit 1; }

# 1. Commands and agents (symlinks, so edits in the kit take effect immediately)
say "Linking commands and agents into ~/.claude"
for kind in commands agents; do
  mkdir -p "$HOME/.claude/$kind"
  for f in "$KIT/.claude/$kind"/*.md; do
    [ -e "$f" ] || continue
    dest="$HOME/.claude/$kind/$(basename "$f")"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
      warn "  skipped $kind/$(basename "$f"): a non-symlink file already exists there"; continue
    fi
    ln -sfn "$f" "$dest"; echo "  $kind/$(basename "$f")"
  done
done

# 2. Settings: resolve values (environment override > env.sh > old rc block > default)
old_value() {  # from env.sh, or the pre-env.sh block in ~/.zshrc / ~/.bashrc
  local v=""
  [ -f "$ENV_FILE" ] && v="$(sed -nE "s/^export $1=\"?([^\"]*)\"?$/\1/p" "$ENV_FILE" | tail -1)"
  if [ -z "$v" ]; then
    for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
      [ -f "$rc" ] || continue
      v="$(sed -n '/# >>> ai-dev-workflow >>>/,/# <<< ai-dev-workflow <<</p' "$rc" | sed -nE "s/^export $1=\"?([^\"]*)\"?$/\1/p" | tail -1)"
      [ -n "$v" ] && break
    done
  fi
  case "$v" in *'${'*) v="" ;; esac   # ignore unexpanded defaults
  printf '%s' "$v"
}
pick() { local cur; eval "cur=\${$1:-}"; [ -n "$cur" ] && { printf '%s' "$cur"; return; }; cur="$(old_value "$1")"; printf '%s' "${cur:-$2}"; }

TICKETS="$(pick AWF_TICKETS_ROOT "$HOME/work/tickets")"
REPOS_ROOT="$(pick AWF_REPOS_ROOT "")"
REPOS_FILE="$(pick AWF_REPOS_FILE "$CONF_DIR/repos.yml")"
MODE="$(pick AWF_BRANCH_MODE branch)"
ROUNDS="$(pick AWF_REVIEW_MAX_ROUNDS 3)"
expand() { case "$1" in "~"*) printf '%s' "$HOME${1#\~}" ;; *) printf '%s' "$1" ;; esac; }
TICKETS="$(expand "$TICKETS")"; REPOS_ROOT="$(expand "$REPOS_ROOT")"; REPOS_FILE="$(expand "$REPOS_FILE")"

say "Settings"
echo "  kit: $KIT"
echo "  tickets: $TICKETS · repos: ${REPOS_ROOT:-not set} · mode: $MODE · review rounds: $ROUNDS"
mkdir -p "$CONF_DIR"; mkdir -p "$TICKETS" 2>/dev/null || warn "  couldn't create $TICKETS"

# 2a. Claude Code's own env (works regardless of shell or how Claude Code is launched)
mkdir -p "$(dirname "$SETTINGS")"; [ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
jq -e . "$SETTINGS" >/dev/null || { warn "$SETTINGS isn't valid JSON; fix it first."; exit 1; }
cp "$SETTINGS" "$SETTINGS.bak.$(date +%Y%m%d%H%M%S)"
jq --arg kit "$KIT" --arg t "$TICKETS" --arg rr "$REPOS_ROOT" --arg rf "$REPOS_FILE" --arg m "$MODE" --arg r "$ROUNDS" '
  .env = ((.env // {}) + {AWF_KIT:$kit, AWF_TICKETS_ROOT:$t, AWF_REPOS_FILE:$rf, AWF_BRANCH_MODE:$m, AWF_REVIEW_MAX_ROUNDS:$r}
          + (if $rr == "" then {} else {AWF_REPOS_ROOT:$rr} end))
' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
echo "  Claude Code env: $SETTINGS"

# 2b. Shell env file + one source line in each shell rc that exists (and the current shell's)
{
  echo "# ai-dev-workflow settings, written by $KIT/install.sh (re-run it to change them)."
  echo "export AWF_KIT=\"$KIT\""
  echo "export AWF_TICKETS_ROOT=\"$TICKETS\""
  if [ -n "$REPOS_ROOT" ]; then echo "export AWF_REPOS_ROOT=\"$REPOS_ROOT\""; else echo "# export AWF_REPOS_ROOT=\"\$HOME/work/repos\""; fi
  echo "export AWF_REPOS_FILE=\"$REPOS_FILE\""
  echo "export AWF_BRANCH_MODE=\"$MODE\""
  echo "export AWF_REVIEW_MAX_ROUNDS=\"$ROUNDS\""
} > "$ENV_FILE"
echo "  shell env: $ENV_FILE"

rcs=""
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do [ -f "$rc" ] && rcs="$rcs $rc"; done
case "${SHELL:-}" in
  */zsh)  case "$rcs" in *".zshrc"*) ;; *) rcs="$rcs $HOME/.zshrc" ;; esac ;;
  */bash) case "$rcs" in *".bashrc"*) ;; *) rcs="$rcs $HOME/.bashrc" ;; esac ;;
esac
for rc in $rcs; do
  touch "$rc"; tmp="$(mktemp)"
  sed '/# >>> ai-dev-workflow >>>/,/# <<< ai-dev-workflow <<</d' "$rc" > "$tmp"
  { cat "$tmp"; printf '\n# >>> ai-dev-workflow >>>\n[ -f "%s" ] && . "%s"\n# <<< ai-dev-workflow <<<\n' "$ENV_FILE" "$ENV_FILE"; } | cat -s > "$rc"
  rm -f "$tmp"; echo "  sourced from: $rc"
done

# 3. Repo registry
if [ -f "$REPOS_FILE" ]; then
  echo "  registry: $REPOS_FILE"
elif [ -n "$REPOS_ROOT" ] && [ -d "$REPOS_ROOT" ]; then
  say "Building the repo registry from $REPOS_ROOT"
  AWF_REPOS_FILE="$REPOS_FILE" "$KIT/bin/awf-repos-scan" "$REPOS_ROOT"
else
  warn "  no repo registry yet: re-run as  AWF_REPOS_ROOT=~/path/to/repos ./install.sh"
fi

# 4. Hooks
if [ "$WITH_HOOKS" = 1 ]; then
  say "Installing hooks into $SETTINGS"
  "$KIT/hooks/install.sh"
fi

# 5. Commit and PR attribution off (commits read as yours)
if [ "${AWF_KEEP_ATTRIBUTION:-0}" != "1" ]; then
  jq '.attribution = ((.attribution // {}) + {commit: "", pr: ""}) | del(.includeCoAuthoredBy)' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
  echo "  attribution: off for commits and PRs"
fi

# 6. Checks
say "Checks"
echo "  jq: ok"
if command -v gh >/dev/null 2>&1; then
  gh auth status >/dev/null 2>&1 && echo "  gh: ok" || warn "  gh: installed but not logged in (gh auth login)"
else
  warn "  gh: missing ($PKG gh). Needed for /pr-describe and /resolve-review"
fi
command -v git >/dev/null 2>&1 && echo "  git identity: $(git config --global user.name 2>/dev/null || echo '?') <$(git config --global user.email 2>/dev/null || echo '?')>"

echo
say "Done. Next:"
echo "  1. Open a new terminal (or: . $ENV_FILE)"
echo "  2. Restart Claude Code, then check /hooks and type / to see the commands"
