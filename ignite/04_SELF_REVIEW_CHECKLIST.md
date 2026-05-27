# 04 — Self-Review Checklist

> **Phase 5 of the mission.** After drafting all reports, walk this checklist. Do not declare the engagement complete until every item is checked or has a written justification for why it's N/A.

---

## Completeness

- [ ] `/reports/SDLC_AUDIT_REPORT.md` exists and every section has content (no `[TBD]` or empty sections)
- [ ] `/reports/RISK_REGISTER.md` exists with at least 10 entries
- [ ] `/reports/SECURITY_FINDINGS.md` exists with findings categorized by severity
- [ ] `/reports/REFACTORING_ROADMAP.md` exists with prioritized work items
- [ ] `/reports/BUILD_VS_BUY_MEMO.md` exists with all sections of the template filled
- [ ] `/reports/README.md` exists as the one-page entry point
- [ ] `/reports/raw/` contains the raw analyzer outputs that back the findings
- [ ] `discovery_notes.md` exists at repo root and is referenced from the SDLC report

## Evidence Discipline

- [ ] Every claim of a problem in every report cites a file path (and line number where applicable)
- [ ] Every quantitative claim (complexity, coverage %, CVE counts) cites the raw report it came from
- [ ] No claim is supported only by "in my view" or "appears to be" — those phrases are flagged and either substantiated or removed
- [ ] When information is unknown, it is explicitly labeled "Unknown — requires [specific action]" rather than glossed over

## Security Hygiene in Your Own Output

- [ ] No actual secrets (passwords, tokens, API keys) appear in any report — only `[REDACTED]` with file:line references
- [ ] No PII from the codebase appears in reports (no real names, policy numbers, customer addresses found in test fixtures)
- [ ] Stack traces and error messages quoted in reports have been scrubbed of any internal hostnames, IPs, or paths that would aid an attacker

## Scoring Discipline

- [ ] Every Risk Register row has both Likelihood and Impact scored using the rubric in the template, not invented
- [ ] Every Security finding has CVSS or the template's severity rubric applied consistently
- [ ] Refactoring roadmap items have Effort and Value estimates with the units defined in the template
- [ ] You can defend, in one sentence, why each High severity item is High and not Medium

## Honesty About Limits

- [ ] The Build-vs-Buy memo does NOT recommend a path; it presents the decision framework and inputs
- [ ] The SDLC report distinguishes "verified" findings (tool output) from "inferred" findings (manual review) from "unknown" gaps
- [ ] Items that require knowledge you don't have (vendor capabilities, runtime telemetry, organizational context) are flagged as "Requires input from [role]" rather than guessed
- [ ] You did NOT propose a full rewrite unless the evidence section explicitly demonstrates rewrite is cheaper than incremental improvement

## Consistency Across Reports

- [ ] The same finding doesn't appear with different severities in different reports
- [ ] Risk Register items cross-reference Security Findings and Refactoring Roadmap items where applicable
- [ ] The "Top 5 Risks" in the SDLC summary match the Top 5 in the Risk Register
- [ ] Counts agree: e.g., if SDLC says "12 High security findings", Security Findings has exactly 12 rows marked High

## Reproducibility

- [ ] `make audit` (or equivalent) runs end-to-end and reproduces the raw outputs in `reports/raw/`
- [ ] The `tooling/.venv` install steps are documented in `02_TOOLING_SETUP.md` or the repo README
- [ ] Pinned versions of analyzers are recorded so a future run yields the same findings
- [ ] `CLAUDE.md` exists at repo root summarizing context for the next session

## Tone & Audience

- [ ] Reports are written for IT leadership and senior engineers — not for the original authors
- [ ] No language that blames the business partner team; describe state, not motive
- [ ] No marketing language ("world-class", "best-in-breed"); plain professional English
- [ ] The Build-vs-Buy memo treats both paths as legitimate and helps decision-makers, not advocates

## Format

- [ ] All reports are valid Markdown that renders correctly (check tables, code blocks, lists)
- [ ] Tables fit reasonable column widths; long content moves to body paragraphs
- [ ] Headings are properly nested (no jumping from H2 to H4)
- [ ] Internal links between reports use relative paths that resolve

## Final Step

- [ ] You have re-read the Mission Brief (`00_MISSION_BRIEF.md`) and confirmed every "What 'Done' Looks Like" item is satisfied

If every box is checked, proceed to Phase 6 — write `/reports/README.md` per `05_HANDOFF_SUMMARY_SPEC.md` and stop. The engagement is complete.

If any box cannot be checked, fix the underlying issue and re-run this checklist. Do not ship a partial assessment.
