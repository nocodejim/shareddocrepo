# Handoff Package — SDLC Evaluation of Inherited ArcGIS Flask Application

This directory contains everything needed to execute an SDLC evaluation of an inherited Flask + ArcGIS application. It is designed to be handed to **Opus inside GitHub Copilot** as a self-contained engagement.

## Who Reads What

**If you are Opus (or any LLM agent picking this up):**
Read `00_MISSION_BRIEF.md` first. Follow the phases in order. Do not skip the self-review.

**If you are a human reviewer:**
Read this file, then `00_MISSION_BRIEF.md` to understand what the agent will do. The templates under `templates/` show the deliverable shapes. If you want to open the original Jupyter notebook for context, see `06_JUPYTER_VSCODE_COPILOT_GUIDE.md`.

## Package Contents

```
handoff/
├── README.md                                  # This file — read first
├── 00_MISSION_BRIEF.md                        # The master brief for Opus
├── 01_DISCOVERY_PROTOCOL.md                   # Phase 1: inventory the codebase
├── 02_TOOLING_SETUP.md                        # Phase 2: install + run analyzers
├── 03_ARCGIS_SECURITY_CHECKLIST.md            # Phase 3: ArcGIS-specific review
├── 04_SELF_REVIEW_CHECKLIST.md                # Phase 5: pre-handoff QA
├── 05_HANDOFF_SUMMARY_SPEC.md                 # Phase 6: the executive summary
├── 06_JUPYTER_VSCODE_COPILOT_GUIDE.md         # Bonus: how to open the notebook in VS Code
└── templates/
    ├── SDLC_AUDIT_REPORT.md                   # Comprehensive per-phase assessment
    ├── RISK_REGISTER.md                       # Scored risk catalog
    ├── SECURITY_FINDINGS.md                   # Detailed security findings
    ├── REFACTORING_ROADMAP.md                 # Prioritized improvement plan
    └── BUILD_VS_BUY_MEMO.md                   # Decision framework for leadership
```

## How to Kick This Off

1. Drop this `handoff/` directory into the repo containing the Flask application.
2. Open the repo in VS Code with GitHub Copilot Chat (see `06_JUPYTER_VSCODE_COPILOT_GUIDE.md` if you need help setting that up).
3. Switch Copilot to **Agent mode** and select **Claude Opus** as the model.
4. Paste this prompt into the chat:

   > Read `handoff/00_MISSION_BRIEF.md` and execute the engagement it describes. The handoff package is in the `handoff/` directory. Begin with Phase 0 (read all package files), then proceed through Phases 1–6 in order. Stop only when the self-review checklist in `handoff/04_SELF_REVIEW_CHECKLIST.md` is fully satisfied.

5. Let Opus work. It will:
   - Read this package
   - Inventory the codebase (Phase 1)
   - Install and run analyzers in a `tooling/.venv` (Phase 2)
   - Walk the ArcGIS-specific checklist (Phase 3)
   - Write five reports into `/reports/` using the templates (Phase 4)
   - Self-review (Phase 5)
   - Produce the executive summary at `/reports/README.md` (Phase 6)

6. Review the output. Spot-check findings against the raw analyzer output in `/reports/raw/`.

## What Gets Created in Your Repo

After Opus finishes, your repo will have:

```
<repo root>/
├── handoff/                       # This package (unchanged)
├── tooling/
│   └── .venv/                     # Analyzer virtualenv (gitignored)
├── pyproject.toml                 # Analyzer config (or appended to existing)
├── Makefile                       # `make audit` re-runs the analysis
├── .secrets.baseline              # detect-secrets baseline
├── CLAUDE.md                      # Persistent context for future agent sessions
├── discovery_notes.md             # Phase 1 output
└── reports/
    ├── README.md                  # One-page executive summary
    ├── SDLC_AUDIT_REPORT.md
    ├── RISK_REGISTER.md
    ├── SECURITY_FINDINGS.md
    ├── REFACTORING_ROADMAP.md
    ├── BUILD_VS_BUY_MEMO.md
    └── raw/                       # Raw analyzer output (re-verifiable)
        ├── ruff.json
        ├── bandit.json
        ├── pip_audit.json
        ├── radon_cc.json
        ├── semgrep.json
        ├── arcgis_review.md
        └── ... (etc.)
```

The application code itself is **not modified**. This is read-only analysis.

## Design Choices in This Package

A few decisions worth noting if you adapt this for other engagements:

- **Templates are markdown** so they render in any viewer (VS Code, GitHub, browsers) and diff cleanly in git.
- **The Build-vs-Buy memo does not recommend a path.** Leadership owns the decision; the agent provides evidence. This protects the assessment from being dismissed as biased.
- **The self-review checklist is non-negotiable.** Agents that skip self-review produce inconsistent reports. The checklist enforces internal coherence.
- **All tooling is open-source and local.** Nothing leaves the environment. No third-party services. This matters for enterprise environments with data-handling restrictions.
- **The mission brief explicitly forbids running the Flask app or hitting external endpoints.** Static analysis only. This avoids the agent inadvertently triggering production ArcGIS calls or burning portal credits.

## Re-Running the Analysis Later

After the initial engagement, you can refresh the raw findings any time:

```bash
make audit
```

The reports themselves are written analysis on top of those findings — they require a reviewer (human or agent) to regenerate. The pattern: re-run `make audit`, then ask the agent to update the reports based on the new raw output, calling out what changed since last time.

## Limitations

This package handles static analysis well. It does not handle:

- **Dynamic / runtime analysis** — DAST scanning, fuzzing, behavior under load
- **Penetration testing** — adversarial probing
- **Production configuration review** — actual environment variables, network policies, TLS posture in deployed environments
- **Vendor evaluation** — assessing the specific external tool the business is considering (the memo frames the decision; it cannot evaluate the unnamed product)

These are out of scope by design. The reports flag them as Open Questions where appropriate.

---

**Built for: Opus in GitHub Copilot. Adaptable to: Sonnet, GPT-class agents, or human reviewers.**
