# 05 — Handoff Summary Spec

> **Phase 6 of the mission.** Produce `/reports/README.md` as the one-page entry point. This is the *only* document many readers will see.

The summary is not a teaser for the full reports. It is a self-contained executive briefing. A reader who only reads this page should leave with a correct mental model of the application's state and the choice in front of them.

---

## Required Sections

### 1. The One-Paragraph Verdict

Four to six sentences. State:
- What this application is and what it does
- Its current SDLC maturity in one word (e.g., "prototype-grade", "production-deployed but undertested", "production-hardened with gaps")
- The single most important risk
- The single most important opportunity
- The shape of the decision in front of leadership

Example skeleton (do not copy verbatim):

> *This is a Flask web application that performs [X function] using ArcGIS [Pro/Online]. It is currently [maturity level]. The most pressing risk is [risk]; the most valuable improvement is [improvement]. Leadership is weighing internal investment in this application against purchasing [external tool category]; this report provides the evidence needed to decide.*

### 2. By the Numbers

A compact table. Replace placeholder numbers with real ones from the analysis.

```markdown
| Metric                              | Value | Interpretation |
|-------------------------------------|-------|----------------|
| Lines of Python code                | 3,420 | Small-to-medium |
| Cyclomatic complexity (average)     | 8.2   | Above target of 5 |
| Functions with complexity > 10      | 14    | Refactor candidates |
| Test coverage                       | 4%    | Effectively untested |
| High-severity security findings     | 6     | Must remediate before production |
| Medium-severity security findings   | 18    | Should remediate |
| Known-vulnerable dependencies (CVE) | 9     | Upgrade required |
| Hardcoded secrets detected          | 3     | Rotate and externalize |
| Direct dependencies                 | 22    | Manageable |
| Routes without authentication       | 7 of 12 | Architecture review needed |
```

### 3. Top Five Risks

A numbered list. For each: one-line description, severity (Critical/High/Medium), and a pointer to the Risk Register row ID.

### 4. What's Working

A short section. This is not flattery — it is essential context. Things to honestly credit:
- Functional capabilities the code delivers
- Architectural decisions that turned out well
- Documentation that exists
- Test fixtures, dev tooling, anything reusable

If genuinely nothing is working, say "The application functions in its current deployed form, but no aspects of its construction reduce future maintenance cost." Do not invent positives.

### 5. The Decision Framework

A compact restatement of the build-vs-buy framing. Three paragraphs:

- **Internal ownership:** what it would cost, what it would yield, what risk it carries
- **External tool:** what it would replace, what it wouldn't, what new risk it introduces
- **Hybrid:** what cleanly separates as commodity vs differentiating

End with: *"This summary does not recommend a path. The Build-vs-Buy memo lays out the inputs leadership needs to choose."*

### 6. Suggested Next Steps (Regardless of Path)

Three to five items that are valuable no matter which path is chosen:

- Rotate the credentials found in code (if any)
- Patch the High-CVE dependencies
- Add a `.env.example` and externalize configuration
- Add a smoke test that exercises one happy path through the Flask app
- Document the ArcGIS Pro version and extensions required to run

These are cheap, reduce immediate risk, and make either path easier to execute.

### 7. Reading Guide

A short table directing different readers to the right report.

```markdown
| If you are...                          | Read first                          |
|----------------------------------------|-------------------------------------|
| An executive deciding build vs. buy    | BUILD_VS_BUY_MEMO.md                |
| A security or compliance lead          | SECURITY_FINDINGS.md, RISK_REGISTER.md |
| An engineering manager planning work   | REFACTORING_ROADMAP.md, SDLC_AUDIT_REPORT.md |
| An engineer who will own this code     | SDLC_AUDIT_REPORT.md (full), then discovery_notes.md |
| An auditor                             | SECURITY_FINDINGS.md, raw outputs in `reports/raw/` |
```

### 8. Reproducing This Analysis

Three lines:

```bash
cd <repo>
make audit
# Outputs land in reports/raw/; reports in /reports/ are written by reviewer (human or LLM)
```

Note that the *findings* are reproducible (the raw outputs) but the *reports* are written analysis on top of those findings and require human or LLM review to refresh.

---

## Length

Aim for two screens (about 700-900 words). If it grows past that, you are duplicating the full reports. Cut.

## Tone

Direct, factual, useful. No hedging. No marketing. No apologizing for the codebase. State what is, point to the evidence, name the decision.

## When This Is Done

`/reports/README.md` is the last file written. Once it exists and passes the Self-Review Checklist, the engagement is complete. Stop.
