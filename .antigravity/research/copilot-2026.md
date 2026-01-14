# Research Brief: GitHub Copilot (2026 Standards)

## 1. Core Evolution: The "Agentic" Shift
By 2026, Copilot has moved beyond simple autocomplete to a dual-mode operation:
*   **Copilot Edits:** A "Pair Programmer" for precise, multi-file edits controlled by the user. Ideal for refactoring specific functions or applying targeted fixes.
*   **Agentic Mode:** A "Robot Contractor" for autonomous task execution. Can plan multi-step workflows, run terminal commands, fix its own errors, and integrate with external tools via MCP.

## 2. Key Features to Document
*   **Autonomous Loop:** Agent mode iterates. It doesn't just suggest code; it runs it, checks errors, and fixes them.
*   **Terminal Integration:** Copilot can now build, test, and deploy directly from the CLI.
*   **MCP Integration:** This is critical. Copilot can now "see" outside the IDE (e.g., database schemas, logs) if provided with MCP servers.
*   **Cloud Agent:** New for 2026 (Preview), allowing offloading of heavy refactoring tasks to the cloud (async workers).

## 3. Best Practices (The "New Rules")
*   **Mode Selection:** Use 'Edits' for speed/precision, 'Agent' for complexity/exploration.
*   **Context:** Explicitly reference files (`#file`) is still good, but Agentic mode can self-assess context.
*   **Prompting:** For Agents, define the *Goal* and *Constraints*, not just the implementation step. "Fix the build" vs "Change line 10".

## 4. Updates Required
*   **Deprecated:** "Inline suggestions" are now just a baseline feature, not the headline.
*   **New/Critical:** Add a dedicated section on **Agentic Mode workflows** and **MCP setup** for Copilot.
*   **Terminology:** Distinguish clearly between "Edits" (Interactive) and "Agent" (Autonomous).

## 5. Source Links
- [GitHub Blog: Copilot Agentic Mode](https://github.blog)
- [Visual Studio 2026 Release Notes](https://visualstudio.com)
