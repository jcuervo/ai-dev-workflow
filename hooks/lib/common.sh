#!/usr/bin/env bash
# Shared helpers for ai-dev-workflow hooks.
# Written for macOS's default bash 3.2: no mapfile, no associative arrays.

# Escape hatch: start Claude with AWF_SKIP_HOOKS=1 to disable every awf hook for that session.
[ "${AWF_SKIP_HOOKS:-0}" = "1" ] && exit 0

if ! command -v jq >/dev/null 2>&1; then
  echo "ai-dev-workflow hooks need jq (brew install jq / sudo apt install jq); skipping check." >&2
  exit 1   # non-blocking: shows a hook error notice, action proceeds
fi

# Make version-managed Ruby/Node visible when Claude was launched from an app (e.g. VS Code)
# rbenv, asdf, mise, Homebrew (macOS), Linuxbrew
for d in "$HOME/.rbenv/shims" "$HOME/.asdf/shims" "$HOME/.local/share/mise/shims" \
         "/opt/homebrew/bin" "/usr/local/bin" "/home/linuxbrew/.linuxbrew/bin"; do
  [ -d "$d" ] && case ":$PATH:" in *":$d:"*) ;; *) PATH="$d:$PATH" ;; esac
done
export PATH

# Commands, overridable per environment (e.g. if a repo runs tests in Docker)
RSPEC_CMD="${AWF_RSPEC_CMD:-bundle exec rspec}"
RUBOCOP_CMD="${AWF_RUBOCOP_CMD:-bundle exec rubocop}"
BRAKEMAN_CMD="${AWF_BRAKEMAN_CMD:-bundle exec brakeman}"
AUDIT_CMD="${AWF_AUDIT_CMD:-bundle exec bundle-audit}"

HOOK_INPUT="$(cat)"

input_get() { printf '%s' "$HOOK_INPUT" | jq -r "$1 // empty"; }

# Absolute, physical path (symlinks resolved), relative paths taken from the
# hook's cwd. Physical matters in branch mode, where repos/<name> in the ticket
# folder is a symlink to the real clone. Works for files that don't exist yet.
abs_path() {
  local p rest=""
  case "$1" in
    /*) p="$1" ;;
    *)  p="$(input_get '.cwd')/$1" ;;
  esac
  while [ ! -d "$p" ] && [ "$p" != "/" ]; do
    rest="/$(basename "$p")$rest"; p="$(dirname "$p")"
  done
  printf '%s%s\n' "$(cd "$p" && pwd -P)" "$rest"
}

# Git repo root containing a path (file or directory), or fail
repo_root() {
  local p="$1"
  [ -d "$p" ] || p="$(dirname "$p")"
  while [ ! -d "$p" ] && [ "$p" != "/" ]; do p="$(dirname "$p")"; done
  git -C "$p" rev-parse --show-toplevel 2>/dev/null
}

# True if the repo's Gemfile.lock includes the given gem
has_gem() { grep -qE "^    $2 \(" "$1/Gemfile.lock" 2>/dev/null; }

# Last N lines of text, for keeping feedback short
tail_lines() { printf '%s\n' "$2" | tail -n "$1"; }

# --- git commit detection (for PreToolUse on Bash) ---------------------------

# Sets COMMIT_DIR to the directory the commit runs in, or returns 1 if the
# command isn't a git commit. Handles `git commit`, `git -C <dir> commit`,
# and `cd <dir> && git commit`.
detect_commit() {
  local cmd dir cwd
  cmd="$(input_get '.tool_input.command')"
  printf '%s' "$cmd" | grep -Eq '(^|[;&|[:space:](])git([[:space:]]+-[cC][[:space:]]+[^[:space:]]+)*[[:space:]]+commit([[:space:]]|$)' || return 1
  cwd="$(input_get '.cwd')"
  dir="$(printf '%s' "$cmd" | sed -nE 's/.*git[[:space:]]+-C[[:space:]]+("([^"]+)"|([^[:space:]]+)).*commit.*/\2\3/p' | head -1)"
  if [ -z "$dir" ]; then
    dir="$(printf '%s' "$cmd" | sed -nE 's/^[[:space:]]*cd[[:space:]]+("([^"]+)"|([^[:space:];&]+)).*/\2\3/p' | head -1)"
  fi
  [ -z "$dir" ] && dir="$cwd"
  case "$dir" in /*) ;; "~"*) dir="$HOME${dir#\~}" ;; *) dir="$cwd/$dir" ;; esac
  [ -d "$dir" ] && dir="$(cd "$dir" && pwd -P)"
  COMMIT_DIR="$dir"
  return 0
}

# Files changed in the repo: staged, unstaged and untracked. A superset of what
# will be committed, because `git add x && git commit` hasn't staged x yet
# when the hook runs.
changed_files() {
  local root="$1"
  {
    git -C "$root" diff --cached --name-only --diff-filter=ACMR
    git -C "$root" diff --name-only --diff-filter=ACMR
    git -C "$root" ls-files --others --exclude-standard
  } 2>/dev/null | sort -u
}
