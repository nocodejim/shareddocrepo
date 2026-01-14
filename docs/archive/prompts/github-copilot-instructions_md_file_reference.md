# GitHub Copilot Instructions Guide

## About `.github/copilot-instructions.md`

GitHub Copilot instructions files allow developers to provide context and guidance to GitHub Copilot to improve its suggestions for their specific project. The file should be placed in the `.github/copilot-instructions.md` path in your repository.

## Top 10 Useful Things to Include

### 1. Project-Specific Coding Conventions
```
Our project follows the Google TypeScript Style Guide. We use 2-space indentation, single quotes for strings, and semicolons at the end of statements. Interface names should be prefixed with 'I' (e.g., IUserService).
```

### 2. Build System and Dependency Management
```
This project uses Poetry for Python dependency management. When suggesting new dependencies, include the appropriate Poetry commands for installation and ensure compatibility with Python 3.10+.
```

### 3. Project Architecture Information
```
Our application follows a microservices architecture. The 'api' directory contains REST endpoints, 'services' directory contains business logic, and 'repositories' directory handles data access. Follow this separation of concerns when suggesting new features.
```

### 4. Technology Stack Details
```
This is a React 18 application that uses Redux for state management, React Router for navigation, and Tailwind CSS for styling. All new components should follow this stack.
```

### 5. Custom Naming Conventions
```
Use camelCase for variables and functions, PascalCase for classes and components, and UPPER_SNAKE_CASE for constants. Redux actions should use the format '[Feature] Action Description'.
```

### 6. Error Handling Practices
```
In this project, errors should be handled with try/catch blocks at service boundaries. Use our custom ErrorHandler class for consistent error formatting and logging.
```

### 7. Testing Approach
```
We use Jest for unit testing and Cypress for E2E tests. Each component should have a corresponding .test.tsx file. Follow arrange-act-assert pattern and aim for >80% test coverage.
```

### 8. Documentation Standards
```
Use JSDoc for function and class documentation. Include @param and @return tags, and provide examples for public APIs. Keep comments concise and focused on 'why' rather than 'what'.
```

### 9. Common Patterns
```
For API endpoints, follow our RESTful convention: GET for retrieval, POST for creation, PUT for full updates, PATCH for partial updates. All endpoints should include validation, error handling, and appropriate HTTP status codes.
```

### 10. Project-Specific Domain Knowledge
```
This e-commerce application uses the terms 'catalog' (collection of products), 'cart' (items selected for purchase), and 'order' (completed purchase). A user can have multiple carts but each cart belongs to only one user.
```

## What NOT to Include

1. **References to External Resources**
   Do not include instructions like "Always conform to the coding styles defined in styleguide.md in repo my-org/my-repo"

2. **Style Instructions**
   Avoid instructions like "Answer all questions in the style of a friendly colleague"

3. **Response Length Requirements**
   Don't use instructions like "Answer all questions in less than 1000 characters"

4. **Sensitive Information**
   Never include API keys, tokens, or passwords

5. **Personal Information**
   Avoid including identifying information about team members

6. **TOS Violations**
   Don't include instructions that conflict with GitHub's terms of service

7. **Excessive Instructions**
   Keep instructions concise and focused rather than overly verbose

8. **Overly Specific Formatting**
   Avoid highly specific formatting that may not work across different editors

9. **Frequently Changing Information**
   Don't include information that changes often and would require frequent updates

10. **Core Function Overrides**
    Avoid commands that attempt to override Copilot's core functionality

## Best Practices

- Keep instructions brief, clear, and to the point
- Focus on project-specific patterns and conventions
- Update the instructions file as your project evolves
- Combine with other Copilot features like inline comments for best results
- Test the effectiveness of your instructions and refine as needed

---

*This guide is based on best practices for GitHub Copilot as of April 2025.*
