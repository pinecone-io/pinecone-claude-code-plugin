---
name: pinecone:mcp
description: Reference for the Pinecone MCP server tools. Documents all available tools - list-indexes, describe-index, describe-index-stats, create-index-for-model, upsert-records, search-records, cascading-search, and rerank-documents. Use when an agent needs to understand what Pinecone MCP tools are available, how to use them, or what parameters they accept.
allowed-tools: Read
---

# Pinecone MCP Tools Reference

The Pinecone MCP server exposes the following tools to AI agents and IDEs. For setup and installation instructions, see the [MCP server guide](https://docs.pinecone.io/guides/operations/mcp-server#tools).

> **Key Limitation:** The Pinecone MCP only supports **integrated indexes** — indexes created with a built-in Pinecone embedding model. It does not work with standard indexes using external embedding models. For those, use the Pinecone CLI.

---

## `list-indexes`

List all indexes in the current Pinecone project.

---

## `describe-index`

Get configuration details for a specific index — cloud, region, dimension, metric, embedding model, field map, and status.

**Parameters:**
- `name` (required) — Index name

---

## `describe-index-stats`

Get statistics for an index including total record count and per-namespace breakdown.

**Parameters:**
- `name` (required) — Index name

---

## `create-index-for-model`

Create a new serverless index with an integrated embedding model. Pinecone handles embedding automatically — no external model needed.

**Parameters:**
- `name` (required) — Index name
- `cloud` (required) — `aws`, `gcp`, or `azure`
- `region` (required) — Cloud region (e.g. `us-east-1`)
- `embed.model` (required) — Embedding model: `llama-text-embed-v2`, `multilingual-e5-large`, or `pinecone-sparse-english-v0`
- `embed.fieldMap.text` (required) — The record field that contains text to embed (e.g. `chunk_text`)

---

## `upsert-records`

Insert or update records in an integrated index. Records are automatically embedded using the index's configured model.

**Parameters:**
- `name` (required) — Index name
- `namespace` (required) — Namespace to upsert into
- `records` (required) — Array of records. Each record must have an `id` or `_id` field and contain the text field specified in the index's `fieldMap`. Do not nest fields under `metadata` — put them directly on the record.

**Example record:**
```json
{ "_id": "rec1", "chunk_text": "The Eiffel Tower was built in 1889.", "category": "architecture" }
```

---

## `search-records`

Semantic text search against an integrated index. Pass plain text — the MCP embeds the query automatically using the index's model.

**Parameters:**
- `name` (required) — Index name
- `namespace` (required) — Namespace to search
- `query.inputs.text` (required) — The text query
- `query.topK` (required) — Number of results to return
- `query.filter` (optional) — Metadata filter using MongoDB-style operators (`$eq`, `$ne`, `$in`, `$gt`, `$gte`, `$lt`, `$lte`)
- `rerank.model` (optional) — Reranking model: `bge-reranker-v2-m3`, `cohere-rerank-3.5`, or `pinecone-rerank-v0`
- `rerank.rankFields` (optional) — Fields to rerank on (e.g. `["chunk_text"]`)
- `rerank.topN` (optional) — Number of results to return after reranking

---

## `cascading-search`

Search across multiple indexes simultaneously, then deduplicate and rerank results into a single ranked list.

**Parameters:**
- `indexes` (required) — Array of `{ name, namespace }` objects to search across
- `query.inputs.text` (required) — The text query
- `query.topK` (required) — Number of results to retrieve per index before reranking
- `rerank.model` (required) — Reranking model: `bge-reranker-v2-m3`, `cohere-rerank-3.5`, or `pinecone-rerank-v0`
- `rerank.rankFields` (required) — Fields to rerank on
- `rerank.topN` (optional) — Final number of results to return after reranking

---

## `rerank-documents`

Rerank a set of documents or records against a query without performing a vector search first.

**Parameters:**
- `model` (required) — `bge-reranker-v2-m3`, `cohere-rerank-3.5`, or `pinecone-rerank-v0`
- `query` (required) — The query to rerank against
- `documents` (required) — Array of strings or records to rerank
- `options.topN` (required) — Number of results to return
- `options.rankFields` (optional) — If documents are records, the field(s) to rerank on
