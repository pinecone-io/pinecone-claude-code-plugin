---
description: Sync local files to a Pinecone Assistant, only uploading new or changed files
argument-hint: assistant [name] source [path] [--delete-missing] [--dry-run]
allowed-tools: Skill, Bash, BashOutput, Read
---

Before proceeding, ALWAYS INVOKE the pinecone:assistant skill before commencing workflow. This will allow
correct resolution of plugin root directory for scripts being run.

> **Script paths are relative to the plugin root directory.**
> Run scripts with: `uv run skills/assistant/scripts/script_name.py [arguments]`

## Overview

Intelligently sync local files to a Pinecone Assistant by only uploading new or changed files. Uses file modification time and size to detect changes, avoiding unnecessary re-uploads.

## Workflow

1. **Parse Arguments**:
   - `assistant`: Name of the assistant (required)
   - `source`: Local file or directory path (required)
   - `--delete-missing`: Delete files from assistant that don't exist locally (optional flag)
   - `--dry-run`: Preview changes without executing (optional flag)
   - `--yes` or `-y`: Skip confirmation prompt (optional flag)

2. **If Arguments Missing**:
   - If no assistant: List assistants and use AskUserQuestion to let user select
   - If no source: Prompt user for the path

3. **Execute Sync Script**:
   ```bash
   uv run skills/assistant/scripts/sync.py \
     --assistant "assistant-name" \
     --source "/path/to/docs" \
     [--delete-missing] \
     [--dry-run] \
     [--yes]
   ```

4. **Script Behavior**:
   - Lists all files currently in the assistant
   - Scans local directory for supported files (.md, .txt, .pdf, .docx, .json)
   - Compares using stored metadata (mtime + size)
   - Identifies: new files, changed files, unchanged files, optionally missing files
   - Shows summary and asks for confirmation
   - Uploads new files, updates changed files (delete + re-upload)
   - Optionally deletes files that no longer exist locally

5. **Display Results**:
   - Summary table showing counts
   - List of files to upload/update/delete
   - Progress indicator during sync
   - Final results panel

## Example Usage

**Basic sync:**
```
/pinecone:assistant-sync assistant docs-bot source ./documentation
```

**Sync with deletion:**
```
/pinecone:assistant-sync assistant docs-bot source ./docs --delete-missing
```

**Dry run (preview changes):**
```
/pinecone:assistant-sync assistant docs-bot source ./docs --dry-run
```

**Auto-confirm (no prompt):**
```
/pinecone:assistant-sync assistant docs-bot source ./docs --yes
```

## How Change Detection Works

The sync script stores metadata when uploading files:
- `mtime`: File modification timestamp
- `size`: File size in bytes
- `file_path`: Relative path from source
- `uploaded_at`: Upload timestamp

On subsequent syncs:
1. Compares local file's mtime and size with stored metadata
2. If different → file changed, needs update
3. If same → file unchanged, skip upload

**Why this works:**
- Fast (just stat() calls, no file reading)
- Reliable (catches 99% of real changes)
- Works for all file types (text and binary)

## Use Cases

**Initial Upload + Future Updates:**
```bash
# First time: upload all files
/pinecone:assistant-sync assistant my-docs source ./documentation

# Later: only upload changed files
/pinecone:assistant-sync assistant my-docs source ./documentation
```

**Keep Assistant in Sync with Repo:**
```bash
# After git pull, sync changes
git pull
/pinecone:assistant-sync assistant repo-docs source ./docs --delete-missing
```

**Preview Changes Before Syncing:**
```bash
/pinecone:assistant-sync assistant my-docs source ./docs --dry-run
```

## What Gets Synced

**Included:**
- `.md` - Markdown files
- `.txt` - Text files
- `.pdf` - PDF documents
- `.docx` - Word documents
- `.json` - JSON files

**Excluded:**
- Files in: `node_modules`, `.venv`, `.git`, `build`, `dist`, `__pycache__`, `.pytest_cache`
- Hidden directories (starting with `.`)
- Source code files (`.py`, `.js`, `.ts`, etc.)

## Flags Explained

**`--delete-missing`:**
- Deletes files from assistant that no longer exist locally
- Use when you've removed files and want to clean up the assistant
- Without this flag, deletions are ignored

**`--dry-run`:**
- Shows what would change without making changes
- Perfect for previewing sync before committing
- No files are uploaded, updated, or deleted

**`--yes` or `-y`:**
- Skips the confirmation prompt
- Useful for automation or when you trust the changes
- Combine with `--dry-run` first to verify

## Script Location

`skills/assistant/scripts/sync.py`

## Troubleshooting

**"No supported files found":**
- Check that your source path contains .md, .txt, .pdf, .docx, or .json files
- Make sure they're not in excluded directories

**Files showing as changed but content is the same:**
- This can happen if you opened and saved a file without changes
- The modification time updates even without content changes
- Generally harmless - the file will be re-uploaded

**Sync is slow:**
- Large files or many files take time
- Each update requires: delete old file + upload new file = 2 operations
- Consider using `--dry-run` first to see scope

## Related Commands

- `/pinecone:assistant-list --files` - See what files are currently in assistant
- `/pinecone:assistant-upload` - One-time upload without sync logic
- `/pinecone:assistant-create` - Create a new assistant before syncing
