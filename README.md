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

## Available Skills

### `/pinecone:help`

Overview of all available Pinecone skills and what you need to get started. Run this when first installing the plugin.

### `/pinecone:quickstart`

Interactive quickstart for new developers. Choose between two paths:
- **Database** — Create an integrated index, upsert data, and query using Pinecone MCP + Python
- **Assistant** — Create a Pinecone Assistant for document Q&A with citations

### `/pinecone:query`

Query integrated indexes using natural language. Wraps the Pinecone MCP server for easy searching.

```
/pinecone:query query [your search text] index [indexName] namespace [ns] reranker [rerankModel]
```

> **Note:** Only works with integrated indexes that use Pinecone's hosted embedding models.

### `/pinecone:full-text-search`

End-to-end workflow for Pinecone's full-text-search (FTS) preview API (`2026-01.alpha`) — design a document schema, ingest a corpus, and construct `documents.search(...)` calls. Covers BM25 (`text` / `query_string`), `dense_vector` and `sparse_vector` scoring, and text-match filters (`$match_phrase` / `$match_all` / `$match_any`) for hybrid lexical+semantic queries.

Ships a `scripts/ingest.py` helper that does bulk `batch_upsert` with per-batch error inspection and post-upsert readiness polling — the three things bare-LLM ingest code reliably skips.

> **Requires `pinecone` Python SDK ≥ 9.0.** The FTS document-schema API lives under `pinecone.preview`.

### `/pinecone:assistant`

All-in-one skill for Pinecone Assistants — create, upload, sync, chat, context retrieval, and list. Works with both slash commands and natural language:

- "Create a Pinecone assistant from my docs"
- "Upload files from ./docs to my-assistant"
- "Sync my assistant with the docs folder"
- "Ask my assistant about authentication"
- "Search my assistant for context about embeddings"

**Learn more:** https://docs.pinecone.io/guides/assistant/quickstart

### `/pinecone:cli`

Guide for using the Pinecone CLI (`pc`) to manage resources from the terminal. The CLI supports all index types and vector operations.

### `/pinecone:mcp`

Reference for all Pinecone MCP server tools — parameters, usage, and examples.

### `/pinecone:docs`

Curated documentation reference with links to official docs organized by topic and data format references.

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
