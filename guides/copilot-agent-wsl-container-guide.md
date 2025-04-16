# GitHub Copilot Agent Mode: Complete Setup Guide for WSL and Containers

This comprehensive guide will help you set up GitHub Copilot Agent Mode for effective operation with WSL (Windows Subsystem for Linux) and containers, with special attention to running tests and resolving common issues.

## Table of Contents

- [Understanding Copilot Agent Mode](#understanding-copilot-agent-mode)
- [Basic Setup for VS Code and WSL](#basic-setup-for-vs-code-and-wsl)
- [Configuring Copilot Agent Mode](#configuring-copilot-agent-mode)
- [Working with WSL Terminals](#working-with-wsl-terminals)
- [Container Integration Strategies](#container-integration-strategies)
- [Running Tests with Maven](#running-tests-with-maven)
- [Troubleshooting Common Issues](#troubleshooting-common-issues)
- [Advanced Configuration](#advanced-configuration)

## Understanding Copilot Agent Mode

GitHub Copilot Agent Mode is an advanced capability that allows Copilot to work more autonomously. Unlike regular Copilot, Agent Mode can:

- Analyze your codebase to understand context
- Make changes across multiple files
- Execute terminal commands
- Monitor command outputs and errors
- Auto-correct issues it encounters

Agent Mode operates in loops:
1. Read and understand the context
2. Apply changes to files
3. Execute terminal commands
4. Analyze results
5. Make corrections based on feedback

## Basic Setup for VS Code and WSL

### Prerequisites

- Windows 10/11 with WSL2 installed
- Visual Studio Code
- GitHub account with Copilot subscription
- Git configured in your WSL environment

### Step 1: Install Required VS Code Extensions

1. Open VS Code and navigate to Extensions (Ctrl+Shift+X)
2. Install the following extensions:
   - GitHub Copilot
   - GitHub Copilot Chat
   - Remote - WSL

### Step 2: Set Up WSL Development Environment

1. Open VS Code and use the command palette (Ctrl+Shift+P)
2. Type and select "Remote-WSL: New Window"
3. This opens VS Code connected to your WSL environment
4. Verify the connection in the bottom-left corner (should show "WSL")

### Step 3: GitHub Authentication in WSL

1. In your WSL VS Code window, open a terminal (Ctrl+`)
2. Run: `gh auth login`
3. Follow prompts to authenticate with GitHub
4. Verify authentication with: `gh auth status`

## Configuring Copilot Agent Mode

### Step 1: Enable Agent Mode

1. In VS Code (WSL window), open Settings (Ctrl+,)
2. Search for "github.copilot.chat.agent.enabled"
3. Check the box to enable Agent Mode
4. Alternatively, you can add this to your settings.json:
   ```json
   "github.copilot.chat.agent.enabled": true
   ```

### Step 2: Configure GitHub Copilot Chat

1. In VS Code (WSL window), open the Command Palette (Ctrl+Shift+P)
2. Type and select "GitHub Copilot: Sign In"
3. Complete the authentication process
4. Open GitHub Copilot Chat (Ctrl+Shift+I or through the Copilot icon)
5. Select "Agent" from the dropdown menu in the chat interface

### Step 3: Configure Tool Permissions

1. In Settings, search for "github.copilot.chat.agent.runTasks"
2. Ensure it's enabled to allow Agent Mode to run workspace tasks
3. Search for "github.copilot.chat.agent.terminals" settings
4. Configure according to your security preferences

## Working with WSL Terminals

### Setting Up the Integrated Terminal

1. Open a terminal in VS Code (Ctrl+`)
2. Verify it's running in WSL (should show your Linux distro)
3. Configure the default terminal profile:
   - Open Settings (Ctrl+,)
   - Search for "terminal.integrated.defaultProfile.windows"
   - Set it to "WSL"

### Optimizing Terminal Interaction

1. Configure terminal to use simple output when possible:
   - Avoid complex terminal programs (like htop, vim, etc.) during Agent Mode sessions
   - Use `-B` or `--batch-mode` flags with Maven commands
   - Add `--no-color` flags to commands that support them

2. Ensure consistent terminal output:
   - Avoid aliases that change command outputs
   - Use full command paths when necessary
   - Set `TERM=dumb` for simpler terminal output when using Agent Mode

## Container Integration Strategies

Since Copilot Agent Mode has limitations with containers, here are strategies to work effectively:

### Method 1: Container Command Wrapper Script

Create a wrapper script in WSL that manages container interactions:

1. Create a file called `container-run.sh`:
   ```bash
   #!/bin/bash
   # This script executes commands in a container and captures output
   
   CONTAINER_NAME=$1
   COMMAND="${@:2}"
   
   # Run command in container and capture output to a file
   docker exec $CONTAINER_NAME bash -c "$COMMAND" | tee /tmp/container-output.txt
   
   # Return the exit code of the command
   exit ${PIPESTATUS[0]}
   ```

2. Make it executable:
   ```bash
   chmod +x container-run.sh
   ```

3. Use it with Copilot Agent:
   ```bash
   ./container-run.sh my-container "cd /app && mvn test -B"
   ```

4. Let Agent Mode read the output file if needed:
   ```bash
   cat /tmp/container-output.txt
   ```

### Method 2: Mount Working Directory

For development containers, mount your working directory:

1. Start container with your working directory mounted:
   ```bash
   docker run -it -v $(pwd):/workspace -w /workspace my-image bash
   ```

2. This allows Agent Mode to make changes directly to files that are visible inside the container

3. Run commands in the container manually, after Agent Mode makes code changes

### Method 3: VSCode Dev Containers

For the most integrated experience:

1. Install the "Remote - Containers" VS Code extension
2. Create a `.devcontainer` configuration for your project
3. Reopen in container using VS Code
4. Use Agent Mode directly in the containerized VS Code

## Running Tests with Maven

### Optimizing Maven for Agent Mode

1. Always use batch mode:
   ```bash
   mvn test -B
   ```

2. Generate detailed output logs:
   ```bash
   mvn test -B -X
   ```

3. Output test results to a file:
   ```bash
   mvn test -B > test-results.txt
   ```

### Why Maven Batch Mode (-B) Helps

The `-B` or `--batch-mode` flag improves Agent Mode interaction by:

- Disabling colored output that can confuse parsing
- Eliminating interactive prompts that could cause hanging
- Producing consistent, predictable output formatting
- Ensuring all output goes directly to stdout/stderr
- Reducing terminal control sequences that might interfere with parsing

## Troubleshooting Common Issues

### Terminal Hangs with "Running command in terminal..."

This is a known issue where Agent Mode gets stuck while executing terminal commands.

**Solutions:**
1. Cancel the operation using the stop button
2. Divide your task into smaller steps:
   - First, have Agent Mode generate the test files
   - Then, manually run the tests
   - Finally, ask Agent Mode to analyze the results

3. Try restarting VS Code to reset the Agent Mode session

### Agent Mode Can't See Test Results

If Agent Mode can't properly detect test completions:

1. Redirect test output to a file:
   ```bash
   mvn test -B > test-results.txt
   ```

2. Ask Agent Mode to analyze the file contents:
   ```
   Can you analyze the test results in test-results.txt?
   ```

### WSL Connection Issues

If you experience intermittent WSL connectivity:

1. Restart the WSL VS Code window
2. Check your WSL distribution status:
   ```bash
   wsl --status
   ```

3. Restart WSL if needed:
   ```bash
   wsl --shutdown
   ```

4. Try a different VS Code window

## Advanced Configuration

### Custom Instructions File

Create a `.github/copilot-instructions.md` file in your repository with specific instructions for Agent Mode:

```markdown
# Copilot Agent Instructions

## Terminal Commands
- Always run Maven with -B flag
- Always redirect test output to files
- Wait for commands to complete before proceeding

## Testing Strategy
- Generate unit tests with clear assertions
- Follow TDD approach where possible
- Create helper methods for test setup

## Code Style
- Follow project code style guidelines
- Use consistent naming conventions
- Add proper documentation
```

### Environment Variables for Agent Mode

Set environment variables to control Agent Mode behavior:

```bash
# In your .bashrc or terminal session
export COPILOT_AGENT_VERBOSE=true
export MAVEN_OPTS="-Djansi.passthrough=true -Dstyle.color=never"
```

### Agent Mode Prompt Template

For consistent results, use this prompt template:

```
Can you help me by creating unit tests for [specific class/method]?
Please follow these steps:
1. Analyze the code structure
2. Generate appropriate test cases
3. Use JUnit 5 and Mockito
4. Include tests for edge cases
5. Run the tests with mvn test -B
6. Fix any issues that arise

Add these files to the working set: [list specific files]
```

---

By following this guide, you should be able to effectively use GitHub Copilot Agent Mode in WSL environments and work around the current limitations with containers. As Copilot Agent Mode evolves, we expect better integration with containers and improved terminal feedback capabilities.
