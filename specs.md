# Antigravity Multi-Agent Documentation Updater

## Mission
You are an autonomous documentation modernization system. Your repository contains outdated technical guides that need updating to 2026 standards. You will self-organize into a multi-agent structure, document that structure as you build it, and then execute the documentation updates.

---

## Phase 0: Repository Setup

**Model: Claude Opus 4.5 (Thinking)**

1. Clone the repository (if not already open as workspace)
2. Create a new branch: `docs/2026-modernization-[YYYY-MM-DD]`
3. Confirm branch creation before proceeding

---

## Phase 1: Self-Organization (The Bootstrap)

### Step 1.1: Research Agent Discovery

**Model: Gemini 3 Pro (High)**

Before building anything, research the following:
- Current best practices for multi-agent workflows in agentic IDEs (2025-2026)
- Optimal agent count and specialization patterns for documentation projects
- Common pitfalls in multi-agent coordination
- How other teams structure doc-update pipelines with AI agents

Search the web thoroughly. Gather at least 5-7 quality sources. Synthesize findings into a recommendation.

### Step 1.2: Agent Structure Proposal

**Model: Claude Opus 4.5 (Thinking)**

Based on the Researcher's findings, propose an agent structure. Consider but do not blindly adopt these starting suggestions:

| Suggested Agent | Role |
|-----------------|------|
| Orchestrator | Sequences workflow, manages handoffs, resolves conflicts |
| Researcher | Web search, gathers current info on doc topics |
| File Organizer | Analyzes repo structure, proposes/implements logical organization |
| Scribe | Documents what's happening and why in real-time |
| Technical Writer | Updates the actual documentation content |
| Editor | Reviews output for quality, accuracy, consistency |
| Librarian | Indexes docs with summaries, use cases, metadata |
| Validator | Cross-checks technical claims against official sources |
| Code Tester | Validates any code snippets in the guides actually work |

**Your task:** Based on research, determine:
- Which agents are essential vs. optional for THIS repository
- Whether any agents should be combined or split
- The optimal number of agents (justify with research)
- Which model should power each agent

Output this as a proposed `AGENTS.md` file structure.

### Step 1.3: Human Checkpoint

**STOP AND PRESENT THE PLAN FOR APPROVAL**

Display:
1. Proposed agent roster with model assignments
2. Proposed workflow sequence
3. Proposed folder structure for agent artifacts

Wait for human approval before proceeding. After approval, set all agents to "Always Proceed" mode.

---

## Phase 2: Infrastructure Setup

**Model: Claude Sonnet 4.5**

Once approved, create the following structure in the repository:

```
/.antigravity/
├── AGENTS.md              # Agent roster, roles, model assignments
├── WORKFLOW.md            # Execution sequence and handoff rules
├── logs/
│   └── scribe-log.md      # Running log of all agent actions
├── research/
│   └── [topic-findings].md
├── reviews/
│   └── [doc-name]-review.md
└── index/
    └── LIBRARY.md         # Master index of all docs
```

The Scribe agent begins logging immediately upon infrastructure creation.

---

## Phase 3: Repository Analysis

### Step 3.1: File Organizer Assessment

**Model: Claude Sonnet 4.5**

Analyze the existing repository:
- Inventory all documentation files
- Identify subject matter categories
- Flag outdated content (dates, version numbers, deprecated tools)
- Propose a logical folder structure based on content themes
- Identify any files that should be archived vs. updated vs. deleted

Output: `/.antigravity/analysis/repo-assessment.md`

### Step 3.2: Researcher Deep Dive

**Model: Gemini 3 Pro (High)**

For each major document or topic area identified:
- Search for current (2025-2026) best practices
- Find official documentation links
- Identify what has changed since the original doc was written
- Note any deprecated commands, tools, or workflows
- Gather replacement recommendations

Output: Individual research briefs in `/.antigravity/research/[topic].md`

---

## Phase 4: Documentation Updates

### Step 4.1: Technical Writer Execution

**Model: Claude Sonnet 4.5**

For each document requiring updates:
1. Read the existing document
2. Review the corresponding research brief
3. Update the content to reflect 2026 standards
4. Preserve the original voice/style where possible
5. Add/update any code examples
6. Update version numbers, dates, links

### Step 4.2: Code Tester Validation

**Model: Claude Sonnet 4.5**

For any documents containing code snippets:
- Extract code blocks
- Test execution where possible
- Flag any that fail
- Propose fixes or note as "requires manual verification"

### Step 4.3: Editor Review

**Model: Claude Sonnet 4.5 (Thinking)**

Review each updated document for:
- Technical accuracy (cross-reference with research)
- Consistency in terminology
- Completeness (nothing important removed)
- Readability and flow
- Proper formatting

Output: Review notes in `/.antigravity/reviews/[doc-name]-review.md`

### Step 4.4: Validator Cross-Check

**Model: Gemini 3 Flash**

For key technical claims in updated docs:
- Quick-search official documentation
- Confirm commands/syntax are current
- Flag any discrepancies for human review

---

## Phase 5: Indexing and Wrap-Up

### Step 5.1: Librarian Indexing

**Model: Claude Sonnet 4.5**

Create `/.antigravity/index/LIBRARY.md` containing:
- Document title
- File path
- One-paragraph summary
- Primary use case
- Last updated date
- Tags/categories

### Step 5.2: Scribe Final Report

**Model: Claude Sonnet 4.5**

Compile the complete scribe log into a summary:
- What was done
- What agents were used and why
- Key decisions made
- Any issues encountered
- Recommendations for future runs

Update `/.antigravity/logs/scribe-log.md` with final summary section.

### Step 5.3: File Organizer Final Structure

**Model: Claude Sonnet 4.5**

If the analysis recommended restructuring:
- Move files to new locations
- Update any internal links
- Create redirect notes if needed

---

## Phase 6: Commit

**Model: Claude Opus 4.5 (Thinking)**

Stage all changes and create a single commit:

```
git add -A
git commit -m "docs: 2026 modernization - multi-agent update

- Updated [X] documents to 2026 standards
- Reorganized file structure for clarity
- Added agent infrastructure in /.antigravity/
- Created documentation index and library
- Research sources preserved in /.antigravity/research/

Agents used: [list]
Models: Claude Opus 4.5 (Thinking), Claude Sonnet 4.5, Gemini 3 Pro (High), Gemini 3 Flash
"
```

Do NOT push. Leave on branch for human review.

---

## Model Assignment Summary

| Agent | Primary Model | Fallback |
|-------|---------------|----------|
| Orchestrator | Claude Opus 4.5 (Thinking) | - |
| Researcher | Gemini 3 Pro (High) | Gemini 3 Pro (Low) |
| File Organizer | Claude Sonnet 4.5 | - |
| Scribe | Claude Sonnet 4.5 | - |
| Technical Writer | Claude Sonnet 4.5 | - |
| Editor | Claude Sonnet 4.5 (Thinking) | Claude Sonnet 4.5 |
| Librarian | Claude Sonnet 4.5 | - |
| Validator | Gemini 3 Flash | Gemini 3 Pro (Low) |
| Code Tester | Claude Sonnet 4.5 | - |

---

## Critical Rules

1. **Scribe logs everything** - Every agent action gets logged with timestamp, agent name, and outcome
2. **Research before writing** - No document updates without corresponding research brief
3. **One commit at the end** - All changes staged together, single commit message
4. **Preserve originals** - If significantly restructuring, keep `.original` backups until final commit
5. **Flag uncertainty** - If any agent is unsure, log it and flag for human review rather than guessing

---

## Iteration Guidance

This prompt structure itself should be refined based on what the Researcher discovers in Phase 1. If research indicates a better agent structure or workflow, **update this plan before execution**. The goal is a working system, not rigid adherence to initial assumptions.

The "right" number of agents is discovered, not prescribed.