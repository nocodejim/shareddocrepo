# Runbook: Enterprise Hardening Review for a Vibe-Coded Application

**Audience:** A frontier-model "master agent" (Claude Code, GitHub Copilot coding agent, or equivalent) plus the sub-agents it spawns, driven by a human operator who owns the application.

**Goal:** Review a production application that grew out of this repository's stack (FastAPI + SQLAlchemy + Alembic, React/TypeScript + Vite, PostgreSQL, containers built by GitHub Actions, pushed to Artifactory, scanned by Xray, deployed to on-prem Kubernetes via Rancher) and produce an evidence-backed plan to make it meet the **3 S's**:

| S | Definition used in this runbook |
|---|---|
| **Scalable** | Runs correctly with more than one replica, survives pod churn, has resource limits, has no single-pod state, and degrades gracefully under load. |
| **Stable** | Boots deterministically, migrates the schema safely, has tests that gate deploys, has health probes that reflect real health, and can be rolled back. |
| **Secure** | No default or committed secrets, least-privilege containers and service accounts, dependency and image scanning enforced, authn/authz applied consistently, sane HTTP hygiene. Data is low risk (no PII), so the bar is "internal enterprise app," not "regulated workload." Do not over-index on data classification. |

The runbook is prompt-driven. Every prompt below is copy-paste ready. Fill in the `{{PLACEHOLDERS}}` once at the top, then paste each prompt in order.

---

## 0. Before you start

### 0.1 Fill in these placeholders once

```text
{{APP_NAME}}          = human name of the app
{{REPO_URL}}          = git URL of the production repo (the diverged work fork)
{{DEFAULT_BRANCH}}    = main / master
{{K8S_MANIFEST_PATH}} = path (or separate repo) holding Deployments/Services/Ingress/Helm/Kustomize
{{GHA_PATH}}          = .github/workflows
{{REGISTRY}}          = Artifactory docker registry hostname
{{NAMESPACES}}        = k8s namespaces per environment (e.g. dmm-dev, dmm-test, dmm-prod)
{{CLUSTER_ACCESS}}    = "read-only kubectl available" | "manifests only, no cluster access"
{{XRAY_ACCESS}}       = "reports attached" | "API available" | "none"
{{OUTPUT_DIR}}        = docs/hardening-review   (where all findings and the plan are written)
```

### 0.2 What the master agent must be given

Provide as much of this as possible. Missing items are recorded as **UNVERIFIED**, never guessed.

- Read access to the production repo at `{{REPO_URL}}` (all modules: backend, frontend, k8s manifests, workflows).
- The GitHub Actions workflow files and, ideally, the logs of the last successful and last failed run of each.
- Kubernetes manifests, Helm values, or Kustomize overlays for every environment.
- Read-only `kubectl` access to at least one non-prod namespace, if allowed. If not, the agent works from manifests only.
- Latest Xray scan summary for each image (or API access).
- Any existing runbooks, on-call notes, incident history, and the current `README`.
- The ancestor repository (this one) for lineage hints. Section 8 lists known weaknesses of the ancestor that likely survived the fork.

### 0.3 Ground rules for every agent

Paste this block at the top of every prompt (it is already included in each prompt below).

```text
GROUND RULES
1. Evidence or it did not happen. Every finding cites a file path and line range, a manifest key, a workflow step, or a command you ran with its output. No finding without a citation.
2. Never guess. If you cannot verify something, label it UNVERIFIED and state exactly what access or artifact would let you verify it.
3. Do not modify production or any live cluster. Read-only investigation only. You may create files under {{OUTPUT_DIR}} and, if asked, a feature branch with proposed changes.
4. Severity scale: P0 = will cause an outage or breach under normal operation; P1 = will cause one under plausible conditions (deploy, scale-out, node loss); P2 = weakens supportability or defense in depth; P3 = hygiene.
5. No time estimates anywhere. Order work by dependency and severity only.
6. The data is low-risk (no PII, no regulated data). Do not recommend data-classification, DLP, encryption-at-rest audits, or privacy tooling unless a finding is specifically about credentials or secrets.
7. Prefer the smallest change that fully fixes a finding. Do not propose rewrites or framework migrations.
8. Write output as Markdown to {{OUTPUT_DIR}}/<your-area>.md using the Finding Format in these rules.

FINDING FORMAT (one block per finding)
### [P<0-3>] <short title>
- Area: <scalable | stable | secure | supportable>
- Evidence: <path:lines | manifest key | command + output>
- Why it matters: <one or two sentences>
- Fix: <concrete change; include a diff or manifest snippet when under 30 lines>
- Verification: <the exact command, test, or observation that proves the fix worked>
- Status: <CONFIRMED | UNVERIFIED>
```

---

## 1. Orchestration model

One **master agent** owns the review. It spawns sub-agents, one per area, gives each the same ground rules plus a scoped prompt, then synthesizes results into a single scorecard and plan.

```
Master agent
 ├─ SA-1  Inventory & architecture map
 ├─ SA-2  Security (app + container + cluster)
 ├─ SA-3  Stability (boot, migrations, tests, probes, rollback)
 ├─ SA-4  Scalability (replicas, state, resources, load)
 ├─ SA-5  Delivery pipeline (GHA → Artifactory → Xray → k8s)
 ├─ SA-6  Data layer (PostgreSQL, Alembic, backups)
 ├─ SA-7  Frontend & API contract
 ├─ SA-8  Observability & supportability
 └─ Synthesis → scorecard, hardening plan, verification gates
```

Run SA-1 first. Its architecture map is an input to every other sub-agent. SA-2 through SA-8 can run in parallel. Synthesis runs last.

If your tooling does not support sub-agents, run the prompts sequentially in one session. The prompts are written so that works too.

---

## 2. Prompt M-0: Master agent kickoff

~~~text
You are the MASTER AGENT for an enterprise-hardening review of {{APP_NAME}}.

Repository: {{REPO_URL}} (branch {{DEFAULT_BRANCH}})
Kubernetes manifests: {{K8S_MANIFEST_PATH}}
CI workflows: {{GHA_PATH}}
Registry: {{REGISTRY}}
Namespaces: {{NAMESPACES}}
Cluster access: {{CLUSTER_ACCESS}}
Xray access: {{XRAY_ACCESS}}
Output directory: {{OUTPUT_DIR}}

CONTEXT
This application was built rapidly ("vibe coded") by a business team and is now in production on on-prem Kubernetes managed by Rancher. It descends from an open-source FastAPI + React + PostgreSQL project that used docker-compose. Nine months of divergent work followed, including moving to Kubernetes Deployments and GitHub Actions that build images, push to Artifactory, scan with Xray, and deploy. Your job is to determine whether it meets the 3 S's (Scalable, Stable, Secure) and produce a hardening plan that IT can execute and support.

GROUND RULES
1. Evidence or it did not happen. Every finding cites a file path and line range, a manifest key, a workflow step, or a command you ran with its output. No finding without a citation.
2. Never guess. If you cannot verify something, label it UNVERIFIED and state exactly what access or artifact would let you verify it.
3. Do not modify production or any live cluster. Read-only investigation only. You may create files under {{OUTPUT_DIR}} and, if asked, a feature branch with proposed changes.
4. Severity scale: P0 = will cause an outage or breach under normal operation; P1 = will cause one under plausible conditions (deploy, scale-out, node loss); P2 = weakens supportability or defense in depth; P3 = hygiene.
5. No time estimates anywhere. Order work by dependency and severity only.
6. The data is low-risk (no PII, no regulated data). Do not recommend data-classification, DLP, encryption-at-rest audits, or privacy tooling unless a finding is specifically about credentials or secrets.
7. Prefer the smallest change that fully fixes a finding. Do not propose rewrites or framework migrations.
8. Write output as Markdown to {{OUTPUT_DIR}}/<your-area>.md using the Finding Format in these rules.

YOUR TASKS, IN ORDER
1. Create {{OUTPUT_DIR}}/00-index.md listing the sub-agent reports you will produce and their status (PENDING / DONE).
2. Run sub-agent SA-1 (Inventory & architecture map) and wait for its report. Do not start other sub-agents until {{OUTPUT_DIR}}/01-inventory.md exists.
3. Run SA-2 through SA-8 in parallel, giving each the ground rules, the SA-1 report, and its scoped prompt.
4. When all reports exist, run the Synthesis prompt to produce {{OUTPUT_DIR}}/90-scorecard.md and {{OUTPUT_DIR}}/91-hardening-plan.md.
5. Run the Verification Gates prompt to produce {{OUTPUT_DIR}}/92-verification-gates.md.
6. Finish by printing the scorecard table and the list of P0 and P1 findings with their fixes.

Do not summarize sub-agent findings from memory. Read each report file back before synthesizing. If a sub-agent returns findings without evidence, send it back with the instruction "cite or drop."

Start with task 1 now.
~~~

---

## 3. Sub-agent prompts

Each prompt assumes the ground rules block from Section 0.3 is pasted above it. For brevity it is referenced as `[GROUND RULES]` here; paste the full block when running.

### 3.1 SA-1: Inventory and architecture map

~~~text
[GROUND RULES]

You are SA-1, INVENTORY AND ARCHITECTURE. Produce {{OUTPUT_DIR}}/01-inventory.md. Every other sub-agent depends on this file, so accuracy beats speed.

Discover and document, with file citations:

1. Modules and runtimes
   - Every deployable unit (backend API, frontend, workers, cron jobs, init containers, database). For each: language, framework, version pins (pyproject.toml / poetry.lock / package.json / package-lock.json), Dockerfile path, base image and tag, exposed ports, entrypoint and CMD.
   - Whether the frontend image serves a production build (nginx or similar) or runs a dev server (vite dev). Cite the Dockerfile CMD.

2. Configuration surface
   - Every environment variable read by the code (grep for os.environ, pydantic BaseSettings fields, import.meta.env, process.env). Table: name, default value in code, where it is set (ConfigMap / Secret / workflow / hardcoded), and whether the default is safe for production.
   - CORS origins, allowed hosts, base URLs, and how the frontend discovers the backend URL.

3. Kubernetes topology
   - For each Deployment/StatefulSet/Job/CronJob: replicas, image reference (tag or digest), resources requests/limits, liveness/readiness/startup probes, securityContext, serviceAccount, volumes and PVCs, env sources. Present as one table per namespace.
   - Services, Ingresses, NetworkPolicies, HPAs, PodDisruptionBudgets. Note absence explicitly.
   - Where PostgreSQL runs: in-cluster StatefulSet, external managed instance, or a single pod with a PVC. Cite.

4. Startup sequence
   - Read the container entrypoint(s). Document exactly what runs before the app process starts (wait-for-db loops, alembic upgrade head, seed scripts, admin user creation). Flag anything that runs on every pod start.

5. Data flow
   - Auth mechanism (JWT/session/SSO), token lifetime, where secrets are read from.
   - Every place the app writes to local disk (backups, exports, uploads, PDFs). Cite path and code.

6. Delivery flow
   - List every workflow in {{GHA_PATH}} with trigger, jobs, and what each job produces or deploys. One line per job.

7. Lineage check
   - Compare against the ancestor repo hints in the section titled "Known weaknesses inherited from the ancestor" (attached below by the master agent). For each hint, state PRESENT / FIXED / NOT APPLICABLE with citation.

Output a one-page ASCII architecture diagram at the top of the report showing request flow from ingress to database and the CI flow from push to deploy.
~~~

### 3.2 SA-2: Security

~~~text
[GROUND RULES]

You are SA-2, SECURITY. Read {{OUTPUT_DIR}}/01-inventory.md first. Produce {{OUTPUT_DIR}}/02-security.md.

Scope is an internal enterprise application with low-risk data. Focus on credentials, privilege, exposure, and hygiene. Do not audit data classification or privacy controls.

Check, and cite, each of the following:

A. Secrets and configuration
   1. Any default secret, password, or key in code or manifests (SECRET_KEY defaults, POSTGRES_PASSWORD literals, DATABASE_URL with embedded password, .env files committed). grep the whole repo and git history (git log -p --all -S 'PASSWORD' and similar) for leaked values.
   2. How k8s Secrets are created and sourced: committed YAML, sealed-secrets, external-secrets, Rancher secret store, or GHA secrets injected at deploy. Confirm no plaintext secret in the repo or workflow logs.
   3. DEBUG flags and their production value.
   4. JWT: algorithm, signing key source, token lifetime, whether the key can be rotated without downtime, whether tokens carry role claims that are trusted without re-checking the database.

B. Authentication and authorization
   1. Every API router: is the auth dependency applied at the router level or per-endpoint? List any endpoint reachable without auth, and any admin endpoint that checks only "is authenticated" instead of "is admin". Cite each.
   2. Login endpoint: rate limiting, lockout, or none. Password hashing algorithm and work factor.
   3. Seeded/default admin account: does it still exist in production, and is its password forced to change or sourced from a secret?
   4. Object-level authorization: can user A read or mutate user B's assessments by changing an ID? Trace two representative endpoints.

C. HTTP hygiene
   1. CORS allowed origins (wildcard, hardcoded IPs and hostnames, credentials flag).
   2. Security headers on the frontend server and API (HSTS, X-Content-Type-Options, CSP presence). Note if TLS terminates at ingress and whether HTTP→HTTPS redirect exists.
   3. OpenAPI /docs and /redoc exposure in production.
   4. Health endpoint: does it leak stack traces, connection strings, or exception text?

D. Containers and cluster
   1. Runs as root? Cite securityContext (runAsNonRoot, runAsUser, readOnlyRootFilesystem, allowPrivilegeEscalation, capabilities.drop).
   2. Base images: tag pinning vs digest pinning; slim/distroless vs full.
   3. Xray: summarize the latest scan per image (critical/high counts), whether the workflow gates on scan results or only reports, and which policy/watch applies. If {{XRAY_ACCESS}} is none, mark UNVERIFIED and state what report is needed.
   4. ServiceAccount: default SA with automountServiceAccountToken true? Any RBAC beyond what the app needs?
   5. NetworkPolicy: does anything restrict pod-to-pod or egress? Is PostgreSQL reachable from any pod in the cluster?
   6. Ingress: TLS config, annotations that widen exposure (e.g., whitelist-source-range absent on admin paths).

E. Supply chain
   1. Lockfiles present and used in the build (poetry.lock, package-lock.json with npm ci).
   2. Dependency scanning in CI (pip-audit, npm audit, Dependabot/Renovate) and whether results gate.
   3. Third-party GitHub Actions pinned to a SHA or a floating tag.
   4. Known-weak libraries in the lineage: python-jose (unmaintained), passlib with bcrypt>=4 incompatibility, datetime.utcnow deprecation. Confirm current versions and whether they matter.

Close with a table: control, status (PASS / FAIL / UNVERIFIED), severity, finding reference.
~~~

### 3.3 SA-3: Stability

~~~text
[GROUND RULES]

You are SA-3, STABILITY. Read {{OUTPUT_DIR}}/01-inventory.md first. Produce {{OUTPUT_DIR}}/03-stability.md.

Answer each question with evidence:

A. Deterministic boot
   1. What runs in the entrypoint before the app serves traffic? If alembic upgrade head or seed scripts run on every pod start, what happens when two replicas start at once or a rolling update overlaps old and new pods? Look for advisory locks, a separate migration Job, or an init container. Absence is a P1 finding.
   2. Does the wait-for-database loop have a bounded retry and a non-zero exit on failure? Does the readiness probe stay false until migrations finish?
   3. Are there hardcoded hostnames in the entrypoint (for example pg_isready -h postgres) that only worked under docker-compose?

B. Health probes
   1. For each container: liveness, readiness, and startup probe definitions. Does liveness hit an endpoint that touches the database? (If so, a DB blip restarts every pod: P1.) Does readiness reflect real readiness?
   2. Probe thresholds: initialDelaySeconds, periodSeconds, failureThreshold. Flag values that would cause crash loops on a slow node.

C. Tests
   1. Backend: count tests, what they cover, whether they run in CI, whether they run against a real PostgreSQL or SQLite. Cite pytest config and the workflow step.
   2. Frontend: unit tests (vitest), type check (tsc), lint. Whether any of these gate the build.
   3. Is there any end-to-end or smoke test executed after deploy (curl /health, login round trip)? Cite or mark absent.
   4. Test data: does seeding logic risk overwriting production data (seed scripts that upsert frameworks or reset admin passwords)? Trace the guard conditions.

D. Rollback and release safety
   1. Are images tagged immutably (git SHA or semver) or with latest/branch names? Can the previous version be redeployed by changing one manifest value?
   2. Deployment strategy: RollingUpdate maxSurge/maxUnavailable, or Recreate. minReadySeconds. PodDisruptionBudget.
   3. Alembic: are all migrations reversible (downgrade implemented)? Is there any migration that drops or renames columns without an expand/contract sequence?
   4. Is there a documented rollback procedure? Cite file or mark absent.

E. Error handling and resilience
   1. Global exception handler: does an unhandled exception return a 500 with a generic body and log the trace, or leak details?
   2. Database session lifecycle: sessions closed on every path? Pool size, pool_pre_ping, connection timeouts configured?
   3. Deprecated FastAPI patterns (on_event startup) and pinned versions that will break on the next base image bump.
   4. Frontend: handling of 401 (redirect to login), network errors, and API version mismatch after a deploy.

Close with a table: control, status, severity, finding reference.
~~~

### 3.4 SA-4: Scalability

~~~text
[GROUND RULES]

You are SA-4, SCALABILITY. Read {{OUTPUT_DIR}}/01-inventory.md first. Produce {{OUTPUT_DIR}}/04-scalability.md.

The target is modest: the app must run correctly at 2 or more replicas per stateless service, survive a node drain, and not fall over under a small burst. Do not design for internet scale.

Check with evidence:

A. Statelessness
   1. Any in-process state that breaks with multiple replicas: in-memory caches, module-level dicts, background tasks started per process, file-based locks, scheduled jobs that would run once per replica.
   2. Any write to the container filesystem (backups, PDF exports, uploads, logs written to files). With replicas > 1 and no shared volume, these are inconsistent or lost: P1 if user-facing.
   3. Session or token state that must be shared (server-side sessions, token blacklist). JWT alone is fine.

B. Resources and scheduling
   1. requests and limits on every container. Absence is P1 (no limits means one pod can starve a node; no requests means the scheduler cannot pack correctly).
   2. HPA present? On what metric? Does the deployment have replicas set in manifests that fight with HPA?
   3. PodDisruptionBudget and topologySpreadConstraints or anti-affinity so replicas do not land on the same node.
   4. Uvicorn/Gunicorn worker model: single uvicorn process per pod is fine if replicas scale; multiple workers with limits set too low cause OOM. Cite the CMD and limits together.

C. Database
   1. Connection pool size per pod times replica count versus PostgreSQL max_connections. Compute the number and cite both sides.
   2. Obvious N+1 query patterns in the hottest endpoints (assessment listing, analytics, insights). Cite up to three examples with the ORM code.
   3. Missing indexes on foreign keys and on columns used in filters (assessments by organization, by user, by status). Read the models and migrations.
   4. Long-running requests (PDF generation, analytics aggregation) executed inline in the request thread. Note timeout settings at ingress and uvicorn.

D. Frontend delivery
   1. Is the production frontend a static build behind nginx (or served by the ingress) with cache headers, or a vite dev server? A dev server in production is P0 for scalability and P1 for security.
   2. Bundle size and code splitting are P3; note them only if trivial to fix.

E. Load evidence
   1. If {{CLUSTER_ACCESS}} allows, propose (do not run without approval) a simple load script using k6 or hey against a non-prod namespace: login, list assessments, fetch analytics at 20 concurrent users. Provide the script in the report.
   2. If any existing load test or performance baseline exists, cite it.

Close with a table: control, status, severity, finding reference, and a one-paragraph statement of the current safe maximum replica count and what limits it.
~~~

### 3.5 SA-5: Delivery pipeline (GitHub Actions → Artifactory → Xray → Kubernetes)

~~~text
[GROUND RULES]

You are SA-5, DELIVERY PIPELINE. Read {{OUTPUT_DIR}}/01-inventory.md first. Produce {{OUTPUT_DIR}}/05-pipeline.md.

Read every workflow in {{GHA_PATH}} and any reusable workflows or composite actions they call. For each, answer:

A. Triggers and branch protection
   1. What triggers build, scan, and deploy? Can a deploy to production run from a non-default branch or a manual dispatch without approval?
   2. Are GitHub Environments used with required reviewers for prod? Cite the environment: key or its absence.
   3. Is the default branch protected (required checks, required reviews)? If you cannot see settings, mark UNVERIFIED and list the API call that would confirm.

B. Build integrity
   1. Is the image built once and promoted, or rebuilt per environment? Rebuilding per environment means prod runs untested bits: P1.
   2. Image tags: git SHA, semver, branch name, latest. Is the deploy step pinned to the exact tag or digest that was scanned?
   3. Build caches, multi-stage Dockerfiles, and whether the frontend build runs tsc and lint before packaging.
   4. Are tests a required job before the push-to-Artifactory job (needs:)? Cite the job graph.

C. Scanning
   1. Xray step: does it fail the workflow on policy violation, or only annotate? Cite the step and its inputs (fail-on-severity or equivalent).
   2. Is there a Dockerfile lint (hadolint) or SBOM generation? Optional but note.

D. Deploy mechanics
   1. How does GHA reach the on-prem cluster: kubeconfig secret, Rancher API token, Fleet, ArgoCD, or self-hosted runner? Cite. Note the blast radius of that credential (cluster-admin vs namespace-scoped).
   2. What exactly is applied: kubectl apply -f, kubectl set image, helm upgrade, kustomize. Is the applied manifest committed or generated at deploy time?
   3. Does the workflow wait for rollout (kubectl rollout status) and fail if it does not complete? Does it run a post-deploy smoke check?
   4. Migrations: run by a Job before rollout, by the pod entrypoint, or by hand? Cross-reference SA-3.

E. Secrets in CI
   1. List every secrets.* reference. Confirm none are echoed to logs. Confirm no secret is written into an image layer (ARG/ENV in Dockerfile).
   2. Third-party actions pinned to SHA?

F. Drift and reproducibility
   1. Can a new engineer reproduce the build locally from the README? List the commands. Missing steps are P2.
   2. Are docker-compose files still present and in sync with k8s manifests, or stale? Stale local tooling is P2 (supportability).

Close with a job-graph diagram (ASCII) of the production path from push to running pod, and the control table.
~~~

### 3.6 SA-6: Data layer (PostgreSQL, Alembic, backups)

~~~text
[GROUND RULES]

You are SA-6, DATA LAYER. Read {{OUTPUT_DIR}}/01-inventory.md first. Produce {{OUTPUT_DIR}}/06-data.md.

A. PostgreSQL deployment
   1. Where does it run and how is it persisted? StatefulSet with PVC, external instance, or a Deployment with a PVC (a Deployment with a PVC is P1: RollingUpdate will try to start two writers).
   2. Storage class, reclaim policy, and what happens to data if the namespace is deleted.
   3. Version pin (postgres:15-alpine vs 15.x) and upgrade path.
   4. Credentials: from a Secret? Rotatable?

B. Alembic discipline
   1. Single linear head? Run alembic heads logic by reading versions/ and confirm one head. Multiple heads is P1.
   2. Is env.py importing every model so autogenerate sees the full schema? Cite the imports and compare against models.
   3. Are migrations idempotent under concurrent execution (SA-3 covers the race; here confirm whether alembic_version locking is relied upon)?
   4. Any migration containing data changes (INSERT/UPDATE) mixed with schema changes? Flag.
   5. Every downgrade() implemented and non-trivial?

C. Seeding
   1. Seed scripts (frameworks, admin user): are they guarded so they never overwrite existing rows? Trace the guard. A seed that resets the admin password on every boot is P0.
   2. Is seeding part of the app boot or a separate one-time Job?

D. Backups and restore
   1. Any admin backup feature that writes pg_dump output to the pod filesystem: where does it go, is it on a PVC, is it reachable after a pod restart, is the endpoint restricted to admins?
   2. Is there a scheduled backup (CronJob, Rancher backup, storage snapshot)? Cite or mark absent (P1 for stability).
   3. Has a restore ever been tested? Look for a documented procedure. Absent is P2.

E. Schema health
   1. Foreign keys with ON DELETE behavior that could orphan or cascade unexpectedly.
   2. Missing indexes on FK columns and common filters (also reported by SA-4; consolidate here).
   3. Enum columns implemented as Python enums vs PostgreSQL enums, and whether adding a value requires a migration the team knows how to write.

Close with the control table and a proposed migration Job manifest (Kubernetes Job running alembic upgrade head with the same image, backoffLimit 0, run before rollout).
~~~

### 3.7 SA-7: Frontend and API contract

~~~text
[GROUND RULES]

You are SA-7, FRONTEND AND API CONTRACT. Read {{OUTPUT_DIR}}/01-inventory.md first. Produce {{OUTPUT_DIR}}/07-frontend.md.

A. Build and serve
   1. Production image: multi-stage build producing static assets served by nginx (or equivalent) with a non-root user? Or vite dev server? Cite Dockerfile.
   2. How the API base URL is resolved at runtime (build-time VITE_ var, runtime config.js, same-origin via ingress path). Hardcoded hostnames or IPs are P1.
   3. nginx config: gzip, cache headers for hashed assets, no-cache for index.html, SPA fallback to index.html, security headers.

B. Auth handling
   1. Where the JWT is stored (localStorage vs httpOnly cookie). For an internal app localStorage is acceptable; note it, do not fail it.
   2. 401 handling: does the API client clear the token and redirect? Is there a refresh flow or just expiry?
   3. Role-based UI gating exists, but confirm the backend enforces the same rules (cross-reference SA-2 B).

C. Type safety and quality gates
   1. tsc strict mode on? eslint runs with max-warnings 0? Are these executed in CI?
   2. Are API response types hand-written or generated from OpenAPI? Hand-written types that drift from the backend are P2; propose openapi-typescript generation as the fix.
   3. Console logging: the ancestor mandated verbose [Component] console.log during MVP. In production this is noise and can leak tokens or payloads. Count console.log calls, check for any that print auth headers or tokens, and propose a logger with level gating.

D. Runtime behavior
   1. Error boundaries present?
   2. Any polling or long-lived requests that multiply with tab count?
   3. Large lists rendered without pagination.

E. API contract
   1. Is the OpenAPI spec versioned or published as an artifact in CI? Does any breaking change detection exist?
   2. Are API paths versioned (/api/v1)? Not required; note as P3 if absent.

Close with the control table.
~~~

### 3.8 SA-8: Observability and supportability

~~~text
[GROUND RULES]

You are SA-8, OBSERVABILITY AND SUPPORTABILITY. Read {{OUTPUT_DIR}}/01-inventory.md first. Produce {{OUTPUT_DIR}}/08-observability.md.

The question this report answers: can an on-call engineer who did not write this app diagnose and fix a 2 a.m. outage using only what exists today?

A. Logging
   1. Structured JSON logging present (structlog or similar)? Request ID / correlation ID per request, propagated to the frontend via header?
   2. Log level configurable via env? Default in prod?
   3. Are logs shipped anywhere (Rancher logging, Loki, ELK) or only kubectl logs? Cite manifests or mark UNVERIFIED.
   4. Do logs contain secrets or tokens (grep the logging middleware for headers)?

B. Metrics and alerting
   1. /metrics endpoint (prometheus-fastapi-instrumentator or similar)? ServiceMonitor present?
   2. Any alert rules (pod restarts, 5xx rate, DB connection failures)? Cite or mark absent (P2).
   3. Dashboards referenced anywhere?

C. Health semantics
   1. /health returns a body with component status; confirm it does not leak exception strings (cross-reference SA-2 C4).
   2. Version endpoint exposes the deployed git SHA so on-call can confirm what is running. Absent is P2.

D. Documentation for support
   1. README accuracy: does it still describe docker-compose only? Are the k8s deploy steps documented?
   2. Presence of: runbook (how to restart, roll back, rotate secrets, restore DB), on-call contact / ownership, architecture doc, ADRs or decision log, environment matrix (which URL is which env).
   3. CLAUDE.md / copilot-instructions.md / AGENTS.md: do they exist and describe the real production layout, or still the ancestor's docker-compose layout? Stale agent instructions are P2 because every future AI-assisted change starts from a wrong mental model.

E. Ownership and process
   1. CODEOWNERS file? Required reviewers?
   2. Issue templates, PR template, change log?
   3. Is there a support escalation path from business owner to IT documented anywhere?

Close with the control table and a list of the minimum documents that must exist before IT can accept support (feed this to Synthesis).
~~~

---

## 4. Prompt M-1: Synthesis (scorecard and hardening plan)

~~~text
[GROUND RULES]

You are the MASTER AGENT performing SYNTHESIS. Read every file {{OUTPUT_DIR}}/01-*.md through {{OUTPUT_DIR}}/08-*.md in full before writing anything.

Produce two files.

FILE 1: {{OUTPUT_DIR}}/90-scorecard.md

1. De-duplicate findings across reports. When two sub-agents reported the same issue, keep one finding, cite both reports, and use the higher severity.
2. Build the scorecard table below. Status per row is PASS, FAIL, or UNVERIFIED, with the finding IDs that justify it.

| # | Control | S | Status | Findings |
|---|---------|---|--------|----------|
| 1 | No default or committed secrets | Secure | | |
| 2 | Auth enforced on every non-public endpoint; admin checks role | Secure | | |
| 3 | Containers run non-root with dropped capabilities | Secure | | |
| 4 | Image scan gates the pipeline | Secure | | |
| 5 | CORS and docs exposure restricted for prod | Secure | | |
| 6 | Migrations run once, before rollout, not per pod | Stable | | |
| 7 | Probes reflect real health and do not restart on DB blips | Stable | | |
| 8 | Tests gate the build (backend + tsc + lint) | Stable | | |
| 9 | Immutable image tags; one-line rollback | Stable | | |
| 10 | Seeding cannot overwrite production data | Stable | | |
| 11 | Scheduled DB backup exists and restore is documented | Stable | | |
| 12 | Runs correctly at replicas >= 2 (no local state) | Scalable | | |
| 13 | Resource requests and limits on every container | Scalable | | |
| 14 | PDB and anti-affinity / spread | Scalable | | |
| 15 | DB pool sized against max_connections | Scalable | | |
| 16 | Frontend is a static production build | Scalable | | |
| 17 | Structured logs with request IDs | Supportable | | |
| 18 | Metrics endpoint and basic alerts | Supportable | | |
| 19 | Version/SHA endpoint | Supportable | | |
| 20 | Runbook, ownership, accurate agent instructions | Supportable | | |

3. Below the table, list every P0 and P1 finding with its fix and verification, ordered by severity then by dependency (a fix that unblocks other fixes comes first).
4. State the overall verdict in one paragraph: READY, READY WITH CONDITIONS (list them), or NOT READY, per S.

FILE 2: {{OUTPUT_DIR}}/91-hardening-plan.md

Write the plan as ordered phases. No durations, no dates, no effort estimates. Each phase lists:
- Goal (one sentence)
- Findings closed (IDs)
- Changes (per repo/file, concrete; include manifest or code snippets under 30 lines, otherwise describe precisely)
- Verification gate (what must be true to declare the phase done; reference Section 5 gates)
- Rollback (how to undo this phase if it breaks something)

Suggested phase order, adjust based on findings:
Phase 0: Stop the bleeding (P0s: secrets, seed overwrite, dev server in prod)
Phase 1: Safe deploys (migration Job, immutable tags, rollout status, smoke test, probes)
Phase 2: Multi-replica readiness (local state removal, resources, PDB, pool sizing)
Phase 3: Security hardening (non-root, scan gating, CORS, docs exposure, SHA-pinned actions)
Phase 4: Supportability (logging/metrics, version endpoint, runbook, CODEOWNERS, updated agent instructions)
Phase 5: Hygiene (P3s, dependency updates, dead docker-compose cleanup)

End the plan with a "Handoff to IT" checklist: the artifacts that must exist and be reviewed before IT accepts operational ownership.
~~~

---

## 5. Prompt M-2: Verification gates

These gates are how the human confirms the plan actually worked. The master agent writes them; a human or an agent with cluster access executes them in non-prod.

~~~text
[GROUND RULES]

You are the MASTER AGENT writing VERIFICATION GATES. Read {{OUTPUT_DIR}}/91-hardening-plan.md. Produce {{OUTPUT_DIR}}/92-verification-gates.md.

For each gate below, write the exact commands (kubectl, curl, psql, pytest, k6/hey) an engineer runs in the {{NAMESPACES}} non-prod namespace, the expected output, and the pass criterion. Adapt names to the real manifests from 01-inventory.md. Do not execute anything against production.

GATE S1: Secrets
  - grep and git-history search return no default secret values.
  - kubectl get secret <name> -o yaml shows keys present; pods reference them via envFrom/secretKeyRef.
  - App fails fast at boot if SECRET_KEY is unset or equals a known default (propose the config check if absent).

GATE S2: AuthZ
  - curl each admin endpoint with a non-admin token: expect 403.
  - curl a protected endpoint with no token: expect 401.
  - curl another user's resource by ID: expect 403/404.

GATE S3: Container posture
  - kubectl get pod -o jsonpath for securityContext shows runAsNonRoot true; kubectl exec whoami is not root.
  - Xray policy: force a known-vulnerable base tag in a throwaway branch and confirm the workflow fails.

GATE T1: Migration safety
  - Scale deployment to 0, run migration Job, confirm alembic_version updated once; scale to 3 and confirm no pod runs alembic (kubectl logs show no "Running upgrade").
  - Trigger a rolling update; confirm zero 5xx during rollout (curl loop against /health and one authenticated endpoint).

GATE T2: Probes
  - Kill the database connection (scale postgres to 0 in non-prod or block with NetworkPolicy); confirm readiness goes false, liveness does NOT restart pods, and pods recover when DB returns.

GATE T3: Tests gate the build
  - Introduce a failing test in a throwaway branch; confirm the push-to-Artifactory job is skipped.
  - Introduce a TypeScript error; confirm the frontend build job fails.

GATE T4: Rollback
  - Deploy version N, then N+1, then roll back to N using only the documented procedure. Confirm /version reports N and the app serves traffic.

GATE T5: Backup and restore
  - Run the backup CronJob (or trigger it), copy the dump, restore into a scratch database, and count rows in the assessments table before and after. Counts match.

GATE C1: Multi-replica
  - Scale backend to 3. Log in, create an assessment, list it, generate a PDF/export, and confirm every request succeeds regardless of which pod serves it (kubectl logs -l app=backend --prefix shows requests spread across pods).
  - kubectl drain one node (non-prod) and confirm the app stays available.

GATE C2: Resources
  - kubectl describe pod shows requests and limits on every container; kubectl top pod shows steady-state usage below limits with headroom.

GATE C3: Load
  - Run the load script from 04-scalability.md at 20 concurrent users. Pass: p95 latency under 1 s for list endpoints, zero 5xx, no pod restarts, DB connections below max_connections.

GATE O1: Observability
  - One request with a known X-Request-ID appears in backend logs with that ID as a JSON field.
  - /metrics returns Prometheus text; a 5xx rate panel or alert rule references it.
  - /version (or /health body) returns the git SHA matching the deployed image label.

GATE O2: Supportability
  - A person who has never seen the repo follows the runbook to: restart the app, roll back one version, rotate SECRET_KEY, restore a backup. Record any step where they had to ask a question; each is a doc defect.

Format each gate as: Purpose, Commands, Expected, Pass criterion, Evidence to attach.
~~~

---

## 6. Prompt M-3: Optional remediation branch

Use only after the human has reviewed the plan and chosen which phases to implement.

~~~text
[GROUND RULES]

You are the MASTER AGENT implementing PHASE {{N}} of {{OUTPUT_DIR}}/91-hardening-plan.md on a new branch named hardening/phase-{{N}}-<slug>.

Rules for this task:
1. Implement only the changes listed for Phase {{N}}. Do not touch other findings even if you see them.
2. Every change must be verifiable locally or in CI before pushing: run the backend tests, tsc, lint, and any manifest validation (kubeconform or kubectl apply --dry-run=client) that the repo supports. Paste the command output in your final message.
3. Update the docs the change affects (README, runbook, agent instructions). A change without its docs is incomplete.
4. Commit in small, single-purpose commits with the message body citing the finding ID.
5. Open a pull request whose description contains: findings closed, verification gate to run, rollback steps. Do not merge.
6. If a change requires a secret value or an approval you do not have, stop, list exactly what is needed, and leave the rest of the phase done.
~~~

---

## 7. Scorecard and report templates

### 7.1 Sub-agent report skeleton

```markdown
# SA-<n>: <Area>

Reviewed: <commit SHA> on <date>
Inputs: 01-inventory.md, <files/manifests/workflows read>

## Summary
<3 to 5 sentences: what is sound, what is not, the single most important fix>

## Findings
### [P1] <title>
- Area:
- Evidence:
- Why it matters:
- Fix:
- Verification:
- Status:

## Control table
| Control | Status | Severity | Finding |
|---------|--------|----------|---------|

## Unverified items and what would verify them
- <item>: needs <access/artifact>
```

### 7.2 Verdict language

Use exactly one of these per S in the scorecard:

- **READY**: all controls for that S are PASS or P3-only.
- **READY WITH CONDITIONS**: no P0, and every P1 has a fix scheduled in Phase 0 or 1 of the plan.
- **NOT READY**: any P0 open, or any P1 without a planned fix.

---

## 8. Known weaknesses inherited from the ancestor (hint list for SA-1)

These exist in this open-source ancestor as of the commit this runbook was written against. The production fork has nine months of changes, so each must be confirmed PRESENT, FIXED, or NOT APPLICABLE with a citation. Do not assume either way.

| # | Ancestor weakness | Where in ancestor | Likely severity if still present |
|---|-------------------|-------------------|----------------------------------|
| A1 | Default `SECRET_KEY` value in code with no startup guard | `backend/app/config.py` | P0 |
| A2 | Database password embedded in the default `DATABASE_URL` and in compose files | `backend/app/config.py`, `docker-compose*.yml` | P0 if the same value reached k8s Secrets |
| A3 | `DEBUG` defaults to `True` | `backend/app/config.py` | P2 |
| A4 | CORS allow-list hardcoded with dev IPs and hostnames; credentials allowed with `*` methods and headers | `backend/app/config.py`, `backend/app/main.py` | P2 |
| A5 | Entrypoint runs `alembic upgrade head` and seed scripts on every container start | `backend/docker-entrypoint.sh` | P1 at replicas > 1 |
| A6 | Entrypoint waits on hardcoded host `postgres` with `pg_isready` | `backend/docker-entrypoint.sh` | P2 (breaks under a different Service name) |
| A7 | Seeded admin user with a documented default password | `backend/app/scripts/init_database.py`, `README.md` | P0 if still active in prod |
| A8 | Frontend Dockerfile runs the Vite dev server, not a static build | `frontend/Dockerfile` | P0 for scale, P1 for security |
| A9 | Backend image runs as root; no `USER` directive | `backend/Dockerfile` | P1 |
| A10 | `/health` returns raw exception text on DB failure | `backend/app/main.py` | P2 |
| A11 | Admin backup feature writes pg_dump output to the container filesystem | `backend/app/api/admin_backups.py` | P1 at replicas > 1 or on restart |
| A12 | `datetime.utcnow()` and FastAPI `on_event` deprecated patterns | `backend/app/core/security.py`, `backend/app/main.py` | P3 |
| A13 | `python-jose` (unmaintained) for JWT; `passlib` with `bcrypt` 4.x | `backend/pyproject.toml` | P2 |
| A14 | No rate limiting on `/api/auth/login` | `backend/app/api/auth.py` | P2 |
| A15 | JWT carries only `sub`; role re-read from DB (good); token lifetime 30 min with no refresh | `backend/app/api/auth.py` | P3 |
| A16 | Frontend auto-detects the backend URL by hostname and port | `frontend/src/services/api.ts` | P1 if hostnames are hardcoded |
| A17 | Verbose `console.log` mandated by `CLAUDE.md` during MVP | `CLAUDE.md`, `frontend/src/**` | P2 in production |
| A18 | Tests directory is mostly manual checklists; pytest suite is thin | `tests/`, `backend/` | P1 (nothing gates deploys) |
| A19 | No CI workflow in the ancestor at all (the fork added GHA) | `.github/` absent | Confirm the fork's workflows gate on tests and scans |
| A20 | Agent instructions (`CLAUDE.md`) describe docker-compose, a dev PC IP, and a test user | `CLAUDE.md` | P2 (stale mental model for every AI-assisted change) |
| A21 | No resource limits, probes, PDB, or NetworkPolicy exist in the ancestor (compose only) | n/a | Confirm the fork's manifests define them |
| A22 | Versioning: `VERSION` string in config, package.json version, pyproject version are all different | `config.py`, `package.json`, `pyproject.toml` | P3 |

---

## 9. Operator checklist

Tick these as you go.

- [ ] Placeholders filled in Section 0.1.
- [ ] Master agent given access listed in Section 0.2.
- [ ] M-0 run; `00-index.md` exists.
- [ ] SA-1 report reviewed by a human for accuracy before SA-2 through SA-8 start.
- [ ] SA-2 through SA-8 reports exist and every finding has evidence.
- [ ] M-1 run; scorecard and plan reviewed.
- [ ] M-2 run; gates executed in non-prod; evidence attached.
- [ ] Phases implemented via M-3 one at a time, each behind a PR.
- [ ] Handoff-to-IT checklist from the plan completed.

---

*Companion document: [Vibe-to-Enterprise Skills Runbook](./vibe-to-enterprise-skills-runbook.md) covers building reusable skills and Copilot instructions so the next app starts from a supportable baseline.*
