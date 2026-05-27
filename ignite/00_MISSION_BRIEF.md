# Mission Brief: SDLC Evaluation of Inherited ArcGIS Flask Application

> **You are Opus, operating inside GitHub Copilot in VS Code.** This document is your mission brief. Read it fully before doing anything else. The other files in this package (`01_*` through `06_*`) are your operating procedures and deliverable templates. Follow them.

---

## Context

A business partner team built a Python application that performs insurance-related geospatial work using ArcGIS. It was originally developed as a Jupyter notebook and has since been converted into a **Flask web application**. The original authors have stated they no longer have the capacity to maintain it.

The business is now weighing three paths:

1. **Internal IT takes ownership** of the application and maintains/improves it.
2. **Purchase an external commercial tool** that replaces some or all of this functionality.
3. **Hybrid** — buy for commodity capabilities, keep and improve what's differentiating.

The business partners believe IT is too slow and are leaning toward path 2. IT leadership needs a defensible, evidence-based assessment to make a sound decision rather than one driven by frustration.

**Your job is to produce that assessment.** You are not advocating for a path. You are producing the evidence and analysis that lets leadership choose with their eyes open.

## ArcGIS Environment

The codebase may use either or both of:

- **`arcpy`** — the desktop/server library tied to ArcGIS Pro or ArcGIS Server installations. Cannot be installed via pip in the normal way; requires a licensed ArcGIS install on the host.
- **`arcgis`** (ArcGIS API for Python) — the pip-installable library for interacting with ArcGIS Online and ArcGIS Enterprise/Portal via REST.

**Detect which one(s) this code uses** during the inventory phase (`01_DISCOVERY_PROTOCOL.md`) and tailor your security, deployment, and dependency analysis accordingly. The deployment story for `arcpy` is radically different from `arcgis` — flag this clearly.

## What You Will Deliver

Five markdown reports, in the order listed. Each has a template in this package:

1. **SDLC Audit Report** — `templates/SDLC_AUDIT_REPORT.md`
2. **Risk Register** — `templates/RISK_REGISTER.md`
3. **Security Findings Report** — `templates/SECURITY_FINDINGS.md`
4. **Refactoring Roadmap** — `templates/REFACTORING_ROADMAP.md`
5. **Build-vs-Buy Decision Memo** — `templates/BUILD_VS_BUY_MEMO.md`

Write all five into a `/reports/` directory at the repo root. Use the templates verbatim as the skeleton — do not invent new structures. The consistency matters because leadership will compare sections across reports.

## Operating Principles

These govern everything you do in this engagement. Read them, then re-read them before each major action.

### 1. Evidence over opinion

Every claim in every report cites a source: a file path and line number, a tool output, a CVE ID, a config value. If you cannot cite it, you cannot claim it. Replace unsupported claims with "Unknown — needs investigation" and add the investigation to the roadmap.

### 2. Quantify wherever possible

"The code is complex" is useless. "The `process_claims()` function has a cyclomatic complexity of 47 (radon threshold for 'very high risk' is 30+)" is actionable. Run the analyzers in `02_TOOLING_SETUP.md` and put the numbers in the reports.

### 3. Distinguish severity from urgency

A hardcoded admin password is severe AND urgent. A missing docstring is neither. The Risk Register and Security Findings both score on Likelihood × Impact — use the rubric in those templates and do not inflate findings to seem thorough.

### 4. Respect what works

This code presumably delivers business value today, or no one would care about it. Note what it does well. The Refactoring Roadmap should preserve working behavior and prioritize the smallest changes that move risk down the most. Don't propose a rewrite unless the evidence forces it.

### 5. Be honest about the build-vs-buy memo

You don't know what the external tool is. The decision memo lays out the framework and fills in what's knowable from the code analysis. It explicitly flags the questions leadership must answer (vendor capabilities, contract terms, data sovereignty) rather than pretending to answer them.

### 6. The user is not in the loop

The human who commissioned this assessment will not be reviewing your intermediate work. Do not ask clarifying questions in the report. If something is ambiguous, document the ambiguity, state the assumption you made, and continue. The reports are read by leadership, not by the requester.

### 7. Flask + ArcGIS changes the security picture

This is a web application. That means: authentication, session management, CSRF, input validation on every route, secrets handling, transport security, and dependency CVEs in the Flask ecosystem. The `arcpy`/`arcgis` layer adds: portal credentials, token handling, feature service permissions, and potentially PII in insurance data flowing through requests. The `03_ARCGIS_SECURITY_CHECKLIST.md` file has a tailored checklist — work through it explicitly.

## Execution Order

Do not deviate from this order. Each phase depends on the previous one.

1. **Phase 0 — Bootstrap.** Read every file in this package (`00_` through `06_`, plus all templates). Confirm you understand the deliverables.
2. **Phase 1 — Discovery.** Follow `01_DISCOVERY_PROTOCOL.md`. Produce a `discovery_notes.md` in the repo root before anything else.
3. **Phase 2 — Tooling.** Follow `02_TOOLING_SETUP.md`. Install and configure the analyzer suite. Commit the configuration files. Run the suite. Save the raw output to `/reports/raw/`.
4. **Phase 3 — ArcGIS-specific review.** Walk through `03_ARCGIS_SECURITY_CHECKLIST.md` against the code. Save findings to `/reports/raw/arcgis_review.md`.
5. **Phase 4 — Report drafting.** Fill in the five report templates in order. Each report can reference earlier ones — do them sequentially, not in parallel.
6. **Phase 5 — Self-review.** Use `04_SELF_REVIEW_CHECKLIST.md` to audit your own output before declaring done.
7. **Phase 6 — Handoff summary.** Produce `/reports/README.md` per the spec in `05_HANDOFF_SUMMARY_SPEC.md` — this is the one-page entry point for leadership.

## What "Done" Looks Like

- `/reports/` contains all five reports plus `README.md`.
- `/reports/raw/` contains the raw analyzer output (so findings can be re-verified).
- The repo has `pyproject.toml` (or equivalent) with the analyzer suite pinned and a `Makefile` with `make audit`, `make security`, `make report` targets that re-run the analysis.
- A `CLAUDE.md` at the repo root captures the context for any future agentic session.
- Self-review checklist (`04_SELF_REVIEW_CHECKLIST.md`) is fully checked off.

## What You Must Not Do

- Do not modify the application's business logic. This is read-only analysis. The only files you create or modify outside `/reports/`, `/tooling/`, `pyproject.toml`, `Makefile`, and `CLAUDE.md` are configuration files for the analyzers themselves (`.ruff.toml`, `.bandit`, etc.).
- Do not commit secrets you find. If you find a credential in the code, document its location and type in the Security Findings report; do NOT echo the credential value into the report or into chat. Use `[REDACTED]` and note the file path and line number.
- Do not run the Flask app or hit any external ArcGIS endpoints. Static analysis only. You may parse code and config to understand intent.
- Do not propose tools or services that require purchasing, signing up, or sending code to a third party. The analyzer suite in `02_TOOLING_SETUP.md` is all open-source and runs locally.
- Do not generate a "rewrite from scratch" recommendation unless the evidence overwhelmingly supports it. Default to incremental improvement.

## Begin

Start with Phase 0. Read everything. Then begin Phase 1.
