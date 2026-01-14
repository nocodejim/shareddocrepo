# Modernization Workflow State Machine

## 0. Initialization
- **Action:** Setup directories and rosters.
- **Agent:** Orchestrator
- **Next:** Phase 1 (Analysis)

## 1. Analysis Phase
- **Step 1.1:** Repo Inventory
    - **Agent:** File Organizer
    - **Output:** `analysis/repo-inventory.md`
- **Step 1.2:** Topic Identification
    - **Agent:** Orchestrator (based on Inventory)
    - **Output:** List of topics for Research.
- **Next:** Phase 2 (Research)

## 2. Research Phase
- **Action:** For each Topic in List:
    - **Agent:** Researcher
    - **Output:** `.antigravity/research/[topic].md`
- **Audit Check:** Auditor verifies coverage of all topics.
- **Next:** Phase 3 (Execution Loop)

## 3. Execution Phase (Per Document)
*Loop for each document needing update:*

1.  **Drafting**
    - **Input:** Original Doc + Research Brief
    - **Agent:** Technical Writer
    - **Action:** Update content to 2026 standards.
2.  **Verification**
    - **Input:** Draft
    - **Agent:** Code Tester
    - **Action:** Verify snippets.
    - **Agent:** Validator
    - **Action:** Verify facts/URLs.
3.  **Review**
    - **Input:** Verified Draft
    - **Agent:** Editor
    - **Action:** Approve or Request Changes.
    - *If Changes Needed:* Return to Drafting.

## 4. Finalization
- **Step 4.1:** Indexing
    - **Agent:** Librarian
    - **Output:** `.antigravity/index/LIBRARY.md`
- **Step 4.2:** Final Audit
    - **Agent:** Auditor
    - **Action:** Certify process completeness.
- **Step 4.3:** Report
    - **Agent:** Scribe
    - **Output:** Final summary in logs.

## 5. Commit
- **Agent:** Orchestrator
- **Action:** Stage and Commit (No Push).
