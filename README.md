# Pinecone Plugin for Claude Code

A lightweight plugin that integrates [Pinecone](https://www.pinecone.io/) vector database capabilities directly into Claude Code, enabling semantic search, index management, and RAG (Retrieval Augmented Generation) workflows.

## Features

- **Pinecone Assistant** – Fully managed RAG service for document Q&A with citations, natural language support, and incremental file syncing
- **Pinecone MCP Server** – Full integration with the Pinecone Model Context Protocol server for index creation, listing, searching, and more
- **Slash Commands** – Quick access to common Pinecone operations directly from Claude Code
- **Semantic Search** – Query your vector indexes using natural language
- **Natural Language Recognition** – Assistant commands work without explicit slash commands

## Installation

### Option A: Claude Code Plugins Directory (Recommended)

Install from the [official Claude Code Plugins Directory](https://github.com/anthropics/claude-plugins-official):

1. Install the plugin:
   ```
   /plugin install pinecone
   ```

2. **Restart Claude Code** to activate the plugin.

### Option B: Pinecone Marketplace

Alternatively, install directly from the Pinecone marketplace:

1. **Add the Pinecone plugin marketplace:**
   ```
   /plugin marketplace add pinecone-io/pinecone-claude-code-plugin
   ```

2. **Install the plugin:**
   ```
   /plugin install pinecone@pinecone-claude-code-plugin
   ```

3. **When prompted**, select your preferred installation scope:
   - **User scope** (default) – Available across all your projects
   - **Project scope** – Shared with your team via version control
   - **Local scope** – Project-specific, not shared (gitignored)

4. **Restart Claude Code** to activate the plugin.

### Set Your API Key

4. Restart Claude Code to activate the plugin.

---

### Set Your API Key

After installing via either method, configure your Pinecone API key before running Claude Code:

```bash
export PINECONE_API_KEY="your-api-key-here"
```

> **Don't have a Pinecone account?** Sign up for free at [app.pinecone.io](https://app.pinecone.io/?sessionType=signup)


### Install uv (Required for Assistant Commands)

To use Pinecone Assistant functionality, you must have uv installed. uv is a fast Python package and project manager:

**macOS and Linux:**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Windows:**
```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

**With Homebrew:**
```bash
brew install uv
```

After installation, restart your terminal and verify with: `uv --version`

Full installation guide: https://docs.astral.sh/uv/getting-started/installation/

### Install the Pinecone CLI (Optional)

For additional command-line capabilities, install the Pinecone CLI:

```bash
brew tap pinecone-io/tap
brew install pinecone-io/tap/pinecone
```

## Available Commands

### Core Commands

### `/pinecone:help`

Display help information about the plugin, including:
- Available functionality
- API key configuration
- Troubleshooting tips

Run this when first installing the Plugin, then proceed to the quickstart.

### `/pinecone:quickstart`

Get started quickly with Pinecone! This command:
1. Downloads and generates an AGENTS.md file, optimized for use with Claude Code and Pinecone
2. Walks you through a Python quickstart tutorial
3. Helps you create your first index and perform semantic searches

### `/pinecone:query`

Query your Pinecone indexes using natural language. This command wraps the Pinecone MCP server for easy searching of integrated indexes.
Most useful when you already have an integrated index created, and want to query it quickly from Claude.

**Usage:**
```
/pinecone:query query [your search text] index [indexName] namespace [ns] reranker [rerankModel]
```

**Parameters:**
| Parameter | Required | Description |
|-----------|----------|-------------|
| `query` | Yes | The text to search for |
| `index` | Yes | The name of the Pinecone index to search |
| `namespace` | No | The namespace within the index |
| `reranker` | No | The reranking model to use for improved relevance |

If you omit required arguments, the command will interactively guide you through selecting available indexes and namespaces.

> **Note:** The `/query` command currently only works with integrated indexes that use Pinecone's hosted embedding models. Third-party embedding models (OpenAI, HuggingFace, etc.) are not yet supported.

### Pinecone Assistant Commands

Pinecone Assistant is a fully managed RAG (Retrieval Augmented Generation) service that enables document Q&A with citations. The plugin includes full support with both slash commands and natural language recognition.

#### `/pinecone:assistant-create`

Create a new Pinecone Assistant for document-based Q&A with custom instructions and regional deployment.

**Usage:**
```
/pinecone:assistant-create --name my-docs-assistant [--instructions "Use professional tone"] [--region us]
```

#### `/pinecone:assistant-upload`

Upload files or entire directories to your assistant for indexing. Supports PDF, Markdown, TXT, DOCX, and JSON files.

**Usage:**
```
/pinecone:assistant-upload --assistant my-docs-assistant --source ./docs
```

#### `/pinecone:assistant-sync`

Sync local files with your assistant. Only uploads new or changed files (uses mtime and size detection). Optionally delete files from assistant that no longer exist locally.

**Usage:**
```
/pinecone:assistant-sync --assistant my-docs-assistant --source ./docs [--delete-missing] [--dry-run]
```

#### `/pinecone:assistant-chat`

Chat with your assistant and receive cited responses with page numbers and source references.

**Usage:**
```
/pinecone:assistant-chat --assistant my-docs-assistant --message "What is RAG?"
```

#### `/pinecone:assistant-context`

Retrieve relevant context snippets from your assistant without generating a full chat response. Useful for custom RAG workflows.

**Usage:**
```
/pinecone:assistant-context --assistant my-docs-assistant --query "embedding models" [--top-k 5]
```

#### `/pinecone:assistant-list`

List all assistants in your account with status, region, and file count details.

**Usage:**
```
/pinecone:assistant-list [--files]
```

#### Natural Language Support

The assistant skill automatically recognizes natural language requests without requiring slash commands:

- "Create a Pinecone assistant from my docs"
- "Upload my docs to the assistant"
- "Sync my documentation with the assistant"
- "Ask my assistant about authentication"
- "Search my assistant for information about embedding models"

The skill remembers the last assistant you used, so you can say "my assistant" or "it" in follow-up requests.

**Learn more:** https://docs.pinecone.io/guides/assistant/quickstart

## MCP Server Tools

The plugin includes the full Pinecone MCP Server with the following tools:

| Tool | Description |
|------|-------------|
| `list-indexes` | List all available Pinecone indexes |
| `describe-index` | Get index configuration and namespaces |
| `describe-index-stats` | Get statistics including record counts and namespaces |
| `search-records` | Search records with optional metadata filtering and reranking |
| `create-index-for-model` | Create a new index with integrated embeddings |
| `upsert-records` | Insert or update records in an index |
| `rerank-documents` | Rerank documents using a specified reranking model |

For complete MCP server documentation, visit: [Pinecone MCP Server Guide](https://docs.pinecone.io/guides/operations/mcp-server)

## Troubleshooting

### "API Key not found" or access errors

Make sure your `PINECONE_API_KEY` environment variable is set correctly:

```bash
echo $PINECONE_API_KEY
```

If it's empty, set it and restart Claude Code.

### MCP server not responding

1. Ensure you have Node.js installed (the MCP server runs via `npx`)
2. Check that your API key is valid
3. Restart Claude Code after setting environment variables

### Query command not working with my index

The `/query` command only works with **integrated indexes** that use Pinecone's hosted embedding models. If you're using external embedding providers (OpenAI, HuggingFace, etc.), you'll need to use the MCP tools directly or wait for expanded support.

### Assistant commands not working

Make sure you have uv installed. uv is required for all assistant commands:

```bash
# Verify uv is installed
uv --version

# Install if missing
curl -LsSf https://astral.sh/uv/install.sh | sh  # macOS/Linux
```

After installing uv, restart your terminal.

## Keywords

`pinecone` · `semantic search` · `vector search` · `vector database` · `retrieval` · `RAG` · `agentic RAG` · `sparse search` · `document Q&A` · `citations` · `assistant` · `managed RAG`

## License

MIT License – see [LICENSE](./LICENSE) for details.


**Have fun and enjoy developing with Pinecone!** 🌲
