# Risk Register

**Application:** [name]
**Date:** [date]
**Reviewer:** Opus

This register catalogs risks identified during the SDLC assessment. Each risk has a unique ID (R001+), a score, owner placeholder, and mitigation. The register is the canonical list — other reports reference these IDs.

---

## Scoring Rubric (apply consistently)

### Likelihood
- **5 — Almost certain:** Will occur in normal operation; condition already exists or is triggered frequently.
- **4 — Likely:** Expected within months under current conditions.
- **3 — Possible:** Plausible within a year; requires a specific trigger.
- **2 — Unlikely:** Would require an unusual combination of conditions.
- **1 — Rare:** Theoretical; no realistic path to occurrence in current state.

### Impact
- **5 — Severe:** Data loss/breach, regulatory exposure, extended outage of business-critical capability, financial loss > [threshold]
- **4 — Major:** Service degradation affecting many users, recoverable data inconsistency, significant remediation effort, audit finding
- **3 — Moderate:** Localized outage, recoverable, customer-facing but limited blast radius
- **2 — Minor:** Internal-only impact, low user friction, workaround exists
- **1 — Negligible:** Cosmetic or developer-experience only

### Risk Score = Likelihood × Impact
- **20–25: Critical** — address immediately
- **12–19: High** — address in current quarter
- **6–11: Medium** — address in current half
- **1–5: Low** — track; address opportunistically

---

## Register

| ID | Category | Description | L | I | Score | Severity | Evidence | Mitigation | Cross-Ref |
|----|----------|-------------|---|---|-------|----------|----------|------------|-----------|
| R001 | Security | Hardcoded ArcGIS portal admin credential in source | 5 | 5 | 25 | Critical | `app/config.py:23` | Rotate credential, move to secret manager, scrub git history | SEC-001, ROAD-01 |
| R002 | Security | Flask app runs with `debug=True` in production path | 4 | 5 | 20 | Critical | `app.py:88` | Set via env var; default False; CI check | SEC-002 |
| R003 | Operations | No automated tests; no safety net for changes | 5 | 4 | 20 | Critical | `pytest.txt` (0 tests collected) | Add characterization tests for top 5 routes | ROAD-02 |
| R004 | Compliance | PII (policyholder addresses) logged at INFO level | 4 | 5 | 20 | Critical | `services/quote.py:142` | Redact PII in formatter; raise log level | SEC-007 |
| R005 | Dependency | `flask==1.1.2` has CVE-XXXX-XXXXX (RCE) | 3 | 5 | 15 | High | `pip_audit.json` | Upgrade to flask==3.0.x; regression test | SEC-010 |
| R006 | Maintainability | Function `process_claim()` CC=47; no tests | 4 | 3 | 12 | High | `services/claim.py:201`, `radon_cc.json` | Decompose into 4-5 named sub-functions | ROAD-04 |
| R007 | Operations | `arcpy` use requires licensed Pro install on each host | 3 | 4 | 12 | High | `services/geo.py:1` | Document; evaluate moving to `arcgis` REST API | ROAD-09 |
| R008 | Architecture | `GIS()` connection at module scope; shared across users | 3 | 4 | 12 | High | `app/__init__.py:14` | Per-request connection or pooled with refresh | SEC-005 |
| R009 | Security | SQL where-clause built via f-string from user input | 3 | 5 | 15 | High | `services/lookup.py:88` | Validate inputs; use parameterized helpers | SEC-004 |
| R010 | Knowledge | Only one git contributor; no design docs | 4 | 3 | 12 | High | `git log --format='%an' \| sort -u` | Pair with current author for transfer; write ADRs | — |
| R011 | Dependency | `arcgis==1.8.5` (3+ years old); breaking changes in newer versions | 3 | 3 | 9 | Medium | `requirements.txt` | Plan upgrade as discrete project | ROAD-08 |
| R012 | Security | No CSRF protection on state-changing routes | 3 | 4 | 12 | High | `app/routes.py` (no `CSRFProtect`) | Add Flask-WTF CSRF middleware | SEC-006 |
| ... | | | | | | | | | |

[Aim for 15-30 entries. Stop adding when you are only finding Low items.]

---

## Distribution

| Severity | Count |
|----------|-------|
| Critical | — |
| High     | — |
| Medium   | — |
| Low      | — |

## Top 5 by Score

1. R001 — [description] — score 25
2. R002 — [description] — score 20
3. R003 — [description] — score 20
4. R004 — [description] — score 20
5. R005 — [description] — score 15

These five drive the "must-do" items in the Refactoring Roadmap.

## Risk Heat Map

```
Impact →     1    2    3    4    5
Likelihood ↓
   5         .    .    .    .   R001
   4         .    .   R010 R006 R002,R003,R004
   3         .    .  R011  R007,R008 R005,R009,R012
   2         .    .    .    .    .
   1         .    .    .    .    .
```

(Update the heat map to reflect actual entries.)

## Notes
- Risks marked "Unknown" in any field should not be scored; they are tracked separately as Open Questions in the SDLC Audit, Appendix B.
- This register is a living document. Re-score after mitigations land. Closed risks move to an `archived/` section, not deleted, for audit trail.
