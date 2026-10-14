# Prompt library (v2)

Twelve prompts that do the code archaeology, data analysis, PII work and app build for this migration, plus one shared context block. Paste P-0 first in every fresh session, then the prompt, then attach what it lists. Text in `<ANGLE_BRACKETS>` is yours to fill in. They're written for Claude Opus or a model of similar strength that can read attached files and run Python. Back to the [runbook](README.md) · [what changed since v1](CHANGELOG.md).

> **Status: draft.** P-0 names Zesty.ai, Precisely, ArcGIS, an internal API gateway and a Postman suite as *likely* parts of the current system. They come from a second analysis and are unconfirmed; the prompts tell the model to verify them, not assume them. Edit P-0 as soon as Phase 1 confirms or corrects them.

| Prompt | Path | Phase | Attach | Produces |
| --- | --- | --- | --- | --- |
| [P-0 Shared context](#p-0-shared-context-paste-first-every-session) | Both | Every session | Nothing | Common ground for every prompt |
| [P-1 System inventory](#p-1-system-inventory-phase-1) | Both | 1 | Code-only notebook script, Flask files, Postman collection, pip freeze, redacted config, screenshots | `SYSTEM_INVENTORY.md` |
| [P-2 Data profiling and decision drivers](#p-2-data-profiling-and-decision-drivers-phase-1) | Full | 1 | Inventory, dataset samples, saved responses | `DATA_PROFILE.md`, `profile.py` |
| [P-3 Business logic spec and golden tests](#p-3-business-logic-spec-and-golden-tests-phase-1) | Both | 1 | Inventory, profile, code, golden outputs | `LOGIC_SPEC.md`, `golden_tests/` |
| [P-4 PII discovery and treatment plan](#p-4-pii-discovery-and-treatment-plan-phase-2) | Both | 2 | Profile, logic spec, column names with fake rows | `PII_TREATMENT_PLAN.md` |
| [P-5 Scrub script and validation](#p-5-scrub-script-and-validation-phase-2) | Both | 2 | Approved plan, raw data and saved responses (approved environment only) | `scrub.py`, `SCRUB_VALIDATION_REPORT.md` |
| [P-6 Snowflake data model](#p-6-snowflake-data-model-phase-3) | Full | 3 | Logic spec, scrubbed headers, fire snapshots | Four SQL scripts, `DATA_MODEL.md` |
| [P-7 External data ingestion](#p-7-external-data-ingestion-phase-4) | Full | 4 | Inventory, logic spec, chosen pattern per source | `ingest.sql`, `INGESTION.md` |
| [P-8 Flask to Streamlit port](#p-8-flask-to-streamlit-port-phase-5-one-page-at-a-time) | Full | 5 | One route, template and screenshot at a time | One page file per route |
| [P-9 Parity test harness](#p-9-parity-test-harness-phase-6) | Full | 6 | Golden tests, validation report, data model | `parity_check.py`, `PARITY_REPORT.md` |
| [P-10 Adversarial leak review](#p-10-adversarial-leak-review-phase-2-again-before-the-demo) | Both | 2 and 6 | Scrubbed files and app screenshots only | `LEAK_REVIEW.md` |
| [P-11 Synthetic scale-up](#p-11-synthetic-scale-up-optional-phase-2) | Optional | 2 | Seed table description, logic spec | `scale_up.sql`, `SYNTHETIC_DATA.md` |
| [P-12 Fast-path app kit](#p-12-fast-path-app-kit-demo-path-phases-3-to-5) | Fast | 3 to 5 | Logic spec, inventory, Postman sample, the runbook's section 5.3 app | Setup SQL, seed SQL, adapted `streamlit_app.py`, check script |

## P-0 Shared context (paste first, every session)

```text
PROJECT CONTEXT

I'm migrating an internal underwriting tool from a Jupyter notebook + Flask app to a Streamlit in Snowflake (SiS) app.

What the current tool does: it compares our insured locations with active wildfires. It measures each location's proximity to fires, totals exposure (TIV) by fire and distance, and compares that exposure with the premium we collect, so an underwriter can decide whether to approve, refer, hold, require mitigation or re-rate a risk.

What we believe but have NOT confirmed (verify each against the code; label findings CONFIRMED or CORRECTED):
- LIKELY: the notebook calls internal microservices through an internal API gateway rather than calling vendors directly.
- LIKELY: those services wrap Zesty.ai (property wildfire risk scores), Precisely (geocodes and property attributes) and ArcGIS (fire perimeters or spatial services).
- LIKELY: spatial math runs in memory with pandas/GeoPandas or the ArcGIS Python SDK.
- LIKELY: a Postman collection exists that exercises the same endpoints.
- UNKNOWN: whether underwriter decisions are stored anywhere today.
- CORRECTED: an earlier assumption that the app calls NASA FIRMS and NIFC directly is wrong.

Target platform:
- Snowflake database WILDFIRE_DB with schemas RAW (data as it arrives), CORE (cleaned, scrubbed, typed tables) and APP (views the app reads, plus the app itself).
- Streamlit in Snowflake on the container runtime (Python 3.11, PyPI packages via pyproject.toml). Fallback: warehouse runtime (Snowflake Anaconda channel only, 32 MB per-message limit, cache not shared between viewers).
- External data lands in RAW tables before the app sees it: captured responses uploaded once (demo), pushed by internal services (production), or pulled from public feeds by scheduled tasks. Snowflake does not call the internal gateway for the demo. The app never calls external APIs itself.
- Vendor answers live in CORE.RISK_MICROSERVICE_CACHE; fire perimeters in CORE.FIRE_PERIMETERS_ALL (live + saved snapshots); decisions in CORE.UNDERWRITING_DECISIONS (append-only).
- The app runs with its owner's privileges, reads only APP views, and inserts only into the decisions table.
- The distance view keeps every location within 50 miles of a fire; the app filters by the underwriter's radius in memory.
- The demo uses the scrubbed real portfolio: no policyholder PII, coordinates coarsened, but real TIV, premium, limits and deductibles. Synthetic clones exist only for load tests and are labelled DATASET = 'SYNTHETIC'.

Rules for everything you produce:
- Never invent facts about my code or data. If something is ambiguous, say so and list what would resolve it.
- Cite evidence as file:line or notebook cell number for every claim about the existing system.
- Treat policyholder data as sensitive. Never echo names, addresses, emails, phone numbers, policy numbers or exact coordinates; refer to columns and row counts instead.
- Treat vendor outputs (scores, geocodes) as licensed data: don't propose displaying or exporting them beyond what I confirm the vendor terms allow.
- Prefer plain, explicit code a Snowflake beginner can read over clever code. Comment every block.
- When you make an assumption, label it ASSUMPTION and keep going.
- End every deliverable with a short "Open questions" list.
```

## P-1 System inventory (Phase 1)

```text
ROLE
You are a senior Python and data engineer doing software archaeology on an analytics tool you've never seen. Produce a complete, evidence-backed inventory so another engineer could rebuild the tool without reading the original code.

INPUTS (attached)
- The notebook converted to a code-only script (jupyter nbconvert --to script). No outputs, so no data rows.
- The Flask Python files (app module, helper modules). Templates only if a route's behaviour depends on them; static/ is not needed.
- The Postman collection (v2.1 JSON) and environment, with secrets blanked
- requirements_current.txt (pip freeze from the notebook kernel)
- Config files with secrets replaced by REDACTED
- Screenshots of each page

TASK
1. Execution order. Reconstruct the order in which notebook cells actually run to start the system (not just file order). Flag cells that look experimental, duplicated or dead, with your reasoning.
2. Entry points. List every Flask route: URL, HTTP method, function, template rendered, query/form parameters, and what the page or JSON response contains. Match each route to a screenshot where possible.
3. Data sources. For every input record: type (file, database, HTTP API), exact location or URL pattern, authentication method, refresh frequency, whether it is internal (behind the gateway) or public, whether it costs money per call, and the code that reads it. Cross-check every HTTP call against the Postman collection: list endpoints the code calls that Postman doesn't cover, and the reverse. For each endpoint, list the exact response fields the downstream math uses and their target Snowflake types (VARCHAR, FLOAT, NUMBER, GEOGRAPHY, VARIANT). At the end, list every host name on its own line, marked INTERNAL or PUBLIC.
4. Data flow. Trace each dataset from load to display: every transformation, join, filter, aggregation and derived column, with cell/line references. Draw it as a Mermaid flowchart.
5. Business logic hotspots. Point to every place where a decision-driving number is computed: distances, buffers, bands, thresholds, ratios, scores, flags. Quote the logic line (no data values) and note hard-coded constants.
6. State and side effects. Global variables, caches, background threads or schedulers, files written to disk, anything kept between requests.
7. Libraries. For each non-standard library: what it does here, and whether it will work in Streamlit in Snowflake. Flag anything that loads JavaScript or CSS from a CDN (Folium, Leaflet, custom map widgets), needs system libraries (GDAL, GEOS, PROJ via geopandas, shapely, fiona), or calls the network.
8. Secrets. Every secret or credential the code expects, by name only.
9. Decisions. How (if at all) underwriter decisions are captured today: CSV export, POST endpoint, database write, or nowhere. List the actions an underwriter can take.
10. Hypothesis check. For each LIKELY / UNKNOWN item in the shared context, state CONFIRMED, CORRECTED (with what is actually true) or STILL UNKNOWN, with evidence.
11. Gaps. What you couldn't determine, and which file or person would answer it.

OUTPUT
One file, SYSTEM_INVENTORY.md, with sections 1 to 11, tables wherever there are more than three items, and the Mermaid diagram in section 4. End with "Migration notes": the 10 things most likely to cause trouble when moving to Streamlit in Snowflake, each with the evidence behind it.

BEFORE YOU FINISH
Re-read the inventory against the code and the Postman collection and confirm: every route is listed, every host is listed and classified, every decision-driving number has a source reference, every hypothesis has a verdict. Fix gaps, then say what you checked.
```

## P-2 Data profiling and decision drivers (Phase 1)

```text
ROLE
You are an insurance data analyst who knows property underwriting and catastrophe exposure management. You profile data rigorously and can tell which fields an underwriter actually decides on.

INPUTS
- SYSTEM_INVENTORY.md from P-1
- Sample exports of every dataset the system uses (policy/location data, fire perimeter snapshots, any rate or reference tables)
- Saved gateway/Postman responses for a sample of locations
- The notebook with outputs (approved environment only)
You can run Python. Work on the files directly; never paste data rows into your answer.

TASK
1. Profile each dataset: row count, grain (what one row represents), candidate keys and whether they're unique, columns and types, null rates, distinct counts, min/max/percentiles for numbers, top values for categories, date ranges. Flag anomalies: zero or negative TIV, premium greater than TIV, coordinates outside the expected area or swapped, duplicate locations, future dates.
2. Relationships. How datasets join (keys, cardinality, match rates). Report orphans in both directions.
3. Financial structure. Identify TIV and its components (building, contents, BI), premium (written or earned, annual or term), limits, deductibles and sublimits. Confirm by reconciling totals with the notebook's own outputs.
4. External data. Vendor responses: which fields are populated, value ranges and tiers for risk scores, geocode match quality, how many locations lack a response. Perimeters: geometry types, validity rate, size distribution, update timestamps. Hotspots, if used: sources, confidence values, time window.
5. Decision drivers. Using SYSTEM_INVENTORY.md and the code, rank fields by how directly they feed the underwriting output. For the top 15 give: how it's used, which output it changes, what breaks without it. Separately list fields that are loaded but never used.
6. Portfolio picture, aggregates only: total locations, TIV and premium; splits by state and by distance band for each snapshot; the 10 largest exposures per fire by TIV, identified by row index or token, never by name or address. These become the golden reference numbers.
7. Sensitivity inventory. Mark every column as Direct identifier, Quasi-identifier, Sensitive financial or Non-sensitive, with a one-line reason. Don't choose treatments yet.

OUTPUT
- DATA_PROFILE.md with sections 1 to 7
- profile_tables/ with a CSV per aggregate in section 6
- profile.py, the script that produced everything, so it can be rerun on fresh data

BEFORE YOU FINISH
Check that your section 6 totals match the notebook's outputs for the same snapshot. If they don't, find out why and explain it; don't paper over it.
```

## P-3 Business logic spec and golden tests (Phase 1)

```text
ROLE
You are a meticulous actuarial-systems analyst. You turn code into a specification precise enough that two engineers implementing it independently would get identical numbers.

INPUTS
- SYSTEM_INVENTORY.md and DATA_PROFILE.md
- The notebook and Flask code
- Golden outputs saved from the running system (CSVs and screenshots for 2 or 3 dates)

TASK
1. Extract every calculation that turns inputs into what the underwriter sees, in dependency order. For each: name, plain-English purpose, input columns, exact formula (pseudocode, plus LaTeX where it helps), units, constants and where they're defined, edge cases (nulls, zero premium, points exactly on a band boundary, a location near two fires, multi-part perimeters), and file:line evidence.
2. Pin down specifically: the distance method (point to point, point to perimeter edge, inside polygon; geodesic or planar; which CRS), every distance band with inclusive/exclusive boundaries, the exposure measure, how multi-location policies roll up, the premium measure, the comparison metric(s) and every flag threshold.
3. List anything that looks unintended (lat/long swapped, km and miles mixed, double counting across fires) under QUESTIONS FOR UNDERWRITING, with its effect on the golden numbers. Don't fix it in the spec.
4. Translate each calculation into Snowflake SQL with GEOGRAPHY functions. Remember: ST_DISTANCE and ST_DWITHIN work in metres; ST_MAKEPOINT takes longitude first; H3_LATLNG_TO_CELL takes latitude first. Mark anything that must stay in Python.
5. Build golden tests: for each golden date, small input slices (by token or row index) with expected outputs taken from the saved Flask results. Cover normal cases and every edge case from step 1, with at least one test per distance band and per flag.

OUTPUT
- LOGIC_SPEC.md: a summary table of all calculations at the top, then sections 1 to 4
- golden_tests/: one inputs CSV and one expected-outputs CSV per test, plus README.md
- run_golden_tests.py: runs the ORIGINAL Python logic against the tests, proving the spec matches the code

BEFORE YOU FINISH
Run run_golden_tests.py. Every test must pass against the original logic before the spec is done. Report the pass count and anything you adjusted.
```

## P-4 PII discovery and treatment plan (Phase 2)

```text
ROLE
You are a privacy engineer with insurance experience. You protect policyholders while keeping the data useful for a realistic product demo.

INPUTS
- DATA_PROFILE.md (especially the sensitivity inventory)
- LOGIC_SPEC.md (which fields and what precision the calculations need)
- Column names plus 20 rows per dataset in which I have replaced real values with plausible fakes. Do not ask for real rows.

GOAL
Every identifying detail removed or replaced. Every financial figure (TIV and its components, premium, limits, deductibles) kept exactly. Locations coarsened only as much as needed so distance-to-fire results don't change.

TASK
1. For every column in every dataset assign: category (direct identifier, record key, quasi-identifier, sensitive financial, non-sensitive), treatment, parameters and justification. Treatments:
   DROP
   FAKE (Faker, fixed seed, consistent per original value)
   TOKEN (HMAC-SHA256 with a secret salt, consistent across all tables so joins survive)
   GENERALISE (e.g. ZIP to 3 digits, year built to 5-year bands, dates to month)
   KEEP
   LOCATION (see step 2)
2. Location method. Compare (a) snapping to H3 cell centres at resolutions 8, 9 and 10 and (b) seeded jitter of 50 to 200 m, against the distance bands in LOGIC_SPEC.md. For each option estimate the maximum displacement and how many locations would likely change band, then recommend one.
3. Re-identification risks specific to this data: very large single risks, sparse areas, unusual occupancy + year-built combinations, free-text fields, file names, row order, policy-change timestamps. Propose the minimum change that removes each risk (cap, round to 2 significant figures, coarser H3 cell, suppression) and say which totals it affects.
4. Join safety. Confirm every key that links datasets is tokenised identically everywhere, and that nothing in the fire data can be joined back to policyholder data.
5. Residual risk: in two or three sentences for a compliance reviewer, what a determined person could still learn from the scrubbed data.

OUTPUT
PII_TREATMENT_PLAN.md: one table with a row per column (dataset, column, category, treatment, parameters, justification), then sections for location method, re-identification risks, join safety and residual risk. Finish with a list of decisions that need human approval (compliance or underwriting).

RULES
Never print real values. If you need an example, invent one and label it FAKE.
```

## P-5 Scrub script and validation (Phase 2)

```text
ROLE
You are a data engineer writing a deterministic, production-quality de-identification pipeline, plus the evidence that it worked.

INPUTS
- PII_TREATMENT_PLAN.md (approved)
- LOGIC_SPEC.md and DATA_PROFILE.md
- The raw datasets, in this approved environment only

TASK
1. Write scrub.py that applies the plan exactly:
   - Reads raw inputs from paths given on the command line; writes scrubbed CSVs with UPPER_SNAKE_CASE headers, ready for Snowflake.
   - Reads the HMAC salt and Faker seed from environment variables, never from code, and refuses to run without them.
   - Is deterministic: same inputs + same salt/seed give byte-identical outputs.
   - Applies the chosen location method and records each location's displacement in metres.
   - Applies the outlier treatments and writes a reconciliation file (token, field, original minus new) that stays with the raw data, never with the outputs.
   - Also scrubs saved vendor responses: replaces each location reference with its token, strips address, owner and parcel fields, and writes risk_responses_scrubbed.jsonl with one object per line and keys SOURCE_SYSTEM, ENDPOINT, LOCATION_TOKEN, RESPONSE, CAPTURED_AT, CAPTURE_METHOD.
   - Never logs raw values.
2. Write validate_scrub.py that compares raw and scrubbed data and writes SCRUB_VALIDATION_REPORT.md with a PASS/FAIL line per check at the top:
   - Totals: row counts, total TIV, premium and each TIV component, overall and by state, county and line of business. Exact match apart from documented outlier adjustments.
   - Band stability: for each fire snapshot, recompute every location's distance band with raw and with scrubbed coordinates using the LOGIC_SPEC method. Report count and TIV of locations that changed band, by band.
   - Displacement: min, median, 95th percentile and max.
   - Leak scan: regex scan of every scrubbed text column for emails, phone numbers, SSN/FEIN and street-address patterns; confirm no scrubbed value equals any raw identifier; confirm no column marked DROP survives.
   - k-anonymity: smallest group size for county + occupancy + year-built band, and every group smaller than 5.
3. Write pytest tests for scrub.py: determinism, token consistency across tables, dropped columns gone, headers upper case.

OUTPUT
scrub.py, validate_scrub.py, tests/, SCRUB_VALIDATION_REPORT.md and RUNBOOK_SCRUB.md (how to rerun on fresh data).

BEFORE YOU FINISH
Run both scripts and the tests. Paste the PASS/FAIL summary (no data values) into your answer. If anything fails, fix the scrub, not the test.
```

## P-6 Snowflake data model (Phase 3)

```text
ROLE
You are a Snowflake data engineer who teaches as you build. The person running your SQL is new to Snowflake, so every script must run top to bottom in a Snowsight worksheet without edits, with a comment above each block explaining it.

INPUTS
- LOGIC_SPEC.md (including its SQL translations)
- The scrubbed CSV headers and the totals in SCRUB_VALIDATION_REPORT.md
- The fire snapshot files saved from the running system
- Existing objects: database WILDFIRE_DB; schemas RAW, CORE, APP; role WILDFIRE_DEV; warehouse WILDFIRE_WH; stage RAW.UPLOADS; file format RAW.CSV_HEADER (PARSE_HEADER = TRUE)

TASK
1. 01_load.sql: RAW tables created from the uploaded CSVs with INFER_SCHEMA + USING TEMPLATE, COPY INTO with MATCH_BY_COLUMN_NAME, then validation queries that must return the totals in SCRUB_VALIDATION_REPORT.md.
2. 02_core.sql: typed CORE tables. POLICY_LOCATIONS with PARENT_TOKEN, DATASET = 'REAL', a GEOGRAPHY point built with ST_MAKEPOINT(longitude, latitude), H3 cell columns at the resolutions the app needs, and money as NUMBER(18,2); an empty POLICY_LOCATIONS_SYNTHETIC (LIKE) and the POLICY_LOCATIONS_ALL union view. RAW.RISK_RESPONSES_RAW loaded from the scrubbed JSONL, and CORE.RISK_MICROSERVICE_CACHE (latest response per location and source, only the fields LOGIC_SPEC.md uses, with real field paths). Snapshot tables FIRE_PERIMETERS_SNAPSHOT (and FIRE_HOTSPOTS_SNAPSHOT if used) with SNAPSHOT_TS; perimeters converted with TRY_TO_GEOGRAPHY, plus a query that counts and lists invalid geometries. CORE.UNDERWRITING_DECISIONS (append-only; columns as in the runbook's section 3.4, actions from LOGIC_SPEC.md).
3. 03_app_views.sql: APP views implementing every calculation in LOGIC_SPEC.md: V_LOCATION_FIRE_DISTANCE (every location within the maximum radius underwriters use, default 50 miles, with exact distance, the fixed bands, and the vendor score joined on PARENT_TOKEN); V_NEAREST_FIRE (no double counting); exposure by fire and band; exposure by H3 cell for the map; V_LATEST_DECISIONS; V_FIRE_PERIMETERS (simplified GeoJSON for the map); all flag logic. Every view carries DATASET and SNAPSHOT_TS so the app can switch datasets and fire pictures. Cast every number the app will chart to FLOAT. UPPER_SNAKE_CASE column names.
4. 04_checks.sql: queries that reproduce each golden output for each snapshot, side by side with the expected values from golden_tests/, showing the difference; plus the bounding-box overlap check (locations vs fires) and a REAL-vs-SYNTHETIC separation check.
5. Performance: estimate the size of the proximity join. If it's large, add an H3 pre-filter (cells covering each buffered perimeter) and/or a dynamic table with a TARGET_LAG, and explain the trade-off in comments.
6. DATA_MODEL.md: a Mermaid ER diagram of the RAW, CORE and APP objects and a table of every object with its purpose and grain.

RULES
- Fully qualify every object (WILDFIRE_DB.SCHEMA.OBJECT).
- No CREATE OR REPLACE on a loaded RAW table unless the script explains why.
- Distances in metres inside SQL; convert to miles only in output columns named *_MILES.

BEFORE YOU FINISH
Walk through 04_checks.sql against the golden tests and list any check you expect to fail, and why.
```

## P-7 External data ingestion (Phase 4)

```text
ROLE
You are a Snowflake data engineer designing how outside data reaches Snowflake for an underwriting app. Reliability, clarity and least privilege beat cleverness.

INPUTS
- SYSTEM_INVENTORY.md (every endpoint, host, INTERNAL/PUBLIC flag, paid-call flag, and the response fields the math uses)
- LOGIC_SPEC.md (which fields, time windows and refresh needs matter)
- My chosen pattern per source, from the runbook's Phase 4 (A capture and upload, B push from inside, C pull a public feed, D pull through the gateway with private connectivity)
- Existing objects: RAW.RISK_RESPONSES_RAW (SOURCE_SYSTEM, ENDPOINT, LOCATION_TOKEN, RESPONSE VARIANT, CAPTURED_AT, CAPTURE_METHOD), RAW.PERIMETERS_RAW (FEATURE_JSON, LOADED_AT_UTC), CORE.RISK_MICROSERVICE_CACHE, CORE.FIRE_PERIMETERS_ALL; role WILDFIRE_DEV; warehouse WILDFIRE_WH

FACTS TO RESPECT
- Snowflake cannot reach endpoints inside our company network without private connectivity and network-team work. Prefer patterns that avoid it.
- Python stored procedures that call the internet need EXTERNAL_ACCESS_INTEGRATIONS and SECRETS clauses, and read secrets with _snowflake.get_generic_secret_string('<alias>').
- Public services may rate-limit; NIFC asks users not to query its perimeter services repeatedly. Poll every 15 minutes or slower and page politely.
- Some vendor calls cost money per request. Never re-request an unchanged location.

TASK
1. Confirm the pattern for each source in a table (source, INTERNAL/PUBLIC, paid?, chosen pattern, why, who must act). Flag any choice that looks wrong given the inventory.
2. Pattern A: a capture script (Python, run where Postman or the notebook runs) that calls each endpoint once per location for a given location list, saves raw responses, and hands them to the scrub (P-5). Include a dry-run mode that counts calls and estimated cost before spending money.
3. Pattern B: a short spec and sample code for the microservice team: a job that writes new or changed responses into RAW.RISK_RESPONSES_RAW with CAPTURE_METHOD = 'PUSH', using write_pandas or Snowpipe; the service user, role and grants it needs (INSERT on RAW only); and how it handles retries and duplicates.
4. Pattern C: for each public feed, a hardened procedure: non-JSON or non-CSV error detection, retries with backoff (max 3), paging, one row per feature, a typed RAW table, and a row per run in RAW.INGEST_LOG (source, rows, status, message, started_at, finished_at). Plus the network rule, secret and integration an admin must create, and the task schedule.
5. Pattern D (only if chosen): the list of objects and approvals needed (external access integration, private connectivity, secret, gateway auth), who owns each, and the risks. Do not write code that assumes connectivity exists.
6. Refresh the cache: a statement that rebuilds CORE.RISK_MICROSERVICE_CACHE from the latest response per location and source, using the field paths from the inventory; and APP.V_DATA_FRESHNESS showing the newest CAPTURED_AT / LOADED_AT_UTC per source and minutes since.
7. Housekeeping: PURGE_OLD_LOADS that keeps 30 days of RAW perimeter loads (never purge captured vendor responses without my approval: they cost money), with a daily task; and a Snowflake alert or documented manual check for failed runs.

OUTPUT
ingest.sql (runs top to bottom in Snowsight; Pattern A and B parts clearly marked as running elsewhere), capture.py if Pattern A is used, PUSH_SPEC.md if Pattern B is used, and INGESTION.md: what runs when, how to pause it, how to troubleshoot the five most likely failures, and estimated daily credit use on an X-Small warehouse.

BEFORE YOU FINISH
Re-check every object name, privilege and clause against the inputs. List everything that needs another team (admin, network, microservice owners, vendor-contract owner) and what you need from each.
```

## P-8 Flask to Streamlit port (Phase 5, one page at a time)

```text
ROLE
You are a senior Streamlit developer who has shipped many Streamlit in Snowflake apps. You port Flask pages faithfully and idiomatically, and you know SiS's constraints.

INPUTS (one Flask page per session)
- The route function, its template, and any JS/CSS it uses
- A screenshot of the page
- The matching section of LOGIC_SPEC.md
- The APP views and their columns (from DATA_MODEL.md)
- Runtime: container runtime, Python 3.11, dependencies in pyproject.toml. Tell me if anything you need isn't on PyPI.

SIS CONSTRAINTS
- Get data with conn = st.connection("snowflake") and conn.query(sql, ttl=...). Never call external APIs from the app.
- Snowflake returns UPPERCASE column names.
- The page reruns top to bottom on every interaction: cache queries, use st.form for groups of filters, keep per-user choices in st.session_state.
- External JavaScript and CSS can't load (Content Security Policy). Use st.pydeck_chart (ScatterplotLayer, GeoJsonLayer, H3HexagonLayer), Altair, Plotly or native charts. No Folium or Leaflet.
- Keep each element's payload small: aggregate in SQL, show top N, paginate large tables (32 MB limit on the warehouse runtime).
- The dataset (REAL or SYNTHETIC) and fire picture (SNAPSHOT_TS) live in st.session_state, set on the home page; every query filters by both. Show a red banner whenever SYNTHETIC is selected.
- Distance filters: read V_NEAREST_FIRE or V_LOCATION_FIRE_DISTANCE once for the chosen fire picture (they hold every location within 50 miles), then apply the underwriter's radius, tier and TIV filters in pandas. Moving a slider must not trigger a new query.
- Pass every widget value to SQL as a bound parameter (session.sql(sql, params=[...])), never by string formatting.
- If the page records decisions: insert into CORE.UNDERWRITING_DECISIONS only (append, never update), with a uuid, the fire picture, the radius, the action, short notes, the viewer from st.user and CURRENT_USER() as a cross-check. Read decisions back uncached.
- No secrets in code. No login code: Snowflake roles control access. st.user is available if a page should show who is viewing.

TASK
1. Describe what the Flask page does in 3 to 5 bullets: every input the user can change and every output.
2. Map each Flask element to its Streamlit equivalent in a table (route parameters to widgets, template blocks to layout, JS interactions to Streamlit features). Call out anything that can't be reproduced and propose the closest acceptable alternative.
3. Write the complete page file for pages/, using only APP views. If the page needs data no view provides, write the SQL for a new view first and say so.
4. Format numbers the way the Flask page did: currency with thousands separators, TIV in $M where used, ratios at the precision in LOGIC_SPEC.md.
5. Add a short "How to read this page" expander written for an underwriter.
6. Use the runbook's section 5.3 app (attached if I include it) as the house style for connection, caching, parameters and the decision form.

OUTPUT
The page file, any new view SQL, the mapping table, and five things I should compare between the Flask screenshot and the new page.

BEFORE YOU FINISH
Re-read the code for any lowercase column reference, uncached query, query without the snapshot filter, or external URL. Fix them and say what you fixed.
```

## P-9 Parity test harness (Phase 6)

```text
ROLE
You are a QA engineer for financial systems. Prove with evidence that the new app produces the same numbers as the old one, and explain every difference.

INPUTS
- golden_tests/ and the golden output CSVs from the running system
- LOGIC_SPEC.md, SCRUB_VALIDATION_REPORT.md (band-shift tolerance, outlier adjustments) and DATA_MODEL.md
- I will run the script myself. Connect with snowflake-snowpark-python using a named connection from my local config; never hard-code credentials.

TASK
1. Write parity_check.py that, for each golden snapshot, queries the APP views and compares them with the golden outputs at three levels: portfolio totals; per fire and distance band; per-location flags or decisions.
2. Pass rules: exact for counts and money totals (net of documented outlier adjustments); within the measured band-shift tolerance for band-level exposure; within 0.5% for ratio metrics unless LOGIC_SPEC.md says otherwise; identical for flags.
3. For each failure, try to classify it automatically: scrub effect (location displaced across a band edge; check the displacement record), rounding, or logic difference. Anything unclassified is "needs review".
4. Write PARITY_REPORT.md: a summary table (check, snapshot, expected, actual, difference, pass/fail, classification), details for every failure, then one plain-English paragraph an underwriting manager could read.
5. Make it rerunnable after any view change, and exit non-zero while any unclassified failure remains.

BEFORE YOU FINISH
List the assumptions the harness makes about the golden files' format, and how it fails if they're wrong.
```

## P-10 Adversarial leak review (Phase 2, again before the demo)

```text
ROLE
You are an independent privacy red-teamer. You did not build this dataset and have no stake in it passing. Find any way someone could identify a policyholder or a specific property from what a customer will see.

INPUTS
- The scrubbed CSVs exactly as they'll be loaded into Snowflake
- PII_TREATMENT_PLAN.md and SCRUB_VALIDATION_REPORT.md
- Screenshots of the finished app pages, if available
You do NOT get the raw data. Work only from what a customer could see or infer.

TASK
1. Scan every column for anything that still looks like a name, address, email, phone, policy or claim number, VIN, parcel ID, URL or free text. Report counts and patterns, never values.
2. Attempt linkage: could any combination of state, county, H3 cell, occupancy, construction, year built, TIV and premium single out one location? Report the smallest group sizes and which combinations produce groups of 1 to 4.
3. Outliers: locations whose TIV or premium alone is distinctive within their county or H3 cell (top values, suspiciously round numbers, isolated cells).
4. Geometry: do coordinates still sit on exact building positions (too many decimal places, alignment to road grids)? Can the snapping or jitter be reversed (constant offsets, visible patterns)?
5. Side channels: file names, row order correlated with original IDs, token formats that leak length or structure, timestamps that reveal policy changes, app tooltips or tables showing finer detail than intended.
6. Rate each finding High, Medium or Low and propose the smallest fix.

OUTPUT
LEAK_REVIEW.md: a findings table (finding, evidence, severity, fix), then a verdict of "safe to show", "safe after fixes" or "not safe", with reasoning.

RULES
Never print a value that could itself identify someone. Describe it instead ("a $1xxM TIV location in a county with 3 locations").
```

## P-11 Synthetic scale-up (optional, Phase 2)

```text
ROLE
You are a data engineer who builds realistic synthetic test data for catastrophe-exposure systems, and who is careful that synthetic data can never be mistaken for real data.

INPUTS
- The column list of WILDFIRE_DB.CORE.POLICY_LOCATIONS (already scrubbed, with DATASET = 'REAL' and PARENT_TOKEN)
- LOGIC_SPEC.md (distance bands, metrics) and DATA_PROFILE.md (distributions of TIV, premium and risk tiers)
- Target size: <ROWS> synthetic locations, for <PURPOSE, e.g. load-testing the distance view>

TASK
1. Write scale_up.sql that builds WILDFIRE_DB.CORE.POLICY_LOCATIONS_SYNTHETIC from a sample of real rows using TABLE(GENERATOR(ROWCOUNT => n)):
   - LOCATION_TOKEN = 'SYN-' || parent token || '-' || copy number; PARENT_TOKEN = parent; DATASET = 'SYNTHETIC'.
   - Location jitter that keeps clones near their parent. Explain the jitter in kilometres in both directions at the portfolio's latitude, and make it isotropic in distance if that's simple.
   - One shared size factor on TIV and premium (default +/-15%) and a smaller independent rate factor (default +/-5%), so premium per $1,000 TIV stays realistic.
   - No change to construction, occupancy or year built; vendor scores are inherited by joining on PARENT_TOKEN, because wildfire risk is spatially clustered.
   - Rebuild GEO with ST_MAKEPOINT(longitude, latitude) and H3 cells with H3_LATLNG_TO_CELL_STRING(latitude, longitude, res).
   - Same columns as POLICY_LOCATIONS so CORE.POLICY_LOCATIONS_ALL keeps working.
2. Add checks: row count; TIV, premium and premium-per-1k distributions compared with the real book (percentiles side by side); share of clones that landed in water or outside the states of their parent, if you can detect it cheaply; proof that no SYNTHETIC row appears in any view filtered to REAL.
3. Write SYNTHETIC_DATA.md: what the data is for, what it must never be used for (parity, customer-facing totals), how to rebuild it, and how to delete it.

RULES
- Never produce synthetic rows from unscrubbed data.
- Never let a view or query mix REAL and SYNTHETIC rows in one total.

BEFORE YOU FINISH
State plainly which tests synthetic data can and cannot support, and why (for example: jitter wider than a distance band breaks band-level parity).
```

## P-12 Fast-path app kit (demo path, Phases 3 to 5)

Use this when the goal is a credible customer demo within about a week. It replaces P-6, P-7 and P-8 for the fast path only; the full migration still uses those. It deliberately keeps the runbook's guardrails (scrubbed data, bound parameters, append-only decisions) that a quick build tends to drop.

```text
ROLE
You are a principal Snowflake and Streamlit architect producing a demo build of a wildfire underwriting app in Streamlit in Snowflake. Speed matters, but the demo will show real (scrubbed) portfolio numbers to a customer, so correctness and data handling matter more.

INPUTS
- LOGIC_SPEC.md (calculations, bands, metrics, actions) and SYSTEM_INVENTORY.md (endpoints and response fields)
- The scrubbed CSV headers, and one sample scrubbed vendor response per source
- One saved fire snapshot (GeoJSON) for the golden date
- The runbook's section 5.3 streamlit_app.py, which is the starting point and house style
- Runtime: <container | warehouse>

CONTEXT RULES
- Ignore HTML/Jinja templates, CSS, JS and Flask routing boilerplate except to learn what the underwriter sees.
- Snowflake does not call the internal API gateway. Vendor data comes from captured responses uploaded once.
- Use the object names from the shared context exactly.

PRODUCE, in this order, code first and a short note after each block:
1. setup.sql: RAW.POLICY_LOCATIONS_SCRUBBED, RAW.RISK_RESPONSES_RAW and the fire snapshot loaded from the stage; CORE.POLICY_LOCATIONS (DATASET = 'REAL', PARENT_TOKEN), the empty POLICY_LOCATIONS_SYNTHETIC and POLICY_LOCATIONS_ALL view; CORE.RISK_MICROSERVICE_CACHE using the real response field paths; CORE.FIRE_PERIMETERS_SNAPSHOT and the snapshot-only CORE.FIRE_PERIMETERS_ALL; CORE.UNDERWRITING_DECISIONS; the APP views V_LOCATION_FIRE_DISTANCE (50-mile ceiling), V_NEAREST_FIRE, V_EXPOSURE_BY_FIRE, V_EXPOSURE_BY_H3, V_LATEST_DECISIONS and V_FIRE_PERIMETERS. Validation queries at the end must return the totals in SCRUB_VALIDATION_REPORT.md.
2. streamlit_app.py: adapt the attached app to LOGIC_SPEC.md: the real KPI definitions, risk tiers, actions and number formats. Keep st.connection, cached reads, in-memory radius filtering, bound parameters, uncached decision reads, the SYNTHETIC banner, and the two-identity decision insert. Add the vendor capture date to the page.
3. The dependency file for the chosen runtime (pyproject.toml or environment.yml).
4. checks.sql: the runbook's section 6.6 checks as runnable queries, plus a side-by-side comparison of the app's KPI queries with the golden date's numbers.

RULES
- Never invent field names: where the inputs don't give one, write a clearly marked placeholder and list it at the end.
- No mock or fabricated fire perimeters in the customer-facing dataset. If no snapshot is available, stop and say so.
- Do not hard-code credentials, account names or URLs.

BEFORE YOU FINISH
List every placeholder left, every assumption made, and the three checks I should run first.
```

