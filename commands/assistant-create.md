---
description: Create a new Pinecone Assistant for document Q&A with citations
argument-hint: assistant [name] [--instructions "behavior"] [--region us|eu]
model: claude-haiku-4-5
allowed-tools: Skill, Bash, BashOutput, Read, AskUserQuestion
---

Before proceeding, ALWAYS INVOKE the pinecone:assistant skill before commencing workflow. This will allow
correct resolution of plugin root directory for scripts being run.

> **Script paths are relative to the plugin root directory.**
> Run scripts with: `uv run skills/assistant/scripts/script_name.py [arguments]`

## Overview

Create a new Pinecone Assistant with custom configuration. This command invokes the assistant creation script to set up a new assistant for RAG workflows.

## Workflow

1. **Parse Arguments**:
   - `assistant`: Unique name for the assistant (required)
   - `instructions`: Instructions for assistant behavior (optional)
   - `region`: Deployment region - "us" or "eu" (optional, default: "us")
   - `timeout`: Seconds to wait for ready status (optional, default: 30)

2. **If Assistant Name Not Provided**:
   - Prompt user for a descriptive assistant name
   - Suggest naming conventions: `{purpose}-{type}` like "docs-qa", "code-search", "support-bot"

3. **Gather Optional Configuration**:
   - Use AskUserQuestion to ask about region preference (US or EU)
   - Ask if user wants to provide custom instructions
   - Examples of instructions:
     - "Use professional technical tone and cite sources"
     - "Respond in Spanish with formal language"
     - "Format code examples with syntax highlighting"

4. **Execute Create Script**:
   ```bash
   uv run skills/assistant/scripts/create.py \
     --name "assistant-name" \
     --instructions "custom instructions" \
     --region "us" \
     --timeout 30
   ```

5. **Display Results**:
   - Assistant name and status
   - Assistant host URL (for MCP configuration)
   - Instructions to set PINECONE_ASSISTANT_HOST environment variable
   - Pinecone Console link: `https://app.pinecone.io/organizations/-/projects/-/assistant/` (users can view and manage their assistants in the web UI)
   - Next steps: upload files and start chatting

6. **Offer Next Actions**:
   - Ask if user wants to upload files now
   - If yes, invoke `/pinecone:assistant-upload` with the new assistant name

## Example Usage

**Basic creation:**
```
/pinecone:assistant-create assistant docs-assistant
```

**With instructions:**
```
/pinecone:assistant-create assistant support-bot --instructions "Use friendly tone and provide step-by-step guidance"
```

**EU region:**
```
/pinecone:assistant-create assistant eu-assistant --region eu
```

**Interactive mode:**
- User invokes: `/pinecone:assistant-create`
- Claude prompts for assistant name
- Claude asks about region preference (use AskUserQuestion)
- Claude asks if custom instructions are needed
- Claude executes the script

## Assistant Naming Best Practices

Suggest these naming patterns to users:
- `{purpose}-{type}`: docs-qa, code-search, api-helper
- `{company}-{function}`: acme-support, startup-docs
- `{project}-{purpose}`: webapp-docs, api-reference

Avoid: generic names like "assistant", "test", "my-bot"

## Instructions Examples

Provide these examples if user wants guidance:
- **Documentation Q&A**: "Use professional technical tone. Cite specific page numbers. If uncertain, say so."
- **Code Assistant**: "Provide code examples with syntax highlighting. Explain reasoning step by step."
- **Customer Support**: "Use friendly, empathetic tone. Provide clear action items. Reference documentation when helpful."
- **Multilingual**: "Respond in French. Use formal language conventions."

## Script Location

`skills/assistant/scripts/create.py`

## Troubleshooting

**Error: PINECONE_API_KEY not set**
- Remind user to export PINECONE_API_KEY before starting Claude Code
- Provide signup link: https://app.pinecone.io/?sessionType=signup

**Error: Assistant name already exists**
- List existing assistants with list script
- Suggest a different unique name
- Or delete the existing assistant first (requires confirmation)

**Timeout errors**
- Increase timeout value: `--timeout 60`
- Check network connectivity
- Verify Pinecone service status

**Region selection**
- US region: Lower latency for North American users
- EU region: European data residency requirements

## Post-Creation Steps

After successful creation:
1. **Save the assistant host URL** - Show the PINECONE_ASSISTANT_HOST value
2. **Pinecone Console access** - Inform user they can view and manage their assistant at https://app.pinecone.io/organizations/-/projects/-/assistant/
   - Upload files via the web UI
   - Chat with the assistant directly in the browser
   - View file lists and assistant configuration
   - Test queries without code
3. **Suggest file upload** - Offer to run `/pinecone:assistant-upload` next
4. **MCP configuration** - Explain that the assistant is now an MCP server

## Related Commands

- `/pinecone:assistant-upload` - Upload files to the new assistant
- `/pinecone:assistant-chat` - Start chatting with the assistant
- List all assistants: Run `uv run skills/assistant/scripts/list.py`
