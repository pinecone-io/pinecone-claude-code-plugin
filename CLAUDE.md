# Claude Code Plugin — Skill Conventions

This file tells Claude how to adapt incoming skills from the base Pinecone skills repo for use in this Claude Code plugin.

## Context

This is the Pinecone Claude Code plugin. Skills here are invoked by Claude Code users via the plugin system. The base skills repo is environment-agnostic — this file describes what to change when adapting those skills for Claude Code specifically.

---

## Skill Naming

The base repo uses hyphenated names like `pinecone-quickstart`. Claude Code uses colon-namespaced names like `pinecone:quickstart`.

Replace the `pinecone-` prefix with `pinecone:` in the `name` frontmatter field and in any cross-references between skills throughout the content.

Rename skill directories to strip the `pinecone-` prefix — the plugin already namespaces with `pinecone:`, so the directory should just be the skill name (e.g., `assistant/`, `quickstart/`, `cli/`).

---

## AskUserQuestion

The base skills use plain prose like "ask the user which path they want" to stay generic. In Claude Code, replace these with the `AskUserQuestion` tool where it improves the interaction — multi-choice selections, confirmations before running scripts, etc.

---

## Environment Variables

The base skills include `.env` file fallback instructions for IDEs that don't inherit shell variables. Claude Code runs in the user's terminal session and inherits the shell environment, so:

- Keep the primary `export PINECONE_API_KEY="your-key"` instruction
- Remove or de-emphasize the `.env` fallback — condense to a one-liner note at most

---

## allowed-tools

The base skills don't include an `allowed-tools` frontmatter field. Add it when adapting skills for Claude Code.

For skills that invoke other skills, always include `Skill` in `allowed-tools`:

```
allowed-tools: Skill, Bash, Read
```

If a skill only calls specific sub-skills, scope it:

```
allowed-tools: Skill(pinecone:assistant *), Bash, Read
```

---

## MCP

You can safely assume the Pinecone MCP will be installed if a user installs the Claude Code Plugin. Check the .mcp.json file if in doubt.

---

## Source Tags

All Python scripts that create a `Pinecone()` client must include a `source_tag` to attribute usage to this plugin. See [Pinecone docs on source tags](https://docs.pinecone.io/integrations/build-integration/attribute-usage-to-your-integration).

Use the format: `claude_code_plugin:<skill>` or `claude_code_plugin:<skill>_<operation>` — add the operation suffix when it helps distinguish scripts within the same skill.

Only lowercase letters, numbers, underscores, and colons are allowed — no spaces, hyphens, or uppercase.

Examples:
```python
pc = Pinecone(api_key=api_key, source_tag="claude_code_plugin:assistant")
pc = Pinecone(api_key=api_key, source_tag="claude_code_plugin:quickstart_upsert")
```

The base skills repo may use generic source tags like `pinecone_skills:*`. When adapting for Claude Code, replace these with the `claude_code_plugin:` prefix.

---
