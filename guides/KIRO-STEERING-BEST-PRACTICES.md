# Kiro Steering System - Best Practices Guide

## Overview

The Kiro steering system allows you to create persistent guidance that automatically influences how Kiro behaves across your projects. Think of it as your personal "AI assistant configuration" that ensures consistent, safe, and effective interactions.

## How Steering Works

Steering files are Markdown documents with special front-matter that control when and how they're applied. Kiro automatically reads these files and incorporates their guidance into every interaction.

## Steering File Locations

### Project-Level Steering (Current Project Only)
```
.kiro/steering/*.md
```
- Applies only to the current project
- Good for project-specific standards or requirements
- Travels with the project in version control

### User-Level Steering (All Projects Globally)
```
~/.kiro/settings/steering/*.md
```
- Applies to ALL your projects
- Perfect for personal coding standards and safety rules
- Persists across all Kiro sessions

## Front-Matter Configuration

Each steering file uses YAML front-matter to control its behavior:

### Always Active
```markdown
---
inclusion: always
---
# This guidance applies to every interaction
```

### File-Type Specific
```markdown
---
inclusion: fileMatch
fileMatchPattern: '*.py'
---
# This guidance only applies when Python files are open
```

### Manual Activation
```markdown
---
inclusion: manual
---
# This guidance only applies when referenced with #steering-name
```

## Recommended Global Steering Files

### 1. System Safety Rules
**File**: `~/.kiro/settings/steering/system-safety.md`
**Purpose**: Prevent destructive commands and ensure system stability

```markdown
---
inclusion: always
---

# System Safety & Security Rules

## CRITICAL SAFETY PROTOCOLS

### Never Execute Destructive Commands
- FORBIDDEN: `docker system prune -f` (removes ALL Docker resources)
- FORBIDDEN: `rm -rf /` or similar filesystem destruction
- FORBIDDEN: `killall -9` without specific targeting

### Always Use Targeted Operations
- Target specific containers: `docker stop container-name`
- Use relative paths: `rm -rf ./project-directory/`
- Verify scope: Ask "Could this affect other projects?"
```

### 2. Personal Coding Standards
**File**: `~/.kiro/settings/steering/personal-coding-standards.md`
**Purpose**: Enforce your preferred coding practices and quality standards

```markdown
---
inclusion: always
---

# Personal Coding Standards & Best Practices

## Code Quality Standards
- Always include clear README.md files
- Document complex functions and classes
- Use consistent naming conventions
- Separate concerns (config, business logic, utilities)

## Security Practices
- Never commit secrets or credentials
- Use environment variables for configuration
- Validate all user inputs
```

### 3. Communication Preferences
**File**: `~/.kiro/settings/steering/communication-preferences.md`
**Purpose**: Define how you want Kiro to communicate with you

```markdown
---
inclusion: always
---

# Communication & Interaction Preferences

## Response Style
- Be direct and concise
- Focus on practical, actionable information
- Explain the "why" behind recommendations
- Provide complete, working examples

## Problem Solving
- Start with the simplest solution
- Break down complex problems into steps
- Include verification steps
```

### 4. Technology-Specific Guidelines
**File**: `~/.kiro/settings/steering/docker-best-practices.md`
**Purpose**: Apply best practices when working with specific technologies

```markdown
---
inclusion: fileMatch
fileMatchPattern: 'docker*|*Dockerfile*|*compose*'
---

# Docker Best Practices

## Container Design Principles
- Use official base images when possible
- Set non-root user for security
- Include health checks

## Resource Management
- Set memory and CPU limits
- Clean up unused resources safely
```

## Creating Your Steering Configuration

### Step 1: Create Global Steering Directory
```bash
mkdir -p ~/.kiro/settings/steering
```

### Step 2: Create Core Safety Rules
```bash
cat > ~/.kiro/settings/steering/system-safety.md << 'EOF'
---
inclusion: always
---

# System Safety Rules

## NEVER Execute Destructive Commands
- docker system prune -f
- rm -rf / or variants
- killall -9 without targeting

## Always Use Targeted Operations
- Specify exact container/file names
- Use relative paths in project context
- Verify scope before execution
EOF
```

### Step 3: Add Personal Standards
```bash
cat > ~/.kiro/settings/steering/personal-coding-standards.md << 'EOF'
---
inclusion: always
---

# Personal Coding Standards

## Documentation Requirements
- Clear README files
- Function/class documentation
- Usage examples

## Code Quality
- Consistent naming conventions
- Proper error handling
- Meaningful commit messages
EOF
```

### Step 4: Configure Communication Style
```bash
cat > ~/.kiro/settings/steering/communication-preferences.md << 'EOF'
---
inclusion: always
---

# Communication Preferences

## Response Style
- Direct and concise
- Practical, actionable information
- Complete working examples
- Explain reasoning behind suggestions

## Problem Solving Approach
- Start with simplest solution
- Break down complex problems
- Include troubleshooting steps
EOF
```

## Advanced Steering Patterns

### Language-Specific Rules
```markdown
---
inclusion: fileMatch
fileMatchPattern: '*.py'
---

# Python-Specific Standards
- Use type hints for function parameters
- Follow PEP 8 style guidelines
- Include docstrings for all public functions
```

### Environment-Specific Rules
```markdown
---
inclusion: fileMatch
fileMatchPattern: '*prod*|*production*'
---

# Production Environment Rules
- Always backup before changes
- Use blue-green deployments
- Monitor all changes closely
```

### Project-Type Rules
```markdown
---
inclusion: fileMatch
fileMatchPattern: '*api*|*service*'
---

# API/Service Development Rules
- Include comprehensive error handling
- Implement proper logging
- Add health check endpoints
```

## Best Practices for Steering Files

### 1. Keep Rules Focused
- One steering file per major concern area
- Avoid overlapping or conflicting rules
- Make rules specific and actionable

### 2. Use Clear Language
- Write rules as clear directives
- Explain the "why" behind important rules
- Use examples to illustrate concepts

### 3. Organize Logically
- Group related rules together
- Use consistent formatting
- Include section headers for navigation

### 4. Regular Maintenance
- Review and update rules periodically
- Remove outdated or unused rules
- Add new rules based on experience

### 5. Test Your Rules
- Verify rules work as expected
- Check for conflicts between files
- Ensure rules don't overly restrict creativity

## Common Steering Use Cases

### Safety & Security
- Prevent destructive system commands
- Enforce security best practices
- Require backup procedures

### Code Quality
- Enforce documentation standards
- Require testing practices
- Maintain consistent style

### Technology Standards
- Docker best practices
- Cloud platform preferences
- Framework-specific guidelines

### Communication Style
- Response format preferences
- Level of detail desired
- Problem-solving approach

### Project Management
- Planning methodologies
- Delivery practices
- Review processes

## Troubleshooting Steering

### Rules Not Being Applied
1. Check file location (`~/.kiro/settings/steering/` for global)
2. Verify front-matter syntax
3. Ensure file has `.md` extension
4. Restart Kiro session if needed

### Conflicting Rules
1. Review all active steering files
2. Make rules more specific
3. Use file matching to limit scope
4. Remove or modify conflicting guidance

### Rules Too Restrictive
1. Add exceptions for special cases
2. Use manual inclusion for optional rules
3. Provide alternative approaches
4. Balance safety with flexibility

## Example Complete Setup

Here's a complete starter set of steering files:

```bash
# Create directory
mkdir -p ~/.kiro/settings/steering

# Core safety (always active)
echo "---
inclusion: always
---
# Never use destructive system commands
# Always target specific resources
# Verify scope before execution" > ~/.kiro/settings/steering/safety.md

# Coding standards (always active)
echo "---
inclusion: always
---
# Document all public APIs
# Use meaningful variable names
# Handle errors gracefully" > ~/.kiro/settings/steering/coding.md

# Docker practices (only for Docker files)
echo "---
inclusion: fileMatch
fileMatchPattern: 'docker*|*Dockerfile*'
---
# Use official base images
# Set resource limits
# Include health checks" > ~/.kiro/settings/steering/docker.md

# Communication style (always active)
echo "---
inclusion: always
---
# Be direct and practical
# Provide working examples
# Explain reasoning" > ~/.kiro/settings/steering/communication.md
```

## Benefits of Using Steering

### Consistency
- Same standards across all projects
- Consistent AI behavior and responses
- Reduced need to repeat preferences

### Safety
- Automatic prevention of dangerous commands
- Built-in security best practices
- Reduced risk of system damage

### Efficiency
- Faster development with established patterns
- Less time explaining preferences
- Automatic application of best practices

### Quality
- Enforced documentation standards
- Consistent code quality
- Better project outcomes

## Conclusion

The Kiro steering system is a powerful way to customize your AI assistant to match your working style, safety requirements, and quality standards. By setting up comprehensive steering files, you create a personalized development environment that consistently delivers the guidance and support you need.

Start with the core safety and communication files, then gradually add more specific guidance as you identify patterns in your work. Remember to review and update your steering files regularly to keep them relevant and effective.

Your steering configuration becomes a valuable asset that improves every interaction with Kiro, making you more productive while keeping your systems safe and your code quality high.