# Changelog

## [1.5.0] - 2026-07-08
### Added
- **SessionStart auth-check hook**: On session start (and resume), the plugin checks your Pinecone setup and guides you through authentication if anything is missing.
  - Checks whether `PINECONE_API_KEY` is present and whether the Pinecone CLI (`pc`) is installed. 
  - Shows a friendly one-line status via `systemMessage`; hands Claude detailed next steps via `additionalContext`, including verifying the key is actually live via the MCP `list-indexes` tool on first Pinecone use, and pointing you at the `pinecone:quickstart` and `pinecone:cli` skills.
  - Stays quiet-but-visible when healthy; only prompts guidance when action is needed.
  - Silence it anytime with `export PINECONE_SKIP_AUTH_CHECK=1` (survives plugin updates).

## [1.4.1] - 2026-06-06
- Version bump and plugin metadata/keyword updates.

## [1.4.0] - 2026-06-06
- **New skill — full-text-search (FTS)**: end-to-end workflow for Pinecone's full-text-search preview API (`2026-01.alpha`) — document schema design, safe bulk ingestion, and `documents.search(...)` query construction (BM25 `text`/`query_string`, `dense_vector`/`sparse_vector` scoring, and `$match_phrase`/`$match_all`/`$match_any` text-match filters).
- Updates across the rest of the plugin to accompany the new skill.

## [1.3.0] - 2026-03-06
- source tag fixes

## [1.2.0] - 2026-03-04
- contextualize: adapt synced skills for this plugin
- refactor: consolidate skills, remove redundant commands, add cli/mcp/…
- contextualize: adapt synced skills for this plugin
- fix: repair broken triple-quoted strings in assistant scripts
- fix: quickstart prereq uses MCP list-indexes instead of echo, add mis…
- refactor: rename skill directories to remove pinecone- prefix
- fix: improve release and contextualize workflows
- fix: generate changelog from commit messages instead of PR body
## [1.1.2] - 2026-01-27
### Fixed

More issues with script path resolution
- explictly added invocation of assistant skill before subcommands
- explictly added permissions for skill usage
- passes internal testing


## [1.1.1] - 2026-01-26

### Fixed
- **Script Path Resolution**: Fixed script paths to use correct relative paths for marketplace installation
  - SKILL.md now uses `scripts/` (relative to skill directory)
  - Commands now use `skills/assistant/scripts/` (relative to plugin root)
  - Added documentation note explaining path structure
  - Scripts now properly accessible when plugin is installed from marketplace

## [1.1.0] - 2026-01-26

### Added

#### Pinecone Assistant Integration
- **New Skill**: Full Pinecone Assistant skill with natural language support for creating, managing, and chatting with document-based Q&A assistants
- **Natural Language Mode**: Proactive recognition of assistant-related requests without requiring slash commands
- **Conversation Memory**: Tracks last assistant used for seamless multi-turn interactions

#### New Commands
- **`/pinecone:assistant-create`** - Create new Pinecone Assistants with custom configuration, instructions, and regional deployment
- **`/pinecone:assistant-upload`** - Upload files or entire directories to assistants for document Q&A
- **`/pinecone:assistant-sync`** - Sync local files with assistants (only uploads new/changed files, with optional deletion of missing files)
- **`/pinecone:assistant-chat`** - Chat with assistants and receive cited responses with source references
- **`/pinecone:assistant-context`** - Retrieve relevant context snippets without generating full chat responses
- **`/pinecone:assistant-list`** - List all assistants in your account with status and configuration details
- **`/pinecone:join-discord`** - Opens link to join the Pinecone Discord community for help, support, and connecting with the Pinecone team


#### Python Scripts
- `skills/assistant/scripts/create.py` - Assistant creation script
- `skills/assistant/scripts/upload.py` - File upload script
- `skills/assistant/scripts/sync.py` - Incremental sync script
- `skills/assistant/scripts/chat.py` - Interactive chat script with citations
- `skills/assistant/scripts/context.py` - Context retrieval script
- `skills/assistant/scripts/list.py` - List assistants script

## [1.0.0] - 2026-01-06

### Added

#### Core Plugin Features
- **Pinecone MCP Server Integration**: Full integration with the Pinecone Model Context Protocol server for seamless vector database operations
- **Slash Commands**: Quick access to common Pinecone operations directly from Claude Code
- **Semantic Search**: Query vector indexes using natural language

#### Available Commands
- **`/pinecone:help`** - Display help information, API key configuration instructions, and troubleshooting tips
- **`/pinecone:quickstart`** - Interactive quickstart tutorial that:
  - Downloads and generates an AGENTS.md file optimized for Claude Code
  - Walks through Python quickstart tutorial
  - Guides through first index creation and semantic search setup
- **`/pinecone:query`** - Query Pinecone indexes using natural language with support for:
  - Index and namespace selection
  - Optional reranking models for improved relevance
  - Interactive guidance for missing parameters
  - Only works with integrated indexes using Pinecone hosted embedding models

#### MCP Server Tools
- **`list-indexes`** - List all available Pinecone indexes
- **`describe-index`** - Get index configuration and namespaces
- **`describe-index-stats`** - Get statistics including record counts and namespaces
- **`search-records`** - Search records with optional metadata filtering and reranking
- **`create-index-for-model`** - Create new indexes with integrated embeddings
- **`upsert-records`** - Insert or update records in an index
- **`rerank-documents`** - Rerank documents using specified reranking models
- **`search-docs`** - Search Pinecone documentation for relevant information

**Note**: For installation instructions and detailed usage, see [README.md](./README.md)
