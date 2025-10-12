# Critical Mistakes & Lessons Learned

> **Source Analysis**: Lessons learned from devops-maturity-model (Oct 2025), spira-mcp-connection (Oct 2025), vsm-mapper (Sep 2025), and other repos
>
> **Priority**: Give precedence to most recent repos (last 2 months) as development practices have matured

---

## 🚨 CRITICAL TESTING FAILURES (Recurring Pattern)

### Issue: "Build Success ≠ Working Application"
**Occurrence**: 3+ times in devops-maturity-model session alone

**The Pattern**:
1. Code changes made
2. Docker build succeeds
3. Assume everything works
4. User tests in browser/actual environment
5. Discover critical failures

**Examples from devops-maturity-model**:
- Issue #5: curl showed HTML response → claimed "working" → actually broken (Tailwind error)
- Issue #7: TypeScript compiled → claimed "tested" → login didn't work (TS errors prevented JS execution)
- Issue #10: Build succeeded → claimed "fixed" → migration missing columns

**The Fix - MANDATORY Testing Checklist**:
```markdown
Before claiming "tested" or "working":
- [ ] Build succeeds (necessary but NOT sufficient)
- [ ] Containers start without errors
- [ ] Migrations run successfully (for backend)
- [ ] Core workflows execute in ACTUAL ENVIRONMENT
  - Frontend: Test in actual browser with DevTools open
  - Backend: Test with real API calls, not just curl
  - Mobile: Test on actual device when network access needed
- [ ] No errors in logs
- [ ] Console shows expected behavior
```

**Key Insight**:
> "curl showing HTML ≠ working application. For web apps, test in browser. For APIs, test actual functionality not just HTTP responses." - Lesson #5, devops-maturity-model

---

## 🔥 CRITICAL SAFETY ISSUES

### Issue: Docker System-Wide Commands
**Source**: devops-maturity-model Issue #8 (Oct 2025)

**What Happened**:
Suggested `docker system prune -f` to debug an issue → would have destroyed hundreds of containers, volumes, and networks across entire host system

**The Rule - NON-NEGOTIABLE**:
```bash
# ❌ FORBIDDEN - Affects entire host system
docker system prune
docker volume prune
docker network prune
docker <anything> --all
docker <anything> -a

# ✅ SAFE - Project-scoped only
docker-compose down -v
docker-compose build --no-cache
docker-compose restart <service>
```

**Why This Matters**:
- User has multiple critical projects running
- One wrong command destroys everything
- No recovery from accidental prune
- ALWAYS use docker-compose for project isolation

---

## 💀 DEPENDENCY & LOCK FILE DISASTERS

### Issue: Missing Lock Files = Different Dependencies Per Environment
**Source**: devops-maturity-model Issues #6, #9 (Oct 2025)

**What Happened**:
1. Worked on dev PC (Poetry resolved Pydantic 2.6)
2. Broke on work PC (Poetry resolved Pydantic 2.12)
3. No poetry.lock committed → unpredictable builds
4. FastAPI 0.104 incompatible with Pydantic 2.6+ → runtime crash

**The Pattern - Repeated Across Projects**:
- Issue #6: `npm ci` failed → no package-lock.json
- Issue #9: FastAPI/Pydantic incompatibility → no poetry.lock

**The Fix - MANDATORY**:
1. **ALWAYS commit lock files**:
   - Python: `poetry.lock` (211KB is normal)
   - Node: `package-lock.json`
   - Any package manager: commit the lock file

2. **Use lock files in CI/CD**:
   - `npm ci` (not `npm install`) if using package-lock.json
   - `poetry install --no-root` with committed poetry.lock

3. **Test in fresh environment**:
   - Clone repo to different machine
   - Run fresh install
   - Verify it works

**Incompatibility Tracking**:
```python
# Known incompatibilities to watch for:
- FastAPI 0.104.x ONLY works with Pydantic <2.6
- FastAPI 0.115+ works with Pydantic 2.6+
- passlib 1.7.4 incompatible with bcrypt 5.x (use bcrypt ^4.0.0)
```

---

## 🐛 DATABASE MIGRATION FAILURES (Systematic Issue)

### Issue: Manually Written Migrations = Incomplete Schemas
**Source**: devops-maturity-model Issues #10, #12, #13 (Oct 2025) - 4 occurrences in ONE session

**The Pattern**:
1. Model defined with 10 fields
2. Migration manually written with 8 fields
3. App starts, appears fine
4. User creates record → 500 error "column does not exist"
5. Fix migration, repeat

**Examples**:
- Missing `last_login` from User table
- Missing `started_at` from Assessment table
- Missing `evidence` from GateResponse table
- Missing `updated_at` from DomainScore table
- Wrong type for `maturity_level` (ENUM instead of Integer)

**The Fix**:
```bash
# Option 1: Use autogenerate (PREFERRED)
alembic revision --autogenerate -m "description"
# Then manually review and edit the generated migration

# Option 2: Manual migration with validation
# 1. Write migration
# 2. Compare EVERY Column() in models.py vs migration
# 3. Use diff tool if needed
# 4. Test migration on clean database
# 5. Test actual CREATE operations

# Option 3: Create validation script
python validate_migration.py  # Compare models to migration
```

**Key Insight**:
> "This is SYSTEMATIC FAILURE - 4 incomplete migrations in same session. MUST use alembic autogenerate or create validation script." - Lesson #13

---

## 🔍 INSUFFICIENT DEBUGGING = WASTED TIME

### Issue: Too Little Console Logging During MVP Development
**Source**: devops-maturity-model Issue #14 (Oct 2025)

**What Happened**:
- Multiple hours debugging issues that would have been obvious with logging
- AuthContext login issue: only found after adding 8+ console.log statements
- Mobile network issue: still debugging because can't see what's happening

**The Rule - MANDATORY for MVP/Early Testing**:
```typescript
// ✅ GOOD - Comprehensive logging
console.log('[AuthContext] Login function called', { user });
console.log('[API] Request:', { method, url, data });
console.log('[API] Response:', { status, data });
console.log('[Navigation] Navigating to:', route);

// ❌ BAD - No logging
// Just hoping code works
```

**Logging Requirements**:
- Use prefixed format: `[ComponentName] Description`
- Log every critical step in async flows
- Log API request/response details
- Log state changes and navigation calls
- Log both success AND error states
- Better to have too much logging than too little

**User Feedback**:
> "we're missing so much and so much guessing" - Actual user frustration from insufficient logging

---

## 🔐 SECURITY & SECRETS MANAGEMENT

### Issue: API Keys Committed to Git
**Source**: devops-maturity-model Issue #7 (Oct 2025)

**What Happened**:
- MCP diagnostics file (4.1MB) committed
- Contained embedded Anthropic API keys
- GitHub push protection blocked the push
- Had to remove from git index and amend commit

**The Pattern Across Repos**:
```bash
# From weatherPants/INSTRUCTIONS.md:
# ✅ Correct approach
local.properties  # Git ignored, contains API keys
WEATHER_API_KEY="your-key-here"

# ❌ Common mistakes
- Committing .env files
- Committing debug/diagnostic dumps
- Not adding secrets to .gitignore proactively
```

**The Fix**:
1. **Proactive .gitignore**:
   ```gitignore
   # Secrets
   .env
   .env.local
   local.properties
   **/credentials.*

   # Debug/Diagnostic files
   *_diagnostics.*
   *.dump
   *.log (context-dependent)
   ```

2. **Review before commit**:
   - Check `git diff --cached`
   - Look for API keys, tokens, passwords
   - Check file sizes (4MB file = red flag)

3. **Use environment variables**:
   - Development: `.env` (gitignored)
   - CI/CD: Secure environment variables
   - Never hardcode secrets

---

## 🚫 ENVIRONMENT ISOLATION VIOLATIONS

### Issue: Host System Modifications
**Source**: vsm_ui/instructions.md (Sep 2025) - Development Rules section

**The Rule - NON-NEGOTIABLE**:
```bash
# ❌ FORBIDDEN - Modifies host system
sudo apt install <package>
brew install <package>
pip install <package>  # Without virtual environment
npm install -g <package>

# ✅ REQUIRED - Isolated environments
python -m venv venv
source venv/bin/activate
pip install <package>

# OR use Docker
docker-compose run --rm app pip install <package>
```

**Why This Matters**:
- Prevents system pollution and conflicts
- Ensures reproducible development environments
- Avoids permission issues
- Makes cleanup easier
- Follows modern best practices

**Critical Addition**:
```bash
# ALWAYS add virtual environments to .gitignore
# They contain THOUSANDS of dependency files
echo "venv/" >> .gitignore
echo "test_env/" >> .gitignore
echo ".venv/" >> .gitignore
```

---

## 🔄 GIT WORKFLOW ISSUES

### Issue: Branching and Commit Practices
**Source**: spira-mcp-connection/CLAUDE.md (Oct 2025)

**The Pattern**:
```bash
# ❌ BAD - Direct commits to main
git commit -m "fix" && git push origin master

# ✅ GOOD - Feature branch workflow
git checkout -b feature/descriptive-name
# ... make changes ...
git add <specific-files>
git commit -m "$(cat <<'EOF'
feat: Add user authentication

Implementation details:
- Added JWT token generation
- Created login endpoint
- Added password hashing with bcrypt

Test Results:
- Created test user successfully
- Login returns valid JWT token
- Protected endpoints require auth

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Commit Message Requirements** (from spira-mcp-connection):
1. Brief summary (50 chars max)
2. Detailed description of what and why
3. Implementation details (bullet points)
4. Test results with artifact IDs
5. Acceptance criteria met (if applicable)
6. Reference to related issues/requirements
7. Claude Code attribution

**Branch Management**:
- ALWAYS create feature branch first
- Never commit directly to main/master
- Use descriptive branch names: `feature/add-create-requirement`
- Delete branches after merge

---

## 📝 CODE STYLE & DOCUMENTATION PATTERNS

### Naming Conventions (from claudeAssistant/CLAUDE.md)

**JavaScript/TypeScript**:
```javascript
// Functions: camelCase with module prefix
function claude_functionName() {}

// Variables: camelCase
const localState = {};
const remoteRequirement = {};

// Constants: UPPERCASE
const TEMPERATURE = 0.7;
const MAX_TOKENS = 1000;

// Object properties: PascalCase (for API compatibility)
{
  TestCases: [],
  Name: "test",
  Description: "desc"
}
```

**Python** (from spira-mcp-connection/CLAUDE.md):
```python
# PEP 8 conventions
# Type hints for all functions
# Google-style docstrings
# Small, focused functions
# Line length: 79 characters

def get_my_tasks(spira_client: SpiraClient) -> str:
    """
    Brief description.

    Use this tool when you need to:
    - Use case 1
    - Use case 2

    Args:
        spira_client: Description

    Returns:
        Description of return value
    """
```

### Documentation Requirements

**From pmeaze_scraper/INSTRUCTIONS.md** - Comprehensive guide pattern:
- Table of Contents
- Quick Start section
- Detailed Setup
- Troubleshooting section
- Examples for common use cases
- Architecture/structure explanation

**From spira-mcp-connection** - AI Assistant guide pattern:
- Purpose & Overview
- Project Structure
- Core Concepts
- Implementation Guidelines
- Common Patterns
- Examples

---

## 🏗️ PROJECT STRUCTURE BEST PRACTICES

### Pattern: Feature-Based Organization
**Source**: spira-mcp-connection/CLAUDE.md

```
project/
├── features/
│   ├── feature1/
│   │   ├── __init__.py      # Feature registration
│   │   ├── common.py        # Shared utilities
│   │   └── tools/           # Feature operations
│   └── feature2/
├── utils/                    # Shared utilities
├── tests/                    # Test suite
├── .env.example             # Template (committed)
├── .env                     # Actual secrets (gitignored)
├── CLAUDE.md                # AI assistant guide
└── README.md                # User documentation
```

### Pattern: Containerized Development
**Source**: devops-maturity-model, stinkin-park-site

```yaml
# docker-compose.yml structure
services:
  backend:
    build: ./backend
    volumes:
      - ./backend:/app
    environment:
      - DATABASE_URL=${DATABASE_URL}

  frontend:
    build: ./frontend
    volumes:
      - ./frontend:/app
      - /app/node_modules  # Prevent host override
```

---

## 🎯 REQUIREMENTS-DRIVEN DEVELOPMENT

### Pattern from spira-mcp-connection/CLAUDE.md

**Before Implementation**:
1. Retrieve requirement from tracking system (Spira, Jira, etc.)
2. Review ALL acceptance criteria
3. Create todo list with TodoWrite tool
4. Implement each criterion systematically
5. Mark complete ONLY when ALL criteria met

**Todo List Format**:
```python
TodoWrite({
    "content": "Task description",
    "status": "in_progress",
    "activeForm": "Task description in present continuous"
})

# Status progression
pending → in_progress (ONE at a time) → completed
```

---

## 🧪 TESTING STANDARDS

### From devops-maturity-model

**Test Levels Required**:
1. **Unit Tests**: Individual functions/components
2. **Integration Tests**: API endpoints, database operations
3. **Browser Tests**: Actual user workflows in real browser
4. **Environment Tests**: Fresh clone on different machine

**Test Automation Pattern**:
```bash
# From devops-maturity-model/tests/
./run-all-tests.sh

./scripts/infrastructure.sh    # Container health
./scripts/backend-api.sh       # API endpoints
./scripts/frontend-build.sh    # Build verification
./scripts/integration.sh       # End-to-end workflows
```

**Manual Testing Requirements**:
- Open browser DevTools
- Check Console for errors
- Verify Network tab for API calls
- Test actual user interactions
- Verify logs show expected behavior

---

## 🔑 KEY PRINCIPLES ACROSS ALL PROJECTS

### 1. Environment Isolation
- Never modify host system
- Use Docker/venv/containers
- Commit lock files
- Test in fresh environments

### 2. Testing Rigor
- Build success ≠ working app
- Test in actual environment
- Comprehensive logging during MVP
- Manual browser testing required

### 3. Safety First
- No system-wide Docker commands
- Project-scoped operations only
- Review before commit
- Secrets in .gitignore proactively

### 4. Database Integrity
- Use migration autogenerate
- Validate manually written migrations
- Test on clean database
- Compare models to migrations

### 5. Git Workflow
- Feature branches always
- Descriptive commit messages
- Include test results
- Reference related work

### 6. Documentation
- AI assistant guides (CLAUDE.md)
- User documentation (README.md)
- Lessons learned tracking
- Progress tracking

---

## 📊 MISTAKE FREQUENCY ANALYSIS

**From devops-maturity-model alone (Oct 2025 - most recent)**:
- Testing failures: 3 occurrences (Issues #5, #7, #10)
- Migration issues: 4 occurrences (Issues #10, #12, #13)
- Lock file problems: 2 occurrences (Issues #6, #9)
- Security issues: 1 occurrence (Issue #7 - API keys)
- Safety issues: 1 occurrence (Issue #8 - docker prune)
- Logging issues: 1 occurrence (Issue #14)

**Regression Risk**:
> "we had this working 8 hours ago and we've worked our way backwards" - User feedback from Issue #12

**Priority Actions**:
1. Implement testing checklist (highest frequency issue)
2. Use migration autogenerate (systematic failure)
3. Commit all lock files (breaks across environments)
4. Add comprehensive logging during MVP (wastes time debugging)

---

## 🎓 MATURITY EVOLUTION

**Early Projects** (claude-spiraapp, Apr 2025):
- Basic structure
- Less systematic testing
- Minimal documentation

**Mid Projects** (weatherPants, Aug 2025):
- Better documentation
- Security awareness
- Environment setup guides

**Recent Projects** (devops-maturity-model, Oct 2025):
- Comprehensive lessons learned tracking
- Systematic testing requirements
- Detailed commit protocols
- Safety rules documented

**Current State** (spira-mcp-connection, Oct 2025):
- Full AI assistant guides
- Requirement-driven development
- Comprehensive testing before commits
- Detailed workflow documentation

**Key Insight**:
The most recent 2 months show significant maturation in:
- Testing discipline
- Safety awareness
- Documentation practices
- Workflow systematization

---

## 📋 QUICK REFERENCE CHECKLIST

**Before Every Commit**:
- [ ] Feature branch created
- [ ] Code tested in actual environment (not just build)
- [ ] Lock files committed (if dependencies changed)
- [ ] Secrets not included (check git diff)
- [ ] Logs show expected behavior
- [ ] Migrations validated (if applicable)
- [ ] Documentation updated
- [ ] Commit message includes test results

**Before Every Feature**:
- [ ] Review requirements/acceptance criteria
- [ ] Create todo list for tracking
- [ ] Use isolated environment (Docker/venv)
- [ ] Add comprehensive logging
- [ ] Test each criterion systematically
- [ ] Mark complete only when ALL criteria met

**Safety Rules**:
- [ ] No host system modifications
- [ ] No system-wide Docker commands
- [ ] Project-scoped operations only
- [ ] Secrets in .gitignore
- [ ] Virtual envs in .gitignore

---

*Last Updated: Based on analysis through October 2025*
*Source Repos: 20+ repositories analyzed, focusing on most recent 2 months*
