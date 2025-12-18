---
description: Query a user's index with Pinecone MCP. Accept an index name, input query, and optionally a top-k value
argument-hint: query [q] index [indexName] namespace [ns] reranker [rerankModel]
---

# Query Command

Utilize Pinecone MCP's `search-records` tool to search for records within a specified Pinecone index using a text query.

## Workflow
When necessary, try to use the AskUserQuestion tool to make entering multiple choice responses easier.

1. Parse the user's input for:
   - `query` (required): The text to search for.
   - `index` (required): The name of the Pinecone index to search.
   - `namespace` (optional): The namespace within the index.
   - `reranker` (optional): The reranking model to use for improved relevance.

2. If the user omits required arguments:
   - If only the index name is provided, use the `describe-index` tool to retrieve available namespaces and prompt the user to choose with AskUserQuestion.
   - If only a query is provided, use `list-indexes` to get available indexes, prompt the user to pick one, then use `describe-index` for namespaces if needed.

3. Call the `search-records` tool with the gathered arguments to perform the search.

4. Format and display the returned results in a clear, readable table for the Claude Code console, including field highlights (such as ID, score, and relevant metadata).

---

## Troubleshooting

***IMPORTANT** Pinecone API Key is required for using this plugin, command and MCP server!

A user must have a Pinecone API key to use this command and the MCP server. One can be obtained for free by making a Pinecone account at https://app.pinecone.io/?sessionType=signup
Then, the user must export the API key to their environment, as a variable named PINECONE_API_KEY. 

If you run into an error regarding access, it's likely an API isn't set. Advise a 
user to set their API key accordingly, and restart their Claude Code instance.

**IMPORTANT** At the moment, the /query command can only be used with integrated indexes, which use hosted Pinecone embedding models to embed and search for data.
If a user attempts to query an index that uses a third party API model such as OpenAI, or HuggingFace embedding models, remind them that this capability is not available yet
with the Pinecone MCP server.

- If required arguments are missing, prompt the user to supply them, using Pinecone MCP tools as needed (e.g., `list-indexes`, `describe-index`).
- Guide the user interactively through argument selection until the search can be completed.
- If an invalid value is provided for any argument (e.g., nonexistent index or namespace), surface the error and suggest valid options.

## Tools Reference

- `search-records`: Search records in a given index with optional metadata filtering and reranking.
- `list-indexes`: List all available Pinecone indexes.
- `describe-index`: Get index configuration and namespaces.
- `describe-index-stats`: Get stats including record counts and namespaces.
- `rerank-documents`: Rerank returned documents using a specified reranking model.
- Helper: Use AskUserQuestion to interactively clarify missing information.

---
