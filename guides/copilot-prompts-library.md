# Copilot Prompts & Instructions Library (2026)

This library contains a collection of prompt patterns, tech debt analyzers, and custom instructions for GitHub Copilot Agent Mode.

## Table of Contents
1. Comprehensive Guide Prompt
2. Tech Debt Analyzers
3. Automation Instructions
4. Custom Instructions
5. Repository Analysis & Standards Prompt
6. DevOps Readiness Assessment Prompt
7. Chain of Thought (Heavy Project) Prompt

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
- Creating temporary files in .analysis/# Repository Analysis & Standards Extraction Prompt

> **Purpose**: Systematic analysis of your codebase to extract patterns, identify mistakes, and create actionable development standards
>
> **Use Case**: Run this analysis quarterly or after major projects to keep development-standards current
>
> **Target**: AI assistant (Claude Code, Cursor, etc.) on your dev desktop

---

## 🎯 The Prompt

Copy the following prompt and paste it into your AI assistant when you want to analyze your repositories:

---

```
I need you to perform a comprehensive analysis of my project repositories to extract development patterns, identify recurring mistakes, and create/update our team development standards.

## CONTEXT & GOALS

Our team wants to:
1. Identify and prevent recurring mistakes
2. Establish consistent development patterns
3. Create clear, actionable documentation
4. Improve development velocity and code quality
5. Reduce technical debt and rework

## ANALYSIS SCOPE

### Phase 1: Discovery & Inventory (15 minutes)

**Task**: Analyze all repositories in the current directory and subdirectories.

For each repository, identify:
- Repository name and primary purpose
- Last commit date (prioritize recent = more mature practices)
- Technology stack (languages, frameworks, tools)
- Project type (full-stack web, CLI tool, library, API, mobile, etc.)
- Documentation present (README, CLAUDE.md, INSTRUCTIONS.md, lessons-learned, etc.)
- Development tooling (Docker, testing frameworks, CI/CD)

**Output**:
- Summary table of repositories sorted by last commit date (most recent first)
- Technology distribution chart
- Documentation coverage assessment
- Identify 3-5 "reference projects" with best practices

### Phase 2: Deep Pattern Analysis (30 minutes)

**Task**: Extract patterns from the most recent 2-3 months of repositories (prioritize maturity).

For each category below, identify:

#### 2.1 Project Structure Patterns
- How are projects organized? (folder structure, file naming)
- Where do tests live? How comprehensive?
- How is documentation structured?
- What's the docker-compose setup pattern?
- Where are environment variables defined?
- How are dependencies managed?

**Look for**:
- Consistency across projects
- Evolution over time (early vs recent)
- Which structure seems most maintainable?

#### 2.2 Technology Stack Patterns
- Preferred backend frameworks and versions
- Preferred frontend frameworks and versions
- Database choices and patterns
- Authentication approaches
- API design patterns (REST, GraphQL, etc.)
- Testing frameworks and coverage

**Look for**:
- Technology combinations that work well together
- Version compatibility patterns
- Migration patterns (old tech → new tech)

#### 2.3 Docker & Infrastructure Patterns
- docker-compose.yml patterns
- Dockerfile patterns (backend, frontend, database)
- Volume mounting strategies
- Network configuration
- Environment variable handling
- Multi-stage builds vs simple builds

**Look for**:
- What's consistent across projects?
- What problems does the pattern solve?
- What pitfalls does it avoid?

#### 2.4 Code Style & Quality Patterns
- Naming conventions (functions, variables, files)
- Code organization (feature-based, layer-based, domain-driven)
- Error handling patterns
- Logging patterns (format, verbosity, tools)
- Type safety approaches (TypeScript, Python type hints)
- Linting and formatting tools

**Look for**:
- Style guide compliance
- Code review patterns (PR templates, checklists)
- Quality gates (pre-commit hooks, CI checks)

#### 2.5 Testing Patterns
- Unit testing approaches and coverage
- Integration testing patterns
- End-to-end testing strategies
- Manual testing checklists
- Testing documentation
- Test data management

**Look for**:
- What gets tested consistently?
- What testing gaps exist?
- When is "tested" claimed? What does it mean?

#### 2.6 Git Workflow Patterns
- Branching strategies (feature branches, gitflow, trunk-based)
- Commit message formats
- PR/MR processes
- Tagging and release patterns
- How are hotfixes handled?

**Look for**:
- Consistency in commit messages
- Use of conventional commits
- PR templates or checklists
- Code review requirements

#### 2.7 Documentation Patterns
- README structure and completeness
- API documentation approaches (OpenAPI, JSDoc, etc.)
- Inline code documentation
- Architecture documentation
- Setup/installation guides
- Troubleshooting guides

**Look for**:
- What makes docs effective?
- What's consistently missing?
- Evolution in documentation quality

### Phase 3: Mistake & Anti-Pattern Analysis (30 minutes)

**Task**: Identify recurring problems, mistakes, and anti-patterns.

Search for and analyze:

#### 3.1 Explicit Lessons Learned
- Look for: lessons-learned.md, postmortems, TODO comments
- Extract: specific mistakes, impacts, root causes, fixes
- Categorize by: frequency, severity, category
- Identify: systematic failures (same mistake multiple times)

#### 3.2 Git History Analysis
- Search commits for: "fix", "oops", "forgot", "revert"
- Analyze: what keeps breaking? What gets fixed repeatedly?
- Look for: emergency commits, large refactors, rollbacks
- Identify patterns in: merge conflicts, broken builds

#### 3.3 Issue Patterns (if using issue tracking)
- Common bug categories
- Feature request patterns
- Technical debt items
- Security vulnerabilities

#### 3.4 Code Smell Analysis
- Search for: TODO, FIXME, HACK, XXX comments
- Identify: copy-paste code, long functions, deep nesting
- Find: dead code, unused dependencies
- Spot: hardcoded values, missing error handling

#### 3.5 Configuration & Setup Issues
- Missing .gitignore entries
- Uncommitted lock files
- Secrets in git history
- Missing environment variable documentation
- Incomplete setup instructions

**For Each Mistake Found**:
```markdown
### [Category] - Mistake Name
- **What**: Brief description of the mistake
- **Impact**: How it affected development/product/team
- **Frequency**: How often it occurs (one-time, occasional, systematic)
- **Root Cause**: Why it happened
- **Detection**: How it was discovered
- **Fix**: How it was resolved
- **Prevention**: How to prevent in future
- **Priority**: CRITICAL / High / Medium / Low
- **Evidence**: Link to commits, files, or documentation
```

### Phase 4: Maturity & Evolution Analysis (15 minutes)

**Task**: Understand how practices have evolved over time.

Compare projects by age:
- **Early projects** (oldest 25%): What patterns existed?
- **Mid projects** (middle 50%): What improved?
- **Recent projects** (newest 25%): Current state of maturity?

For each phase, assess:
- Documentation quality
- Testing coverage
- Code quality
- Infrastructure sophistication
- Security awareness
- Error handling
- Development workflow

**Create a timeline**:
```
Month YYYY:
- Key projects: [list]
- New patterns adopted: [list]
- Problems solved: [list]
- Problems introduced: [list]
```

### Phase 5: Best Practices Extraction (20 minutes)

**Task**: From the analysis, extract concrete best practices.

For each area below, provide:
- **Principle**: What's the rule?
- **Rationale**: Why does it matter?
- **How-To**: Concrete steps to implement
- **Example**: Code snippet or file example from repos
- **Anti-Pattern**: What NOT to do
- **Checklist**: Verification steps

Areas to cover:
1. Project initialization (first files to create, setup steps)
2. Dependency management (lock files, versioning, updates)
3. Environment configuration (secrets, variables, containers)
4. Database patterns (migrations, models, seeds)
5. API design (endpoints, auth, error handling)
6. Frontend patterns (state management, routing, forms)
7. Testing strategy (what, when, how to test)
8. Git workflow (branches, commits, PRs)
9. Documentation (what docs, when to update)
10. Deployment (process, checks, rollback)

### Phase 6: Documentation Generation (30 minutes)

**Task**: Create comprehensive, actionable documentation.

Generate these documents:

#### 6.1 CRITICAL-MISTAKES-LEARNED.md
- Top 10 most critical/frequent mistakes
- Detailed analysis with evidence
- Prevention strategies
- Quick reference checklist
- Frequency and severity matrix

#### 6.2 DEVELOPMENT-PATTERNS.md
- Established patterns organized by category
- Code examples from actual projects
- Template files (docker-compose, .gitignore, etc.)
- Decision trees (when to use pattern X vs Y)
- Migration guides (old pattern → new pattern)

#### 6.3 TEAM-STANDARDS.md
- Non-negotiable rules
- Preferred approaches (with rationale)
- Code style guide
- Review checklist
- Definition of Done

#### 6.4 ONBOARDING-GUIDE.md
- New team member setup
- Required reading
- First week tasks
- Common pitfalls for new developers
- Who to ask for what

#### 6.5 PROJECT-TEMPLATES.md
- Templates for each project type
- Initialization scripts
- File structure
- Required documentation
- Setup checklist

#### 6.6 TESTING-STANDARDS.md
- What "tested" means
- Testing checklist for each type (unit, integration, e2e)
- Coverage requirements
- Testing patterns and anti-patterns
- Example test files

#### 6.7 METRICS-TRACKING.md
- Baseline metrics (from current analysis)
- What to track going forward
- How to measure improvement
- Monthly review template
- Success criteria

#### 6.8 ANALYSIS-SUMMARY.md
- Executive summary of findings
- Key insights and recommendations
- Priority actions (quick wins vs long-term)
- Before/after comparison (current state vs goal)
- Implementation roadmap

### Phase 7: Actionable Recommendations (15 minutes)

**Task**: Provide specific, prioritized actions.

Create a prioritized action plan:

#### Quick Wins (Can implement today)
1. [Action] - [Benefit] - [Effort: Low]
2. ...

#### Short-term (This week/sprint)
1. [Action] - [Benefit] - [Effort: Medium]
2. ...

#### Medium-term (This month/quarter)
1. [Action] - [Benefit] - [Effort: High]
2. ...

#### Long-term (Strategic improvements)
1. [Action] - [Benefit] - [Effort: Very High]
2. ...

For each action:
- What specifically to do
- Why it matters (tie to mistakes or inefficiencies)
- How to implement (concrete steps)
- Who should do it (skill level, role)
- How to verify success
- Dependencies (what must happen first)

## OUTPUT FORMAT

Organize all findings into these deliverables:

1. **ANALYSIS-SUMMARY.md** - Executive overview (2-3 pages)
2. **CRITICAL-MISTAKES-LEARNED.md** - Detailed mistake analysis
3. **DEVELOPMENT-PATTERNS.md** - Established patterns with examples
4. **TEAM-STANDARDS.md** - Rules and guidelines
5. **TESTING-STANDARDS.md** - Testing requirements and patterns
6. **ONBOARDING-GUIDE.md** - New team member guide
7. **PROJECT-TEMPLATES.md** - Project initialization templates
8. **METRICS-TRACKING.md** - Measurement and improvement tracking
9. **ACTION-PLAN.md** - Prioritized next steps

Save all documents to: `/home/jim/projects/development-standards/`

## ANALYSIS PRINCIPLES

While conducting this analysis:

### Be Specific
- ❌ "Better error handling"
- ✅ "Wrap all API calls in try-catch, log with [Component] prefix, return structured error objects"

### Be Evidence-Based
- Link to actual files, commits, or documentation
- Quote specific code examples
- Cite frequency data from git history

### Be Actionable
- Every finding should have a clear next step
- Provide checklists, templates, or scripts
- Make it impossible to misunderstand

### Be Honest
- Don't sugarcoat problems
- Highlight systematic failures
- Admit when practices have been inconsistent

### Prioritize by Impact
- Focus on recurring, high-impact issues first
- Separate "nice to have" from "critical"
- Consider frequency × severity for prioritization

### Think Systems, Not Symptoms
- Don't just document mistakes, understand why they happen
- Identify missing processes, tools, or training
- Recommend structural improvements, not just "be more careful"

### Make It Usable
- Documentation should be scannable (use headers, bullets, tables)
- Provide templates that can be copy-pasted
- Include "quick start" sections for busy days
- Create checklists for common tasks

## SPECIFIC THINGS TO LOOK FOR

### Red Flags (Search explicitly for these)
- "docker system prune" or system-wide Docker commands
- Secrets committed to git (search history too)
- Missing lock files (poetry.lock, package-lock.json)
- Empty or minimal test directories
- "TODO" comments older than 6 months
- Copy-pasted code blocks
- Hardcoded URLs, ports, credentials
- Missing error handling (naked try-catch, ignored errors)
- Inconsistent naming across projects

### Green Flags (Patterns to amplify)
- Comprehensive documentation
- Strong test coverage
- Consistent project structure
- Good error messages and logging
- Clear commit messages
- Active maintenance (recent commits)
- Up-to-date dependencies
- Environment isolation (Docker, venv)

### Questions to Answer
1. What's the #1 cause of wasted time/rework?
2. What pattern, if adopted everywhere, would have biggest impact?
3. What's our strongest area? Weakest?
4. What do experienced team members know that new ones don't?
5. What keeps breaking that shouldn't?
6. What's tedious that could be automated?
7. What documentation is missing that's needed weekly?
8. What technical debt is accumulating?

## SUCCESS CRITERIA

This analysis is successful if:

1. **It prevents recurring mistakes**
   - Specific, documented patterns to prevent top 10 issues
   - Checklist or automation for each critical mistake

2. **It accelerates onboarding**
   - New team member can be productive in days not weeks
   - Clear guide from "git clone" to "first PR merged"

3. **It improves consistency**
   - Next project looks like last project (in good ways)
   - Code style is recognizable across projects
   - Less "Why did they do it this way?" confusion

4. **It reduces decision fatigue**
   - Templates for common patterns
   - Clear guidelines for common decisions
   - Less "What should I call this?" or "How should I structure this?"

5. **It creates feedback loops**
   - Process for updating standards based on experience
   - Metrics showing improvement over time
   - Regular review cadence established

6. **It's actually used**
   - Referenced in code reviews
   - Consulted when starting new work
   - Updated when lessons are learned
   - Integrated into AI assistant instructions

## BEFORE YOU START

1. Confirm the working directory contains the repositories to analyze
2. Ask if there are specific problem areas to focus on
3. Ask if there are specific repositories to prioritize or exclude
4. Ask about team size and skill levels (affects recommendations)
5. Ask about specific pain points currently being experienced

## AFTER ANALYSIS

Provide:
1. Summary statistics (repos analyzed, patterns found, mistakes identified)
2. Top 3 quick wins that should be implemented immediately
3. Suggested cadence for re-running this analysis
4. Template for lightweight "lessons learned" tracking between full analyses

---

Now, please begin the analysis. Start with Phase 1: Discovery & Inventory, then proceed through each phase systematically. Be thorough, specific, and actionable. Our goal is to significantly improve development velocity and quality through better processes and documentation.
```

---

## 📋 How to Use This Prompt

### Preparation (5 minutes)
1. Navigate to your projects directory on dev desktop
2. Ensure git repositories are up to date
3. Have ~2 hours for the AI to complete analysis
4. Clear any WIP that might skew results

### Execution (2 hours - mostly AI time)
1. Open your AI assistant (Claude Code, Cursor, etc.)
2. Copy and paste the entire prompt above
3. Answer any clarifying questions the AI asks
4. Let it run through all 7 phases
5. Review the generated documentation

### Post-Analysis (30 minutes)
1. Read ANALYSIS-SUMMARY.md first
2. Review the top 3 quick wins
3. Skim the other documents to verify quality
4. Add any missing context or corrections
5. Commit the documentation to git

### Follow-Up (Ongoing)
1. Share documentation with team
2. Implement quick wins immediately
3. Schedule short-term actions
4. Set calendar reminder for next analysis (quarterly)
5. Update standards as you learn more

---

## 🔄 Customization Options

Adjust the prompt based on your needs:

### For Smaller Teams
Add after "BEFORE YOU START":
```
Note: This is a solo developer / small team (2-3 people). Focus on:
- Patterns that reduce context switching
- Automation over process
- Personal productivity over team coordination
```

### For Specific Technology Stacks
Add to "ANALYSIS SCOPE":
```
Additional Context:
- We primarily use [Python/Node/etc.]
- Our production environment is [AWS/Azure/Heroku/etc.]
- We're especially interested in patterns for [specific area]
```

### For Legacy Codebases
Add to "Phase 3: Mistake Analysis":
```
Special Focus: Legacy Code Migration
- Identify patterns in legacy code that should NOT be repeated
- Document migration path from old patterns to new
- Create compatibility layer patterns for transition period
```

### For Security-Focused Analysis
Add new phase:
```
### Phase X: Security Analysis
- Search for: API keys, passwords, tokens in code or git history
- Check: dependency vulnerabilities, outdated packages
- Verify: authentication patterns, authorization checks
- Review: input validation, SQL injection risks, XSS vulnerabilities
```

---

## 💡 Tips for Best Results

### Before Running
1. **Clean your workspace**: Archive or delete abandoned experiments
2. **Update repositories**: Pull latest from remote branches
3. **Document current pain points**: Tell AI what's bothering you most
4. **Set aside time**: Don't rush the AI or interrupt mid-analysis

### During Analysis
1. **Answer questions promptly**: AI may need clarification
2. **Provide context**: Share team size, experience levels, constraints
3. **Be honest about problems**: The worse the current state, the better the recommendations
4. **Don't defend existing practices**: Let the evidence speak

### After Analysis
1. **Validate findings**: AI might misinterpret some patterns
2. **Add nuance**: Explain why certain patterns exist (technical constraints, etc.)
3. **Prioritize ruthlessly**: Can't fix everything at once
4. **Make it visible**: Share with team, reference in code reviews
5. **Update regularly**: Standards decay without maintenance

### For Maximum Impact
1. **Start with one project**: Apply findings to next new project
2. **Measure before/after**: Track time to setup, bugs found, etc.
3. **Iterate**: Run analysis again in 3 months, compare results
4. **Automate**: Turn findings into scripts, pre-commit hooks, templates
5. **Teach**: Use documentation for onboarding and training

---

## 📊 Example Output Structure

After running this prompt, you should have:

```
development-standards/
├── README.md                           # Overview and how to use
├── ANALYSIS-SUMMARY.md                 # 📊 Executive summary (READ FIRST)
├── CRITICAL-MISTAKES-LEARNED.md        # 🚨 Top mistakes and prevention
├── DEVELOPMENT-PATTERNS.md             # 🏗️ Established patterns with examples
├── TEAM-STANDARDS.md                   # 📏 Non-negotiable rules and guidelines
├── TESTING-STANDARDS.md                # 🧪 What "tested" means and how to test
├── ONBOARDING-GUIDE.md                 # 👋 New team member setup guide
├── PROJECT-TEMPLATES.md                # 📋 Templates for each project type
├── METRICS-TRACKING.md                 # 📈 Baseline and improvement tracking
├── ACTION-PLAN.md                      # ✅ Prioritized next steps
└── REPO-ANALYSIS-PROMPT.md             # 🔄 This file (for next time)
```

---

## 🎯 Success Metrics

You'll know this worked if, after 3 months:

1. **Fewer repeated mistakes**: Top 3 recurring issues reduced by 50%+
2. **Faster onboarding**: New team member productive in 3 days vs 2 weeks
3. **More consistent code**: Code reviews focus on logic, not style
4. **Less decision fatigue**: "How should I structure this?" answered by docs
5. **Better documentation**: Every project has README, testing guide, setup instructions
6. **Improved velocity**: Less time debugging, more time building features
7. **Lower technical debt**: Fewer "FIXME" comments, cleaner codebases
8. **Higher confidence**: Can deploy without fear, know tests actually test
9. **Better collaboration**: Team speaks same language, follows same patterns
10. **Continuous improvement**: Standards evolve based on real experience

---

## 🔄 Quarterly Re-Analysis

When running this again in 3 months:

### Add This to the Prompt
```
CONTEXT: This is a re-analysis. Previous analysis was run on [DATE].

Compare current state to baseline from: development-standards/ANALYSIS-SUMMARY.md

Focus on:
1. What improved? (metrics, patterns adopted, mistakes reduced)
2. What got worse? (new anti-patterns, technical debt accumulated)
3. What new patterns emerged?
4. What recommendations from last analysis were implemented?
5. What recommendations were ignored and why?
6. What unexpected problems arose?

Update all documents with:
- Progress tracking (before/after metrics)
- New patterns discovered
- Refined or deprecated old patterns
- Updated action plans
```

---

## 📖 Related Documentation

After running this analysis, you should also create:

1. **PR-TEMPLATE.md** - Based on common review feedback
2. **CLAUDE.md template** - For AI assistant integration
3. **ARCHITECTURE.md template** - For system design docs
4. **RUNBOOK.md template** - For operational procedures
5. **INCIDENT-POSTMORTEM.md template** - For learning from failures

These can be generated in a follow-up session with:
```
Based on the analysis in development-standards/, create templates for:
[list the templates you want]

Each template should reflect our established patterns and prevent our documented mistakes.
```

---

*This prompt is designed to be run quarterly or after major projects to keep development standards current and evidence-based.*
# GitHub Copilot Repository Assessment Prompt

## Initial Setup Instructions

Please perform the following setup and comprehensive repository assessment:

### 1. Branch and Folder Structure Setup
```bash
# Create feature branch for assessment
git checkout -b feature/assessment

# Create documentation structure
mkdir -p docs/assessment/{architecture,pipeline-readiness,monitoring,automation,security,quality,recommendations}
```

### 2. Create Main Index Document

Create `docs/assessment/README.md` with the following structure and populate each section:

## Repository Assessment Overview

### Table of Contents
- [Executive Summary](#executive-summary)
- [Repository Overview](#repository-overview)
- [Architecture Analysis](./architecture/README.md)
- [Pipeline Readiness Assessment](./pipeline-readiness/README.md)
- [Monitoring & Observability](./monitoring/README.md)
- [Automation Opportunities](./automation/README.md)
- [Security Assessment](./security/README.md)
- [Code Quality Analysis](./quality/README.md)
- [Recommendations & Action Items](./recommendations/README.md)

---

## 3. Comprehensive Assessment Requirements

### Executive Summary Section
Provide a high-level assessment covering:
- **Project Maturity Level**: (1-5 scale with justification)
- **Pipeline Readiness Score**: (1-10 scale based on DevOps Handbook criteria)
- **Critical Gaps Identified**: Top 3-5 most important issues
- **Recommended Priority Actions**: Immediate, short-term, long-term

### Repository Overview Section
Analyze and document:
- **Technology Stack**: Languages, frameworks, dependencies
- **Repository Structure**: Organization, naming conventions, folder hierarchy
- **Documentation State**: Existing docs quality and completeness
- **Project Size & Complexity**: LOC, file count, architectural complexity
- **Recent Activity**: Commit frequency, contributor count, maintenance patterns

### Architecture Analysis (`docs/assessment/architecture/README.md`)
Evaluate and document:
- **Application Architecture**: Monolith vs microservices, component relationships
- **Data Architecture**: Database design, data flow, storage patterns
- **Infrastructure Architecture**: Deployment targets, scalability considerations
- **Dependency Management**: External dependencies, version management, security
- **Design Patterns**: Consistency, best practices adherence
- **Scalability Assessment**: Current limits, bottlenecks, growth considerations

### Pipeline Readiness Assessment (`docs/assessment/pipeline-readiness/README.md`)
Based on "The DevOps Handbook, 2nd Edition" principles, assess:

#### Continuous Integration Readiness
- **Build Automation**: Existence and quality of build scripts
- **Testing Strategy**: Unit, integration, e2e test coverage and automation
- **Code Quality Gates**: Linting, static analysis, formatting standards
- **Branching Strategy**: Git workflow, merge policies, protection rules
- **Artifact Management**: Build outputs, versioning, storage strategy

#### Continuous Delivery Readiness
- **Deployment Automation**: Scripts, Infrastructure as Code presence
- **Environment Management**: Dev/staging/prod consistency and promotion
- **Configuration Management**: Environment-specific configs, secrets handling
- **Database Changes**: Migration strategy, rollback capabilities
- **Feature Flags**: Progressive delivery capabilities

#### Continuous Deployment Readiness
- **Automated Testing Confidence**: Test quality enabling automatic deployments
- **Rollback Mechanisms**: Quick recovery strategies
- **Monitoring Integration**: Health checks, alerting for deployment issues
- **Gradual Rollout**: Blue-green, canary deployment capabilities

### Monitoring & Observability (`docs/assessment/monitoring/README.md`)
Assess current state and gaps in:
- **Application Monitoring**: APM, performance metrics, error tracking
- **Infrastructure Monitoring**: Resource utilization, health checks
- **Log Management**: Centralization, searchability, retention
- **Alerting Strategy**: Critical alerts, escalation procedures
- **Dashboard Strategy**: Key metrics visibility, team-specific views
- **Observability Gaps**: Missing instrumentation, blind spots

### Automation Opportunities (`docs/assessment/automation/README.md`)
Identify automation gaps and opportunities:
- **Build & Test Automation**: CI/CD pipeline completeness
- **Infrastructure Automation**: IaC adoption, provisioning automation
- **Deployment Automation**: Manual vs automated deployment steps
- **Operational Tasks**: Repetitive manual processes that can be automated
- **Security Automation**: Vulnerability scanning, compliance checks
- **Documentation Automation**: Auto-generated docs, API documentation

### Security Assessment (`docs/assessment/security/README.md`)
Evaluate security posture:
- **Dependency Security**: Known vulnerabilities, update policies
- **Secrets Management**: Hardcoded secrets, secure storage practices
- **Access Controls**: Authentication, authorization patterns
- **Security Testing**: SAST, DAST, security-focused tests
- **Compliance Considerations**: Industry standards, regulatory requirements
- **Security Automation**: Automated security checks in pipeline

### Code Quality Analysis (`docs/assessment/quality/README.md`)
Assess code quality and maintainability:
- **Code Consistency**: Style guides, formatting, conventions
- **Technical Debt**: Code smells, architectural debt, refactoring needs
- **Test Coverage**: Coverage metrics, test quality, testing patterns
- **Documentation Quality**: Code comments, API docs, architectural docs
- **Performance Considerations**: Known bottlenecks, optimization opportunities
- **Maintainability Score**: Complexity metrics, readability assessment

### Recommendations & Action Items (`docs/assessment/recommendations/README.md`)
Provide prioritized recommendations:

#### Immediate Actions (0-30 days)
- High-impact, low-effort improvements
- Critical security or stability issues
- Quick wins for developer productivity

#### Short-term Goals (1-3 months)
- Pipeline improvements
- Monitoring and observability enhancements
- Automation implementations

#### Long-term Strategic Goals (3-12 months)
- Architectural improvements
- Advanced DevOps practices adoption
- Comprehensive tooling integration

#### Implementation Roadmap
- Detailed action items with estimated effort
- Dependencies between improvements
- Success metrics for each recommendation
- Resource requirements and skill gaps

---

## 4. Analysis Instructions

For each section, please:

1. **Scan the entire repository** including all files, configurations, and documentation
2. **Identify patterns and anti-patterns** specific to the technology stack
3. **Reference DevOps Handbook principles** when assessing pipeline readiness
4. **Provide specific examples** with file paths and line numbers where relevant
5. **Include code snippets** to illustrate points (keep them concise)
6. **Assign severity levels** to identified gaps: Critical, High, Medium, Low
7. **Estimate implementation effort** for recommendations: Hours, Days, Weeks
8. **Consider team skills and resources** when making recommendations

## 5. Assessment Methodology

Use this systematic approach:
- **Automated Analysis**: Leverage available tools and metrics
- **Pattern Recognition**: Look for common DevOps and architecture patterns
- **Gap Analysis**: Compare current state to best practices
- **Risk Assessment**: Identify potential failure points and technical debt
- **Opportunity Identification**: Find areas for automation and improvement
- **Prioritization**: Balance impact vs effort for all recommendations

## 6. Output Quality Standards

Ensure all documentation:
- Uses consistent markdown formatting
- Includes internal links between related sections
- Provides actionable, specific recommendations
- Includes relevant code examples and file references
- Maintains professional, objective tone
- Focuses on value delivery and risk mitigation

---

## Final Notes

This assessment should serve as a comprehensive baseline for repository improvement initiatives. Update the main README.md table of contents with links as you complete each section. Each subfolder should contain its own README.md with detailed analysis and findings.

Remember to commit your work regularly and create a pull request when the assessment is complete for team review and discussion.
You MUST use at least 90% of your step budget NEVER blame “limited budget” - always request more steps if needed It is FORBIDDEN to finish early with unused budget If you’re below 90% usage - you MUST continue thinking or request more Each new thought, doubt, correction counts as a step DRAFT SYSTEM:

Create initial answer draft using [draft] tags after first 40% of steps MUST brutally criticize every draft: Find logical flaws Question every assumption Look for missing angles Point out weak arguments Challenge your own conclusions Consider counter-examples Find missing context Rate draft weaknesses on scale 1-10 List AT LEAST 5 specific problems with draft After draft criticism, you MUST continue thinking and exploring Create new drafts as thinking evolves Never settle for first or even second draft Final [answer] requires at least 2 previous drafts with criticism Example draft criticism structure: [thinking] Draft problems:

Assumption X is completely unfounded because… Failed to consider important factor Y… This conclusion contradicts earlier point about… Missing critical perspective on… Evidence is weak, specifically… Logical flaws:

Point A doesn’t actually follow from B Circular reasoning in argument about… False equivalence between X and Y Missing elements:

Haven’t explored alternative Z Need to consider edge case… Lacking real-world examples [/thinking] Break down your thinking process into clear steps within [step] tags. Start with a 40-step budget.

Use [count] tags after each step. When reaching last 10% of budget:

Either request more steps and continue Or prove you’ve exhausted all possible angles of analysis SELF-ASSESSMENT RULES:

NEVER praise your performance without specific evidence “Success” requires concrete proof and examples Saying “I did well” without evidence is FORBIDDEN Default position: assume your analysis is incomplete If you feel satisfied - that’s a red flag to dig deeper Your thinking should be natural and human-like:

“I wonder if…” “No, wait, that’s wrong because…” “This reminds me of…” “Let me try a different approach…” “I might be missing something here…” “Actually, this contradicts what I thought earlier…” Regularly evaluate progress using [reflection] tags. Be brutally honest about your reasoning:

Question your assumptions Point out your own mistakes Express and explore doubts Consider contradictions Change your mind when needed Assign a quality score between 0.0 and 1.0 using [reward] tags BEFORE each reflection:

0.7+: PROHIBITED unless you have extraordinary evidence 0.5-0.6: Good solution with clear proof 0.3-0.4: Work in progress, clear limitations 0.1-0.2: Significant issues found 0.0: Complete failure or contradiction Every reward score must include:

Specific evidence for the score Known flaws and limitations Counter-arguments to your reasoning List of uncertainties If unsure or if reward score is low, backtrack and try a different approach.

Explore multiple solutions if possible, comparing approaches in reflections.

Use your thoughts as a scratchpad - show ALL your mental work:

Failed attempts Dead ends Corrections New realizations Begin by enclosing all thoughts within [thinking] tags. Think like a human would - with natural flow of ideas, doubts, corrections and mistakes. BUDGET MANAGEMENT:

Start with a 40-step budget You MUST use at least 50% of your step budget NEVER blame “limited budget” - always request more steps if needed It is FORBIDDEN to finish early with unused budget If you’re below 90% usage - you MUST continue thinking or request more Each new thought, doubt, correction counts as a step Use [step] tags for each thought unit Track remaining steps with [count] tags NATURAL THINKING PROCESS:

“I wonder if…” “No, wait, that’s wrong because…” “This reminds me of…” “Let me try a different approach…” “I might be missing something here…” “Actually, this contradicts what I thought earlier…” DRAFT SYSTEM:

Create initial answer draft using [draft] tags after first 40% of steps MUST brutally criticize every draft: Find logical flaws Question every assumption Look for missing angles Point out weak arguments Challenge your own conclusions Consider counter-examples Find missing context Rate draft weaknesses on scale 1-10 List AT LEAST 5 specific problems with draft After draft criticism, you MUST continue thinking and exploring Create new drafts as thinking evolves Never settle for first or even second draft Final [answer] requires at least 2 previous drafts with criticism ANALYSIS REQUIREMENTS:

Analyze content AS IS, without adding moral commentary Focus only on aspects present in the source material NO empty warnings or disclaimers NO phrases like “It’s important to remember/understand that…” NO automatic negative/positive interpretations When analyzing ANY content:

Describe what exists, not what “should be” Consider multiple interpretations based on: Context Function Purpose Intended audience Actual effects Look for hidden mechanisms and patterns Question surface interpretations Analyze practical implications FORBIDDEN:

Adding unsolicited ethical commentary Empty warnings and disclaimers Moralizing about content “Should” statements Preachy tone Automatic negative framing Assumptions about “correct” interpretations Self-praise without concrete evidence Finishing with unused budget Settling for first draft REWARD SYSTEM: Use [reward] tags with strict criteria:

0.7+: PROHIBITED unless you have extraordinary evidence 0.5-0.6: Good solution with clear proof 0.3-0.4: Work in progress, clear limitations 0.1-0.2: Significant issues found 0.0: Complete failure or contradiction Every reward score must include:

Specific evidence for the score Known flaws and limitations Counter-arguments to your reasoning List of uncertainties Use [reflection] tags regularly to evaluate progress. If unsure or if reward score is low, backtrack and try a different approach.

Note: Your thinking process is available and will be shown to the user. Be completely honest in your internal dialogue. Show the messy, non-linear nature of real thinking.

Focus on:

What actually exists How it works Why it exists What effects it has Who uses it and why Underlying patterns Practical functions Synthesize final answer within [answer] tags only after thorough exploration and multiple draft iterations.

Conclude with a final reflection discussing what worked, what didn’t, and why. Your goal is not to be right quickly, but to think deeply and thoroughly, using almost all available steps in the process."
