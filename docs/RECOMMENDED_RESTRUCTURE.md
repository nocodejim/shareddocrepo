# Documentation Restructuring Recommendations (2026)

The `guides/` directory currently contains 42 files with significant overlap, conflicting version information (2023 vs 2025 vs 2026), and fragmented advice. To modernize the repository, I recommend the following consolidation strategy.

## 1. Core Documentation (The "Golden Set")

These files should be the **Single Sources of Truth**. All other guides should be merged into these or archived.

| Status | Current Filename | Recommended New Name | Purpose |
|:---|:---|:---|:---|
| **UPDATED** | `guides/github-copilot-technical-guide.md` | `guides/copilot-technical-manual.md` | The primary technical reference (Installation, CLI, IDE setup). |
| **UPDATED** | `guides/Gemini_GitHub_Copilot_Agentic_Mode_Guide_.md` | `guides/copilot-agent-playbook.md` | Strategy guide for Agent Mode, MCP, and complex workflows. |
| **KEEP** | `guides/GHCP-Guideline_Policy.md` | `guides/copilot-enterprise-policy.md` | Governance, security, and enterprise rollout policies. |
| **KEEP** | `guides/github_apps_Gemini.md` | `guides/github-apps-development.md` | Guide for building GitHub Apps (Gemini perspective). |

## 2. Specialized Guides (Keep Separate)

Valuable niche content that shouldn't be merged but needs renaming for clarity.

| Current Filename | Recommendation | Reason |
|:---|:---|:---|
| `guides/github-copilot-agent-mastery.md` | **RENAME** to `guides/java-repo-discovery-patterns.md` | Content is highly specific to Java/Spring discovery, not generic agent mastery. |
| `guides/copilot-agent-wsl-container-guide.md` | **KEEP** | Specific workflow for WSL/Containers. |
| `guides/dev-container-patterns.md` | **KEEP** | Distinct DevOps topic. |

## 3. Archive Candidates (Redundant/Outdated)

These files contain advice that is either 1) covered better in the "Core" docs, or 2) outdated (pre-2025).

**Propose moving to `docs/archive/`:**

*   `guides/github-copilot-guide.md` (Redundant with Technical Manual)
*   `guides/github-copilot-mastery.md` (Redundant with Technical Manual)
*   `guides/github-copilot-for-novice-developers.md` (Redundant)
*   `guides/GHCP-Guideline_starter.md` (Redundant with Policy)
*   `guides/github-copilot-knowledge-base.md` (Generic/Redundant)
*   `guides/github-copilot-use-case-guide.md` (Merge unique use cases into Agent Playbook, then archive)
*   `guides/github-copilot-edits-use-case-guide.md` (Merge into Agent Playbook, then archive)

## 4. Action Plan

1.  **Execute Renames** for Group 1 & 2 to establish clear nomenclature.
2.  **Create `docs/archive/`** directory.
3.  **Move** Group 3 files to archive.
4.  **Update `LIBRARY.md`** to reflect the clean state.

**Pending User Approval to Execute.**
