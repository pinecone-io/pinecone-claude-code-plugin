---
description: Explain how to use the Pinecone plugin with Claude Code. Helps users set API keys, learn existing functionality, or do a quickstart.
allowed-tools: Bash, BashOutput, Read
model: claude-haiku-4-5
---

## Overview
Invoke (or suggest to the user to invoke) this command whenever a user tries to use the Pinecone MCP, slash command, or other Pinecone plugin
functionality and gets a failure message. Invoke this command when it is likely the user has not configured the Pinecone plugin yet with an API key, or has not installed our CLI.

## First Time Installation
After a user has installed a Pinecone plugin, they will need to set their Pinecone API key in their development environment.

The best way to do this is set an environment variable called PINECONE_API_KEY:

export PINECONE_API_KEY="your-api-key-here"

## Pinecone Plugin Functionality

The Pinecone Plugin is a lightweight package of tools that helps developers use Pinecone with Claude Code. It comes bundled with:

- the Pinecone MCP Server, which allows for index creation, listing, search, and other functionality documented here: https://docs.pinecone.io/guides/operations/mcp-server
- the /query slash command, which wraps the MCP for easy querying of existing integrated indexes
- this /help command, which helps users understand how to use the Plugin
- the /quickstart command, which creates a set of agentic docs for users, and helps users learn how to use Pinecone to implement a semantic search in Python.

## After Invoking the Help Command

1. Recap the functionality of the Pinecone Plugin above
2. Remind the user to set a Pinecone API Key if does not exist in environment. Warn them that they must set the API key, then start Claude Code to begin using Pinecone. 
3. Remind the user to optionally install the Pinecone cli optionally:

brew tap pinecone-io/tap
brew install pinecone-io/tap/pinecone

4. Check if you can use the Pinecone MCP tool list-indexes. If you get an error, you may need to tell the user to set an API key.
5. Encourage them explore the plugin and develop with Pinecone: "Have fun and enjoy developing with Pinecone"

