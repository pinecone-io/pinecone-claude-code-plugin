---
description: Upload files or repository contents to a Pinecone Assistant's knowledge base
argument-hint: assistant [name] source [path] [--patterns "*.md,*.py"]
allowed-tools: Skill, Bash, BashOutput, Read
---

Before proceeding, ALWAYS INVOKE the pinecone:assistant skill before commencing workflow. This will allow
correct resolution of plugin root directory for scripts being run.

> **Script paths are relative to the plugin root directory.**
> Run scripts with: `uv run skills/assistant/scripts/script_name.py [arguments]`

## Overview

Upload files or entire repository contents to a Pinecone Assistant. This command helps users provide knowledge to their assistants by uploading **documentation and text-based files**.

**Key Principle**: Users tell Claude what repository or directory to upload, and Claude scans and uploads the relevant files.

**Important**: Pinecone Assistant works with **documentation and data files** only, not source code. Focus on uploading:
- README files
- Documentation directories (markdown, PDF, Word)
- User guides and API docs
- Design documents and specifications
- Meeting notes and reports
- JSON data files

**Supported**: .docx, .json, .md, .pdf, .txt

**Not supported**: Source code files (.py, .js, .ts, .java, etc.) as Assistant is optimized for natural language documents, not code syntax.

## Workflow

1. **Parse Arguments**:
   - `assistant`: Name of the assistant to upload to (required)
   - `source`: File path, directory path, or repository to upload (required)
   - `patterns`: Comma-separated glob patterns (optional, defaults to common doc/code files)
   - `exclude`: Directories to exclude (optional, defaults to node_modules, .venv, etc.)
   - `metadata`: Additional JSON metadata (optional)

2. **If Arguments Missing**:
   - If no assistant: List assistants and use AskUserQuestion to let user select
   - If no source: Ask user for the repository or directory path
     - Suggest current directory (`.`)
     - Suggest common paths like `./docs`, `./src`, etc.

3. **Understand Source Type**:
   - **Single file**: Upload it directly
   - **Directory/Repository**: Scan for relevant files
   - **Current repo** (`.` or `./`): Use current working directory

4. **Ask User About File Selection**:
   - Use Glob to preview what files will be uploaded
   - Show user the count and types of files found
   - Use AskUserQuestion to confirm or let them customize patterns:
     - "Upload all documentation files (recommended)" - *.md, *.txt, *.pdf
     - "Only upload markdown files" - *.md
     - "Only upload PDFs" - *.pdf
     - "Custom documentation pattern"
   - **If code files detected in directory**: Actively warn user and suggest filtering them out

5. **Execute Upload Script**:
   ```bash
   uv run skills/assistant/scripts/upload.py \
     --assistant "assistant-name" \
     --source "/path/to/repo" \
     --patterns "*.md,*.py,*.js" \
     --exclude "node_modules,.venv,.git"
   ```

6. **Display Progress and Results**:
   - The script shows a progress bar during upload
   - Summary table with uploaded/failed counts
   - Next steps suggestions

7. **Post-Upload Actions**:
   - Remind user that files are being processed
   - Suggest trying a chat query after a moment
   - Offer to run `/pinecone:assistant-chat` now

## Default File Patterns

The upload script includes **only documentation and data files** by default:
- `**/*.md` - Markdown files
- `**/*.txt` - Text files
- `**/*.pdf` - PDF documents
- `**/*.docx` - Word documents
- `**/*.json` - JSON data files

**Code files are NOT supported**: Do not upload `.py`, `.js`, `.ts`, `.java`, or any other source code files. Assistant is designed for natural language documents only.

## Default Exclusions

These directories are excluded by default:
- `node_modules`
- `.venv`, `venv`
- `.git`
- `build`, `dist`
- `__pycache__`
- `.next`, `.cache`

## Example Usage

**Upload current repository:**
```
/pinecone:assistant-upload assistant docs-qa source .
```

**Upload specific directory:**
```
/pinecone:assistant-upload assistant my-bot source ./documentation
```

**Upload with custom patterns (documentation only):**
```
/pinecone:assistant-upload assistant docs-bot source ./docs --patterns "*.md,*.pdf"
```

**Upload single file:**
```
/pinecone:assistant-upload assistant support-bot source ./README.md
```

## Repository Upload Workflow

When user says "upload my repository" or provides a repo path:

1. **Confirm the repository path** with the user
2. **Use Glob to preview files**:
   ```bash
   # Example: Count files by type
   ls -R | grep -E '\.(md|py|js|ts)$' | wc -l
   ```
3. **Show user what will be uploaded**:
   - Total file count
   - Breakdown by type (e.g., "25 Markdown files, 8 PDFs, 3 text files")
   - **If code files detected**: Warn user that Assistant works best with documentation, suggest filtering to docs only
4. **Ask for confirmation** with AskUserQuestion
5. **Execute the upload script**
6. **Show progress and results**

**Warning for Code Files**:
If user's directory contains .py, .js, .ts, .java or other code files, **actively warn and filter them out**:
```
⚠️  Found 50 Python files and 30 JavaScript files in this directory.

Pinecone Assistant does not support source code - it's designed for documentation only.

I found these documentation files instead:
- 15 Markdown files (READMEs, docs)
- 5 PDF files
- 3 text files

I'll upload only the documentation files. Continue?
```

**Do not give users the option to upload code files** - always filter them out automatically.

## Metadata Best Practices

Encourage users to add metadata for better organization:
```bash
--metadata '{"source":"github","repo":"owner/repo","branch":"main"}'
```

Benefits:
- Track where files came from
- Filter by source later
- Debug and maintain knowledge base

## Interactive Mode Example

User: `/pinecone:assistant-upload`

Claude:
1. Lists assistants, asks user to select
2. Asks: "What repository or directory should I upload?"
3. User provides path: `/Users/arjun/my-project`
4. Claude scans and reports: "Found 45 documentation files: 25 Markdown, 15 PDFs, 5 text files"
5. **If code files found**: "⚠️ Also found 50 Python files. Assistant works with documents only - I'll skip the code files."
6. Claude asks: "Should I upload all documentation files?" (uses AskUserQuestion)
7. User confirms
8. Claude executes upload script with `--patterns "*.md,*.txt,*.pdf"`
9. Claude shows progress and results

## Script Location

`skills/assistant/scripts/upload.py`

## Troubleshooting

**Error: PINECONE_API_KEY not set**
- Remind user to export PINECONE_API_KEY before starting Claude Code

**Error: Assistant not found**
- List available assistants
- Check for typos in assistant name

**Error: Path does not exist**
- Verify the path with user
- Check current working directory
- Use absolute paths if relative paths fail

**No files found**
- Check if patterns match file types in directory
- Verify directory isn't empty
- Check exclusion patterns aren't too broad

**Upload failures**
- Check file formats are supported (PDF, TXT, MD, etc.)
- Verify files aren't corrupted
- Check network connectivity
- Try uploading in smaller batches

**Large repository warnings**
- If >100 documentation files, ask user if they want to be more selective
- Suggest uploading specific documentation directories (e.g., `./docs` only)
- Offer to exclude examples or auto-generated docs

**Code files detected**
- Always filter out code files automatically
- Warn user that code files were found and excluded
- Explain that Assistant is for documents only

## Post-Upload Guidance

After successful upload:
1. **Remind about processing time**: "Files are being indexed and will be available shortly"
2. **Suggest a test query**: Offer to run `/pinecone:assistant-chat` with a sample question
3. **Monitor status**: Suggest checking assistant status with list command

## Related Commands

- `/pinecone:assistant-chat` - Chat with the assistant using uploaded knowledge
- `/pinecone:assistant-context` - Search uploaded files
- List assistants: Run `uv run skills/assistant/scripts/list.py`
