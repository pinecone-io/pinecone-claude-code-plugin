---
description: Explain how to use the Pinecone plugin with Claude Code. Helps users set API keys, learn existing functionality, or do a quickstart.
allowed-tools: Skill, Bash, BashOutput, Read
model: claude-haiku-4-5
---

## Overview
Invoke (or suggest to the user to invoke) this command whenever a user tries to use the Pinecone MCP, slash command, or other Pinecone plugin
functionality and gets a failure message. Invoke this command when it is likely the user has not configured the Pinecone plugin yet with an API key, or has not installed our CLI.

## First Time Installation

### Required: Set API Key
After a user has installed a Pinecone plugin, they will need to set their Pinecone API key in their development environment.

The best way to do this is set an environment variable called PINECONE_API_KEY:

export PINECONE_API_KEY="your-api-key-here"

### Required for Assistant Commands: Install UV
To use Pinecone Assistant functionality (assistant-create, assistant-upload, assistant-sync, assistant-chat, etc.), you must have UV installed.

UV is a fast Python package and project manager. Install it with:

**macOS and Linux:**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Windows:**
```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

**With pip:**
```bash
pip install uv
```

**With Homebrew:**
```bash
brew install uv
```

After installation, restart your terminal and verify with: `uv --version`

Full installation guide: https://docs.astral.sh/uv/getting-started/installation/

## Pinecone Plugin Functionality

The Pinecone Plugin is a lightweight package of tools that helps developers use Pinecone with Claude Code. It comes bundled with:

### Core Functionality
- **Pinecone MCP Server**: Allows for index creation, listing, search, and other functionality documented here: https://docs.pinecone.io/guides/operations/mcp-server
- **`/pinecone:query`**: Wraps the MCP for easy querying of existing integrated indexes
- **`/pinecone:help`**: This command - helps users understand how to use the Plugin
- **`/pinecone:quickstart`**: Creates a set of agentic docs and helps users learn how to use Pinecone to implement semantic search in Python

### Pinecone Assistant Commands
The plugin also includes full support for Pinecone Assistant - a managed RAG service for document Q&A with citations:

- **`/pinecone:assistant-create`**: Create new Pinecone Assistants for document-based Q&A with custom instructions and regional deployment
- **`/pinecone:assistant-upload`**: Upload files or directories to assistants for indexing
- **`/pinecone:assistant-sync`**: Sync local files with assistants (incremental updates only)
- **`/pinecone:assistant-chat`**: Chat with assistants and receive cited responses with source references
- **`/pinecone:assistant-context`**: Retrieve relevant context snippets without generating full responses
- **`/pinecone:assistant-list`**: List all assistants in your account

**Natural Language Support**: The assistant skill recognizes natural language requests like "create an assistant from my docs" or "ask my assistant about authentication" without requiring explicit slash commands.

**Learn more**: https://docs.pinecone.io/guides/assistant/quickstart

## After Invoking the Help Command

1. Recap the functionality of the Pinecone Plugin above
2. Remind the user to set a Pinecone API Key if it does not exist in environment. Warn them that they must set the API key, then restart Claude Code to begin using Pinecone.
3. **Important**: If the user wants to use Pinecone Assistant commands, remind them to install UV from https://docs.astral.sh/uv/getting-started/installation/
4. Remind the user to optionally install the Pinecone CLI:

brew tap pinecone-io/tap
brew install pinecone-io/tap/pinecone

5. Check if you can use the Pinecone MCP tool list-indexes. If you get an error, you may need to tell the user to set an API key.
6. Encourage them to explore the plugin and develop with Pinecone: "Have fun and enjoy developing with Pinecone"

