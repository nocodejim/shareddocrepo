# Runbook: Building the "De-Vibe" Skill Set

**Purpose:** Turn the one-off hardening review into a repeatable capability. This runbook shows how to build a small set of agent **skills** that take a vibe-coded application from "works on the author's laptop" to something IT can support, measured against the 3 S's (Scalable, Stable, Secure). It includes:

1. The design rules for a good skill.
2. The catalog of skills to build, and what each one produces.
3. Where skills and instructions live for GitHub Copilot (GHCP) and for Claude Code, and how to write both from one source.
4. Complete sample files: `SKILL.md` files, `copilot-instructions.md`, path-scoped `*.instructions.md`, a prompt file, and a custom agent file.
5. Copy-paste prompts that make GHCP (or any frontier model) generate the skills and initialize the instructions for a new app.
6. The business-to-IT handoff checklist that the skills collectively satisfy.

Nothing in this document contains time estimates. Order is by dependency.

---

## 1. What a skill is, and the rules for a good one

A skill is a folder containing a `SKILL.md` file (YAML frontmatter plus Markdown instructions) and optional supporting files (templates, scripts, checklists). An agent loads the skill when the task matches its description, then follows its instructions.

Both Claude Code and GitHub Copilot read the same format. Claude Code looks in `.claude/skills/<name>/SKILL.md`. Copilot looks in `.github/skills/<name>/SKILL.md` and also honors `.claude/skills/`. Keep one copy under `.github/skills/` and symlink or copy to `.claude/skills/` if your team uses both tools.

### Rules

1. **One job, one artifact.** Each skill produces a specific, checked-in output (a file, a manifest, a workflow, a report). If you cannot name the file it creates or changes, the skill is too vague.
2. **Verify before declaring done.** Every skill ends with a verification step the agent must run and paste output from. "Should work" is not a result.
3. **Evidence over opinion.** Findings cite file paths and lines. Recommendations include the diff.
4. **Idempotent.** Running the skill twice on the same repo makes no further changes the second time.
5. **Frontmatter description is the trigger.** Write it as "Use when the user asks to ... or when the repo lacks ..." so the agent picks it up without being told the skill name.
6. **Keep SKILL.md under ~300 lines.** Move long templates into sibling files and reference them by relative path.
7. **No time estimates, no vague phases.** Steps, checks, outputs.
8. **Never touch production.** Skills operate on the repo and on non-prod environments only.

---

## 2. Skill catalog

Build these ten skills in this order. Each row names the artifact it produces and the S it serves.

| # | Skill name | Produces | Serves | Depends on |
|---|-----------|----------|--------|------------|
| 1 | `app-inventory` | `docs/ARCHITECTURE.md` with module map, config table, startup sequence, data flow | All | none |
| 2 | `init-agent-instructions` | `.github/copilot-instructions.md`, `AGENTS.md`, `CLAUDE.md`, path-scoped `.github/instructions/*.instructions.md` | Supportable | 1 |
| 3 | `config-secrets-hygiene` | Startup guard for default secrets, `.env.example`, k8s Secret references, removal of hardcoded values | Secure | 1 |
| 4 | `container-hardening` | Multi-stage Dockerfiles, non-root user, static frontend build, `.dockerignore`, pinned bases | Secure, Scalable | 1 |
| 5 | `k8s-readiness` | Resources, probes, PDB, anti-affinity, migration Job, Secret/ConfigMap wiring | Scalable, Stable | 3, 4 |
| 6 | `db-migration-discipline` | Alembic single-head check, downgrade coverage, migration Job, seed guards | Stable | 1 |
| 7 | `test-baseline` | Smoke tests (health, login, one CRUD round trip), `tsc` + lint gate, pytest against real Postgres | Stable | 1 |
| 8 | `ci-pipeline-gha` | Build-once/promote workflow, test gate, Xray gate, SHA-pinned actions, rollout status, post-deploy smoke | Stable, Secure | 4, 5, 7 |
| 9 | `observability-baseline` | Structured logs with request ID, `/metrics`, `/version` with git SHA, alert rule stubs | Supportable | 1 |
| 10 | `three-s-scorecard` | `docs/SCORECARD.md` with PASS/FAIL per control and links to evidence; the handoff gate | All | all |

Skill 10 is the one you run at the end of every engagement and again before every handoff. It is the same scorecard as Section 4 of the companion hardening runbook.

---

## 3. Where files live

```
repo/
├── AGENTS.md                              # tool-neutral agent instructions (Copilot reads this)
├── CLAUDE.md                              # Claude Code instructions (can be one line: "See AGENTS.md")
├── .github/
│   ├── copilot-instructions.md            # repo-wide Copilot instructions
│   ├── instructions/
│   │   ├── backend.instructions.md        # applyTo: "backend/**"
│   │   ├── frontend.instructions.md       # applyTo: "frontend/**"
│   │   ├── k8s.instructions.md            # applyTo: "k8s/**,deploy/**,charts/**"
│   │   └── workflows.instructions.md      # applyTo: ".github/workflows/**"
│   ├── prompts/
│   │   ├── three-s-review.prompt.md       # /three-s-review in Copilot Chat
│   │   └── harden-phase.prompt.md
│   ├── agents/
│   │   └── hardening-reviewer.agent.md    # custom Copilot agent persona
│   └── skills/
│       ├── app-inventory/SKILL.md
│       ├── init-agent-instructions/SKILL.md
│       ├── config-secrets-hygiene/SKILL.md
│       ├── container-hardening/SKILL.md
│       ├── k8s-readiness/SKILL.md
│       ├── db-migration-discipline/SKILL.md
│       ├── test-baseline/SKILL.md
│       ├── ci-pipeline-gha/SKILL.md
│       ├── observability-baseline/SKILL.md
│       └── three-s-scorecard/SKILL.md
└── .claude/
    └── skills -> ../.github/skills        # symlink, or a copy if symlinks are not allowed
```

**File roles, briefly**

- `copilot-instructions.md`: always loaded by Copilot for this repo. Short. What the app is, how to build and test, non-negotiable rules.
- `AGENTS.md`: the same content in the emerging cross-tool convention. Copilot coding agent reads it; so do several other agents. Keep the two in sync or make one include the other.
- `*.instructions.md`: loaded only when the file being edited matches `applyTo`. Put module-specific rules here (Alembic rules for `backend/**`, TypeScript rules for `frontend/**`).
- `*.prompt.md`: reusable slash-command prompts in Copilot Chat.
- `*.agent.md`: a named persona with a system prompt and tool allow-list.
- `SKILL.md`: procedural knowledge the agent loads on demand.

---

## 4. Sample files

Copy these verbatim, then adjust the placeholders in braces. They are written for the FastAPI + React + PostgreSQL + Kubernetes + GHA stack but the structure applies to any vibe-coded app.

### 4.1 `.github/copilot-instructions.md`

~~~markdown
# {{APP_NAME}} — Copilot instructions

## What this is
Internal {{ONE_LINE_PURPOSE}}. FastAPI backend (`backend/`), React + TypeScript frontend (`frontend/`), PostgreSQL. Runs on on-prem Kubernetes (Rancher) in namespaces {{NAMESPACES}}. Images are built by GitHub Actions, pushed to {{REGISTRY}}, scanned by Xray, and deployed by the workflow in `.github/workflows/deploy.yml`.

Data is low-risk internal data (no PII). Treat secrets as sensitive; treat application data as ordinary.

## Owners and support
- Business owner: {{BUSINESS_OWNER}}
- IT support owner: {{IT_OWNER}}
- Escalation: {{ESCALATION_CHANNEL}}

## Build, test, run
- Backend tests: `cd backend && poetry run pytest` (requires DATABASE_URL pointing at a scratch PostgreSQL; see `docs/DEVELOPMENT.md`).
- Backend lint: `poetry run ruff check . && poetry run black --check .`
- Frontend: `cd frontend && npm ci && npm run lint && npm run build` (build runs `tsc`).
- Local stack: `docker compose up` (dev only; production uses `k8s/`).
- Manifest check: `kubeconform -strict k8s/`  (or `kubectl apply --dry-run=client -k k8s/overlays/dev`).

## Rules that always apply
1. Never commit secrets, `.env` files, or kubeconfigs. Secrets come from k8s Secrets referenced by name.
2. Every schema change ships with an Alembic migration that has a working `downgrade()`. One head only.
3. Every API endpoint declares its auth dependency explicitly. Admin endpoints check role, not just authentication.
4. Do not add code that writes to the container filesystem for anything user-facing. Replicas > 1 is the norm.
5. Changes to `k8s/` must keep resources, probes, and securityContext intact. Never remove them to "make it work."
6. Do not weaken CI gates (tests, tsc, lint, Xray) to get a green build. Fix the cause.
7. No time estimates in docs, plans, or PR descriptions.
8. Update `docs/ARCHITECTURE.md` and the relevant runbook when behavior, config, or deployment changes.

## When unsure
Read `docs/ARCHITECTURE.md` first, then the path-specific instructions in `.github/instructions/`. If the answer is not there, ask rather than guess, and propose adding the answer to the docs.
~~~

### 4.2 `AGENTS.md`

~~~markdown
# AGENTS.md

This file is read by AI coding agents (GitHub Copilot coding agent, Claude Code, and others).
The canonical instructions live in `.github/copilot-instructions.md`; this file mirrors them so tools that do not read that path still get the same rules.

<!-- Keep the sections below identical to .github/copilot-instructions.md. A CI check (scripts/check-agent-docs.sh) fails if they drift. -->

{{PASTE THE BODY OF copilot-instructions.md HERE}}
~~~

And `CLAUDE.md` at the repo root can be simply:

~~~markdown
# CLAUDE.md
See `AGENTS.md` for all project instructions. Skills live in `.claude/skills/` (mirror of `.github/skills/`).
~~~

### 4.3 `.github/instructions/backend.instructions.md`

~~~markdown
---
applyTo: "backend/**"
---
# Backend rules (FastAPI + SQLAlchemy + Alembic)

- Settings come from `app/config.py` (pydantic-settings). Add a field there; never read `os.environ` directly elsewhere.
- Any setting that is a secret has no default. The `Settings` validator must reject known placeholder values (see `config-secrets-hygiene` skill).
- Routers: apply `Depends(get_current_user)` at `APIRouter(dependencies=[...])` level. Use `Depends(require_admin)` for admin routers.
- Database sessions only via `Depends(get_db)`. Never create `SessionLocal()` in request code.
- Migrations: `alembic revision --autogenerate -m "<verb> <object>"`, then hand-review the file. Implement `downgrade()`. Run `alembic heads` and confirm exactly one head before committing.
- Seed scripts must be guarded: check for existing rows and skip; never update passwords or overwrite framework content on existing rows.
- Logging: use `get_logger(__name__)` from `app/core/logging_config.py`. Never log tokens, passwords, or full request bodies.
- Health: `/health` returns component status strings only, never exception text. `/version` returns `GIT_SHA` from env.
- Tests: pytest against a real PostgreSQL (use the `db` fixture). Every new endpoint gets at least one authorized and one unauthorized test.
~~~

### 4.4 `.github/instructions/frontend.instructions.md`

~~~markdown
---
applyTo: "frontend/**"
---
# Frontend rules (React + TypeScript + Vite)

- `npm run build` must pass (`tsc` strict). `npm run lint` runs with `--max-warnings 0`.
- API base URL comes from runtime config (`/config.js` served by nginx, or same-origin `/api`). Never hardcode hostnames or IPs.
- Use the shared `logger` (`src/lib/logger.ts`) instead of `console.log`. Debug-level output is stripped in production builds.
- Never log the auth token or Authorization header.
- API types are generated from the backend OpenAPI spec (`npm run gen:api`). Do not hand-edit `src/types/api.generated.ts`.
- Any list that can exceed ~100 rows is paginated server-side.
- Handle 401 centrally in the API client: clear session, redirect to login.
- The production image is a static build served by nginx as non-root. Do not change the Dockerfile to run `vite dev`.
~~~

### 4.5 `.github/instructions/k8s.instructions.md`

~~~markdown
---
applyTo: "k8s/**,deploy/**,charts/**"
---
# Kubernetes manifest rules

- Every container has `resources.requests` and `resources.limits`.
- Every Deployment has `readinessProbe` and `livenessProbe`. Liveness must not depend on the database. Use `startupProbe` if boot takes more than a few seconds.
- `securityContext`: `runAsNonRoot: true`, `allowPrivilegeEscalation: false`, `capabilities.drop: ["ALL"]`, `readOnlyRootFilesystem: true` where the app allows it (mount `emptyDir` for `/tmp`).
- Images are referenced by immutable tag (git SHA) or digest. Never `latest`.
- Stateless services: `replicas >= 2`, a `PodDisruptionBudget`, and `topologySpreadConstraints` on hostname.
- Schema migrations run in a `Job` (`k8s/base/migrate-job.yaml`) that the deploy workflow runs and waits on before the Deployment rollout. The app container never runs `alembic upgrade`.
- Secrets are referenced via `secretKeyRef` / `envFrom`. No secret values in manifests, kustomization files, or Helm values committed to git.
- PostgreSQL is a `StatefulSet` (or external). Never a `Deployment` with a PVC.
- Validate with `kubeconform -strict` before committing.
~~~

### 4.6 `.github/instructions/workflows.instructions.md`

~~~markdown
---
applyTo: ".github/workflows/**"
---
# GitHub Actions rules

- Pin third-party actions to a full commit SHA with a version comment: `uses: actions/checkout@<sha> # v4.2.2`.
- Job order: `test` → `build` → `scan` → `deploy-<env>`. Each later job declares `needs:` on the earlier ones.
- Build the image once, tag with `${{ github.sha }}`, push to {{REGISTRY}}. Deploy jobs promote that exact tag; they never rebuild.
- The Xray step fails the job on policy violation. Do not set it to report-only.
- Production deploy uses a GitHub Environment named `prod` with required reviewers.
- Deploy job runs the migration Job, waits (`kubectl wait --for=condition=complete`), then `kubectl rollout status` with a timeout, then a smoke check against `/health` and `/version` that asserts the SHA.
- Never `echo` a secret. Never write a secret into a Dockerfile `ARG` or `ENV`.
- Cluster credentials are namespace-scoped service account tokens, one per environment.
~~~

### 4.7 `.github/prompts/three-s-review.prompt.md`

~~~markdown
---
description: "Run the 3 S's (Scalable, Stable, Secure) readiness review and write docs/SCORECARD.md"
agent: "agent"
tools: ["codebase", "terminal", "githubRepo"]
---
Use the `three-s-scorecard` skill. Review this repository against every control in the scorecard. For each control: state PASS, FAIL, or UNVERIFIED with a file citation or a command output as evidence. Write the result to `docs/SCORECARD.md`, then list every FAIL with the skill that fixes it. Do not modify any file other than `docs/SCORECARD.md`.
~~~

### 4.8 `.github/prompts/harden-phase.prompt.md`

~~~markdown
---
description: "Implement one hardening skill end to end on a new branch and open a PR"
agent: "agent"
tools: ["codebase", "terminal", "githubRepo"]
---
Skill to apply: ${input:skill:e.g. container-hardening}

1. Read `.github/skills/${input:skill}/SKILL.md` and follow it exactly.
2. Work on a new branch `harden/${input:skill}`.
3. Run every verification step the skill lists and paste the output in your summary.
4. Update docs the skill names.
5. Open a PR titled `harden: ${input:skill}` whose body lists: what changed, the verification output, how to roll back. Do not merge.
~~~

### 4.9 `.github/agents/hardening-reviewer.agent.md`

~~~markdown
---
name: hardening-reviewer
description: "Read-only reviewer that audits an app against the 3 S's and produces evidence-backed findings"
tools: ["codebase", "githubRepo", "terminal"]
---
You are a read-only enterprise readiness reviewer. You never modify source files, manifests, or workflows; you only write reports under `docs/hardening-review/`.

Rules:
- Every finding cites a file path and line range, a manifest key, a workflow step, or a command and its output.
- Unknown is reported as UNVERIFIED with what would verify it. Never guess.
- Severity: P0 outage or breach under normal operation; P1 under plausible conditions; P2 weakens supportability or defense in depth; P3 hygiene.
- Data is low-risk (no PII). Do not recommend privacy or data-classification tooling.
- No time estimates.
- Use the Finding Format from `.github/skills/three-s-scorecard/SKILL.md`.
~~~

### 4.10 `SKILL.md` samples

Four of the ten skills are written out in full below. The remaining six follow the same shape; Section 5 has the prompt that generates them.

#### 4.10.1 `.github/skills/app-inventory/SKILL.md`

~~~markdown
---
name: app-inventory
description: "Discover and document a repo's modules, config surface, startup sequence, data flow, and deploy path into docs/ARCHITECTURE.md. Use when onboarding an app, when ARCHITECTURE.md is missing or stale, or before any hardening work."
---
# App inventory

## Output
`docs/ARCHITECTURE.md` (create or fully regenerate). Nothing else is modified.

## Steps
1. **Modules.** For each deployable unit (backend, frontend, workers, jobs, database): language, framework, version pins (cite lockfile), Dockerfile path, base image and tag, ports, ENTRYPOINT and CMD. Note explicitly whether the frontend image serves a static build or a dev server.
2. **Config surface.** grep for `BaseSettings`, `os.environ`, `import.meta.env`, `process.env`. Produce a table: variable, default in code, where set (ConfigMap / Secret / workflow / hardcoded), safe-for-prod (yes/no/unknown).
3. **Startup sequence.** Read every entrypoint script. List what runs before the server accepts traffic. Flag anything that runs on every pod start (migrations, seeds, admin creation).
4. **Kubernetes topology.** For each workload: replicas, image ref style (tag/digest/latest), resources, probes, securityContext, serviceAccount, volumes, env sources. List Services, Ingresses, NetworkPolicies, HPAs, PDBs; state absent ones explicitly. Say where PostgreSQL runs and how it is persisted.
5. **Data flow.** Auth mechanism and token source. Every write to local disk (cite code).
6. **Delivery flow.** One line per workflow job: trigger, what it produces or deploys, what it `needs:`.
7. **Diagram.** ASCII diagram at the top: request path ingress → frontend → backend → DB, and CI path push → test → build → scan → deploy.

## Verification
- `docs/ARCHITECTURE.md` exists and every table row has a citation.
- Run `grep -c "UNVERIFIED" docs/ARCHITECTURE.md` and list each one with what would resolve it.

## Do not
- Do not fix anything you find. Record it. Other skills fix things.
~~~

#### 4.10.2 `.github/skills/init-agent-instructions/SKILL.md`

~~~markdown
---
name: init-agent-instructions
description: "Create or refresh .github/copilot-instructions.md, AGENTS.md, CLAUDE.md, and path-scoped .github/instructions/*.instructions.md so every AI-assisted change starts from an accurate model of the app. Use when these files are missing, describe a stale layout (e.g. docker-compose when prod is k8s), or after an architecture change."
---
# Initialize agent instructions

## Inputs
- `docs/ARCHITECTURE.md` (run `app-inventory` first if missing).
- Owner names and escalation channel from the human (ask once; do not invent).

## Output
- `.github/copilot-instructions.md`
- `AGENTS.md` (mirror)
- `CLAUDE.md` (pointer to AGENTS.md, or full copy if the team wants it standalone)
- `.github/instructions/backend.instructions.md`, `frontend.instructions.md`, `k8s.instructions.md`, `workflows.instructions.md` (only for directories that exist)
- `scripts/check-agent-docs.sh` that fails when `AGENTS.md` and `copilot-instructions.md` differ

## Steps
1. Read `docs/ARCHITECTURE.md`. Extract: purpose, stack, module paths, real build/test/lint commands (verify each command exists in `package.json` / `pyproject.toml` / `Makefile` before writing it), deploy path, namespaces, registry.
2. Write `copilot-instructions.md` from `templates/copilot-instructions.md` in this skill folder. Keep it under 80 lines. Every command listed must be one you ran or confirmed exists.
3. Remove anything inherited from a dev-only era: local IP addresses, test-user passwords, "add console.log everywhere" mandates, docker-compose-only workflows if prod is k8s. Move dev-only conveniences to `docs/DEVELOPMENT.md`.
4. Write the path-scoped instruction files from `templates/*.instructions.md`, keeping only rules that are true for this repo today plus rules the hardening plan will make true (mark those with `<!-- target -->`).
5. Write `AGENTS.md` as an exact mirror and `CLAUDE.md` as a pointer.
6. Add `scripts/check-agent-docs.sh` and a CI step that runs it.

## Verification
- `bash scripts/check-agent-docs.sh` exits 0.
- Every command in the instructions runs successfully (paste output) or is marked `<!-- target -->`.
- No IP address, password, or token string appears in any instruction file: `grep -nE "([0-9]{1,3}\.){3}[0-9]{1,3}|password|secret" .github/copilot-instructions.md AGENTS.md CLAUDE.md .github/instructions/` returns only allow-listed lines.

## Do not
- Do not include time estimates, roadmap dates, or phase durations.
- Do not describe features that do not exist yet as if they do.
~~~

#### 4.10.3 `.github/skills/config-secrets-hygiene/SKILL.md`

~~~markdown
---
name: config-secrets-hygiene
description: "Remove default and hardcoded secrets, add a startup guard that refuses known placeholder values, create .env.example, and wire k8s Secret references. Use when config.py or manifests contain default passwords/keys, or before first production deploy."
---
# Config and secrets hygiene

## Output
- `backend/app/config.py`: secret fields have no default; validator rejects placeholders.
- `backend/.env.example` with every variable and a comment, no real values.
- `k8s/base/secret.example.yaml` (documented shape, no values) and `secretKeyRef` wiring in Deployments.
- `docs/RUNBOOK.md` section "Rotate secrets".
- Removal of dev IPs/hostnames from CORS defaults; CORS list comes from env.

## Steps
1. Inventory: `grep -rnE "SECRET|PASSWORD|TOKEN|API_KEY" --include=*.py --include=*.yml --include=*.yaml --include=*.env* --include=*.ts .` and `git log -p --all -S "change-in-production" -- . | head`. Record every hit.
2. In `Settings`, make `SECRET_KEY` and `DATABASE_URL` required (`str` with no default). Add a validator:
   ```python
   PLACEHOLDERS = {"dev-secret-key-change-in-production", "changeme", "secret", ""}
   @field_validator("SECRET_KEY")
   def _no_placeholder(cls, v):
       if v.strip().lower() in PLACEHOLDERS or len(v) < 32:
           raise ValueError("SECRET_KEY is unset or a placeholder; refusing to start")
       return v
   ```
3. `DEBUG` defaults to `False`. `ALLOWED_ORIGINS` is read from env as a comma-separated list with no default in prod.
4. Replace literal values in manifests with `valueFrom.secretKeyRef`. Add the example Secret manifest.
5. If any real secret was ever committed, note it in the findings: it must be rotated, not just removed (history retains it).
6. Write the rotation procedure: how to update the k8s Secret, restart pods (`kubectl rollout restart`), and confirm via `/health`.

## Verification
- Start the backend with `SECRET_KEY=dev-secret-key-change-in-production`: process exits non-zero with the validator message. Paste output.
- Start with a 48-char random key: `/health` returns 200.
- `grep -rn "devops123\|change-in-production" .` returns nothing outside `docs/` history notes.
- `kubeconform -strict k8s/` passes.

## Do not
- Do not print secret values in logs, PR descriptions, or verification output.
~~~

#### 4.10.4 `.github/skills/three-s-scorecard/SKILL.md`

~~~markdown
---
name: three-s-scorecard
description: "Audit a repo against the Scalable / Stable / Secure / Supportable control list and write docs/SCORECARD.md with PASS/FAIL/UNVERIFIED and evidence per control. Use for readiness reviews, before handoff from business to IT, and after each hardening PR."
---
# 3 S's scorecard

## Output
`docs/SCORECARD.md`. Read-only otherwise.

## Finding format
```
### [P<0-3>] <title>
- Area: scalable | stable | secure | supportable
- Evidence: <path:lines | manifest key | command + output>
- Why it matters:
- Fix: <skill name that fixes it, plus the concrete change>
- Verification:
- Status: CONFIRMED | UNVERIFIED
```

## Controls
Check each. Status is PASS / FAIL / UNVERIFIED. Every status needs evidence.

| # | Control | S | How to check |
|---|---------|---|--------------|
| 1 | No default or committed secrets | Secure | `grep` + git history; config validator exists |
| 2 | Auth on every non-public endpoint; admin checks role | Secure | read each router; list unauthenticated routes |
| 3 | Containers non-root, caps dropped | Secure | Dockerfile USER; manifest securityContext |
| 4 | Image scan gates pipeline | Secure | workflow step fails on violation |
| 5 | CORS from env; /docs off in prod | Secure | config + main.py |
| 6 | Migrations run once via Job, not per pod | Stable | entrypoint has no alembic; Job manifest exists; workflow waits on it |
| 7 | Probes: readiness real, liveness DB-independent | Stable | manifest + endpoint code |
| 8 | Tests gate the build (pytest, tsc, lint) | Stable | workflow `needs:` graph |
| 9 | Immutable image tags; one-line rollback documented | Stable | manifests + RUNBOOK.md |
| 10 | Seeding cannot overwrite prod data | Stable | seed script guards |
| 11 | Scheduled backup + documented, tested restore | Stable | CronJob + RUNBOOK.md + evidence of a restore |
| 12 | Correct at replicas >= 2 (no local state) | Scalable | grep for disk writes, module-level state |
| 13 | Resources on every container | Scalable | manifests |
| 14 | PDB + spread/anti-affinity | Scalable | manifests |
| 15 | DB pool x replicas < max_connections | Scalable | compute and cite |
| 16 | Frontend static build served by nginx | Scalable | Dockerfile |
| 17 | Structured logs with request ID | Supportable | middleware + sample log line |
| 18 | /metrics + at least one alert rule | Supportable | code + manifests |
| 19 | /version returns git SHA | Supportable | code + workflow injects it |
| 20 | RUNBOOK.md, CODEOWNERS, accurate agent instructions | Supportable | files exist and match ARCHITECTURE.md |

## Verdict
Per S: READY (all PASS or P3-only), READY WITH CONDITIONS (no P0; every P1 has a named fix), NOT READY (any P0, or a P1 with no fix).

## Verification
- `docs/SCORECARD.md` has exactly 20 control rows, each with a status and evidence.
- FAIL rows each name the skill that fixes them.
~~~

### 4.11 `scripts/check-agent-docs.sh`

```bash
#!/usr/bin/env bash
# Fails if AGENTS.md drifts from .github/copilot-instructions.md.
set -euo pipefail
a=$(sed -e '1,/^<!-- BEGIN SHARED -->$/d' -e '/^<!-- END SHARED -->$/,$d' AGENTS.md)
b=$(sed -e '1,/^<!-- BEGIN SHARED -->$/d' -e '/^<!-- END SHARED -->$/,$d' .github/copilot-instructions.md)
if [ "$a" != "$b" ]; then
  echo "AGENTS.md and .github/copilot-instructions.md shared sections differ." >&2
  diff <(echo "$a") <(echo "$b") >&2 || true
  exit 1
fi
echo "agent docs in sync"
```

Wrap the shared body in both files with `<!-- BEGIN SHARED -->` and `<!-- END SHARED -->` markers.

---

## 5. Prompts for GHCP (or any frontier model) to build the skill set

Run these in order in Copilot Chat (agent mode) or Claude Code at the root of the target repo. Each is self-contained.

### 5.1 Bootstrap the skills folder and the first two skills

~~~text
You are setting up AI agent skills for this repository so that future AI-assisted changes are consistent and supportable.

Create the directory `.github/skills/` and a symlink `.claude/skills -> ../.github/skills` (if symlinks are not permitted in this repo, copy instead and add a note in `.claude/skills/README.md` that `.github/skills` is canonical).

Create two skills, each as `<name>/SKILL.md` with YAML frontmatter containing `name` and `description`, followed by Markdown sections titled exactly: Output, Steps, Verification, Do not.

Skill 1: `app-inventory`
- Purpose: discover and document modules, config surface, startup sequence, Kubernetes topology, data flow, and CI/CD flow into `docs/ARCHITECTURE.md`.
- Description (frontmatter) must start with "Discover and document" and end with "Use when onboarding an app, when ARCHITECTURE.md is missing or stale, or before any hardening work."
- Steps must require a citation (file:line, manifest key, or command output) for every documented fact, and must state explicitly whether the frontend image serves a static build or a dev server, and what the container entrypoint runs before the server starts.
- Verification: the file exists; every table row has a citation; list every UNVERIFIED item.
- Do not: fix anything found.

Skill 2: `init-agent-instructions`
- Purpose: create or refresh `.github/copilot-instructions.md`, `AGENTS.md` (mirror), `CLAUDE.md` (pointer), and path-scoped `.github/instructions/{backend,frontend,k8s,workflows}.instructions.md` with an `applyTo` frontmatter glob, from `docs/ARCHITECTURE.md`.
- Steps must: verify every build/test command exists before writing it; strip dev-era artifacts (local IPs, test passwords, "log everything" mandates); add `scripts/check-agent-docs.sh` that fails on drift between AGENTS.md and copilot-instructions.md; forbid time estimates.
- Verification: the drift script passes; each listed command runs; a grep for IP addresses and the words password/secret returns nothing unexpected.

Constraints:
- Keep each SKILL.md under 120 lines.
- No time estimates anywhere.
- After writing, run `app-inventory` on this repository and show me `docs/ARCHITECTURE.md`. Do not run `init-agent-instructions` yet; I will review the inventory first.
~~~

### 5.2 Initialize the instructions files

~~~text
Run the `init-agent-instructions` skill on this repository.

Facts you need from me (do not invent them):
- App name: {{APP_NAME}}
- One-line purpose: {{ONE_LINE_PURPOSE}}
- Business owner: {{BUSINESS_OWNER}}
- IT support owner: {{IT_OWNER}}
- Escalation channel: {{ESCALATION_CHANNEL}}
- Namespaces: {{NAMESPACES}}
- Registry: {{REGISTRY}}

Requirements for `.github/copilot-instructions.md`:
- Under 80 lines. Sections: What this is; Owners and support; Build, test, run; Rules that always apply; When unsure.
- Every command under "Build, test, run" must be one you executed successfully in this repo, or be marked `<!-- target -->` with the skill that will make it true.
- Rules must include: no committed secrets; every schema change has a reversible Alembic migration with one head; every endpoint declares auth; no user-facing writes to container disk; never remove resources/probes/securityContext from manifests; never weaken CI gates; no time estimates; update ARCHITECTURE.md and runbook on behavior change.

Then produce `AGENTS.md` as a mirror wrapped in `<!-- BEGIN SHARED -->` / `<!-- END SHARED -->` markers, `CLAUDE.md` pointing to it, the four path-scoped instruction files, and `scripts/check-agent-docs.sh`.

Show me the diff. Do not commit.
~~~

### 5.3 Generate the remaining hardening skills

~~~text
Generate the following skills under `.github/skills/`, one folder each, using the same SKILL.md structure as `app-inventory` (frontmatter name + description; sections Output, Steps, Verification, Do not). Each skill must name the exact files it creates or modifies, include a verification step with a command whose output proves success, and be idempotent. No time estimates.

1. `container-hardening`
   Output: multi-stage backend Dockerfile with a non-root USER, pinned base tag, no build tools in the final stage; multi-stage frontend Dockerfile that runs `npm ci && npm run build` and serves `dist/` with nginx as non-root on port 8080; `.dockerignore` for both; nginx.conf with SPA fallback, gzip, cache headers for hashed assets, no-cache for index.html, and basic security headers.
   Verification: `docker build` both images; `docker run --rm <image> id -u` is not 0; frontend container serves index.html and a deep link; hadolint passes or listed exceptions are justified.

2. `k8s-readiness`
   Output: for each Deployment, `resources`, `readinessProbe` (HTTP /health), `livenessProbe` (HTTP / that does not touch the DB), `startupProbe`, `securityContext` (runAsNonRoot, drop ALL, no privilege escalation, readOnlyRootFilesystem with emptyDir /tmp), `topologySpreadConstraints`, a `PodDisruptionBudget`, `envFrom` Secret/ConfigMap wiring, immutable image tag placeholder; a `migrate-job.yaml` Job that runs `alembic upgrade head` with `backoffLimit: 0`; PostgreSQL as StatefulSet if in-cluster.
   Verification: `kubeconform -strict`; `kubectl apply --dry-run=server` in a non-prod namespace if available; a table showing (pool_size + max_overflow) x replicas versus PostgreSQL max_connections.

3. `db-migration-discipline`
   Output: `alembic heads` check script in CI; audit of every migration for a real `downgrade()`; seed script guards that never update existing rows; removal of `alembic upgrade` and seeding from the container entrypoint (moved to the Job / a one-time seed Job); `docs/RUNBOOK.md` section "Schema migrations and rollback".
   Verification: `alembic heads` prints one head; `alembic downgrade -1 && alembic upgrade head` succeeds on a scratch DB; entrypoint contains no alembic call.

4. `test-baseline`
   Output: backend pytest suite with fixtures for a real PostgreSQL (testcontainers or a CI service container) covering `/health`, login success and failure, one authenticated CRUD round trip, one admin-only endpoint denied to a non-admin; frontend `vitest` smoke test for the login form; CI job that runs pytest, `npm run lint`, `npm run build`.
   Verification: paste the pytest and vitest summary lines; a deliberately failing test blocks the build job.

5. `ci-pipeline-gha`
   Output: workflow(s) with job graph test → build → scan → deploy-dev → deploy-test → deploy-prod; build once tagged with git SHA and pushed to Artifactory; Xray step configured to fail on policy violation; all third-party actions pinned to commit SHAs; deploy jobs run the migration Job, wait for completion, `kubectl rollout status --timeout`, then curl `/health` and `/version` asserting the SHA; `prod` uses a GitHub Environment with required reviewers.
   Verification: `actionlint` passes; a dry run on a branch shows the job graph; a manifest shows the image tag equals the workflow SHA.

6. `observability-baseline`
   Output: request-ID middleware (accept incoming `X-Request-ID` or generate; echo in response; bind to structlog context); `/metrics` via prometheus-fastapi-instrumentator; `/version` returning `GIT_SHA` and `BUILD_TIME` from env set by the workflow; a `ServiceMonitor` and one `PrometheusRule` for 5xx rate and pod restarts (marked optional if the cluster lacks the operator); frontend logger that gates debug output by build mode.
   Verification: curl with `X-Request-ID: test-123` and show the JSON log line containing it; `/metrics` returns Prometheus text; `/version` matches the image label.

After generating all six, run `three-s-scorecard` (if it exists; otherwise generate it from the control table in `docs/runbooks/vibe-to-enterprise-skills-runbook.md` Section 4.10.4) and show me `docs/SCORECARD.md`. Do not implement any fixes yet.
~~~

### 5.4 Apply one skill (repeat per skill)

~~~text
Apply the `{{SKILL_NAME}}` skill to this repository on a new branch `harden/{{SKILL_NAME}}`.

- Follow `.github/skills/{{SKILL_NAME}}/SKILL.md` exactly. Do not do work belonging to other skills even if you notice it; record it in `docs/SCORECARD.md` under "Deferred".
- Run every Verification step and paste the raw output.
- Update the docs the skill names. Update `docs/SCORECARD.md` rows this skill affects.
- Commit in small single-purpose commits. Open a PR titled `harden: {{SKILL_NAME}}` with sections: What changed, Verification output, Rollback. Do not merge.
- If you need a value or approval you do not have (a secret, cluster access, an owner name), stop, list exactly what is needed, and leave the rest complete.
~~~

### 5.5 Refresh instructions after the hardening lands

~~~text
The hardening PRs for {{LIST_OF_SKILLS}} have merged. Re-run `app-inventory` to regenerate `docs/ARCHITECTURE.md`, then re-run `init-agent-instructions`. Remove every `<!-- target -->` marker whose rule is now true, and fail if any rule is still marked target. Then run `three-s-scorecard` and show me the verdict per S.
~~~

### 5.6 Prompt to make GHCP write a new skill from a recurring problem

Use this whenever the team notices a class of mistake that keeps recurring.

~~~text
We keep seeing this problem: {{DESCRIBE THE RECURRING MISTAKE, WITH ONE CONCRETE EXAMPLE AND THE FILE IT HAPPENED IN}}.

Write a new skill `.github/skills/{{skill-name}}/SKILL.md` that prevents it. Requirements:
- Frontmatter `description` phrased as "Use when ..." so an agent picks it up without being told the name.
- Sections: Output, Steps, Verification, Do not.
- Output names the exact files created or changed.
- Verification includes a command that fails before the fix and passes after; show both runs on this repo.
- Under 120 lines. No time estimates.
Also add one sentence to the relevant `.github/instructions/*.instructions.md` file pointing at the new skill.
~~~

---

## 6. Business-to-IT handoff checklist

The skills above exist to make these true. IT should accept operational ownership only when every row is checked, with a link to the evidence.

| # | Handoff requirement | Produced by | Evidence link |
|---|---------------------|-------------|---------------|
| 1 | `docs/ARCHITECTURE.md` accurate at current commit | app-inventory | |
| 2 | `.github/copilot-instructions.md`, `AGENTS.md`, `CLAUDE.md`, path instructions accurate; drift check in CI | init-agent-instructions | |
| 3 | No default secrets; startup guard; rotation documented | config-secrets-hygiene | |
| 4 | Non-root, pinned, multi-stage images; static frontend | container-hardening | |
| 5 | Resources, probes, PDB, spread, Secret wiring, migration Job | k8s-readiness | |
| 6 | One Alembic head; downgrades work; seeds guarded; entrypoint clean | db-migration-discipline | |
| 7 | Tests gate the build; smoke tests exist | test-baseline | |
| 8 | Build-once/promote pipeline; Xray gates; SHA-pinned actions; prod environment approval; post-deploy smoke | ci-pipeline-gha | |
| 9 | Request IDs, /metrics, /version, alert stubs | observability-baseline | |
| 10 | `docs/SCORECARD.md` shows READY or READY WITH CONDITIONS for all three S's | three-s-scorecard | |
| 11 | `docs/RUNBOOK.md` covers: restart, roll back, rotate secrets, restore DB, where logs are, who to call | config-secrets-hygiene + db-migration-discipline + observability-baseline | |
| 12 | `CODEOWNERS` names the IT team for `k8s/`, `.github/workflows/`, `backend/alembic/` | init-agent-instructions | |
| 13 | A person outside the original team performed a restart, rollback, and restore using only the runbook | human, recorded in SCORECARD.md | |

---

## 7. Maintaining the skill set

- Keep skills in a single shared repository (for example `platform-skills`) and vendor them into each app repo with a script or git subtree, so a fix to a skill reaches every app.
- Version the skill set with a `CHANGELOG.md`. A skill change that alters what "PASS" means bumps the major version.
- When a skill's verification step fails on a repo for a legitimate reason, add the exception to the skill's "Do not" section with the reasoning, not to the repo.
- Review `docs/SCORECARD.md` at every release. A control that flips from PASS to FAIL is a regression and blocks the release the same way a failed test does.

---

*Companion document: [Enterprise Hardening Review Runbook](./enterprise-hardening-review-runbook.md) is the one-time deep review that these skills operationalize.*
