# Wildfire Underwriting App: Flask/Jupyter to Streamlit in Snowflake (SiS) Migration Runbook

## 1. Executive Architecture & Plan Confirmation

This runbook outlines the rapid, low-token migration of the legacy **Jupyter Notebook + Flask** wildfire underwriting application into a native **Streamlit in Snowflake (SiS)** solution.

### Architecture Shift
* **Legacy State:** A local or standalone Jupyter Notebook executing Pandas/GeoPandas spatial joins, calling internal microservices (via an API Gateway) that wrap third-party providers (**Zesty.ai**, **Precisely**, **ArcGIS**), and serving decisions through Flask routes and HTML/Jinja templates.
* **Target State:** A single-file Python application (`streamlit_app.py`) running natively inside **Streamlit in Snowflake**, synced via **Snowflake Git Integration**, backed by pre-fetched/synthesized Snowflake tables and native **Snowflake Geospatial (`GEOGRAPHY`)** calculations.

| System Layer | Legacy Stack (Jupyter + Flask) | Target Stack (Streamlit in Snowflake) | Migration Action |
| :--- | :--- | :--- | :--- |
| **UI & Routing** | Flask `@app.route`, HTML/CSS/JS templates | `st.slider`, `st.pydeck_chart`, `st.metric`, `st.data_editor` | Delete `templates/` and `static/`; replace with declarative Streamlit widgets. |
| **Vendor Data (Zesty / Precisely)** | Live synchronous calls through Internal API Gateway | Pre-fetched / seeded Snowflake table (`RISK_MICROSERVICE_CACHE`) | Bypass live API Gateway networking; seed from Postman/Jupyter and multiply in Snowflake. |
| **Spatial Math** | In-memory `geopandas` / ArcGIS Python SDK | Snowflake Geospatial SQL (`ST_DWITHIN`, `ST_INTERSECTS`, `ST_MAKEPOINT`) | Push radius buffer and polygon intersection calculations down to the Snowflake Virtual Warehouse. |
| **State & Caching** | Manual Flask session state or repeated API runs | `@st.cache_data` + `get_active_session()` | Cache dataset pulls in memory so UI slider interactions cost $0 in extra compute/API calls. |
| **Underwriter Decisions** | Local CSV export or custom POST endpoint | Direct Snowflake table write-back (`UNDERWRITING_DECISIONS`) | Persist holds, approvals, and notes directly via `session.sql()`. |

---

## 2. Strategic Nuances: Testing, Data Seeding, & Token Optimization

### Nuance 1: Token-Optimal Context Pruning (Save $\sim 85\%$ in LLM Costs)
Before running any AI coding prompts against your GitHub repository, strip out files that will not survive the migration:
1. **Never feed `templates/` or `static/`** to the coding agent. Streamlit handles layout natively.
2. **Never feed raw `.ipynb` files.** Notebook files contain massive JSON metadata and base64-encoded chart images. Convert your notebook to a clean Python script first:
   ```bash
   jupyter nbconvert --to script your_notebook.ipynb
   ```

### Nuance 2: Bypassing the Internal API Gateway via Pre-Fetched Cache Tables
Calling an internal company API Gateway from inside Snowflake requires configuring External Access Integrations, Secrets, and private networking (AWS PrivateLink / Azure Private Link / firewall allowlists). 
* **The Shortcut:** Use your existing **Postman test suite** or a single run of the **Jupyter Notebook** to capture real responses from your internal microservices (Zesty risk scores, Precisely lat/longs, property attributes). Land those responses in a Snowflake table (`RISK_MICROSERVICE_CACHE`).
* **Future Production Path:** Once the SiS app is validated, your internal microservice pipeline or an automated ingestion job (Snowpipe / Kafka / Scheduled Task) can continuously populate `RISK_MICROSERVICE_CACHE` in the background, keeping the Streamlit app 100% decoupled from API Gateway latency and downtime.

### Nuance 3: Golden Sample Harvesting, PII Scrubbing, & Spatial Multiplication
To test realistic portfolio exposure without running thousands of paid calls through Zesty or Precisely:
1. **Harvest:** Export 50 to 100 joined rows (Policy + Microservice Response) from your Jupyter DataFrame (`df.head(100).to_csv("seed_data.csv", index=False)`) or Postman Runner output.
2. **Scrub PII Locally:** In Pandas, replace customer names, street addresses, and policy IDs with synthetic identifiers before uploading to Snowflake, while **preserving real coordinates, premiums, Total Insured Value (TIV), and Zesty risk scores**.
3. **Multiply with Correlated Spatial Jitter:** Use Snowflake's `GENERATOR` function to clone those 100 real records into 5,000+ synthetic neighboring properties.
   * *Testing Nuance:* Apply small coordinate jitter ($\pm 0.01^\circ$ to $\pm 0.03^\circ$ latitude/longitude) and $\pm 15\%$ variance on Premium/TIV, **but keep the Zesty wildfire risk score tightly correlated to the parent seed record**. Wildfire risk is geographically clustered; keeping risk scores anchored to their parent cluster ensures your spatial buffer tests and loss-ratio metrics behave realistically on the map.

### Nuance 4: Streamlit Rerun Lifecycle & `@st.cache_data`
Streamlit re-executes `streamlit_app.py` from top to bottom on every widget interaction.
* Wrap all Snowflake table reads and spatial queries in `@st.cache_data(ttl=600)`.
* When an underwriter drags the wildfire distance slider from $5\text{ miles}$ to $25\text{ miles}$, you can either pass the slider parameter into a fast cached Snowpark spatial query (`ST_DWITHIN`) or pre-calculate distances up to $50\text{ miles}$ once and filter the resulting Pandas DataFrame instantaneously in memory.

---

## 3. Individual Step-by-Step Prompts (Granular Workflow)

Use these four sequential prompts if you want to inspect and verify each layer step-by-step.

### Prompt 1: The Endpoint & Schema Hunter (Repo + Postman X-Ray)
> **Context to attach:** File tree, converted `.py` script from Jupyter, and exported Postman Collection JSON (exclude `templates/` and `static/`).
>
> **Prompt:**
> "Scan the attached `.py` files and Postman collection JSON. Ignore all HTML/CSS/Flask UI rendering code. Output ONLY:
> 1. A compact Markdown table of every internal microservice / third-party endpoint called (Zesty, Precisely, ArcGIS, Wildfire feeds), showing: Endpoint Path, Request Parameters, Exact Response JSON keys used in downstream math, and Target Snowflake Data Types (`VARCHAR`, `FLOAT`, `NUMBER`, `GEOGRAPHY`, `VARIANT`).
> 2. A Snowflake SQL `CREATE OR REPLACE TABLE` script for `POLICY_EXPOSURE_SEED` and `WILDFIRE_PERIMETERS` that captures these exact fields. No conversational explanation."

### Prompt 2: Seed Data Scrubber & Snowflake Synthetic Multiplier
> **Context to attach:** A 5-row sample or column list from your Jupyter DataFrame / Postman response.
>
> **Prompt:**
> "Given this schema from our Jupyter notebook/Postman output: `[paste columns or sample JSON]`, write two short scripts (code only, no prose):
> 1. A local Python Pandas snippet to strip PII (customer name, policy number, street address) from a 100-row `seed.csv` export while preserving lat, long, Zesty risk scores, Total Insured Value (TIV), and Premium.
> 2. A Snowflake SQL script that takes those 100 uploaded rows in `POLICY_EXPOSURE_SEED` and cross-joins them with `TABLE(GENERATOR(ROWCOUNT => 50))` to populate a 5,000-row table `POLICY_EXPOSURE_SYNTHETIC`. Add random coordinate jitter between $-0.025$ and $+0.025$ degrees to lat/long, vary TIV and Premium by $\pm 15\%$ using `UNIFORM()`, construct a native `GEOGRAPHY` point column via `ST_MAKEPOINT(lon, lat)`, and keep the Zesty risk score anchored to the parent seed row."

### Prompt 3: Push Spatial & Exposure Math to Snowflake SQL / Snowpark
> **Context to attach:** Only the Python functions in your `.py` file that calculate wildfire proximity, exposure, and premium ratios.
>
> **Prompt:**
> "Convert these Pandas/GeoPandas/ArcGIS spatial and underwriting calculation functions into a single Snowflake SQL query wrapped in a Snowpark Python function `get_underwriting_exposure(session, buffer_miles: float)`. Use Snowflake native geospatial functions (`ST_DWITHIN`, `ST_DISTANCE`) to join `POLICY_EXPOSURE_SYNTHETIC` against `WILDFIRE_PERIMETERS` within `buffer_miles`. Calculate distance to nearest fire (in miles), flag policies inside the buffer, and return a Pandas DataFrame ready for Streamlit. Output code only."

### Prompt 4: One-Shot Flask to Streamlit in Snowflake (`streamlit_app.py`)
> **Context to attach:** Your Flask route file (`app.py`) and the function from Prompt 3.
>
> **Prompt:**
> "Convert this Flask application into a single-file `streamlit_app.py` designed for Streamlit in Snowflake (SiS). Follow these strict constraints:
> 1. Initialize connection using `from snowflake.snowpark.context import get_active_session`.
> 2. Decorate all data-fetching functions with `@st.cache_data(ttl=600)` so UI interactions never trigger redundant queries.
> 3. Sidebar controls: Slider for Wildfire Buffer Radius ($1$ to $50\text{ miles}$), multi-select for Zesty Risk Score tiers, and minimum TIV filter.
> 4. Top KPI row using `st.columns(4)` and `st.metric`: Total Policies Exposed, Total Insured Value (TIV) at Risk, Total Premium in Buffer, and Exposure-to-Premium Ratio.
> 5. Interactive map using `st.pydeck_chart` plotting wildfire polygons/points in red and insured properties color-coded by Zesty risk score.
> 6. Underwriter Decision Form (`st.form`): Allow selecting a policy/region, choosing an action ('Approve', 'Flag for Hold', 'Require Mitigation'), and writing the decision back to a Snowflake table `UNDERWRITING_DECISIONS` via `session.sql()`.
> Output the complete `streamlit_app.py` code and an `environment.yml` file for Snowflake Anaconda packages (`streamlit`, `pydeck`, `pandas`, `plotly`). No prose."

---

## 4. The Consolidated "One-Shot" Mega-Prompt

If you want to execute the entire analysis, SQL generation, synthetic data expansion, and Streamlit app creation in **one single prompt** to minimize round-trip context tokens, attach ONLY your converted notebook script (`notebook.py`), your main Flask file (`app.py`), and a sample Postman response JSON, then paste this prompt:

```text
You are a Principal Snowflake & Streamlit Architect. We are migrating a legacy Jupyter Notebook + Flask wildfire underwriting application into a native Streamlit in Snowflake (SiS) app.

CONTEXT RULES (STRICT TOKEN SAVING):
- Ignore all HTML/Jinja templates, CSS, JS, and Flask routing boilerplate.
- We do NOT call Zesty.ai, Precisely, or ArcGIS directly from Snowflake; our internal microservices fetch that data. For this implementation, we are bypassing the internal API Gateway by pre-fetching/seeding those responses into Snowflake tables and multiplying them synthetically.

Review the attached Python scripts and Postman payload sample, and generate the complete migration kit in 4 code blocks with ZERO conversational filler:

BLOCK 1: ENDPOINT & SCHEMA MAPPING + SNOWFLAKE DDL (`setup_schema.sql`)
1. Brief Markdown table mapping every external/microservice data field used in our underwriting math (Precisely lat/long, Zesty risk scores, ArcGIS/Wildfire polygons, Policy TIV & Premium) to Snowflake data types.
2. Snowflake SQL DDL creating:
   - `POLICY_EXPOSURE_SEED` (raw 100-row upload table)
   - `POLICY_EXPOSURE_SYNTHETIC` (expanded table with `GEOGRAPHY` point column)
   - `WILDFIRE_PERIMETERS` (active fire locations/polygons with `GEOGRAPHY` column)
   - `UNDERWRITING_DECISIONS` (audit table for write-back: `decision_id`, `policy_id`, `underwriter_action`, `notes`, `decided_at`)

BLOCK 2: PII SCRUBBER & 5,000-ROW SYNTHETIC MULTIPLIER (`seed_and_multiply.sql`)
1. A short local Pandas one-liner showing how to export 100 rows from our Jupyter DataFrame (`seed.csv`) with PII scrubbed.
2. Snowflake SQL that takes the 100 rows in `POLICY_EXPOSURE_SEED` and cross-joins with `TABLE(GENERATOR(ROWCOUNT => 50))` into `POLICY_EXPOSURE_SYNTHETIC`. Apply random lat/long jitter between -0.025 and +0.025 degrees, vary TIV and Premium by +/- 15%, construct a `GEOGRAPHY` point using `ST_MAKEPOINT(lon, lat)`, and keep the Zesty risk score tied to the parent seed row to preserve spatial risk clustering. Include 5 realistic mock rows for `WILDFIRE_PERIMETERS` in matching coordinate bounds.

BLOCK 3: SNOWFLAKE ENVIRONMENT FILE (`environment.yml`)
- Snowflake Anaconda channel spec including `streamlit`, `snowflake-snowpark-python`, `pydeck`, `pandas`, and `plotly`.

BLOCK 4: PRODUCTION STREAMLIT IN SNOWFLAKE APP (`streamlit_app.py`)
Write the complete single-file SiS app replacing all Flask routes and notebook logic:
- Use `get_active_session()` from `snowflake.snowpark.context`.
- Wrap data queries in `@st.cache_data(ttl=600)` pushing spatial proximity checks (`ST_DWITHIN`, `ST_DISTANCE`) down to Snowflake SQL.
- Sidebar controls: Wildfire Buffer Radius slider (1–50 miles), Zesty Risk Tier filter, Exposure threshold.
- Top KPI metrics (`st.columns(4)`): Exposed Policy Count, Total Exposure ($ TIV), Total Premium ($), and Exposure-to-Premium Ratio.
- Map visualization (`st.pydeck_chart`): Multi-layer map showing wildfire perimeters/radii and color-coded property pins by risk & exposure vs. premium.
- Underwriter Write-Back (`st.form`): Let the underwriter log a binding decision ('Approve', 'Refer/Hold', 'Adjust Rate') that inserts directly into `UNDERWRITING_DECISIONS`.
```

---

## 5. Plan Verification & Testing Checklist

Once your coding agent outputs the four blocks above, follow this verification sequence to confirm the build:

- [ ] **Step 1: Verify Coordinate Alignment (Sanity Check)**
  Run the `seed_and_multiply.sql` script in a Snowsight SQL Worksheet. Confirm that `ST_MINX`, `ST_MAXX`, `ST_MINY`, and `ST_MAXY` of your synthetic properties overlap geographically with the `WILDFIRE_PERIMETERS` rows so the map isn't empty on first load.
- [ ] **Step 2: Validate Spatial Pushdown Speed**
  Run the `ST_DWITHIN` query standalone in Snowsight against all 5,000 synthetic rows. Execution time on an `X-SMALL` warehouse should be under $500\text{ ms}$.
- [ ] **Step 3: Verify `@st.cache_data` Hit Behavior**
  Open the Streamlit app in Snowsight and adjust the UI filters. Check Snowsight **Monitoring $\rightarrow$ Query History**: moving in-memory filters should trigger $0$ new warehouse queries when reading cached results.
- [ ] **Step 4: Confirm Write-Back Governance**
  Submit a test underwriting hold via the `st.form` button and verify the row lands in `UNDERWRITING_DECISIONS` with `CURRENT_USER()` and `CURRENT_ROLE()` captured automatically.