#!/usr/bin/env bash
#
# SessionStart hook for the Pinecone Claude Code plugin.
#
# Confirms the user is set up to talk to Pinecone and, if not, hands Claude the
# guidance it needs to walk them through authentication.
#
# Why this is a `command` hook and not an `mcp_tool` hook: SessionStart runs
# before the MCP client exists, so `mcp_tool` hooks are hard-rejected there
# ("no MCP client context"). A shell subprocess likewise has no handle to the
# MCP client. So we validate the key against the same endpoint the MCP
# `list-indexes` tool wraps — the REST control-plane `GET /indexes` — directly.
#
# Checks performed:
#   1. Is PINECONE_API_KEY set?
#   2. If so, is it *active*? (presence != valid) — verified via GET /indexes.
#   3. Is the Pinecone CLI (`pc`) installed?
#
# Output contract: print a single JSON object with a `hookSpecificOutput`
# wrapper to stdout. SessionStart hooks only add context; they cannot block.
#
# Security: the API key is passed to curl through a --config block on stdin, so
# it never appears in argv (i.e. never visible via `ps`). It is never written
# to disk and never included in the emitted context.

set -uo pipefail

API_VERSION="2025-04"

# --- 1 & 2: API key presence and validity -----------------------------------

# key_state is one of: missing | active | invalid | unverified
if [ -z "${PINECONE_API_KEY:-}" ]; then
  key_state="missing"
elif ! command -v curl >/dev/null 2>&1; then
  # Can't validate without curl; presence is all we know.
  key_state="unverified"
else
  # Pass the key via a --config block on stdin so it stays out of argv.
  # printf is a shell builtin, so the key never becomes a process argument.
  http_code="$(
    printf 'header = "Api-Key: %s"\nheader = "X-Pinecone-API-Version: %s"\nurl = "https://api.pinecone.io/indexes"\n' \
      "$PINECONE_API_KEY" "$API_VERSION" \
      | curl -sS --max-time 5 -o /dev/null -w '%{http_code}' --config - 2>/dev/null
  )" || http_code="000"

  case "$http_code" in
    2*)        key_state="active" ;;
    401 | 403) key_state="invalid" ;;
    *)         key_state="unverified" ;;  # network error, timeout, etc.
  esac
fi

# --- 3: CLI presence ---------------------------------------------------------

if command -v pc >/dev/null 2>&1; then
  cli_installed="yes"
else
  cli_installed="no"
fi

# --- Reusable guidance snippets ---------------------------------------------

read -r -d '' API_KEY_HELP <<'EOF'
Create an API key in the Pinecone console (https://app.pinecone.io/?sessionType=signup), then have the user export it in their own terminal:
    export PINECONE_API_KEY="your-key"
Claude Code inherits the shell environment, so that export is sufficient. Claude cannot set this for the user — they must run it themselves, then restart the session so the MCP server picks it up.
EOF

read -r -d '' CLI_HELP <<'EOF'
Install the Pinecone CLI (optional — enables terminal management of all index types, batch ops, and backups):
    brew tap pinecone-io/tap && brew install pinecone-io/tap/pinecone
Then run `pc login` directly in a terminal (not inside an agent loop — the browser auth link may not surface in-agent). Note: `pc login` authenticates the CLI only; it does not set PINECONE_API_KEY.
EOF

# --- Assemble the context ----------------------------------------------------

CONTEXT="[Pinecone plugin — auth check]
Session-start status: API key = ${key_state}; Pinecone CLI (pc) installed = ${cli_installed}.

Act on this ONLY as described below. Do NOT announce a healthy check to the user — stay silent when everything is fine.

API key:"

# SYSTEM_MSG is a short, friendly one-liner shown directly to the user.
case "$key_state" in
  active)
    CONTEXT+=" Valid and active — no action needed. Proceed with Pinecone work normally."
    SYSTEM_MSG="✅ Pinecone: your API key is active and ready."
    ;;
  missing)
    CONTEXT+=" PINECONE_API_KEY is not set. The Pinecone MCP and SDK cannot work without it. Proactively tell the user and guide them to authenticate before any Pinecone operation — the pinecone:quickstart skill walks them through setup end to end.
${API_KEY_HELP}"
    SYSTEM_MSG="🔑 Pinecone plugin is installed but no API key is available. Get a free API key here: https://app.pinecone.io/?sessionType=signup and use the pinecone:quickstart skill to get started."
    ;;
  invalid)
    CONTEXT+=" PINECONE_API_KEY is set but the Pinecone API rejected it (401/403) — it is invalid, expired, or revoked. Tell the user and guide them to replace it with a working key.
${API_KEY_HELP}"
    SYSTEM_MSG="⚠️ Pinecone: your API key was rejected (invalid or expired). Ask me and I'll help you fix it."
    ;;
  unverified)
    CONTEXT+=" PINECONE_API_KEY is set but its validity could not be confirmed from this hook (curl missing or a network/timeout error — NOT necessarily an auth failure). Do not alarm the user. If a Pinecone request later fails auth, verify with the MCP tool mcp__pinecone__list-indexes and, if that also fails, guide re-authentication.
${API_KEY_HELP}"
    SYSTEM_MSG="ℹ️ Pinecone: API key found, but I couldn't verify it just now (network). I'll double-check when you use Pinecone."
    ;;
esac

CONTEXT+="

Pinecone CLI:"

if [ "$cli_installed" = "yes" ]; then
  CONTEXT+=" \`pc\` is installed. No action needed unless the user hits a CLI auth error, in which case suggest \`pc auth status\` / \`pc login\`."
  SYSTEM_MSG+=" Pinecone CLI (pc): installed."
else
  CONTEXT+=" \`pc\` is not installed. The CLI is optional — mention it only if the user needs functionality the MCP does not cover (non-integrated indexes, batch vector ops, backups).
${CLI_HELP}"
  SYSTEM_MSG+=" Pinecone CLI (pc): not installed (optional)."
fi

# --- Emit JSON ---------------------------------------------------------------

if command -v jq >/dev/null 2>&1; then
  jq -n --arg ctx "$CONTEXT" --arg msg "$SYSTEM_MSG" \
    '{systemMessage: $msg, hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
else
  # jq is not guaranteed; fall back to python3 for safe JSON string escaping.
  CONTEXT="$CONTEXT" SYSTEM_MSG="$SYSTEM_MSG" python3 -c '
import json, os
print(json.dumps({
    "systemMessage": os.environ["SYSTEM_MSG"],
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": os.environ["CONTEXT"],
    }
}))'
fi
