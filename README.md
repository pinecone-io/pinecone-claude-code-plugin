# Pinecone Plugin for Claude Code

A lightweight plugin that integrates [Pinecone](https://www.pinecone.io/) vector database capabilities directly into Claude Code, enabling semantic search, index management, and RAG (Retrieval Augmented Generation) workflows.

## Features

- **Pinecone MCP Server** – Full integration with the Pinecone Model Context Protocol server for index creation, listing, searching, and more
- **Slash Commands** – Quick access to common Pinecone operations directly from Claude Code
- **Semantic Search** – Query your vector indexes using natural language

## Installation

### Step 1: Add the Pinecone Marketplace

Open Claude Code and add the Pinecone plugin marketplace:

```
/plugin marketplace add pinecone-io/pinecone-claude-code-plugin
```

### Step 2: Install the Plugin

Install the Pinecone plugin interactively:

```
/plugin install pinecone@pinecone-claude-code-plugin
```

When prompted, select your preferred installation scope:
- **User scope** (default) – Available across all your projects
- **Project scope** – Shared with your team via version control
- **Local scope** – Project-specific, not shared (gitignored)

After installation, restart Claude Code to activate the plugin.

### Step 3: Set Your API Key

After installing the plugin, you'll need to configure your Pinecone API key:

```bash
export PINECONE_API_KEY="your-api-key-here"
```

> **Don't have a Pinecone account?** Sign up for free at [app.pinecone.io](https://app.pinecone.io/?sessionType=signup)


### Optional: Install the Pinecone CLI

For additional command-line capabilities, install the Pinecone CLI:

```bash
brew tap pinecone-io/tap
brew install pinecone-io/tap/pinecone
```

## Available Commands

### `/pinecone:query`

Query your Pinecone indexes using natural language. This command wraps the MCP server for easy searching of integrated indexes.

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

### `/pinecone:quickstart`

Get started quickly with Pinecone! This command:
1. Downloads agentic documentation for Pinecone
2. Walks you through a Python quickstart tutorial
3. Helps you create your first index and perform semantic searches

### `/pinecone:help`

Display help information about the plugin, including:
- Available functionality
- API key configuration
- Troubleshooting tips

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

## Keywords

`pinecone` · `semantic search` · `vector search` · `vector database` · `retrieval` · `RAG` · `agentic RAG` · `sparse search`

## License

MIT License – see [LICENSE](./LICENSE) for details.

## Author

Arjun Patel

---

**Have fun and enjoy developing with Pinecone!** 🌲
