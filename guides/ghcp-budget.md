# GitHub Copilot AIC Budget Management — Implementation-Ready Package for EMU Enterprises (Copilot Business, 500–2,000 seats)

## TL;DR
- On **June 1, 2026**, GitHub replaced premium request units (PRUs) with **GitHub AI Credits (AIC)** where **1 AI credit = $0.01 USD** (confirmed in GitHub Docs "Models and pricing"). Copilot Business includes **1,900 credits/user/month** ($19), promotionally **3,000** through Sept 1, 2026; Copilot Enterprise **3,900** (promo 7,000). Credits are **pooled at the enterprise level** and reset monthly (no rollover).
- The single most important technical finding: a **budget-write REST API exists and is GA** (`POST /enterprises/{enterprise}/settings/billing/budgets`) and supports **user-scoped** AI-credit budgets — so the requested self-service "+2,000 AIC on submit" grant is **fully automatable today with no mandatory human step**. The safest production auth is a **classic PAT with `manage_billing:enterprise`** (GitHub App/fine-grained support is very new and was still reported non-functional by real users in summer 2026).
- Everything below is repo-friendly plain text: a full RUNBOOK, Teams/email/FAQ comms templates, Excel/PowerPoint analysis prompts written against the **real** usage-export schema, a complete Issue-Form + GitHub Actions self-service system, feedback mechanisms, and a config-as-code change pipeline.

---

## Key Findings

### AIC fundamentals (verified against GitHub Docs & Changelog)
- **Effective date:** usage-based billing went live June 1, 2026 (Changelog "Updates to GitHub Copilot billing and plans"). PRUs are retired; there is no path to renew into premium requests. Fallback-to-cheaper-model behavior is **gone** — when credits/budget are exhausted, premium features stop.
- **Conversion rate — user's belief CONFIRMED:** 1 AIC = $0.01, so **2,000 AIC = $20**. GitHub Docs: "AI credits draw down the budget at a fixed rate: 1 AI credit = $0.01 USD, so a $10 USD budget covers 1,000 AI credits."
- **What consumes credits:** Copilot Chat, Copilot CLI, Copilot cloud agent (coding agent), Copilot code review, Copilot Spaces, Spark, and third-party coding agents. Consumption = tokens (input + output + cached) × each model's published per-token rate.
- **What does NOT consume credits:** Code completions and Next Edit Suggestions remain **unlimited** on all paid plans. (This is the single most reassuring message for developers.)
- **Included allowances (per user/month, pooled):** Business **1,900** ($19) / Enterprise **3,900** ($39). **Promotional June 1–Sept 1, 2026:** Business **3,000**, Enterprise **7,000**, then they revert to 1,900/3,900. Individual plans (for reference): Pro $10 = 1,500; Pro+ $39 = 7,000; Max $100 = 20,000; Free = limited.
- **Pooling mechanics:** e.g., 100 Business seats = shared pool of 190,000 credits. Adding licenses mid-cycle grows the pool immediately; removals reflected next cycle. No rollover; pool resets 00:00:00 UTC on the 1st of each calendar month.
- **Existing premium-request budgets** were **automatically migrated** to control AI-credit spend on June 1.
- **Model pricing (per 1M tokens; verify live table, it changes):** **GPT-4.1** (Versatile) and **GPT-5 mini** (Lightweight) are **included at zero credit cost** on paid plans (Bodega One, verified vs GitHub docs). Frontier models are expensive: **GPT-5.5 ≈ $5 input / $30 output**; **Claude Opus 4.5–4.8 ≈ $5 input / $25 output**. Practical math: on GPT-5.5, one credit buys ~2,000 input or ~330 output tokens; a large agentic diff can cost 600–1,200 credits ($6–$12) in a single interaction. Authoritative table: `docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing`.

### Budgets — hierarchy and behavior
- **Budget scopes (enterprise view):** enterprise, organization, repository, cost center, and — for AI credits (bundled) **only** — **per user**: *universal* (all licensed users), *per-cost-center universal*, or *individual* (single user). Individual overrides cost-center-universal, which overrides universal.
- **Budget types:** Product-level, SKU-level, and **Bundled AI credits budget**. In the API: `budget_type` = `ProductPricing` | `SkuPricing` | `BundlePricing` (with `budget_product_sku: "ai_credits"`).
- **Evaluation order (official):** (1) **User-level budget** — the first check; "A user-level budget can block a user even when the enterprise or cost center budget still has capacity" (GitHub Docs). (2) Organization / cost-center budgets. (3) Enterprise spending limit — which can also block a user *before* they reach their ULB if it runs out first.
- **Alert thresholds:** 75%, 90%, 100%, shown in the GitHub UI and sent by email (GitHub Docs "Budgets and alerts"). **User-scoped budgets have alerting always disabled.**
- **"Stop usage when budget limit is reached"** (`prevent_further_usage`): For **user** and **multi_user_customer** scopes it **must be `true`** (hard stop always enforced). For most **license-based** products the stop toggle is unavailable — "setting a budget does not prevent usage over the budget amount but does provide alerts"; for **metered** products (Actions, **Copilot AI credits**, cloud sandboxes) "you can set budgets to prevent usage once the budget threshold is reached" (GitHub Docs).
- **Default behavior with NO blocking budget:** The **"AI credits paid usage" policy is enabled by default** for orgs/enterprises — so **overage bills automatically** once the pool is exhausted, unless an admin disables the policy or sets a blocking budget: "Additional usage is enabled by default for organizations and enterprises. If you want to prevent any spending beyond your included AI credits, an administrator must explicitly disable the AI credits paid usage policy." A **$0 user-level budget blocks a user immediately.** (Legacy note: pre-Aug 22 2025 accounts had a default $0 premium-request budget, but those account-level $0 budgets were removed Dec 2, 2025.)

### Cost centers
- Full lifecycle via UI **and** REST API: create/edit/delete; add/remove/reassign resources (orgs, repos, users, enterprise teams). Limits: **1,000** active cost centers/enterprise; **25,000** resources/cost center; **50** resources per add/remove call.
- **For license-based products like Copilot, cost centers are charged by the USERS added.** Users must be added via the API (or UI as of Aug 18, 2025). **Each user belongs to only one cost center**; adding a user already elsewhere moves them. Assigning an **enterprise team** keeps membership in sync automatically.
- **Verdict:** cost centers ARE the right primitive for grouping users into budget tiers — use **direct user assignment** (not org-based) to avoid the "GitHub picks one org at random each cycle" unpredictability when users hold licenses through multiple orgs.

### The critical API question — RESOLVED (budget-write API EXISTS)
Announced GA June 4, 2026 ("Budget and usage management APIs now generally available"). Endpoints under `/enterprises/{enterprise}/settings/billing/budgets`:
- `GET` (list, non-standard paging via `has_next_page`), `POST` (create), `GET /{budget_id}`, `PATCH /{budget_id}` (update amount/stop/alerts), `DELETE /{budget_id}`, and `GET /{budget_id}/user-states` (per-user consumed vs target for multi-user budgets).
- **User-scoped create body** requires: `budget_amount` (whole dollars), `prevent_further_usage: true`, `budget_scope: "user"`, `budget_type: "BundlePricing"`, `budget_product_sku: "ai_credits"`, `user: "<login>"`, `budget_entity_name: ""`. (Docs warn: omit `user` → `HTTP 400: Missing required fields: budget_entity_name`.)
- **Auth (documentation contradiction resolved via targeted research):** The **current** Enterprise Cloud docs say the endpoint works with GitHub App user tokens and GitHub App installation tokens holding **"Enterprise billing" (write)**. Older cached docs and community issues (navikt/copilot #111) said "does not work with…fine-grained…or GitHub App tokens." The change is real but **very new**; as recently as summer 2026 real users (community #164562) reported the GitHub-App path non-functional for this exact endpoint. The **only verified working method** is a **classic PAT with `manage_billing:enterprise`** (plus `manage_billing:copilot`, `read:enterprise`, `read:user`, `user:email` for surrounding automation), from an enterprise-owner/billing-manager service account (proven by the jessehouwing.net working automation). **Standalone fine-grained PATs are not listed** for this enterprise endpoint. **Recommendation: use classic PAT in production; empirically verify the GitHub App path before switching.**
- Enterprise-installed apps get a separate rate-limit budget (15,000 req / 10,000 pts per hour) and **cannot subscribe to webhooks**.

### Usage reports — actual schema
- **Report types:** *Summarized* (all products, up to 1 year), *Detailed* (all products, up to 31 days), and **AI usage report** (per-user AIC breakdown, up to 31 days) — the last two are separate pages ("Metered usage" and "AI usage").
- **AI usage report columns (real field names):** `date, product, sku, quantity, unit_type, applied_cost_per_quantity, gross_amount, discount_amount, net_amount, username, organization, repository, cost_center_name, model, input, output, cache_read, cache_write`. It sums by `date, model, username`; `net_amount = gross_amount − discount_amount` (included/pooled usage shows in `discount_amount`).
- **Granularity/retention:** Detailed & AI reports = max **31 days each** (so 2 months = **two pulls**). REST summarized data = past **24 months**. Reports are emailed as **CSV**; only one report request per account at a time. Removed fields: `usage_at` → use `date`; `workflow_name` → `workflow_path`.
- **API caveat (important):** The **detailed/AI** report (with `username`) is available **only via the web UI**, not the REST `/usage` endpoint (which is summarized only). A separate **CSV usage-reports REST API** (`POST /enterprises/{ent}/settings/billing/reports`) exists in preview (needs `manage_billing:enterprise`). The **Copilot metrics API** exposes `ai_credits_used` per user (added June 19, 2026; in `users-1-day` and `users-28-day`; a per-user *total*, not broken down by model/feature) and `ai_adoption_phase` cohorts (Phase 0–3; added May 29, 2026).

### Overage-abuse controls
- **"AI credits paid usage" policy** (enterprise **AI Controls** tab or org settings): disable to block all overage beyond the pool (enabled by default).
- **$0 user-level budget** = immediate block for that user.
- **EMU per-org policies:** enterprise policies are set first; most support enable / disable / "let organizations decide." Copilot policies live on the **AI controls** tab; changes propagate quickly.
- **AI credit session limits** in Copilot CLI/SDK (July 1, 2026) cap per-session agent spend for unattended automation.

---

## Details — Deliverables

# DELIVERABLE A — `RUNBOOK.md`

## GitHub Copilot AIC Budget Runbook (EMU, 500–2,000 seats)

### 0. Prerequisites
- Enterprise owner or billing manager access.
- A service account (enterprise owner/billing manager) with a **classic PAT** scoped `manage_billing:enterprise, manage_billing:copilot, read:enterprise, read:user, user:email`. Store as Actions secret `GH_BILLING_TOKEN`. SSO-authorize it if SAML is enforced.
- Confirm your enterprise **slug** and that each Copilot-licensed user holds a license through a **single** organization (prevents random-org billing).

### 1. Baseline data collection (Week 1)
1. Enterprise → **Billing & Licensing** → **Usage** → **AI usage** page → download the AI usage report for the last full month; repeat for the prior month (two ≤31-day pulls = 2 months).
2. Pull the Copilot metrics `users-28-day` report for `ai_credits_used` and `ai_adoption_phase` per user.
3. Land both CSVs under `/data/` (or a secured store).

### 2. Sizing methodology
- Compute each user's **monthly AIC consumption**. Set the **base user-level budget = p75 of observed monthly usage**. Rationale: p75 covers ~75% of users with no friction; the p90–p99 tail are power users who self-serve up or get individual overrides; it keeps enterprise-guardrail math bounded.
- **Pool math:** pool value = (Business seats × 1,900) + (Enterprise seats × 3,900) credits — use 3,000/7,000 during the promo until Sept 1, 2026. Set the **enterprise spending limit** to cover the gap between the *sum of user-level budgets* and the pool (raising ULBs without raising the enterprise budget can cause the enterprise limit to block users first).

### 3. Cost center design (500–2,000 seats)
- Create **tiered** cost centers by usage profile, not just org chart:
  - `cc-copilot-standard` — UULB at p75.
  - `cc-copilot-power` — higher per-user budget (e.g., p90).
  - `cc-copilot-restricted` — $0 or low.
- Assign via **enterprise teams** for auto-sync where possible; otherwise add users via API (≤50 per call). One user → one cost center.

### 4. Budget structure recommendation
1. **Enterprise guardrail:** one enterprise-scope Bundled AI credits budget = max acceptable monthly overage, `prevent_further_usage: true`.
2. **Universal user-level budget (UULB):** p75 (e.g., $20–$30/user).
3. **Cost-center user-level budgets:** override UULB for power/restricted tiers.
4. **Individual overrides:** created by the self-service system (+$20 each).

### 5. Step-by-step UI configuration
1. Enterprise → **Billing & Licensing** tab → **Budgets and alerts** → **New budget**.
2. Budget Type = **Bundled AI credits budget**.
3. Budget scope = **Users** → leave user empty for *universal*; select a **cost center** for a tier ULB; select a **user** for an individual override.
4. Set amount (user-level always hard-stops).
5. Add alert recipients (n/a for user scope).
6. Repeat for the enterprise-scope guardrail (add alert recipients here).

### 6. Rollout phases (suggested timeline)
- **Week 1:** Baseline data + advance-notice comms.
- **Week 2:** Create cost centers + enterprise guardrail (monitor only — set generously, no user block yet).
- **Week 3:** Publish the self-service system; set a generous UULB.
- **Week 4:** Tighten UULB to p75; go-live comms.
- **Weeks 5–8:** Monitor, iterate, re-baseline before the promo ends (pool shrinks Sept 1).

### 7. Rollback plan
- **Relax a user:** `PATCH` the budget to a higher amount or `prevent_further_usage: false`, or `DELETE` the ULB/individual budget (reverts to the next-broader scope).
- **Emergency unblock everyone:** raise or `DELETE` the enterprise guardrail and the UULB. Policy/budget changes propagate quickly.

### 8. Ongoing operations cadence
- **Weekly:** review `GET /budgets/{id}/user-states` for users near cap; request-volume trend; pool depletion %.
- **Monthly:** re-pull AI usage report; recompute distribution; post the monthly summary; re-baseline UULB if the trigger criteria (Deliverable E) are met.

---

# DELIVERABLE B — Communication Plan & Templates

**Teams formatting note:** Office 365 Connector webhooks are retired — use **Teams Workflows** ("Post to a channel when a webhook request is received"). Cards must be Adaptive Card **v1.4** (v1.5 renders inconsistently in Teams), wrapped as `{"type":"message","attachments":[{"contentType":"application/vnd.microsoft.card.adaptive","content":{…}}]}`. Throttle: ≤4 requests/second/webhook. @-mentions are not supported from incoming webhooks.

**Template 1 — Advance notice (Teams post)**
> **📣 Copilot billing is changing — heads up**
> As of June 1, 2026, GitHub Copilot moved from "premium requests" to **AI Credits (AIC)** — 1 credit = $0.01. **Your everyday autocomplete stays unlimited and free.** Only Chat, agents, code review, CLI and Spaces use credits, based on how much work the AI actually does (tokens × model rate). To keep spend predictable and fair, we're introducing per-person monthly budgets. Mechanics next week. Questions → [channel/FAQ link].

**Template 2 — Budget go-live**
> **✅ Copilot AI Credit budgets are live**
> Everyone now has a monthly budget of **[X] AI credits ($[Y])**. **Autocomplete is unaffected.** If you run low, you can **self-serve +2,000 credits ($20)** anytime via our request form: [link]. Chat/agents pause only if you hit your cap. Credits reset on the 1st (UTC); they don't roll over. Tip: routine chat on **GPT-5 mini / GPT-4.1 costs 0 credits.**

**Template 3 — How to request more credits**
> **➕ Need more Copilot credits?**
> Open a request: **[Issue Form link]**. A **reason is required**; pick a justification category and your cost center. On submit you're **automatically granted +2,000 AIC ($20)** for this cycle. Requests are logged and reviewed. Limit: **[N] increases/month**.

**Template 4 — Approaching-limit warning (adaptive card body)**
> **⚠️ You're at 90% of your Copilot budget**
> You've used **[used]/[total]** AI credits this cycle. Avoid interruption — request more: [link]. Save credits: use GPT-5 mini/GPT-4.1 (0 credits) for quick questions; start fresh chats to shrink context; reserve frontier models/agents for high-value work.

**Template 5 — Budget exhausted**
> **⛔ Copilot premium features paused**
> You've reached your AI credit budget. **Autocomplete still works.** Request +2,000 AIC here: [link] — grants apply automatically on submit. Otherwise resets **[date]**.

**Template 6 — Monthly usage summary**
> **📊 Copilot usage — [Month]**
> Pool consumed: **[%]** · Users blocked: **[n]** · Median usage: **[x]** credits · p90: **[y]** · Top models: **[…]** · Credit-increase requests granted: **[n]** · Avg time-to-grant: **[t]s**. No action needed unless you regularly hit your cap.

**Template 7 — FAQ (top ~20 questions)**
1. **Why am I being limited?** To keep AI spend predictable and fair across the org — not to restrict your work. Autocomplete is never limited.
2. **Does this affect autocomplete / inline suggestions?** No. Code completions and Next Edit Suggestions are unlimited and free on all paid plans.
3. **What counts as a credit?** Tokens (input + output + cached) consumed by Chat, agents, code review, CLI, Spaces, Spark — priced per model. 1 credit = $0.01.
4. **What happens if I run out mid-sprint?** Premium features pause; autocomplete continues. Submit the form for an instant +2,000 AIC.
5. **Who sees / reviews my request form?** Requests are logged and reviewed by the platform team; individual reviewers are not disclosed.
6. **Is this used to evaluate my performance?** No. Usage is for capacity planning and cost management, not performance review.
7. **How fast is a grant?** Automatic on submission (seconds).
8. **Do credits roll over?** No — they reset on the 1st (UTC) each month.
9. **How do I use fewer credits?** Prefer GPT-5 mini/GPT-4.1 (0 credits) for routine chat; shorter context; reserve agents/frontier models for high-value tasks.
10. **Which models are free?** GPT-4.1 and GPT-5 mini on paid plans.
11. **Why did one agent run cost hundreds of credits?** Agentic runs produce large outputs; output tokens are the expensive side, especially on frontier models.
12. **Can I see my own usage?** Yes — GitHub Settings → Copilot usage page shows credits used this cycle.
13. **What's my budget?** [X] credits ($[Y])/month, plus any self-serve increases.
14. **Is there a cap on how many increases I can request?** Yes — [N]/month.
15. **What if I need a permanent higher budget?** Note it in your request; recurring max-outs feed our monthly re-baselining.
16. **Does code review cost credits?** Yes, plus GitHub Actions minutes as of June 1, 2026.
17. **Will my team's spend affect me?** Included credits are pooled; power users can draw more while light users offset — but your personal cap still applies.
18. **What happens when the promo ends (Sept 1, 2026)?** Included credits drop (Business 3,000→1,900). We'll re-baseline before then.
19. **Where do I get help?** [channel link].
20. **Can I still use Copilot with $0 budget?** Autocomplete yes; premium features no until you request an increase.

**Email variants:** identical copy; subject lines e.g. "Action needed: Copilot billing is changing," "Your Copilot AI Credit budget is live," "You're at 90% of your Copilot budget."

---

# DELIVERABLE C — Data Analysis Prompts (Microsoft Copilot in Excel / PowerPoint)

**Real schema to reference (AI usage report):** `date, product, sku, quantity, unit_type, applied_cost_per_quantity, gross_amount, discount_amount, net_amount, username, organization, repository, cost_center_name, model, input, output, cache_read, cache_write`. (`quantity` on AI-credit rows is credits; `net_amount` is the billable $.)

**Copilot in Excel — real limitations:**
- Data must be a **formatted Excel table** (Ctrl+T), single header row, consistent types, no merged cells; file saved in **OneDrive/SharePoint** (.xlsx/.xlsm) — the Copilot icon is greyed out for local files.
- Practical row ceiling ~**2,000,000** (native Excel max is 1,048,576 rows/sheet); performance degrades on large/unstructured data. Use **Power Query** to split/filter beyond that.
- **Cannot** build Power Query steps or advanced statistical/econometric models. The `COPILOT()` function can omit rows on large arrays, returns dates as text, and has no web/enterprise grounding.
- Provide **fallback formulas** wherever Copilot struggles (below).

**Prompts:**
1. **Clean/normalize:** "Convert this range to a table named `Usage`. Ensure `date` is a real date, and `quantity`/`net_amount` are numbers. Remove rows where `username` is blank. Add a `month` column = the year-month of `date`."
2. **Per-user monthly consumption:** "Create a PivotTable summing `quantity` by `username` (rows) and `month` (columns)." *Fallback:* `=SUMIFS(Usage[quantity],Usage[username],$A2,Usage[month],B$1)`.
3. **Distribution stats:** "For monthly credits per user, compute mean, median, and the 50th/75th/90th/95th/99th percentiles." *Fallback:* `=PERCENTILE.INC(range,0.75)` (and 0.5/0.9/0.95/0.99), `=AVERAGE()`, `=MEDIAN()`.
4. **Segment power/light/zero users:** "Classify each user: zero (0), light (< p50), medium (p50–p90), power (> p90)." *Fallback:* `=IFS(C2=0,"zero",C2<$p50,"light",C2<=$p90,"medium",TRUE,"power")`.
5. **"What % hit the cap at $X":** "For candidate budgets $10–$50, compute the % of users whose monthly credits ≥ budget×100." *Fallback:* `=COUNTIF(monthly_credits,">="&X*100)/COUNT(monthly_credits)`.
6. **Segment by org/team/cost center:** "PivotTable: rows = `cost_center_name` then `organization`; values = sum `quantity`, count distinct `username`."
7. **Month-over-month growth / forecast:** "Compare month-1 vs month-2 total credits per user, compute growth %, and project month-3 with simple linear growth." *Fallback:* `=(M2-M1)/M1`.
8. **PowerPoint deck:** "Build a 6-slide executive deck from this analysis: (1) title + period, (2) current spend vs pooled credits, (3) per-user distribution histogram, (4) power-user segment and their share of spend, (5) recommended base budget at p75 with the % who would hit that cap, (6) 90-day forecast and the re-baseline trigger criteria."

**Recommended statistical approach:** set the **base budget at p75** of observed monthly usage. Justification: covers the majority with no friction; the p90–p99 tail (power users) self-serve up or get individual overrides; keeps the enterprise-guardrail exposure bounded and forecastable.

---

# DELIVERABLE D — Self-Service Budget Increase System (Issue Forms + Actions)

**This is fully automatable today** — a user-scoped budget-write API exists, so no mandatory human step is required for the grant.

### D.1 `.github/ISSUE_TEMPLATE/copilot-credit-request.yml`
```yaml
name: Copilot Credit Increase Request
description: Request an additional 2,000 AI credits ($20) for GitHub Copilot.
title: "[Copilot Credits] Request"
labels: ["copilot-credit-request"]
body:
  - type: markdown
    attributes:
      value: |
        ## Copilot AI Credit Increase
        Submitting this form grants you **+2,000 AI credits ($20)** for the current billing cycle.
        Requests are logged and reviewed. A **reason is required.**
  - type: input
    id: github_username
    attributes:
      label: Your GitHub username (EMU handle)
      description: Must exactly match your handle (the submitter).
    validations:
      required: true
  - type: dropdown
    id: justification_category
    attributes:
      label: Justification category
      options:
        - "Agentic workflow / coding agent"
        - "Large refactor or migration"
        - "Code review at scale"
        - "Sprint deadline / delivery pressure"
        - "Learning / onboarding"
        - "Other (explain below)"
    validations:
      required: true
  - type: textarea
    id: reason
    attributes:
      label: Reason / justification (required)
      description: Explain why you need more credits. This is auditable.
    validations:
      required: true
  - type: dropdown
    id: cost_center
    attributes:
      label: Project / cost center
      options:
        - "cc-copilot-standard"
        - "cc-copilot-power"
        - "Other / unsure"
    validations:
      required: true
  - type: checkboxes
    id: acknowledgments
    attributes:
      label: Acknowledgments
      options:
        - label: I understand this grants +2,000 AIC ($20) until exhausted or the monthly reset.
          required: true
        - label: I understand my request is logged and may be reviewed.
          required: true
```
**Notes:** `required: true` is enforced **only in public repos** — in private/internal repos all fields are optional, so the workflow re-validates. A checkbox *group* can't be "at least one required"; each option's `required: true` is per-option (used here for the two acknowledgments). Wrap any Yes/No dropdown options in quotes to avoid YAML boolean coercion.

### D.2 `.github/workflows/copilot-credit-grant.yml`
```yaml
name: Copilot Credit Grant
on:
  issues:
    types: [opened]
permissions:
  issues: write
  contents: write   # for audit-log commit
jobs:
  grant:
    if: contains(github.event.issue.labels.*.name, 'copilot-credit-request')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Parse issue form
        id: parse
        uses: stefanbuck/github-issue-parser@v3
        with:
          template-path: .github/ISSUE_TEMPLATE/copilot-credit-request.yml

      - name: Validate submitter and required fields
        env:
          ISSUE_USER: ${{ github.event.issue.user.login }}
          FORM_USER: ${{ steps.parse.outputs.issueparser_github_username }}
          REASON: ${{ steps.parse.outputs.issueparser_reason }}
        run: |
          if [ -z "$REASON" ]; then echo "reason missing"; exit 1; fi
          if [ "${ISSUE_USER,,}" != "${FORM_USER,,}" ]; then
            echo "requester mismatch"; exit 1; fi

      - name: Rate-limit check (max 3 grants/user/month)
        id: ratelimit
        env:
          GH_TOKEN: ${{ github.token }}
          USER: ${{ github.event.issue.user.login }}
        run: |
          MONTH=$(date -u +%Y-%m)
          COUNT=$(gh issue list --repo "$GITHUB_REPOSITORY" \
            --label copilot-credit-request --state all --limit 200 \
            --search "author:$USER created:${MONTH}-01..${MONTH}-31" \
            --json number | jq length)
          echo "count=$COUNT" >> "$GITHUB_OUTPUT"
          if [ "$COUNT" -gt 3 ]; then echo "over_limit=true" >> "$GITHUB_OUTPUT"; fi

      - name: Deny if over limit
        if: steps.ratelimit.outputs.over_limit == 'true'
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          gh issue comment ${{ github.event.issue.number }} \
            --body "You've reached the monthly limit of credit-increase requests. Please contact an admin."
          gh issue close ${{ github.event.issue.number }}
          exit 0

      - name: Read current budget & compute new amount
        id: budget
        if: steps.ratelimit.outputs.over_limit != 'true'
        env:
          GH_TOKEN: ${{ secrets.GH_BILLING_TOKEN }}   # classic PAT: manage_billing:enterprise
          ENT: your-enterprise-slug
          USER: ${{ github.event.issue.user.login }}
        run: |
          BUDGET_JSON=$(gh api "/enterprises/$ENT/settings/billing/budgets?scope=user&user=$USER")
          CURRENT=$(echo "$BUDGET_JSON" | jq -r '.budgets[0].budget_amount // 0')
          BID=$(echo "$BUDGET_JSON" | jq -r '.budgets[0].id // ""')
          echo "new_amount=$((CURRENT + 20))" >> "$GITHUB_OUTPUT"
          echo "budget_id=$BID" >> "$GITHUB_OUTPUT"

      - name: Create or update user budget (+$20)
        if: steps.ratelimit.outputs.over_limit != 'true'
        env:
          GH_TOKEN: ${{ secrets.GH_BILLING_TOKEN }}
          ENT: your-enterprise-slug
          USER: ${{ github.event.issue.user.login }}
          NEW_AMOUNT: ${{ steps.budget.outputs.new_amount }}
          BUDGET_ID: ${{ steps.budget.outputs.budget_id }}
        run: |
          if [ -z "$BUDGET_ID" ]; then
            gh api --method POST "/enterprises/$ENT/settings/billing/budgets" \
              -f budget_scope=user -f user="$USER" -f budget_type=BundlePricing \
              -f budget_product_sku=ai_credits -F budget_amount="$NEW_AMOUNT" \
              -F prevent_further_usage=true -f budget_entity_name="" \
              -F 'budget_alerting[will_alert]=false'
          else
            gh api --method PATCH "/enterprises/$ENT/settings/billing/budgets/$BUDGET_ID" \
              -F budget_amount="$NEW_AMOUNT" -F prevent_further_usage=true
          fi

      - name: Append to audit log
        if: steps.ratelimit.outputs.over_limit != 'true'
        run: |
          mkdir -p audit
          echo "$(date -u +%FT%TZ),${{ github.event.issue.user.login }},+20,${{ steps.budget.outputs.new_amount }},#${{ github.event.issue.number }}" >> audit/grants.csv
          git config user.name "copilot-budget-bot"
          git config user.email "bot@users.noreply.github.com"
          git add audit/grants.csv && git commit -m "audit: grant for ${{ github.event.issue.user.login }}" && git push

      - name: Notify reviewers via Teams
        if: steps.ratelimit.outputs.over_limit != 'true'
        env:
          TEAMS_WEBHOOK: ${{ secrets.TEAMS_WEBHOOK }}
        run: |
          curl -H "Content-Type: application/json" -d '{
            "type":"message",
            "attachments":[{
              "contentType":"application/vnd.microsoft.card.adaptive",
              "content":{
                "$schema":"http://adaptivecards.io/schemas/adaptive-card.json",
                "type":"AdaptiveCard","version":"1.4",
                "body":[
                  {"type":"TextBlock","text":"Copilot credit grant","weight":"Bolder","size":"Large"},
                  {"type":"FactSet","facts":[
                    {"title":"User","value":"${{ github.event.issue.user.login }}"},
                    {"title":"Amount","value":"+2000 AIC ($20)"},
                    {"title":"New budget","value":"$${{ steps.budget.outputs.new_amount }}"},
                    {"title":"Issue","value":"#${{ github.event.issue.number }}"}
                  ]}
                ]
              }
            }]
          }' "$TEAMS_WEBHOOK"

      - name: Confirm to requester and close
        if: steps.ratelimit.outputs.over_limit != 'true'
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          gh issue comment ${{ github.event.issue.number }} --body "✅ Granted +2,000 AI credits. New monthly budget: \$${{ steps.budget.outputs.new_amount }}."
          gh issue close ${{ github.event.issue.number }}
```

### D.3 Automatable vs human (be explicit)
- **Fully automatable today:** parse → validate → rate-limit → read current budget → create/update the **user-scoped** budget via API → audit → Teams notify → confirm/close. **No human step is required** because the user-scoped budget-write API exists.
- **Optional human-in-loop (<60s):** If you want approval-gating for large requests, wrap the "Create/update budget" step in a **GitHub Actions Environment** with required reviewers; the reviewer just clicks "Approve." Keep the pre-filled context (user, amount, reason) in the deployment summary so approval takes seconds.
- **Psychological deterrent (as requested):** reviewers are notified privately in Teams; **requesters are never told who reviews.** The **required reason + append-only audit log** is the deterrent, analogous to Azure PIM elevation.

### D.4 Rate-limit / abuse detection, audit trail, reviewer dashboard
- **Rate limit:** max 3 grants/user/month (workflow-enforced; tune `N`). Auto-deny + close over limit.
- **Abuse detection:** flag users who max out every month (query `audit/grants.csv`) and users near cap via `GET /budgets/{id}/user-states` — feed both into monthly re-baselining.
- **Audit trail:** append-only `audit/grants.csv` (committed) **plus** the issues themselves as immutable records.
- **Reviewer dashboard concept:** a **GitHub Projects** board filtered on the `copilot-credit-request` label (columns: New → Granted → Flagged), augmented by a scheduled job that writes `GET /budgets/{id}/user-states` output to a Markdown summary in the repo.

---

# DELIVERABLE E — Feedback Mechanisms
- **Monthly pulse survey (lightweight):** one question — "Is your Copilot budget sized right? (too low / about right / too high)" + optional free text. Post via Teams adaptive card or a Forms link.
- **Issue-form feedback intake:** a `copilot-budget-feedback.yml` form (same repo) labeled `copilot-budget-feedback`, triaged monthly.
- **Metrics to watch:** % of users hitting cap, credit-increase request volume trend, **time-to-grant**, pool depletion %, p90/p95 monthly consumption, cohort mix (`ai_adoption_phase`).
- **Re-baseline trigger criteria (defined):** re-baseline the UULB/cost-center budgets when **any** of: >15% of users hit cap in a month; request volume up >25% MoM; pool consistently >90% consumed; or the promo→standard transition (Sept 1, 2026). On trigger, recompute p75 from the latest AI usage report and `PATCH` budgets.

---

# DELIVERABLE F — Change Pipeline (config-as-code)
- **`budgets.yml` manifest** in the repo describing every managed budget (scope, entity, amount, stop flag). Example:
```yaml
enterprise: your-enterprise-slug
budgets:
  - scope: enterprise
    type: BundlePricing
    product_sku: ai_credits
    amount: 5000
    prevent_further_usage: true
  - scope: multi_user_customer     # universal ULB
    type: BundlePricing
    product_sku: ai_credits
    amount: 20
    prevent_further_usage: true
  - scope: multi_user_cost_center
    cost_center: cc-copilot-power
    type: BundlePricing
    product_sku: ai_credits
    amount: 40
    prevent_further_usage: true
```
- **CODEOWNERS** requires platform-team approval on `budgets.yml`.
- **PR-based review:** a validation workflow lints the manifest (schema, and that Σ user-level budgets vs pool math is covered by the enterprise budget) and blocks merge on failure.
- **Drift detection:** scheduled workflow calls `GET /enterprises/{ent}/settings/billing/budgets`, diffs against `budgets.yml`, and comments/opens an issue on drift.
- **Approval/deployment flow:** merge to `main` → apply workflow (using `GH_BILLING_TOKEN`) reconciles actual state to the manifest via POST/PATCH/DELETE.

---

## Recommendations (staged, with thresholds)
1. **Now (before Sept 1, 2026):** set an enterprise-scope Bundled AI-credits **guardrail** + a **universal user-level budget at p75**. This is critical because the promotional pool (Business 3,000) reverts to 1,900 on Sept 1 — sizing must be validated during the promo.
2. **Deploy the self-service Issue-Form + Actions system with the classic-PAT auth path** — it is fully automatable today. Only migrate to a GitHub App/fine-grained token **after** verifying it works against your enterprise (support is brand-new and was unreliable in summer 2026).
3. **Use cost centers with direct user assignment** for budget tiering; ensure single-org license assignment to keep enforcement predictable.
4. **Automate monthly re-baselining** from the AI usage report + the `ai_credits_used` metrics field. **Re-baseline when** >15% hit cap, requests grow >25% MoM, pool >90% consumed, or at the promo transition.
5. **Keep the "AI credits paid usage" policy ON but bounded by the enterprise guardrail + ULBs** so developers are never hard-blocked unexpectedly while spend stays capped. Reserve **disabling** the policy (or $0 ULBs) for restricted cohorts.

## Caveats
- **Auth is the biggest live risk:** GitHub App / fine-grained PAT support for the **enterprise** budget-write endpoint is very new and was reported non-functional by real users as recently as summer 2026. Use a **classic PAT with `manage_billing:enterprise`** (service account) in production and verify empirically before switching. Standalone fine-grained PATs are not listed for this enterprise endpoint.
- **Detailed/AI per-user usage report is UI-only** (not the REST `/usage` endpoint, which is summarized). Plan for CSV downloads or the preview CSV usage-reports API for automation.
- **Model credit-per-token figures change** as models are added/deprecated (e.g., GPT-5.x and Claude Opus 4.x cadence). Always verify against `docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing`; treat third-party blog numbers as directional.
- **`required: true` on issue forms is enforced only in public repos** — the workflow re-validates required fields for private/internal repos.
- **A known data caveat:** some Copilot code-review entries can show 0 AI credits (reviews charged directly to orgs via automation or by unlicensed users), and preview fields `aic_quantity`/`aic_gross_amount` were retroactively zeroed for AIC usage from June 1 forward — use `quantity`/`net_amount` (and the token columns) for AIC analysis, not the deprecated preview fields.

---

## Sources & Last-Verified (all verified Aug 19, 2026)
**GitHub Docs**
- Usage-based billing for organizations and enterprises — `docs.github.com/en/copilot/concepts/billing/usage-based-billing-for-organizations-and-enterprises`
- Budgets for usage-based billing — `docs.github.com/en/copilot/concepts/billing/budgets-for-usage-based-billing`
- Setting up budgets to control spending on metered products — `docs.github.com/en/billing/how-tos/set-up-budgets`
- Budgets and alerts — `docs.github.com/en/billing/concepts/budgets-and-alerts`
- REST — Budgets — `docs.github.com/en/enterprise-cloud@latest/rest/billing/budgets`
- REST — Cost centers — `docs.github.com/en/enterprise-cloud@latest/rest/billing/cost-centers`
- REST — Billing usage — `docs.github.com/en/rest/billing/usage`
- Cost centers (concept) — `docs.github.com/en/billing/concepts/cost-centers`
- Charging business units — `docs.github.com/en/enterprise-cloud@latest/billing/managing-your-billing/charging-business-units`
- Controlling and tracking costs at scale — `docs.github.com/en/billing/tutorials/control-costs-at-scale`
- Optimizing your budget configuration — `docs.github.com/en/copilot/tutorials/budgets/optimizing-your-budget-configuration`
- Getting started with budget controls — `docs.github.com/en/copilot/tutorials/budgets/getting-started-with-budget-controls`
- Billing reports reference (usage-report schema) — `docs.github.com/en/enterprise-cloud@latest/billing/reference/billing-reports`
- About usage reports — `docs.github.com/en/enterprise-cloud@latest/billing/managing-your-billing/about-usage-reports`
- Automating usage reporting with the REST API — `docs.github.com/en/billing/tutorials/automate-usage-reporting`
- Models and pricing for GitHub Copilot — `docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing`
- Copilot policies — `docs.github.com/en/copilot/concepts/policies`
- Copilot usage metrics — `docs.github.com/en/copilot/concepts/copilot-usage-metrics/copilot-metrics`
- Syntax for issue forms / form schema — `docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms`
- Installing a GitHub App on your enterprise — `docs.github.com/en/enterprise-cloud@latest/apps/using-github-apps/installing-a-github-app-on-your-enterprise`

**GitHub Changelog**
- Updates to GitHub Copilot billing and plans (2026-06-01)
- GitHub Copilot is moving to usage-based billing (news post + Community Discussion #192948)
- Budget and usage management APIs now generally available (2026-06-04)
- Manage budgets and track usage with new billing API updates (2025-11-03)
- Managing cost centers via API is now available (2025-06-30)
- Customers can now add users to a cost center from both UI and API (2025-08-18)
- AI credits consumed per user now in the Copilot usage metrics API (2026-06-19)
- Copilot usage metrics API adds cohorts for AI adoption (2026-05-29)
- AI usage report updates (2026-06-11)
- Per-model token breakdown in the usage report (2026-08-11)
- Set AI credit session limits in Copilot CLI and SDK (2026-07-01)
- Enterprise-level access for GitHub Apps and installation automation APIs (2025-07-01)
- API access to billing usage reports in public preview (2026-02-17)

**Microsoft Learn / Microsoft Support**
- Create an Incoming Webhook (Teams Workflows) — `learn.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook`
- Send messages in Teams using incoming webhooks — `support.microsoft.com` (Workflows for Teams)
- Create & Send Actionable Messages / Adaptive Cards (rate limits) — `learn.microsoft.com`

**Corroborating/secondary (verify against primary):** jessehouwing.net & dev.to "Auto-assign GitHub Copilot AI Credit budget to users" (working classic-PAT budget-API example); Bodega One, TokenMix, digitalapplied.com, pickurai.ai, devtoolhub.com (model pricing/credit math); ki-company.ai, sumproduct.com, wisechecker.com (Copilot in Excel limits); github/copilot-billing-preview repo (report-format schema); community discussions #164562, #197605, navikt/copilot #111 (auth caveats).
