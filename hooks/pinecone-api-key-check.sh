#!/usr/bin/env bash
#
# SessionStart hook for the Pinecone Claude Code plugin.
#
# Does the cheap, safe, shell-side checks only:
#   1. Is PINECONE_API_KEY present in the environment?
#   2. Is the Pinecone CLI (`pc`) installed?

# Output contract: print a single JSON object to stdout with `systemMessage`
# (shown to the user) and `hookSpecificOutput.additionalContext` (injected into
# Claude's context). SessionStart hooks only add context; they cannot block.

set -uo pipefail

# Opt-out: users can silence this hook with `export PINECONE_SKIP_AUTH_CHECK=1`.
# This survives plugin updates (unlike editing the installed hook file).
if [ -n "${PINECONE_SKIP_AUTH_CHECK:-}" ]; then
  exit 0
fi

# --- Deterministic checks ----------------------------------------------------

# key_state is one of: present | missing. We do NOT judge validity here.
if [ -n "${PINECONE_API_KEY:-}" ]; then
  key_state="present"
else
  key_state="missing"
fi

if command -v pc >/dev/null 2>&1; then
  cli_installed="yes"
else
  cli_installed="no"
fi

# --- Reusable guidance snippets ---------------------------------------------

read -r -d '' API_KEY_HELP <<'EOF' || true
Create an API key in the Pinecone console (https://app.pinecone.io/?sessionType=signup), then have the user export it in their own terminal:
    export PINECONE_API_KEY="your-key"
Claude Code inherits the shell environment, so that export is sufficient. Claude cannot set this for the user — they must run it themselves, then restart the session so the MCP server picks it up.
EOF

read -r -d '' CLI_HELP <<'EOF' || true
Install the Pinecone CLI (optional — enables terminal management of all index types, batch ops, and backups):
    brew tap pinecone-io/tap && brew install pinecone-io/tap/pinecone
Then run `pc login` directly in a terminal (not inside an agent loop — the browser auth link may not surface in-agent). Note: `pc login` authenticates the CLI only; it does not set PINECONE_API_KEY.
EOF

# --- Assemble the context ----------------------------------------------------

CONTEXT="[Pinecone plugin — auth check]
Session-start status: PINECONE_API_KEY present = ${key_state}; Pinecone CLI (pc) installed = ${cli_installed}.

Act on this ONLY as described below. Do NOT announce a healthy check to the user — stay silent when everything is fine.

API key:"

# SYSTEM_MSG is a short, friendly one-liner shown directly to the user.
case "$key_state" in
  present)
    CONTEXT+=" PINECONE_API_KEY is set, but presence does not prove it is active. On the user's first Pinecone-related request, silently verify it by calling the MCP tool mcp__pinecone__list-indexes. If that succeeds, proceed without comment. If it fails with an authentication error (e.g. 401/403), the key is invalid, expired, or revoked — tell the user and guide them to replace it.
${API_KEY_HELP}"
    SYSTEM_MSG="✅ Pinecone plugin active — API key detected; I'll confirm it's live when you first use Pinecone."
    ;;
  missing)
    CONTEXT+=" PINECONE_API_KEY is not set. The Pinecone MCP and SDK cannot work without it. Proactively tell the user and guide them to authenticate before any Pinecone operation — the pinecone:quickstart skill walks them through setup end to end.
${API_KEY_HELP}"
    SYSTEM_MSG="🔑 Pinecone plugin active, but no API key is available. Get a free API key here: https://app.pinecone.io/?sessionType=signup and use the pinecone:quickstart skill to get started."
    ;;
esac

CONTEXT+="

Pinecone CLI:"

if [ "$cli_installed" = "yes" ]; then
  CONTEXT+=" \`pc\` is installed. For terminal-based Pinecone work (all index types, batch operations, backups, namespaces, CI/CD), use the pinecone:cli skill to drive it. If the user hits a CLI auth error, suggest \`pc auth status\` / \`pc login\`."
  SYSTEM_MSG+=" Pinecone CLI installed — use the pinecone:cli skill to have Claude use it."
else
  CONTEXT+=" \`pc\` is not installed. The CLI is optional — mention it only if the user needs functionality the MCP does not cover (non-integrated indexes, batch vector ops, backups).
${CLI_HELP}"
  SYSTEM_MSG+=" Pinecone CLI (pc): not installed (optional)."
fi

CONTEXT+="

To disable this check: the user can run \`export PINECONE_SKIP_AUTH_CHECK=1\` in their shell (persists across sessions and survives plugin updates). Tell them this if they ask how to turn off or silence the Pinecone session-start message."

SYSTEM_MSG+=" (To silence this, set PINECONE_SKIP_AUTH_CHECK=1, or ask Claude how.)"

# --- Emit JSON ---------------------------------------------------------------
#
# All values here are plugin-controlled strings (no secret, no free-form user
# input), but they contain quotes and newlines, so they must be escaped. Prefer
# jq, then python3; fall back to a pure-bash escaper so output is always valid
# JSON even when neither is installed.

json_escape() {
  local s=$1
  s=${s//\\/\\\\}      # backslash first
  s=${s//\"/\\\"}      # double quotes
  s=${s//$'\n'/\\n}    # newlines
  s=${s//$'\t'/\\t}    # tabs
  s=${s//$'\r'/\\r}    # carriage returns
  printf '%s' "$s"
}

if command -v jq >/dev/null 2>&1; then
  jq -n --arg ctx "$CONTEXT" --arg msg "$SYSTEM_MSG" \
    '{systemMessage: $msg, hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
elif command -v python3 >/dev/null 2>&1; then
  CONTEXT="$CONTEXT" SYSTEM_MSG="$SYSTEM_MSG" python3 -c '
import json, os
print(json.dumps({
    "systemMessage": os.environ["SYSTEM_MSG"],
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": os.environ["CONTEXT"],
    }
}))'
else
  printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' \
    "$(json_escape "$SYSTEM_MSG")" "$(json_escape "$CONTEXT")"
fi
