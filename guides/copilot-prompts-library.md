# Copilot Prompts & Instructions Library (2026)

This library contains a collection of prompt patterns, tech debt analyzers, and custom instructions for GitHub Copilot Agent Mode.

## Table of Contents
1. Comprehensive Guide Prompt
2. Tech Debt Analyzers
3. Automation Instructions
4. Custom Instructions

---

# Comprehensive Technical Guide Creation Prompt

## Template for comprehensive technical guides

I need a comprehensive guide on [INSERT SPECIFIC TECHNOLOGY/TOOL HERE] that meets the following requirements:

## Required Components

### 1. Technical Depth and Completeness
- Provide complete coverage of all administrative settings and configuration options
- Include step-by-step instructions with exact menu paths and setting names
- Detail what happens during each key process or workflow
- Explain the "why" behind configuration choices, not just how to set them
- Identify dependencies and prerequisites

### 2. User Experience Walkthroughs
- Explain exactly what users see and experience at each step
- Include visual descriptions of UI changes and interactive elements
- Detail the complete end-to-end workflow for key processes
- Highlight user decision points and their implications
- Provide troubleshooting guidance for common issues

### 3. Technical Context and Related Technologies
- Define all technical terms and protocols (e.g., "What is MCP in this context?")
- Explain how this technology integrates with other systems
- Clarify which components are built-in vs. requiring separate implementation
- Include version-specific information with clear labeling of feature availability
- Detail performance implications of different configuration choices

### 4. Context Management
- Explain exactly how to include/exclude specific content or context
- Detail file patterns, configuration files, and context control mechanisms
- Provide examples of configuration for different scenarios
- Explain limitations and best practices for context management

### 5. Enterprise-Specific Considerations
- Address enterprise security concerns and compliance features
- Detail multi-user management and role-based access control
- Include licensing, quota management, and cost control mechanisms
- Explain differences between individual and enterprise features
- Provide guidance on organizational governance and policies

### 6. Practical Application Guidance
- Include clear use cases with specific examples
- Provide decision matrices for when to use different features/options
- Include performance optimization guidance
- Detail scaling considerations for larger implementations
- Offer migration or upgrade strategies if relevant

## Format Requirements
- Use clear headings and subheadings for easy navigation
- Include tables for feature comparisons where appropriate
- Provide code blocks or configuration examples as needed
- Use numbered lists for sequential procedures
- Include "Note" and "Warning" callouts for important considerations

Please ensure the guide is thorough, technically accurate, and follows a logical progression from basic to advanced concepts. The goal is to create a resource that would allow a technical professional to fully implement and optimize the technology without requiring additional research.

---

# Comprehensive Technical Debt Analysis and Remediation Plan

## Objective
Analyze this repository comprehensively to identify all sources of technical debt and create a prioritized, actionable remediation plan with specific implementation steps.

## Context & Scope
You are acting as a senior software architect and technical debt specialist. Examine the entire codebase with focus on:
- **Code quality and maintainability**
- **Security vulnerabilities and outdated dependencies**
- **Performance bottlenecks and inefficiencies**
- **Documentation gaps and inconsistencies**
- **Testing coverage and quality**
- **Architecture and design patterns**

## Analysis Instructions

### 1. Repository Assessment
Perform a comprehensive scan of the repository structure and identify:

**@workspace** analyze the following technical debt categories:

#### Code Quality Issues
- Duplicated code blocks and repetitive patterns
- Code smells (long methods, large classes, complex conditionals)
- Inconsistent coding standards and formatting
- Dead code and unused imports/variables
- Hardcoded values that should be configurable
- Missing error handling and edge cases

#### Security & Dependencies
- Outdated dependencies with known vulnerabilities
- Insecure coding patterns (SQL injection, XSS, etc.)
- Hardcoded credentials or sensitive data
- Missing security headers and configurations
- Insufficient input validation

#### Performance & Efficiency
- N+1 query problems and database inefficiencies
- Memory leaks and resource management issues
- Slow algorithms and unoptimized data structures
- Missing caching strategies
- Inefficient API calls and network requests

#### Architecture & Design
- Violations of SOLID principles
- Tight coupling and low cohesion
- Missing or inappropriate design patterns
- Inconsistent API designs
- Monolithic structures that should be modularized

#### Documentation & Testing
- Missing or outdated documentation
- Insufficient test coverage (< 80%)
- Flaky or slow tests
- Missing integration and end-to-end tests
- Unclear README and setup instructions

### 2. Prioritization Framework
For each identified issue, provide:

**Impact Assessment:**
- **Critical** (blocks development, security risk, causes outages)
- **High** (significant performance impact, maintainability issues)
- **Medium** (developer experience, moderate technical debt)
- **Low** (minor improvements, cosmetic issues)

**Effort Estimation:**
- **Large** (> 2 weeks, architectural changes)
- **Medium** (1-2 weeks, moderate refactoring)
- **Small** (< 1 week, local changes)

**Dependencies:**
- List any prerequisite work or blockers
- Identify items that can be parallelized

### 3. Detailed Remediation Plan

For the **top 10 highest priority items**, provide:

#### Problem Statement
- Clear description of the technical debt issue
- Current impact on development velocity/quality
- Risk if left unaddressed

#### Acceptance Criteria
- Specific, measurable outcomes
- Definition of "done" for the fix
- Success metrics and validation steps

#### Implementation Approach
- Step-by-step technical approach
- Files/modules that need modification
- Recommended tools, libraries, or patterns
- Migration strategy if applicable

#### Estimated Timeline
- Development time breakdown
- Testing and review time
- Deployment considerations

## Output Format

Please structure your response as follows:

```markdown
# Technical Debt Analysis Report

## Executive Summary
- Total issues identified: [count]
- Critical issues requiring immediate attention: [count]
- Estimated total remediation effort: [time estimate]
- Primary risk areas: [list top 3 categories]

## High-Priority Issues (Top 10)

### Issue #1: [Title]
**Category:** [Code Quality/Security/Performance/Architecture/Documentation]
**Priority:** [Critical/High/Medium/Low]
**Effort:** [Large/Medium/Small]
**Impact:** [Description]

**Problem Statement:**
[Detailed explanation]

**Files Affected:**
- `path/to/file1.ext`
- `path/to/file2.ext`

**Acceptance Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

**Implementation Plan:**
1. Step one
2. Step two
3. Step three

**Dependencies:** [List any blockers or prerequisites]
**Timeline:** [Estimated effort]

---

[Repeat for remaining top 9 issues]

## Complete Issue Inventory

### By Category
**Code Quality (X issues)**
- Issue brief description [Priority] [Effort]
- Issue brief description [Priority] [Effort]

**Security (X issues)**
- Issue brief description [Priority] [Effort]

**Performance (X issues)**
- Issue brief description [Priority] [Effort]

**Architecture (X issues)**
- Issue brief description [Priority] [Effort]

**Documentation & Testing (X issues)**
- Issue brief description [Priority] [Effort]

## Recommended Implementation Strategy

### Phase 1: Critical Security & Stability (Weeks 1-2)
[List critical issues to address first]

### Phase 2: High-Impact Performance & Quality (Weeks 3-6)
[List high-impact improvements]

### Phase 3: Architecture & Maintainability (Weeks 7-12)
[List longer-term architectural improvements]

### Phase 4: Documentation & Developer Experience (Ongoing)
[List documentation and DX improvements]

## Success Metrics
- Code quality score improvement
- Test coverage increase target
- Performance benchmarks to achieve
- Security vulnerability reduction
- Developer velocity improvements
```

## Analysis Guidelines

**Be Specific and Actionable:**
- Provide exact file paths and line numbers where possible
- Include code snippets for context
- Suggest specific tools, libraries, or frameworks
- Reference industry best practices and standards

**Consider Business Impact:**
- Prioritize issues affecting user experience
- Factor in development team productivity
- Consider maintenance and operational costs
- Account for compliance and security requirements

**Provide Realistic Estimates:**
- Base effort estimates on typical developer productivity
- Include time for testing, code review, and documentation
- Account for learning curves with new technologies
- Consider team size and skill level

## Additional Requests

After completing the main analysis, please also:

1. **Generate GitHub Issues:** Create markdown templates for the top 5 issues that can be copied directly into GitHub Issues
2. **Quick Wins:** Identify 3-5 issues that can be resolved in < 1 day each
3. **Automation Opportunities:** Suggest areas where CI/CD, linting, or other automation could prevent future technical debt
4. **Team Recommendations:** Provide suggestions for team processes, code review practices, and development guidelines to minimize future technical debt accumulation

---

**Note:** Please examine the entire repository context using `@workspace` before providing your analysis. Focus on actionable insights that will genuinely improve code quality, security, and maintainability.

---

# GitHub Copilot Automated Analysis Instructions

## Copilot Analysis Instructions

When analyzing this repository collection:

## Constraints
- NEVER install packages globally
- NEVER modify existing code files
- NEVER prompt for confirmation on read operations
- ONLY write to the docs/ directory
- Use virtual environments or containers for any tools

## Automated Analysis Approach
1. First, scan all repositories and create an inventory
2. Batch similar operations together
3. Create scripts that can run unattended
4. Output structured markdown for all findings

## Output Structure
Always organize findings into:
- DevOps principle alignment
- Business impact
- Technical categorization
- Priority (P0-P4)

## Non-Interactive Operations
- Use `find`, `grep`, `awk` for file analysis
- Read files without prompting
- Make reasonable assumptions about patterns
- Skip operations requiring user input
- Batch multiple operations into single scripts

## Safe Operations Whitelist
- Reading any file in the repository
- Creating new files in docs/ directory
- Running analysis in Docker containers
- Using Python virtual environments
- Creating temporary files in .analysis/