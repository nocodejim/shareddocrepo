# Chrome DevTools MCP Server - Installation & Usage Plan

## Overview

Google's official **Chrome DevTools MCP Server** enables AI coding agents to control and inspect live Chrome browsers with full DevTools capabilities. This provides automation, debugging, and performance analysis directly from your AI assistant.

## Prerequisites

- **Node.js**: v20.19 or higher
- **Chrome**: Current stable version
- **npm**: Included with Node.js
- **MCP-compatible client**: Claude Desktop or Claude Code

## Installation Steps

### Step 1: Check Prerequisites

```bash
node --version  # Should be v20.19+
which chrome    # Verify Chrome is installed
```

### Step 2: Configure MCP Client

Add the following configuration to your MCP client settings:

**For Claude Desktop** (`~/Library/Application Support/Claude/claude_desktop_config.json` on macOS):
```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest"]
    }
  }
}
```

**For Claude Code** (`.claude/config.json` in your home directory):
```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest"]
    }
  }
}
```

### Step 3: Restart MCP Client

- Restart Claude Desktop or reload Claude Code for changes to take effect
- The server will be downloaded and initialized on first use

## Available Tools (26 Total)

### Input Automation (7 tools)
- `click` - Click on an element
- `drag` - Drag an element onto another
- `fill` - Type text into inputs or select options
- `fill_form` - Fill multiple form elements at once
- `handle_dialog` - Handle browser dialogs (alert, confirm, prompt)
- `hover` - Hover over an element
- `upload_file` - Upload files through file inputs

### Navigation Automation (7 tools)
- `navigate_page` - Navigate to a URL
- `new_page` - Create a new tab/page
- `close_page` - Close a page by index
- `list_pages` - List all open pages
- `select_page` - Switch context to a specific page
- `wait_for` - Wait for text to appear
- `navigate_page_history` - Go back/forward in history

### Performance Analysis (3 tools)
- `performance_start_trace` - Begin recording performance
- `performance_stop_trace` - Stop recording and get results
- `performance_analyze_insight` - Get detailed performance insights

### Network Inspection (2 tools)
- `list_network_requests` - List all network requests
- `get_network_request` - Get details of a specific request

### Debugging (4 tools)
- `evaluate_script` - Execute JavaScript in the page
- `list_console_messages` - View console logs
- `take_screenshot` - Capture page screenshot
- Additional debugging utilities

### Emulation (3 tools)
- `emulate_cpu` - Throttle CPU performance
- `emulate_network` - Simulate network conditions (3G, offline, etc.)
- `resize_page` - Change viewport dimensions

## Configuration Options

Optional command-line arguments for advanced use:

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": [
        "-y",
        "chrome-devtools-mcp@latest",
        "--headless",           // Run without visible window
        "--isolated",           // Use temporary profile
        "--executablePath=/path/to/chrome"  // Custom Chrome location
      ]
    }
  }
}
```

Available options:
- `--browserUrl` - Connect to existing Chrome instance
- `--headless` - Run in headless mode
- `--executablePath` - Custom Chrome binary path
- `--isolated` - Use temporary user data directory
- `--userDataDir` - Specify user data directory

## Testing Plan

### Test 1: Basic Navigation
**Prompt:** "Navigate to https://example.com and take a screenshot"

**Expected:** Browser opens, navigates to URL, returns screenshot

### Test 2: Performance Analysis
**Prompt:** "Check the performance of https://web.dev"

**Expected:** Performance trace captured and analyzed with LCP, FID, CLS metrics

### Test 3: Console Debugging
**Prompt:** "Navigate to https://developers.chrome.com and list any console messages"

**Expected:** Lists console logs, warnings, or errors from the page

### Test 4: Network Inspection
**Prompt:** "Navigate to https://github.com and list all network requests"

**Expected:** Returns list of HTTP requests with URLs, methods, and status codes

### Test 5: Form Interaction
**Prompt:** "Navigate to a search page, fill in the search box with 'testing', and submit"

**Expected:** Demonstrates form filling and interaction capabilities

## Common Use Cases

### 1. Performance Auditing
```
Start a performance trace, navigate to [URL], stop the trace, and analyze the results
```

### 2. Responsive Testing
```
Resize the page to 375x667 (iPhone SE), take a screenshot, then resize to 1920x1080 and take another
```

### 3. Network Debugging
```
Navigate to [URL], list all failed network requests, and show their error details
```

### 4. Automated Testing
```
Navigate to [URL], fill in the login form with test credentials, click submit, and verify success
```

### 5. Console Error Detection
```
Navigate to [URL], list all console errors, and analyze their severity
```

### 6. CPU Throttling Test
```
Emulate 4x CPU slowdown, run a performance trace on [URL], and compare metrics
```

## Security Considerations

- The tool exposes browser content to the AI assistant
- Avoid navigating to pages with sensitive information
- Use `--isolated` flag for testing to prevent profile contamination
- Be cautious when filling forms with real credentials

## Troubleshooting

### Chrome not found
Set `--executablePath` to your Chrome binary location

### Node version too old
Update Node.js to v20.19 or higher

### Server not appearing in Claude
- Verify JSON syntax in config file
- Restart the MCP client completely
- Check logs for initialization errors

## Resources

- **Official Blog Post**: https://developer.chrome.com/blog/chrome-devtools-mcp
- **GitHub Repository**: https://github.com/ChromeDevTools/chrome-devtools-mcp
- **Tool Reference**: https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/docs/tool-reference.md
- **MCP Protocol**: https://modelcontextprotocol.io

## Next Steps

1. ✅ Review this plan
2. ⬜ Install and configure the server
3. ⬜ Run basic tests
4. ⬜ Explore advanced features
5. ⬜ Integrate into development workflow
