# The Complete Guide to Global CLAUDE.md

This guide explains how to set up and use a "Global" `CLAUDE.md` file to enforce standards, improve security, and automate project setup across all your work with Claude Code.

## 1. The Memory Hierarchy
Claude Code processes instructions in a specific order of precedence. Understanding this hierarchy allows you to cascade rules effectively.

| Priority | Scope | Path (Linux/Mac) | Purpose |
| :--- | :--- | :--- | :--- |
| **1** | **Enterprise/System** | `/etc/claude-code/CLAUDE.md` | Mandatory company-wide policies (Startups/Enterprises). |
| **2** | **Global User** | `~/.claude/CLAUDE.md` | **Your personal standards**, security rules, and scaffolding. |
| **3** | **Project Root** | `./CLAUDE.md` | Specific tech stack, build commands, and architecture for the current project. |
| **4** | **Project Local** | `./CLAUDE.local.md` | Non-committed, user-specific overrides (e.g., "I use VS Code, not Vim"). |

> [!IMPORTANT]
> Instructions in a higher priority file (lower number) generally override or set the baseline for those below it.

## 2. Setting Up Your Global File
On Linux and macOS, the global configuration lives in your home directory.

1.  **Create the directory:**
    ```bash
    mkdir -p ~/.claude
    ```
2.  **Create the file:**
    ```bash
    touch ~/.claude/CLAUDE.md
    ```

## 3. The "Rule of Thumb": Global vs. Local
Deciding where to put an instruction is simple if you follow this rule:

- **Global (`~/.claude/CLAUDE.md`) is for STANDARDS.**
  - Identity & Auth (How you want to be addressed).
  - Security Gatekeepers (Universal "Never do this" rules).
  - Scaffolding (How to build *new* projects).
  - Broad preference (e.g., "Always use TypeScript").

- **Local (`./CLAUDE.md`) is for CONTEXT.**
  - Specific Tech Stack (React, Vue, Django).
  - Project Logic & Architecture.
  - Unique Constraints.

## 4. Essential Global Sections
Here are the recommended sections to include in your global file.

### A. Security Gatekeeper Rules
These rules apply to *every* project you touch, ensuring you never accidentally leak secrets.

```markdown
## Security Gatekeeper Rules
1. **NEVER** publish sensitive data, API keys, or credentials.
2. **NEVER** commit `.env` files to version control.
3. **ALWAYS** create a `.env.example` file when creating or modifying `.env`.
4. **NEVER** hardcode credentials; always use environment variables.
```

### B. New Project Scaffolding
Teach Claude how to start a project "The Right Way™" so you don't have to manually set up boilerplates.

```markdown
## New Project Scaffolding Standards
When creating a new project from scratch:
1. **Initialize Git**: Run `git init` and create a `.gitignore` immediately.
   - Include: `.env`, `node_modules`, `dist`, `__pycache__`, etc.
2. **Directory Structure**: Create a standard folder layout (e.g., `/src`, `/tests`, `/docs`).
3. **Generate Local Config**: Create a `./CLAUDE.md` file in the root with:
   - Project Overview
   - Tech Stack details
   - Build & Test commands
   - Architecture summary
```

### C. Framework-Specific Scaffolding (Optional)
If you frequently use specific stacks, define their "Golden Paths" here.

```markdown
### Node.js Standards
- Ensure all entry points access environment variables safely.
- Use `npm ci` for CI/CD environments.

### Python Standards
- Prefer `pyproject.toml` over `setup.py`.
- Always use a virtual environment (`venv`).
```

## Summary
By setting up a Global `CLAUDE.md`, you turn Claude Code from a blank slate into a seasoned developer that already knows your style, security requirements, and project setup preferences before you even type your first prompt.

