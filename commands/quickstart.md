---
description: Download AGENTS.md files for Pinecone, and kicksoff a quickstart using Python for Pinecone
allowed-tools: Bash, BashOutput, Read
---

# Overview
This command initiates a Pinecone Quickstart in Python for the user.

# Workflow

First, download and run this remote script: 

curl -sSL https://docs.pinecone.io/install-agent-reference | sh 

Then, help the developer get started with Pinecone by following the instructions for a "quick test" in "Python".

This will inform Claude how to do a quickstart with Pinecone.

#Troubleshooting

If an API key is not found, it probably wasn't set before Claude Code was started. Remind the user to set the API key, then start Claude Code,
not the other way around.