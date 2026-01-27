---
name: pinecone-assistant
description: Main skill for all Pinecone Assistant operations. Read this first! Create, manage, and chat with Pinecone Assistants for document Q&A. Automatically recognizes natural language requests like "create an assistant from my docs" or "ask my assistant about authentication" without requiring slash commands. ALWAYS invoke when using Pinecone Assistant related commands
allowed-tools: Skill(assistant *), Bash, BashOutput, Read
---

ALWAYS invoke this skill before running any assistant-* commands, as it will inform you of the correct directories for associated scripts!

# Pinecone Assistant Skill

> **All paths are relative to the directory containing this SKILL.md file.**
> Scripts are run with: `uv run scripts/script_name.py [arguments]`

## 🎯 Natural Language Mode (IMPORTANT - READ THIS FIRST)

**You should proactively recognize and handle natural language requests about Pinecone Assistant without requiring slash commands.**

### Recognize These Patterns & Take Action

**Creating Assistants:**
- "Create a Pinecone assistant from my docs"
- "Make an assistant for my documentation"
- "Set up an assistant called [name]"

→ Run: `uv run scripts/create.py --name [name]`
→ Use AskUserQuestion if name is missing

**Uploading Files:**
- "Upload my docs to the assistant"
- "Add files from ./documentation to [assistant]"
- "Index my local files"

→ Run: `uv run scripts/upload.py --assistant [name] --source [path]`
→ Use AskUserQuestion if missing info

**Syncing Files:**
- "Sync my docs with the assistant"
- "Update the assistant with my latest files"
- "Refresh [assistant] from ./docs"
- "Keep [assistant] in sync with my documentation"

→ Run: `uv run scripts/sync.py --assistant [name] --source [path]`
→ Sync only uploads new/changed files (uses mtime + size detection)
→ Add `--delete-missing` if user wants to remove files that no longer exist locally
→ Add `--dry-run` to preview changes without executing

**Chatting/Asking Questions:**
- "Ask my assistant about [topic]"
- "What does my assistant know about [topic]?"
- "Chat with [assistant]: [question]"

→ Run: `uv run scripts/chat.py --assistant [name] --message "[question]"`
→ **IMPORTANT**: Remember the last assistant used - if user says "my assistant" or doesn't specify, use the last one mentioned

**Getting Context:**
- "Search my assistant for [topic]"
- "Find context about [topic]"

→ Run: `uv run scripts/context.py --assistant [name] --query "[topic]"`

**Listing Assistants:**
- "Show my assistants"
- "What assistants do I have?"

→ Run: `uv run scripts/list.py`

### 🧠 Conversation Memory (CRITICAL)

**Track the last assistant used within the conversation:**

```
User: "Create an assistant called docs-bot"
You: [Creates it] ✅ Remember: last_assistant = "docs-bot"

User: "Upload ./docs to it"
You: [Uploads to docs-bot] ✓ Using remembered assistant

User: "What is authentication?"
You: "Let me ask docs-bot..." [Runs chat with docs-bot]

User: "Tell me more"
You: [Continues with docs-bot]
```

**Rules:**
1. Remember assistant name when user creates or first uses one
2. If user says "my assistant", "it", "the assistant" → use last one
3. Briefly mention which assistant you're using: "Asking docs-bot..."
4. If ambiguous and multiple exist → use AskUserQuestion to clarify

### Combined Multi-Step Requests

Handle chained requests naturally:

**Example 1: Create + Upload + Chat**
"Create an assistant called docs-bot, upload my ./docs folder, and ask what the main features are"

→ Execute in sequence:
1. `uv run scripts/create.py --name docs-bot`
2. `uv run scripts/upload.py --assistant docs-bot --source ./docs`
3. `uv run scripts/chat.py --assistant docs-bot --message "what are the main features?"`

**Example 2: Sync + Query**
"Update my assistant with the latest docs and tell me what changed about authentication"

→ Execute in sequence:
1. `uv run scripts/sync.py --assistant [remembered-assistant] --source ./docs`
2. `uv run scripts/chat.py --assistant [remembered-assistant] --message "what changed about authentication?"`

### Best Practices for Natural Mode

- **Be proactive**: Don't wait for slash commands, recognize intent
- **Be helpful**: Fill in missing info from context when obvious
- **Be interactive**: Use AskUserQuestion when truly ambiguous
- **Be efficient**: Batch operations when user requests multiple steps
- **Be clear**: Show what you're doing ("Creating assistant...", "Uploading 25 files...")

## What is Pinecone Assistant?

Pinecone Assistant is a fully managed RAG (Retrieval Augmented Generation) service that enables you to upload documents and ask questions about them with cited responses. The assistant automatically chunks, embeds, and indexes your files for instant semantic search and question answering.

### Key Features

- **Automatic Processing**: Upload files (PDF, TXT, MD, etc.) and they're automatically chunked, embedded, and indexed
- **Cited Responses**: Every answer includes references to specific pages and source documents
- **Multiple Models**: Compatible with GPT-4o, GPT-4.1, GPT-5, o4-mini, and other models
- **Regional Deployment**: Available in US and EU regions
- **Streaming Support**: Enable streaming for faster perceived response times
- **MCP Integration**: Every assistant is also an MCP server for agent integration
- **Context Retrieval**: Get relevant document excerpts without generating full chat responses

### Common Use Cases

- **Documentation Q&A systems** - Product docs, API references, user guides
- **Research paper analysis** - Academic papers, whitepapers, technical reports with citations
- **Customer support knowledge bases** - Help articles, FAQs, troubleshooting guides
- **Internal company knowledge management** - Policies, procedures, meeting notes
- **Technical writing** - Specifications, design docs, RFCs
-- Creating instant-expert RAG agents for workflows -- It's super easy to create a Pinecone Assistant, and then use the Context API to send information to other agents

**Important Note**: Pinecone Assistant is optimized for **document-based content** (PDFs, markdown, text files with natural language). It is **not recommended for indexing codebases** at this time. For code search and understanding, consider using Pinecone's vector database with specialized code embeddings instead.

### Perfect for Low-Code/No-Code Users

**Pinecone Assistant is ideal for users who want an instant Q&A assistant without writing code!**

If you have local documentation, PDFs, or markdown files and want to:
- Ask questions about your documents and get cited answers
- Build a knowledge base without complex infrastructure
- Get started in minutes with simple commands
- Avoid writing embedding pipelines, chunking logic, or retrieval code

Then Pinecone Assistant is the perfect solution. Simply:
1. Create an assistant with `/pinecone:assistant-create`
2. Upload your local documents with `/pinecone:assistant-upload`
3. Start asking questions with `/pinecone:assistant-chat`

No coding required - just point to your documentation directory and start chatting!

## Assistant Lifecycle

### 1. Create an Assistant

```python
from pinecone import Pinecone

pc = Pinecone(api_key=os.environ['PINECONE_API_KEY'])
assistant = pc.assistant.create_assistant(
    assistant_name="my-docs-assistant",
    instructions="Use professional tone and cite sources.",
    region="us",  # or "eu"
    timeout=30
)
```

**Parameters:**
- `assistant_name` (required): Unique identifier for the assistant
- `instructions` (optional): Directive for assistant behavior (e.g., tone, format, language)
- `region` (optional): "us" or "eu" (default: "us")
- `timeout` (optional): Seconds to wait for ready status (default: 30)

**Returns:** Assistant object with name, host, and status

### 2. Upload Files

```python
# Get assistant instance
assistant = pc.assistant.Assistant(assistant_name="my-docs-assistant")

# Upload a single file
response = assistant.upload_file(
    file_path="/path/to/document.pdf",
    metadata={"source": "github", "repo": "owner/repo", "type": "documentation"},
    timeout=None
)
```

**Parameters:**
- `file_path` (required): Path to local file
- `metadata` (optional): Dictionary of custom metadata attached to the file
- `timeout` (optional): Wait duration (None = no timeout)

**Supported File Types:**
- DOCX (.docx) - Word documents
- JSON (.json) - JSON data files
- Markdown (.md) - Markdown files
- PDF (.pdf) - PDF documents
- Text (.txt) - Plain text files

**Best for**: Documentation, technical writing, reports, papers, guides, data files, and other natural language content.

**Not recommended for**: Source code files (.py, .js, .ts, etc.). Assistant is optimized for documents and natural language, not code syntax and structure.

**Best Practice:** Add metadata to track file sources, types, versions, etc. This helps with:
- Understanding where information comes from
- Filtering and organizing knowledge
- Debugging and maintenance

### 3. Chat with Assistant

```python
from pinecone_plugins.assistant.models.chat import Message

# Create message
msg = Message(role="user", content="What is the main feature of this product?")

# Get response
response = assistant.chat(messages=[msg])

# Access response components
print(response.message.content)  # Assistant's answer
print(response.citations)         # Source references with page numbers
print(response.usage)             # Token usage statistics
```

**Message Object:**
- `role`: "user" or "assistant"
- `content`: Text of the message

**Response Object:**
- `message`: Assistant's reply with content and role
- `citations`: List of citation objects, each containing:
  - `position`: Character position in response where citation appears
  - `references`: List of reference objects with:
    - `file.name`: Source file name
    - `file.id`: Unique file identifier
    - `file.signed_url`: Temporary download URL (valid ~1 hour)
    - `pages`: List of page numbers (for PDFs)
    - `metadata`: File metadata (content_type, file_path, etc.)
- `usage`: Token consumption (prompt_tokens, completion_tokens, total_tokens)
- `finish_reason`: "stop", "length", or "error"

**Multi-turn Conversations:**
```python
messages = [
    Message(role="user", content="What is RAG?"),
    Message(role="assistant", content=response1.message.content),
    Message(role="user", content="How does it work with Pinecone?")
]
response = assistant.chat(messages=messages)
```

### 4. Retrieve Context (Without Chat)

```python
# Get relevant context snippets without generating a full response
response = assistant.context(
    query="deployment architecture",
    top_k=5,
    snippet_size=2048  # Maximum tokens per snippet
)

# Process context snippets
for snippet in response.snippets:
    # Extract file info from reference
    file_name = snippet.reference.file.name
    pages = snippet.reference.pages  # List of page numbers
    content = snippet.content  # The actual text snippet
    score = snippet.score  # Relevance score

    print(f"File: {file_name}")
    print(f"Pages: {pages}")
    print(f"Content: {content}")
    print(f"Score: {score}")
```

**Parameters:**
- `query` (required): Search query text
- `top_k` (optional): Number of snippets to return (default: 16, max: 16)
- `snippet_size` (optional): Maximum tokens per snippet (default: 2048)

**Response Structure:**
- `response.snippets`: List of snippet objects containing:
  - `content`: The text snippet
  - `score`: Relevance score (0-1)
  - `type`: Content type (usually "text")
  - `reference`: Reference object with:
    - `file.name`: Source filename
    - `file.id`: Unique file identifier
    - `file.signed_url`: Temporary download URL (~1 hour)
    - `pages`: List of page numbers

**Use Cases for Context Retrieval:**
- Building custom RAG pipelines
- Extracting specific information
- Pre-filtering before chat
- Debugging assistant knowledge

### 5. List Assistants

```python
# List all assistants in account
assistants = pc.assistant.list_assistants()

for asst in assistants:
    print(f"Name: {asst.name}")
    print(f"Region: {asst.region}")
    print(f"Status: {asst.status}")
    print(f"Host: {asst.host}")
```

### 6. Delete Assistant

```python
# Delete assistant and all uploaded files
pc.assistant.delete_assistant(assistant_name="my-docs-assistant")
```

**Warning:** This permanently deletes the assistant and all associated files.

## Working with Repositories

### Recommended Workflow for Repository Uploads

1. **User creates/identifies a repository** containing files to upload
2. **User tells you the repository path** (local directory or GitHub URL)
3. **You scan the repository** to find relevant files:
   - Include: Documentation (*.md, *.txt), code (*.py, *.js, etc.), specs
   - Exclude: Binary files, dependencies (node_modules, .venv), build artifacts
4. **You upload files with metadata** tracking source repo, file path, commit hash
5. **For updates**: Re-scan repo, upload new/changed files, optionally remove deleted files

### Example Repository Upload Pattern

```python
import os
import glob

# User provides repo path
repo_path = "/path/to/user/repo"

# Find relevant files
patterns = ["**/*.md", "**/*.py", "**/*.js", "**/*.txt"]
files_to_upload = []
for pattern in patterns:
    files_to_upload.extend(glob.glob(f"{repo_path}/{pattern}", recursive=True))

# Filter out unwanted directories
exclude_dirs = ["node_modules", ".venv", ".git", "build", "dist"]
files_to_upload = [
    f for f in files_to_upload
    if not any(excl in f for excl in exclude_dirs)
]

# Upload each file with metadata
for file_path in files_to_upload:
    relative_path = os.path.relpath(file_path, repo_path)
    assistant.upload_file(
        file_path=file_path,
        metadata={
            "source": "local_repo",
            "repo_path": repo_path,
            "file_path": relative_path,
            "file_type": os.path.splitext(file_path)[1]
        }
    )
```

## Environment Variables

### Required

```bash
export PINECONE_API_KEY="your-api-key-here"
```

Get your API key from: https://app.pinecone.io/?sessionType=signup

### Optional

```bash
export PINECONE_ASSISTANT_HOST="https://prod-1-data.ke.pinecone.io"
```

The assistant host is automatically provided when you create an assistant. Typical values:
- US region: `https://prod-1-data.ke.pinecone.io`
- EU region: Check Pinecone Console for your specific host

## MCP Server Integration

Every Pinecone Assistant is also an MCP (Model Context Protocol) server, enabling AI agents to access the assistant's knowledge.

### Remote MCP Endpoint

Format: `https://<YOUR_ASSISTANT_HOST>/mcp/assistants/<YOUR_ASSISTANT_NAME>`

### Available Tools

- **context tool**: Retrieve relevant context snippets from assistant's knowledge base

### Configuration

Add to your MCP configuration (`.mcp.json` or Claude Desktop config):

```json
{
  "mcpServers": {
    "my-assistant": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "PINECONE_API_KEY",
        "-e", "PINECONE_ASSISTANT_HOST",
        "pinecone/assistant-mcp"
      ],
      "env": {
        "PINECONE_API_KEY": "${PINECONE_API_KEY}",
        "PINECONE_ASSISTANT_HOST": "${PINECONE_ASSISTANT_HOST}"
      }
    }
  }
}
```

## API Best Practices

### 1. Use Descriptive Assistant Names
- Good: `company-docs-qa`, `codebase-search`, `product-support`
- Bad: `test`, `assistant1`, `my-assistant`

### 2. Add Rich Metadata to Files
```python
metadata = {
    "source": "github",
    "repo": "owner/repo",
    "branch": "main",
    "commit": "abc123",
    "file_path": "docs/api.md",
    "uploaded_at": "2024-01-15",
    "category": "documentation"
}
```

### 3. Provide Clear Instructions
```python
instructions = """
- Use professional technical tone
- Cite specific page numbers and files
- If unsure, say so rather than guessing
- Format code examples with proper syntax highlighting
"""
```

### 4. Handle Multi-turn Conversations
Maintain conversation history by passing previous messages to enable context-aware responses.

### 5. Use Context Retrieval for Custom Workflows
When you need raw context without generated responses, use the context API instead of chat.

### 6. Regional Considerations
- Choose region based on data residency requirements
- US region typically has lower latency for North American users
- EU region for European data compliance

## Error Handling

### Common Errors

**API Key Missing:**
```python
# Check before use
if not os.environ.get('PINECONE_API_KEY'):
    raise ValueError("PINECONE_API_KEY not set")
```

**Assistant Not Found:**
```python
# List assistants first
assistants = pc.assistant.list_assistants()
if assistant_name not in [a.name for a in assistants]:
    raise ValueError(f"Assistant '{assistant_name}' not found")
```

**File Upload Failures:**
- Check file exists and is readable
- Verify file format is supported
- Ensure file size is within limits
- Check network connectivity

**Timeout Errors:**
- Increase timeout parameter
- Check assistant status (may still be indexing)
- Verify network connection

## Python SDK Installation

```bash
pip install pinecone-client pinecone-plugin-assistant
```

Or with the unified SDK:
```bash
pip install "pinecone[assistant]"
```

For use with `uv`:
```python
# /// script
# dependencies = [
#   "pinecone[assistant]",
# ]
# ///
```

## Documentation Links

- **Quickstart**: https://docs.pinecone.io/guides/assistant/quickstart
- **MCP Server**: https://docs.pinecone.io/guides/assistant/mcp-server
- **Create Assistant**: https://docs.pinecone.io/guides/assistant/create-assistant
- **API Reference**: https://docs.pinecone.io/reference/api/assistant
- **Python SDK Docs**: https://docs.pinecone.io/guides/get-started/python-sdk

## Available Scripts

This skill provides Python scripts that Claude Code can invoke via `uv run`:

- **`list.py`** - List all assistants in account (use `--files` flag to show file details)
- **`create.py`** - Create a new assistant
- **`upload.py`** - Upload files or repository to assistant (one-time upload)
- **`sync.py`** - Sync local files to assistant (only uploads new/changed files)
- **`chat.py`** - Chat with assistant and get cited responses
- **`context.py`** - Retrieve context snippets from assistant

All scripts assume `PINECONE_API_KEY` is set in the environment, and uv is installed.
