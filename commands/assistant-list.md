---
description: List all Pinecone Assistants in your account with optional file details. 
argument-hint: [--files] [--json]
model: claude-haiku-4-5
allowed-tools: Skill, Bash, BashOutput, Read
---

Before proceeding, ALWAYS INVOKE the pinecone:assistant skill before commencing workflow. This will allow
correct resolution of plugin root directory for scripts being run.

> **Script paths are relative to the plugin root directory.**
> Run scripts with: `uv run skills/assistant/scripts/script_name.py [arguments]`

## Overview

List all Pinecone Assistants in your account. Optionally include detailed file listings for each assistant using the `--files` flag.

## Workflow

1. **Execute List Script**:
   ```bash
   uv run skills/assistant/scripts/list.py [--files] [--json]
   ```

2. **Display Results**:
   - Table showing all assistants with name, region, status, and host
   - With `--files`: Additional "Files" column showing count, plus detailed file tables below
   - With `--json`: JSON output with optional file arrays

3. **File Details** (when `--files` is used):
   - For each assistant, shows a table of uploaded files
   - File information includes: name, status, and ID
   - File status color-coded (green=available, yellow=processing)

## Example Usage

**Basic listing:**
```
/pinecone:assistant-list
```

**With file details:**
```
/pinecone:assistant-list --files
```

**JSON output with files:**
```
/pinecone:assistant-list --files --json
```

## Use Cases

**Quick Overview**: See all assistants and their status
```
/pinecone:assistant-list
```

**Audit Files**: Check what files are uploaded to each assistant
```
/pinecone:assistant-list --files
```

**Programmatic Access**: Get JSON output for scripting or automation
```
/pinecone:assistant-list --json
```

## Output Format

### Without --files
- Name: Assistant identifier
- Region: us or eu
- Status: ready, indexing, or error
- Host: Assistant API endpoint

### With --files
- Adds file count column to main table
- Shows detailed file tables for each assistant:
  - File Name: Original filename
  - Status: Processing state (available, processing)
  - ID: Unique file identifier for deletion/management

## Script Location

`skills/assistant/scripts/list.py`

## Related Commands

- `/pinecone:assistant-create` - Create a new assistant
- `/pinecone:assistant-upload` - Upload files to an assistant
- `/pinecone:assistant-chat` - Chat with an assistant
