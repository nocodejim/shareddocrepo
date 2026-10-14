# Changelog: wildfire SiS runbook v1 → v2

*Oct 14, 2026 · Compare: [v1 runbook](../wildfire-sis-runbook/README.md) · [v2 runbook](README.md) · [v1 prompts](../wildfire-sis-runbook/PROMPT_LIBRARY.md) · [v2 prompts](PROMPT_LIBRARY.md)*

v2 merges a second analysis of the same system ([prompt suite](../wildfire-sis-runbook/wildfire_sis_migration_runbook_prompt_suite.md), [architecture image](../wildfire-sis-runbook/diagram-sis.jpeg)) into v1. That analysis was written without the codebase too, so its claims about the system are treated as **hypotheses**. Its ideas were taken on merit, and several were changed before adoption. v1 is unchanged and stays in its folder for comparison.

## The biggest changes

1. **Data access path.** v1 assumed the notebook calls public fire feeds (NASA FIRMS, NIFC) directly, which you've said is wrong. v2 assumes, unconfirmed, that it calls **internal microservices through an API gateway** that wrap Zesty.ai, Precisely and ArcGIS. That changes Phase 4 completely: the demo no longer needs Snowflake to reach anything, because captured responses are uploaded once.
2. **A demo fast path.** v2 adds a 5-to-7-day route to a customer demo alongside the full migration, with its own app-kit prompt (P-12).
3. **Underwriter decisions are written back** to an append-only `UNDERWRITING_DECISIONS` table from an `st.form`, with grants that allow INSERT and nothing else.
4. **Radius slider instead of fixed bands only.** Distances are computed once up to 50 miles and filtered in memory, so moving the slider costs no query. The fixed bands remain for parity with the Flask screens.
5. **A working, tested single-file app** in section 5.3 (slider, four KPIs, map, decision form). It passed a Streamlit `AppTest` run against a stand-in Snowflake session. It has not yet run against a real account.

## Adopted from the second analysis, and how

| Idea | Where in v2 | Changed before adoption? |
| --- | --- | --- |
| Internal API gateway wrapping Zesty.ai, Precisely, ArcGIS | Known/likely table; diagrams; Phase 4; P-0, P-1 | Marked LIKELY, with a Phase 1 step to confirm each one |
| Pre-fetched cache table (`RISK_MICROSERVICE_CACHE`) instead of live gateway calls | Section 3.3; Phase 4 Pattern A | Split into a raw VARIANT table plus a narrow typed cache, so unused fields need no second paid call and only checked fields reach the app |
| Future production feed into the cache | Phase 4 Pattern B | Framed as "push from inside", which avoids Snowflake-to-gateway networking entirely |
| Postman collection as source of endpoints and seed data | Section 1.1; P-1, P-2, P-5, P-7 | Postman responses go through the same scrub as everything else |
| Convert notebooks with `nbconvert --to script` before giving them to an AI | Section 1.1 | Reframed mainly as a PII control (saved outputs contain data rows), with an outputs version kept for the approved environment. Templates are still used for the page port, rather than never |
| `UNDERWRITING_DECISIONS` write-back via `st.form` | Sections 3.4, 5.3, 6.2, 6.6 | Append-only by grant (INSERT only); records the fire picture, radius and app version; captures the viewer from `st.user` and `CURRENT_USER()`, with a test to see which is right under owner's rights; bound parameters, not string-built SQL |
| Buffer slider 1–50 miles; precompute distances and filter in memory | Sections 3.5, 5.1, 5.3 | Kept the fixed bands as well, for parity |
| KPI row: exposed count, TIV at risk, premium in buffer, exposure-to-premium ratio | Section 5.3 | Ratio shown as premium per $1,000 TIV, with a note to use whichever metric the Flask app shows |
| Risk-tier filter and colour-coding by risk score | Section 5.3 | None |
| `@st.cache_data(ttl=600)` around reads | Sections 5.1, 5.3 | Decisions are read uncached so new ones show immediately |
| GENERATOR-based synthetic multiplication with correlated risk scores | Section 2.7; P-11 | Optional, load testing only. Seed must be scrubbed, every row carries `DATASET = 'SYNTHETIC'`, the app shows a banner, and premium moves with TIV so rates stay realistic |
| Verification checklist: coordinate overlap, pushdown speed, cache hits in Query History, write-back governance | Sections 3.6, 6.6 | Added checks that the app can't delete decisions, that REAL and SYNTHETIC never mix, and a viewer-only walkthrough. Dropped the fixed "under 500 ms" target in favour of a page-load bar you agree on |
| Snowflake Git integration for the app code | Section 6.7 | Implemented as GitHub Actions + Snowflake CLI deploys from a **private** repository |
| Consolidated one-shot "mega-prompt" | P-12 | Rewritten to start from the tested section 5.3 app, keep the guardrails, and refuse to invent field names or mock perimeters |
| Land → enrich → visualize → decide → write back (from the image) | "The underwriter's loop" diagram | Redrawn in Mermaid; the image's Cortex AI box left out, since nothing in this design uses it yet |

## Not adopted, and why

| Suggestion | Why v2 differs |
| --- | --- |
| Keep real coordinates while scrubbing | An exact geocode plus TIV identifies a building from a parcel map. v2 still snaps to H3 cell centres (section 2.3) and measures the effect on distance bands |
| Build the demo on 100 seed rows multiplied to 5,000 | You asked for real numbers and exposures. Multiplied rows change every total, and ±0.025° jitter (about 2–3 km) is wider than a 1-mile band. v2 uses the full scrubbed book for the demo and keeps synthetic data for load tests |
| Mock wildfire perimeter rows "in matching bounds" | Invented fires next to real exposure would make the demo's numbers fiction. v2 uses saved snapshots from the running system |
| "Code only, no prose" output instructions | The person running the code is new to Snowflake; v2 prompts ask for code plus short notes, placeholders and checks |
| Single-file app as the end state | Fine for the demo; the full migration still ports one page per Flask route |
| `get_active_session()` as the only connection pattern | v2 uses `st.connection("snowflake")`, which works on both runtimes, and mentions the alternative |

## New in v2 that neither earlier version had

- Vendor-licence check for storing and displaying Zesty/Precisely outputs (section 2, Phase 2 exit check), with a pointer to Precisely's Snowflake Marketplace route.
- Four ingestion patterns with a decision flowchart (Phase 4), including private connectivity as a last resort.
- Paid-call discipline: capture once per location, keep raw responses, dry-run cost counts (Phase 4, P-7).
- `DATASET` and `PARENT_TOKEN` columns through the whole model, so synthetic data can exist without contaminating real totals.
- Nine new hurdle rows (marked ★), including "notebook outputs carry data", "gateway unreachable", "decision records the wrong user" and "app code in a public repo".

## Still unconfirmed

Every row marked Likely or Unknown in the runbook's first table. Until Phase 1 settles them, treat Zesty.ai, Precisely, ArcGIS, the gateway and the Postman suite as names to check, not facts. Phase 4's FIRMS sections remain only as a worked example of a public feed.

## Files

| File | v1 | v2 |
| --- | --- | --- |
| Runbook | `../wildfire-sis-runbook/README.md` | `README.md` |
| Prompt library | `../wildfire-sis-runbook/PROMPT_LIBRARY.md` (P-0 to P-10) | `PROMPT_LIBRARY.md` (P-0 to P-12) |
| Second analysis (input) | `../wildfire-sis-runbook/wildfire_sis_migration_runbook_prompt_suite.md` | Not copied; linked |
| Architecture image (input) | `../wildfire-sis-runbook/diagram-sis.jpeg` | Not copied; linked |
| This changelog | n/a | `CHANGELOG.md` |
