# Research Brief: Model Context Protocol (MCP)

## 1. What is MCP (2026 Status)?
MCP is the industry standard for connecting AI agents to external systems ("data silos"). It allows Copilot (and other agents) to:
- Read resources (logs, docs, DB rows).
- Execute tools (API calls, scripts).
- Use prompts (standardized workflows).

## 2. Architecture & Components
- **Host:** The IDE (VS Code, Cursor, Windsurf).
- **Server:** The connector (e.g., "Postgres MCP", "Sentry MCP").
- **Client:** The bridge inside the Host.
- **Transport:** Now standardized on **Streamable HTTP** for remote/production and `stdio` for local.

## 3. Best Practices for Documentation
- **Security First:** 2026 focus is on Access Control (ACLs). Docs must warn about giving Agents "write" access to production tools.
- **Agentic Workflows:** Don't just "install code". Use "Coordinator Agents" that dynamically load tools.
- **Tool Naming:** Tools must have descriptive names/docstrings so agents know *when* to use them.

## 4. Documentation Strategy
- **New Section:** "Extending Copilot with MCP".
- **Tutorial:** How to set up a basic MCP server (e.g., `sqlite` or `fetch`).
- **Safety Warning:** "The Agent is only as safe as the Tools you give it."

## 5. Source Links
- [Model Context Protocol Official Site](https://modelcontextprotocol.io)
- [Anthropic MCP Specs](https://anthropic.com)
