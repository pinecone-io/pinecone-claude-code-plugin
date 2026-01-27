---
description: Chat with a Pinecone Assistant and receive answers with source citations
argument-hint: assistant [name] message [your question]
model: claude-haiku-4-5
allowed-tools: Skill, Bash, BashOutput, Read
---

Before proceeding, ALWAYS INVOKE the pinecone:assistant skill before commencing workflow. This will allow
correct resolution of plugin root directory for scripts being run.

> **Script paths are relative to the plugin root directory.**
> Run scripts with: `uv run skills/assistant/scripts/script_name.py [arguments]`

## Overview

Chat with a Pinecone Assistant and receive cited responses. This command invokes the assistant chat script to send messages and display responses with citations.

## Workflow

1. **Parse Arguments**:
   - `assistant`: Name of the assistant (required)
   - `message`: The user's question or message (required)
   - `stream`: Enable streaming responses (optional, flag)

2. **If Arguments Missing**:
   - If no assistant name provided: Run `uv run skills/assistant/scripts/list.py --json` to get available assistants
   - Use AskUserQuestion to let user select an assistant from the list
   - If no message provided: Prompt user for their question

3. **Execute Chat Script**:
   ```bash
   uv run skills/assistant/scripts/chat.py \
     --assistant "assistant-name" \
     --message "user's question"
   ```

4. **Display Results**:
   - The script will show the assistant's response
   - Citations table with:
     - Citation number
     - Source file name (e.g., "document.pdf", "notes.txt")
     - Page numbers (e.g., "1, 2, 3" or "N/A" for text files)
     - Position in response text
   - Token usage statistics
   - Follow-up suggestions

**Note**: File URLs are temporary signed links valid for approximately 1 hour. They are not displayed in the output to keep it clean.

## Example Usage

**With all arguments:**
```
/pinecone:assistant-chat assistant docs-qa message "What is the main feature?"
```

**With streaming:**
```
/pinecone:assistant-chat assistant my-assistant message "Explain the architecture" --stream
```

**Interactive mode** (missing arguments):
- User invokes: `/pinecone:assistant-chat`
- Claude lists assistants and asks user to select
- Claude prompts for the message
- Claude executes the script

## Script Location

`skills/assistant/scripts/chat.py`

## Troubleshooting

**Error: PINECONE_API_KEY not set**
- Remind user to export PINECONE_API_KEY before starting Claude Code
- Provide signup link: https://app.pinecone.io/?sessionType=signup

**Error: Assistant not found**
- Run list command to show available assistants
- Check for typos in assistant name

**Error: No response or timeout**
- Check if assistant has files uploaded
- Verify assistant status is "ready" (not "indexing")
- Suggest waiting if files are still processing

**Empty or poor responses**
- Assistant may not have relevant documents uploaded
- Suggest uploading relevant files with `/pinecone:assistant-upload`

## Related Commands

- `/pinecone:assistant-context` - Get context snippets without full chat response
- `/pinecone:assistant-upload` - Upload files to provide knowledge to the assistant
- List assistants: Run `uv run skills/assistant/scripts/list.py`
