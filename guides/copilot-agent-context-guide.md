# GitHub Copilot Agent: Comprehensive Context Guide

## Context Types Reference Table

| Context Type | Description | Use Case(s) | Example |
|-------------|-------------|------------|---------|
| **#file** | References specific files from your workspace to provide code context | When you need to reference specific files for targeted operations or when asking about specific implementation details | `#file:src/components/Button.js` - Explicitly references a file using drag and drop or by clicking on the Add Files button |
| **#selection** | Adds the currently selected code in the editor as context | When you want Copilot to focus on a specific section of code rather than an entire file | `@workspace /fix linting error in the style of #selection` - Focuses on just the selected code |
| **#codebase** | Allows Copilot to search and analyze your entire codebase | When you're not sure which files are relevant to your question or when working with complex, multi-file functionality | `#codebase` added to your prompt or selecting "Codebase" from the list of context types |
| **#editor** | References the current file open in the editor | When you want to focus on the current file you're working on | `#editor` references the current file context |
| **#sym** or **#symbol** | References specific functions, methods, classes, or variables | When you need to focus on a specific code element rather than entire files | `#BasketAddItem` - References a specific method named BasketAddItem |
| **Terminal Context** | Includes terminal output and commands | When you're working with command-line operations, build processes, or runtime errors | `#terminalLastCommand` - Attaches the output of the last command run in the terminal |
| **Problem Context** | References specific code issues from the Problems panel | When fixing bugs or addressing error messages | Drag and drop items from the Problems panel or select "Problem..." from context types |
| **Test Failure Context** | Includes test failure details | When fixing failing tests or implementing test coverage | Select "Test Failure" context type to add test failure details |
| **Custom Instructions** | Persistent instructions that guide Copilot's behavior | When you want to enforce coding standards or specific patterns across multiple interactions | Create a `.github/copilot-instructions.md` file with project-specific instructions |
| **@workspace** | References the entire workspace with intelligent context selection | When you want Copilot to search through the codebase to find relevant information | `@workspace` extracts the most relevant information from different context sources |
| **MCP Tools** | External tools and services accessed via Model Context Protocol | When you need to integrate with external systems like GitHub repos, APIs, or databases | MCP allows agent mode to access tools for tasks like "understanding database schema or querying the web" |
| **Machine Context** | Information about your operating system and environment | When creating platform-specific code or configurations | "Machine context (e.g. what OS you are using)" |
| **Workspace Index** | A searchable index of your codebase that can be remote, local, or basic | When searching through large codebases efficiently | Copilot uses an index to quickly search your codebase for relevant code snippets |
| **Chat Variables** | Dynamic context references in chat prompts with the # symbol | When you want to combine multiple context types in a single prompt | Use the # character to reference context using chat variables |
| **Conversation History** | Previous interactions in the current chat thread | When building on previous questions or continuing a complex task | Select between multiple ongoing threads to provide the right historical context |
| **Image Context** | Attached images for visual context | When working with UI components, mockups, or visual errors | Attach images to your prompt to provide additional context in VS Code 17.14+ |

## Model Context Protocol (MCP) in Copilot Agent

The Model Context Protocol (MCP) is a significant advancement in GitHub Copilot Agent mode that dramatically expands its capabilities. It functions as a standardized interface that enables AI models to interact with external tools and services.

### Key Aspects of MCP

1. **Definition**: MCP is "an open standard that enables AI models to interact with external tools and services through a unified interface"

2. **Function**: Works like a "USB port for intelligence" allowing Agent Mode to access any context or capabilities it needs

3. **Implementation**: VS Code supports "local standard input/output (stdio) and server-sent events (sse) for MCP server transport"

4. **Tool Types**: MCP servers can provide various tools like file operations, database access, or API calls that Copilot Agent can use when processing your requests

5. **GitHub MCP Server**: GitHub has released "a new open source and local GitHub MCP server" that adds GitHub functionality to any LLM tool supporting MCP

6. **Configuration**: MCP servers can be configured in VS Code through `.vscode/mcp.json` files with server definitions and required inputs

### MCP Server Example Configuration

```json
// Example .vscode/mcp.json
{
  "inputs": [
    {
      "type": "promptString",
      "id": "api-key",
      "description": "API Key",
      "password": true
    }
  ],
  "servers": {
    "github": {
      "type": "stdio",
      "command": "github-mcp-server",
      "args": []
    },
    "remote-api": {
      "type": "sse",
      "url": "https://api.example.com/mcp",
      "headers": {
        "Authorization": "Bearer ${input:api-key}"
      }
    }
  }
}
```

### Enabling MCP Tools in Agent Mode

1. Open Copilot Chat view (⌃⌘I on Mac, Ctrl+Alt+I on Windows/Linux)
2. Select Agent mode from the dropdown
3. Click the Tools button in the Chat view
4. Toggle specific tools on/off as needed
5. Add specific tools to your prompt using the Add Context button or by typing #

## Best Practices for Context Management

1. **Be Specific**: The more specific your context, the better Copilot's responses will be

2. **Combine Context Types**: Mix different context types for comprehensive understanding:
   ```
   @workspace /fix linting error in #file:components/Button.js similar to #file:components/Input.js
   ```

3. **Use Custom Instructions**: Create a `.github/copilot-instructions.md` file to set persistent context and preferences

4. **Organize Chat Threads**: Use separate threads for different tasks to maintain clear context boundaries

5. **Start with Broad Context**: Begin with @workspace for general questions, then narrow down with specific context as needed

6. **Explicit File References**: When working with related files, explicitly include them rather than hoping Copilot will find them

7. **Context Variables**: Use # as an IntelliSense trigger to select files or symbols accurately

8. **Error Context**: Always include error messages or test failures when asking Copilot to fix issues
