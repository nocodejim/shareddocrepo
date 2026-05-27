# SDLC Audit Report

**Application:** [name]
**Repository:** [repo / commit hash]
**Date of Assessment:** [date]
**Reviewer:** Opus (GitHub Copilot)
**Methodology:** Static analysis + manual review. No code was executed. No external endpoints were called.

---

## Executive Summary

Three to five paragraphs. Cover:

1. What the application is, what it does, and its role in the business
2. Overall SDLC maturity in one phrase, plus a per-phase scorecard (table below)
3. The top three concerns and the top two opportunities
4. The deployment and operational reality (especially the ArcGIS licensing/runtime implications)
5. A short note on the build-vs-buy framing, deferring to the dedicated memo

### Scorecard

| SDLC Phase | Rating | One-Line Justification |
|------------|--------|------------------------|
| Requirements & Documentation | 🟢🟡🔴 | — |
| Design & Architecture | 🟢🟡🔴 | — |
| Implementation Quality | 🟢🟡🔴 | — |
| Security Posture | 🟢🟡🔴 | — |
| Testing & Verification | 🟢🟡🔴 | — |
| Deployment & Operations | 🟢🟡🔴 | — |
| Maintenance & Evolution | 🟢🟡🔴 | — |

**Rating key:**
- 🟢 Green: meets baseline for production support; minor improvements only
- 🟡 Yellow: gaps exist that should be addressed but do not block operation
- 🔴 Red: serious deficiency; must be addressed before production confidence

---

## 1. Requirements & Documentation

**What to assess:** Does anything explain *why* the code does what it does? For insurance/GIS, undocumented business rules are higher risk than undocumented code.

### Findings

- **Business context documentation:** [present / partial / absent], citing files
- **Functional requirements traceability:** [...]
- **Algorithm documentation:** any narrative for risk calculations, scoring, thresholds
- **API/route documentation:** OpenAPI? Docstrings? Comments?
- **Operational runbook:** how to start, stop, recover

### Evidence
Cite specific files: `README.md` (or its absence), `docs/`, inline docstrings sampled.

### Recommendations
[Bullet list of concrete, sized improvements with priorities.]

---

## 2. Design & Architecture

**What to assess:** Module boundaries, separation of concerns, coupling to ArcGIS, Flask app structure.

### Findings

- **Application shape:** monolithic single file? Blueprints? Layered (routes → services → data)?
- **ArcGIS coupling:** is `arcpy`/`arcgis` called directly from route handlers, or wrapped in a service layer?
- **Configuration management:** how are environment-specific values handled?
- **State management:** sessions, caches, in-memory state vs persistent
- **Dependency graph:** any concerning patterns (circular imports, god modules)?

### Module Map

[ASCII or Mermaid diagram showing actual structure observed.]

### Evidence
File counts, line counts per module, import graph summary from `pipdeptree` and grep.

### Recommendations
[Concrete refactoring opportunities, prioritized.]

---

## 3. Implementation Quality

**What to assess:** Code-level health. This is where the analyzers carry most of the weight.

### Quantitative Metrics

| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| Total LOC (Python)              | — | — | — |
| Average cyclomatic complexity   | — | < 5 ideal, < 10 acceptable | — |
| Functions with CC ≥ 10          | — | minimize | — |
| Functions with CC ≥ 30          | — | should be zero | — |
| Maintainability index (average) | — | > 65 acceptable | — |
| Files with MI < 20              | — | refactor candidates | — |
| Ruff violations (total)         | — | — | — |
| Type coverage (mypy)            | — | > 80% ideal | — |
| Dead code findings (vulture)    | — | minimize | — |

### Top Complexity Offenders
Table of the 10 highest-complexity functions with file:line and CC score. Pull from `radon_cc.json`.

### Recurring Anti-Patterns
List the top 5 ruff/bandit/manual review patterns by frequency. For each, the rule code, count, and a representative file:line.

### Evidence
Reference `reports/raw/ruff.json`, `reports/raw/radon_cc.json`, `reports/raw/mypy.txt`.

### Recommendations
[Specific refactors with effort estimates.]

---

## 4. Security Posture

**Defer detailed findings to `SECURITY_FINDINGS.md`. This section summarizes.**

### Summary

| Severity | Count | Source |
|----------|-------|--------|
| Critical | — | bandit + manual |
| High     | — | bandit + dependency CVEs + manual |
| Medium   | — | — |
| Low      | — | — |

### Top Categories
- Authentication / credentials: [N findings]
- Input validation: [N findings]
- Dependency vulnerabilities: [N findings]
- Web framework (Flask) misconfiguration: [N findings]
- ArcGIS-specific: [N findings, from `arcgis_review.md`]

### Evidence
Reference `SECURITY_FINDINGS.md`, `reports/raw/bandit.json`, `reports/raw/pip_audit.json`, `reports/raw/semgrep.json`, `reports/raw/arcgis_review.md`.

---

## 5. Testing & Verification

**What to assess:** Confidence that changes don't break things.

### Findings

- **Test framework:** pytest / unittest / none
- **Test count:** [N tests]
- **Coverage:** [X%] line coverage, [Y%] branch coverage
- **Coverage by module:** highlight modules with 0% coverage
- **Test types present:** unit / integration / end-to-end
- **Fixtures and mocking:** how is ArcGIS mocked, if at all
- **CI execution:** are tests actually run on changes?

### Evidence
Reference `reports/raw/pytest.txt`, `reports/raw/coverage_html/`.

### Recommendations
Specifically: characterization tests (Feathers) for the highest-value functions, not retrofit unit tests for everything. Identify the 5-10 functions where a test would prevent the most likely regression.

---

## 6. Deployment & Operations

**What to assess:** Can someone other than the original authors reliably operate this?

### Findings

- **Deployment mechanism:** documented? Dockerfile? manual? CI/CD?
- **Production server:** gunicorn/uwsgi/waitress? Or `app.run()`?
- **ArcGIS licensing implications:** see ArcGIS checklist F1 — does this require a licensed ArcGIS install on every host?
- **Concurrency model:** thread vs process workers — does this match `arcpy` thread-safety constraints?
- **Logging:** present? structured? routed where?
- **Monitoring:** health endpoints? metrics? alerting?
- **Backup/recovery:** what state needs to survive a host failure?
- **Configuration externalization:** can the same artifact deploy to dev, stage, prod?

### Evidence
Cite Dockerfile, Procfile, CI configs, README, or note their absence.

### Recommendations
[Prioritized; flag anything that is currently a single-point-of-failure on the original authors' tribal knowledge.]

---

## 7. Maintenance & Evolution

**What to assess:** What happens when this code needs to change.

### Findings

- **Version control:** git history depth, contributor count, branching strategy in evidence
- **Code review:** PR history if available
- **Issue tracking:** linked? ad hoc? absent?
- **Onboarding cost:** estimate hours for a new engineer to make a small change safely
- **Tribal knowledge dependency:** what facts are not in the repo but are required to operate the system

### Evidence
`git log` summary, presence/absence of CONTRIBUTING, ADRs, design docs.

### Recommendations
The single highest-value documentation that does not yet exist.

---

## Cross-Cutting Concerns

### ArcGIS-Specific
Summary of `arcgis_review.md`. Highlight the 3-5 issues that are not visible to generic Python analyzers.

### Insurance Domain
- Audit trail completeness
- PII handling in logs and responses
- Reproducibility of underwriting decisions

---

## Appendix A — Methodology

- Tools used and versions (link to `tooling/installed_versions.txt`)
- Manual review scope (which files were read end-to-end vs sampled)
- Limitations: no runtime telemetry, no production logs, no vendor demo of external tool

## Appendix B — Open Questions
Items that require input from specific roles:

| # | Question | Owner |
|---|----------|-------|
| 1 | What is the ArcGIS Pro version on production hosts? | Platform admin |
| 2 | Does the service account hold publisher or admin role? | ArcGIS administrator |
| 3 | What is the SLA expectation from the business? | Product owner |
| ... | | |

## Appendix C — File Inventory
Optional — list of files reviewed with one-line purpose each.
