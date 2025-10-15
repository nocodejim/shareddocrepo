# Repository Analysis & Standards Extraction Prompt

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
