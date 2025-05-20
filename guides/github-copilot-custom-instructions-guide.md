# GitHub Copilot Custom Instructions Guide: Repository-Level Configuration

## Table of Contents
1. [Introduction to Custom Instructions](#introduction-to-custom-instructions)
2. [Types of Custom Instructions](#types-of-custom-instructions)
3. [Setting Up Repository-Level Custom Instructions](#setting-up-repository-level-custom-instructions)
4. [Content Structure and Format](#content-structure-and-format)
5. [Recommended Patterns and Examples](#recommended-patterns-and-examples)
6. [What to Avoid](#what-to-avoid)
7. [Security Considerations](#security-considerations)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)

## Introduction to Custom Instructions

Custom instructions are directives that personalize how GitHub Copilot interacts with your codebase, allowing you to provide context-specific guidance about code style, architecture, conventions, and preferences. When properly configured, custom instructions help Copilot generate more relevant and consistent suggestions that align with your project's specific requirements and standards.

As of 2025, GitHub Copilot supports several levels of custom instructions:
- **Personal level**: Applied to all your Copilot interactions
- **Organization level**: Applied across an organization (Enterprise tier)
- **Repository level**: Applied to a specific repository

This guide focuses on repository-level custom instructions, which are particularly valuable for team collaboration, onboarding new developers, and maintaining consistent coding practices.

## Types of Custom Instructions

### Repository-Level Instructions (`.github/copilot/`)

GitHub Copilot can read custom instructions directly from your repository. These instructions are stored in specific files within the `.github/copilot/` directory. The primary files include:

1. **`instructions.md`**: General instructions for the entire repository
2. **`prompts/`**: Directory containing reusable prompt templates
3. **`references/`**: Directory containing knowledge base files that Copilot can use for context

### VS Code Chat Custom Instructions

In addition to repository files, you can configure custom instructions directly in the VS Code Copilot Chat interface:

1. Open VS Code
2. Click the Copilot icon in the sidebar to open Copilot Chat
3. Click the settings gear icon
4. Select "Configure Custom Instructions"

These custom instructions in VS Code can reference and build upon the repository-level instructions.

## Setting Up Repository-Level Custom Instructions

### Directory Structure

To set up repository-level custom instructions, create the following directory structure:

```
your-repository/
├── .github/
│   ├── copilot/
│   │   ├── instructions.md
│   │   ├── prompts/
│   │   │   ├── testing.md
│   │   │   ├── refactoring.md
│   │   │   └── ...
│   │   └── references/
│   │       ├── architecture.md
│   │       ├── coding-standards.md
│   │       └── ...
```

### File Formats and Limits

- All files should use Markdown (`.md`) format
- `instructions.md` is limited to 10,000 characters
- Individual prompt and reference files are limited to 20,000 characters each
- Repository can contain up to 100 reference files (as of May 2025)

### Activation and Visibility

- Custom instructions are automatically detected and applied when Copilot Chat is used within a repository
- Files must be in the default branch to be detected
- Changes to instruction files take effect immediately after being pushed to the repository

## Content Structure and Format

### Instructions.md Structure

The `instructions.md` file should be structured as follows:

```markdown
# Repository Custom Instructions

## About this Project
[Brief description of the project, its purpose, and core functionality]

## Architecture Overview
[High-level description of the architecture, key components, and design patterns]

## Code Style and Conventions
[Specific coding standards, naming conventions, and style preferences]

## Testing Approach
[Testing framework, methodology, and expectations]

## Common Practices
[Recurring patterns, error handling, logging conventions, etc.]

## Dependencies and Technologies
[Key libraries, frameworks, and tools with versions]

## Special Considerations
[Security requirements, performance constraints, etc.]
```

### Prompt Templates Structure

Prompt template files in the `prompts/` directory should follow this format:

```markdown
# [Prompt Name]

## Use Case
[When to use this prompt]

## Template
[The actual prompt template, with placeholders]

## Examples
[Examples of using this prompt]

## Notes
[Additional context or considerations]
```

### Reference Files Structure

Reference files in the `references/` directory should be organized by topic and include detailed information:

```markdown
# [Topic Name]

## Overview
[Brief introduction to the topic]

## Details
[Comprehensive information about the topic]

## Examples
[Code examples demonstrating the concepts]

## Related Topics
[Links to related topics or references]
```

## Recommended Patterns and Examples

### Effective General Instructions

```markdown
# Repository Custom Instructions

## About this Project
This is a React-based e-commerce platform built with TypeScript, Redux for state management, and Firebase for backend services. The application follows a component-based architecture with a focus on performance and accessibility.

## Code Style and Conventions
- Use functional components with hooks instead of class components
- Follow the AirBnB JavaScript style guide
- Use camelCase for variables and functions, PascalCase for components
- Prefix interface names with 'I' (e.g., IUserProps)
- Group imports: React, external libraries, internal components, styles
- Use named exports instead of default exports

## Testing Approach
- Jest and React Testing Library for unit and integration tests
- Cypress for end-to-end testing
- Test files should be co-located with components (.test.tsx)
- Follow the Arrange-Act-Assert pattern
- Mock external dependencies and API calls
```

### Domain-Specific Instructions

```markdown
# E-Commerce Domain Instructions

## Product Management
- Products have SKUs, titles, descriptions, prices, inventory counts, and categories
- Product variants use the Variant pattern with shared base properties
- Inventory is real-time and must be checked before checkout
- Prices may have discounts applied via promotion rules

## Shopping Cart
- Cart is persisted in local storage and synced with user accounts when logged in
- Cart items contain product references, quantity, and price at time of addition
- Implement optimistic UI updates for cart operations with rollback on errors
```

### Technology-Specific Instructions

```markdown
# React Patterns

## Component Structure
- Use the Container/Presenter pattern for complex components
- Implement lazy loading for routes and heavy components
- Keep components focused on a single responsibility
- Extract reusable logic into custom hooks

## State Management
- Use Redux for global state, React Context for theme/localization
- Follow the ducks pattern for Redux modules
- Use Redux Toolkit for reducers and async actions
- Normalize complex state with entity adapters
```

### Project Structure Guidelines

```markdown
# Project Structure

## Directory Organization
- src/components/ - Reusable UI components
- src/features/ - Feature-specific components and logic
- src/hooks/ - Custom React hooks
- src/services/ - API clients and service integrations
- src/utils/ - Helper functions and utilities
- src/types/ - TypeScript type definitions

## File Naming
- Component files: PascalCase.tsx
- Utility files: camelCase.ts
- Test files: [filename].test.tsx
- Style files: [filename].module.css
```

## What to Avoid

### Avoid in Custom Instructions

1. **Sensitive Information**
   - API keys, tokens, or credentials
   - Internal URLs or IP addresses
   - Employee names or contact information
   - Non-public business information

2. **Conflicting Instructions**
   - Contradictory style guidelines
   - Inconsistent naming conventions
   - Mixed architectural patterns without clear boundaries

3. **Overly Rigid Rules**
   - Excessive micromanagement of code style
   - Too many exceptions to established patterns
   - Highly specific rules that may not apply to all scenarios

4. **Unnecessarily Complex Instructions**
   - Verbose explanations where simple guidelines would suffice
   - Instructions requiring deep domain knowledge to understand
   - Unnecessary jargon or acronyms without explanation

5. **Outdated Information**
   - References to deprecated libraries or versions
   - Obsolete patterns or practices
   - Links to documentation that no longer exists

### Anti-Patterns to Avoid

```markdown
# AVOID THIS TYPE OF INSTRUCTION

## Developer Rules
- Always use double quotes for strings (except John and Sarah who can use single quotes)
- Variable names must be at least 3 characters but no more than 12 characters unless they're constants
- Functions can be arrow functions on Mondays, Wednesdays, and Fridays, but must be function declarations on other days
- Comments are required every 5 lines of code exactly
- Use tabs for indentation in JS files and spaces in TS files
```

## Security Considerations

### Information Exposure Risks

1. **Business Logic Exposure**
   - Custom instructions may reveal proprietary algorithms or business logic
   - Consider what competitive advantage might be exposed through instructions

2. **Architecture Vulnerabilities**
   - Detailed system architecture might expose potential attack vectors
   - Avoid documenting security workarounds or known vulnerabilities

3. **Access Control Information**
   - Don't include details about authentication mechanisms or authorization rules
   - Avoid mentioning internal security protocols or policies

### Data Protection

1. **Personal Data**
   - Never include actual user data, even as examples
   - Use fictional personas and synthetic data for examples

2. **Credential Protection**
   - Never include actual credentials, even in examples
   - Don't document patterns that might encourage insecure credential handling

3. **Environment Information**
   - Avoid specific details about production environments
   - Don't include IP addresses, domain names, or internal URLs

### Safe Examples

Use fictional or sanitized examples that don't expose sensitive information:

```markdown
# GOOD EXAMPLE

## Authentication
- User authentication uses JWT tokens with standard claims
- Implement the IAuthenticatable interface for protected resources
- Use the AuthGuard directive for protected routes
- Example (fictional data):
  ```typescript
  // Good - uses fictional data and standard patterns
  interface IUser {
    id: string;
    roles: string[];
  }
  
  // Authenticate user with email/password
  async function loginUser(email: string, password: string): Promise<IAuthResult> {
    // Implementation details...
  }
  ```
```

```markdown
# BAD EXAMPLE - DO NOT USE

## Authentication
- Our authentication server runs at auth.internal-company.com:8080
- Admin accounts use the backdoor password "companySecret123" for emergency access
- We store user passwords with MD5 hashing (planning to upgrade later)
- Here's how we validate users:
  ```typescript
  // Bad - exposes real endpoint, weak security, and poor patterns
  async function loginUser(email, pwd) {
    const result = await fetch('https://auth.internal-company.com:8080/login', {
      method: 'POST',
      body: JSON.stringify({ email, p: md5(pwd) })
    });
  }
  ```
```

## Best Practices

### Organization and Clarity

1. **Hierarchical Structure**
   - Organize instructions from general to specific
   - Group related concepts together
   - Use clear headings and subheadings

2. **Concise Language**
   - Be specific and direct
   - Avoid unnecessary explanations
   - Use bullet points for lists of requirements

3. **Code Examples**
   - Include representative examples for key patterns
   - Annotate examples to highlight important aspects
   - Keep examples simple enough to illustrate without overwhelming

### Maintenance Strategy

1. **Regular Updates**
   - Review and update instructions quarterly
   - Align updates with major releases or architecture changes
   - Assign an owner responsible for keeping instructions current

2. **Version Alignment**
   - Ensure instructions align with current codebase
   - Update when introducing new libraries or patterns
   - Note when instructions apply to specific versions only

3. **Team Review Process**
   - Have multiple team members review instructions
   - Incorporate feedback from new team members about clarity
   - Test instructions by having Copilot generate code based on them

### Maximizing Effectiveness

1. **Start Small and Iterate**
   - Begin with core patterns and conventions
   - Add more specific guidance as needed
   - Refine based on Copilot's output quality

2. **Balance Freedom and Constraints**
   - Provide clear guidelines without excessive restrictions
   - Focus on important patterns rather than stylistic minutiae
   - Allow creative solutions within architectural boundaries

3. **Combine with IDE Settings**
   - Use .editorconfig for basic formatting rules
   - Configure linters and formatters to enforce style automatically
   - Let custom instructions focus on patterns rather than syntax

### Example of Comprehensive Custom Instructions

```markdown
# E-Commerce Platform Custom Instructions

## About this Project
This is a microservice-based e-commerce platform built with Node.js, TypeScript, and React. The system follows Domain-Driven Design principles and CQRS for the backend, with a React-based frontend using Redux for state management.

## Architecture Overview
- Microservice architecture with service boundaries aligned to business domains
- Event-driven communication between services using RabbitMQ
- CQRS pattern for data operations with separate read and write models
- API Gateway pattern for client communication
- React frontend with component-based architecture

## Code Style and Conventions
- TypeScript for all new code
- ESLint with Airbnb preset (see .eslintrc for customizations)
- Functional programming principles preferred
- Immutable data structures using Immer or spread operators
- Error handling via custom error classes extending BaseError

## Naming Conventions
- Services: PascalCase, suffixed with "Service"
- Components: PascalCase
- Interfaces: Prefixed with "I"
- Types: PascalCase, suffixed with "Type"
- Variables/Functions: camelCase
- Constants: UPPER_SNAKE_CASE
- Files: kebab-case.ts/tsx

## Testing Approach
- Jest for unit tests
- Supertest for API testing
- React Testing Library for component tests
- BDD-style tests with describe/it syntax
- Test coverage minimum: 80% for business logic

## State Management
- Redux for global state
- Redux Toolkit for reducers and actions
- Redux Saga for side effects
- Normalized state using normalizr
- Selectors for derived state

## API Design
- RESTful APIs for CRUD operations
- GraphQL for complex data requirements
- Versioned API endpoints (v1, v2)
- Consistent error response format
- JWT-based authentication

## Error Handling
- Use try/catch blocks around async operations
- Custom error classes for different error types
- Centralized error logging through ErrorService
- Client-friendly error messages separate from technical details

## Logging
- Winston for logging with structured JSON format
- Log levels: error, warn, info, debug
- Include correlation IDs in all logs
- No sensitive data in logs

## Performance Considerations
- Use pagination for lists
- Implement caching for frequently accessed data
- Optimize React renders with memoization
- Lazy load routes and components

## Accessibility
- All components must be keyboard navigable
- Use semantic HTML elements
- Include ARIA attributes where appropriate
- Maintain WCAG 2.1 AA compliance

## Security Requirements
- Validate all user input
- Sanitize data before rendering
- Implement rate limiting on authentication endpoints
- Follow OWASP Top 10 recommendations
```

## Troubleshooting

### Common Issues

1. **Instructions Not Being Applied**
   - Ensure files are in the correct location (`.github/copilot/`)
   - Verify files are committed to the default branch
   - Check file sizes don't exceed limits
   - Ensure Markdown formatting is valid

2. **Conflicting Instructions**
   - Check for contradictions between repository, organization, and personal instructions
   - Repository instructions take precedence, but conflicts can cause confusion

3. **Too Verbose/Too Brief**
   - Instructions that are too long may be skipped or partially processed
   - Instructions that are too brief may not provide enough context
   - Aim for concise but complete guidance

### Resolving Issues

1. **Testing Instructions**
   - Create a test branch to experiment with different instruction formats
   - Use Copilot Chat to explicitly ask about the instructions
   - Generate sample code and evaluate if it follows guidelines

2. **Iterative Improvement**
   - Start with minimal instructions and add detail gradually
   - Ask team members to use the instructions and provide feedback
   - Monitor code reviews for recurring issues that could be addressed in instructions

3. **Documentation**
   - Keep a changelog of instruction updates
   - Document the rationale behind key instructions
   - Include examples of before/after code to illustrate the impact

---

Custom instructions represent a powerful way to personalize GitHub Copilot for your specific repository. When properly implemented, they can significantly improve the quality and consistency of AI-generated code, reduce the need for extensive code reviews, and help maintain project standards across a team.

By carefully balancing guidance with flexibility, avoiding security risks, and maintaining up-to-date instructions, you can transform Copilot from a generic coding assistant to a repository-specific expert that understands your project's unique requirements and conventions.
