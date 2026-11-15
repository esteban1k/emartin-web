#!/usr/bin/env bash
# Explicit Git Ship gate — beforeShellExecution
# Blocks/asks on git commit & git push unless Esteban explicitly authorized.
# Always emit valid JSON via jq (fail-closed friendly).

set -euo pipefail

input="$(cat || true)"
# beforeShellExecution: .command — preToolUse Shell: .tool_input.command
command="$(printf '%s' "$input" | jq -r '.command // .tool_input.command // empty' 2>/dev/null || true)"

# Normalize for matching (strip leading env assignments loosely)
cmd_lc="$(printf '%s' "$command" | tr '[:upper:]' '[:lower:]')"

is_git_commit=0
is_git_push=0

# Match real git commit/push even inside wrappers: bash -c, env, quotes, etc.
if printf '%s' "$cmd_lc" | grep -Eq '(^|[[:space:];|&/'\''"`])git[[:space:]]+commit([[:space:]'\''"`]|$)'; then
  is_git_commit=1
fi
if printf '%s' "$cmd_lc" | grep -Eq '(^|[[:space:];|&/'\''"`])git[[:space:]]+push([[:space:]'\''"`]|$)'; then
  is_git_push=1
fi

# Also gate gh that can publish commits (rare); keep narrow
if printf '%s' "$cmd_lc" | grep -Eq '(^|[[:space:];|&'\''"`])gh[[:space:]]+repo[[:space:]]+sync([[:space:]'\''"`]|$)'; then
  is_git_push=1
fi

if [[ "$is_git_commit" -eq 0 && "$is_git_push" -eq 0 ]]; then
  jq -n --arg cmd "$command" '{permission:"allow",agentMessage:("gate-git-ship: allow non-ship command")}'
  exit 0
fi

# One-shot override only when Esteban (or coordinator with his OK) set this in the same shell env
# Example: EXPLICIT_GIT_SHIP=1 git push
if [[ "${EXPLICIT_GIT_SHIP:-}" == "1" ]]; then
  jq -n --arg cmd "$command" '{
    permission: "allow",
    agentMessage: ("gate-git-ship: EXPLICIT_GIT_SHIP=1 — allowing: " + $cmd),
    userMessage: "Git ship allowed (EXPLICIT_GIT_SHIP=1)."
  }'
  exit 0
fi

kind="git commit/push"
[[ "$is_git_push" -eq 1 ]] && kind="git push"
[[ "$is_git_commit" -eq 1 && "$is_git_push" -eq 0 ]] && kind="git commit"

jq -n --arg cmd "$command" --arg kind "$kind" '{
  permission: "ask",
  userMessage: ("Confirm " + $kind + "? Agents must not ship unless you asked explicitly."),
  agentMessage: ("BLOCKED pending confirmation: " + $kind + " → `" + $cmd + "`. Do not retry commit/push unless Esteban explicitly asked in this turn. Prefer local edits only. Override only with EXPLICIT_GIT_SHIP=1 when he authorized.")
}'
exit 0