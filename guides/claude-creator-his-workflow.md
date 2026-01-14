# Mastering Claude Code: A Guide from the Creator

This guide summarizes the setup, workflow, and tips shared by Boris, the creator of Claude Code. It's designed to help you maximize your productivity by leveraging parallel execution, seamless handoffs, and robust verification strategies.

> [!NOTE]
> This guide is based on insights from Boris's personal workflow. Adoption of these practices can significantly enhance your agentic coding experience.

## 1. The Multi-Instance Workflow
Boris emphasizes a workflow that prioritizes parallel execution to overcome the "waiting game" of single-threaded agents.

- **Parallel Processing**: Run multiple Claude sessions (Boris uses ~5) in separate terminal tabs.
- **Isolation is Key**: Use a separate git checkout (e.g., `git worktree` or separate clones) for each active Claude instance.
  - *Why?* This prevents file conflicts and ensures each agent operates in a clean, isolated environment without stepping on another agent's toes.
- **Stay Alert**: Configure system notifications (like iTerm2 alerts) to notify you when a background instance finishes a task or requires input.

## 2. Seamless Handoff: CLI to Web
Claude Code is designed to work where you are, whether that's deep in the terminal or reviewing on the web.

- **Teleporting**: Use the `&` command to "teleport" a local terminal session to the web interface (`claude.ai/code`).
  - *Use Case*: When you need a richer UI for reviewing complex plans or changes.
- **Sync Back**: Use `--teleport` to pull the session back to your CLI or to sync context across environments.
- **Mobile Monitoring**: Use the Claude iOS app to keep an eye on long-running local sessions when you step away from your desk.

## 3. Planning & Configuration Rules
A little preparation goes a long way in preventing "agent drift".

- **Plan Mode First**: deeply ingrained habit: always start a complex task in **Plan Mode**.
  - **Action**: Press **`Shift+Tab`** twice.
  - *Benefit*: This forces Claude to think through the architecture and create a plan *before* writing a single line of code.
- **Shared Context (`CLAUDE.md`)**: Create a `CLAUDE.md` file in the root of your repository.
  - *Content*: Add team-wide coding standards, architectural decisions, and project context. This acts as a "long-term memory" for every new Claude instance.
- **Custom Commands**: Define custom slash commands in `.claude/commands/` for repetitive tasks specific to your project.
- **Permissions**: Use `/permissions` to pre-approve specific commands (like tests or linters) to reduce friction and interruptions.

## 4. Verification: The "Secret Sauce"
The most critical part of an autonomous workflow is verification.

- **Close the Loop**: Always give Claude the ability to verify its own work.
  - **Server-side**: Provide tools to start/restart the server or run specific test suites.
  - **Client-side**: Give Claude access to a browser tool or extension to interact with the UI and verify changes visually or functionally.
- **Subagents**: Utilize specialized subagents for distinct tasks (e.g., a "refactoring agent" or a "verification agent") to keep the main context clean and focused.

## 5. Advanced Configuration
- **Thinking Mode**: Boris keeps "Thinking" mode **ON** by default (often using internal models like Opus 4.5).
  - *Trade-off*: It's slower, but the enhanced steerability and reasoning capability are worth it for complex coding tasks.
- **MCP Servers**: Connect Claude to your external tools (Slack, Sentry, BigQuery) using [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) servers.
- **Hooks**: particular useful for automation, such as `PostToolUse` hooks for running formatters (like Prettier or Black) immediately after Claude edits a file.

## Quick Reference: Key Bindings & Commands

| Action | Command / Key |
| :--- | :--- |
| **Enter Plan Mode** | `Shift+Tab` (twice) |
| **Teleport to Web** | `&` |
| **Sync Session** | `--teleport` |
| **Silent Permissions** | `--permission-mode=dontAsk` |
| **Manage Permissions** | `/permissions` |

---
**Summary**: Treat Claude not just as a chatbot, but as a junior developer that runs in parallel. Isolate its environments, force it to plan, and most importantly, give it the tools to verify its own work.
