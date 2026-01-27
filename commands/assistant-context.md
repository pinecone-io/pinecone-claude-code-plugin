---
description: Retrieve context snippets from a Pinecone Assistant's knowledge base
argument-hint: assistant [name] query [search text] [--top-k 5]
model: claude-haiku-4-5
allowed-tools: Skill, Bash, BashOutput, Read
---

Before proceeding, ALWAYS INVOKE the pinecone:assistant skill before commencing workflow. This will allow
correct resolution of plugin root directory for scripts being run.

> **Script paths are relative to the plugin root directory.**
> Run scripts with: `uv run skills/assistant/scripts/script_name.py [arguments]`

## Overview

Retrieve relevant context snippets from a Pinecone Assistant's knowledge base without generating a full chat response. This is useful for:
- Quick knowledge base searches
- Finding specific information in uploaded documents
- Debugging what the assistant knows
- Building custom RAG workflows

## Workflow

1. **Parse Arguments**:
   - `assistant`: Name of the assistant (required)
   - `query`: Search query text (required)
   - `top_k`: Number of snippets to return (optional, default: 5, max: 16)
   - `snippet_size`: Maximum tokens per snippet (optional, default: 2048)
   - `json`: Output in JSON format (optional flag)

2. **If Arguments Missing**:
   - If no assistant: List assistants and use AskUserQuestion to let user select
   - If no query: Prompt user for their search text

3. **Execute Context Script**:
   ```bash
   uv run skills/assistant/scripts/context.py \
     --assistant "assistant-name" \
     --query "search text" \
     --top-k 5 \
     --snippet-size 2048
   ```

4. **Display Results**:
   - Context snippets displayed in panels with:
     - File name and page numbers
     - Relevance scores (0-1)
     - Actual snippet content (truncated if > 500 chars)
     - Relevance percentage

5. **Offer Next Actions**:
   - Suggest using `/pinecone:assistant-chat` to ask a full question
   - Offer to refine the search with a different query
   - Suggest uploading more documents if no results found

## Example Usage

**Basic context retrieval:**
```
/pinecone:assistant-context assistant docs-qa query "authentication methods"
```

**With custom top-k:**
```
/pinecone:assistant-context assistant support-bot query "reset password" --top-k 10
```

**JSON output:**
```
/pinecone:assistant-context assistant my-docs query "API endpoints" --json
```

**Interactive mode:**
- User invokes: `/pinecone:assistant-context`
- Claude lists assistants and asks user to select
- Claude prompts for the search query
- Claude executes the script and displays results

## Use Cases

**Quick Lookup**: Find specific information without needing a full conversational response
```
Query: "pricing tiers"
Result: Returns relevant sections from pricing documentation
```

**Debugging Knowledge**: Check what documents the assistant has about a topic
```
Query: "deployment"
Result: Shows all relevant deployment-related content
```

**Pre-filtering**: See what context exists before asking a question
```
Query: "authentication"
Result: Preview relevant docs, then ask detailed question in chat
```

**Custom Workflows**: Get raw context for building your own RAG pipelines

## Script Location

`skills/assistant/scripts/context.py`

## Troubleshooting

**Error: PINECONE_API_KEY not set**
- Remind user to export PINECONE_API_KEY before starting Claude Code

**Error: Assistant not found**
- List available assistants
- Check for typos in assistant name

**No results found**
- Assistant may not have relevant documents uploaded
- Try broader search terms
- Suggest uploading relevant files with `/pinecone:assistant-upload`
- Offer to show what documents are in the assistant

**Error: context method not available**
- Check that you're using Pinecone SDK v8.0.0+ which includes assistant.context() support
- The context API requires API version 2025-04 or later for full parameter support
- If the method doesn't exist, your SDK may need updating: `pip install --upgrade pinecone`
- Fallback suggestion: Use `/pinecone:assistant-chat` instead to get responses with citations

## Context vs Chat

Help users understand the difference:

**Use Context when**:
- You want quick snippets without generated responses
- You're debugging the knowledge base
- You need raw source material
- You're building custom workflows

**Use Chat when**:
- You want conversational Q&A
- You need synthesized answers from multiple sources
- You want citations with the response
- You're having a back-and-forth conversation

## Interpreting Results

Guide users on reading context results:

- **Score**: Higher scores (closer to 1.0) mean more relevant
- **File Name**: Which document the snippet came from
- **Page Number**: Exact page reference for PDFs
- **Text**: The actual content snippet

Low scores (<0.5) may indicate:
- Weak match to query
- Assistant needs more relevant documents
- Query too broad or too specific

## Related Commands

- `/pinecone:assistant-chat` - Ask questions and get full responses
- `/pinecone:assistant-upload` - Add more documents to improve results
- List assistants: Run `uv run skills/assistant/scripts/list.py`
