# 03 — ArcGIS Security & Architecture Checklist

> **Phase 3 of the mission.** Walk through this checklist against the codebase. Save findings to `reports/raw/arcgis_review.md`. These findings feed the Security Findings Report and the SDLC Audit.

Generic Python security tools don't know about ArcGIS. This checklist exists because the failure modes here are real and recurring, and no automated scanner catches them.

For each item: mark **Pass / Fail / N/A / Unknown**, cite file:line evidence, and write a one-line note.

---

## A. Authentication & Credentials

### A1. Portal credentials are not hardcoded
Search for `GIS("https://...", "username", "password")` patterns.

```bash
grep -rn 'GIS(' --include="*.py" | grep -v test
```

❌ **Fail** indicators: literal username/password strings, tokens embedded in source.
✅ **Pass** indicators: credentials from environment variables, a secrets manager, or interactive prompt.

### A2. Token refresh and expiry are handled
ArcGIS tokens expire. Long-running processes that cache a `GIS` object can fail mid-execution.

Look for: explicit token refresh logic, or use of `GIS(...)` with persistent identity providers (OAuth, PKI, IWA).

### A3. Connection objects are not shared across requests carelessly
In a Flask app, a module-level `gis = GIS(...)` initialized at import time means:
- All requests share one user's privileges (privilege escalation risk)
- Token expiry affects every request simultaneously
- Per-user audit trails are impossible

Look for: `GIS(...)` at module scope vs inside request handlers. Both have tradeoffs; flag which pattern is used and the implications.

### A4. Service-account principle of least privilege
If a service account is used, does it have *only* the permissions needed (read specific layers, edit specific feature services)? Or is it an admin/publisher account "because it was easier"?

This is usually unknowable from code alone — flag it as a question for the platform admin.

## B. Input Validation Around Geospatial Operations

### B1. User-supplied geometries are validated
If a route accepts WKT, GeoJSON, or coordinate inputs from users, those must be validated before being passed to `arcpy` or `arcgis`. Malformed geometry can crash or hang geoprocessing.

```bash
grep -rn "request.\(form\|args\|json\).*\(geom\|wkt\|geojson\|coord\|lat\|lon\|lng\)" --include="*.py"
```

### B2. SQL where-clauses are parameterized
ArcGIS feature service queries accept a `where` parameter. Concatenating user input into that string is SQL injection.

❌ **Fail** pattern:
```python
where = f"OBJECTID = {request.args['id']}"
feature_layer.query(where=where)
```

✅ **Pass** pattern: validate `id` as integer first, or use the ArcGIS query helpers that escape properly.

### B3. File uploads are constrained
Insurance applications may accept shapefiles, geodatabases, KML, CSV. Each is a parser attack surface.

Check: file size limits, extension allowlist, content-type validation, where uploaded files are written (and whether the path is user-influenced — path traversal).

### B4. Address inputs (geocoding) are size-limited
A common Flask + ArcGIS pattern is bulk geocoding. Without limits, one request can submit 10,000 addresses, exhaust API quota, and become a DoS or a billing event.

## C. Data Handling

### C1. PII in logs
Insurance data is sensitive. Check the logging configuration and `print()` statements for anything that emits policy numbers, SSNs, names, addresses, claim amounts.

```bash
grep -rn "print(\|logger.\|logging\." --include="*.py" | grep -iE "policy|ssn|claim|customer|address"
```

### C2. Feature service writes are intentional
`arcgis.features.FeatureLayer.edit_features()` modifies live data. Verify every write call site is gated by appropriate authorization and that test environments are isolated from production layers (different URLs or different portals).

### C3. Temporary scratch workspaces are cleaned up
`arcpy` operations often create intermediate datasets. Without cleanup, disk fills up and temp data may contain PII.

Look for: explicit `arcpy.management.Delete()` calls, `with` statements around scratch workspaces, or `arcpy.env.scratchWorkspace` set to an ephemeral location.

### C4. Geodatabases and shapefiles are not committed to git
```bash
git ls-files | grep -iE '\.(gdb|shp|shx|dbf|prj|sbn|sbx|cpg)$'
```
None should be returned. If any are, they go in `.gitignore` and may need git-filter-repo to remove from history.

## D. Flask + ArcGIS Web Surface

### D1. `app.run(debug=True)` is not in production code paths
Werkzeug's debugger allows arbitrary code execution. This is the single most common Flask CVE.

```bash
grep -rn "debug=True\|debug = True" --include="*.py"
```

### D2. Flask secret key is from configuration, not literal
```bash
grep -rn "app.secret_key\|SECRET_KEY" --include="*.py"
```

❌ `app.secret_key = "dev"` or any literal string.
✅ `app.secret_key = os.environ["FLASK_SECRET_KEY"]`.

### D3. CSRF protection on state-changing routes
Flask doesn't enable CSRF by default. Check for `Flask-WTF` with `CSRFProtect` or equivalent. If routes accept POST/PUT/DELETE without CSRF, document it.

### D4. CORS configuration is restrictive
If `flask-cors` is in use, look for `CORS(app)` with no `origins` argument — that's allow-all.

### D5. Routes that proxy to ArcGIS services don't enable SSRF
If a Flask route fetches an arbitrary URL from user input and forwards to ArcGIS or to a feature service URL, that's server-side request forgery. The URL must be validated against an allowlist.

### D6. Error responses don't leak ArcGIS internals
Stack traces, full portal URLs, internal IPs, GDB paths, or token fragments should never reach the user. Check `errorhandler` setup and `try/except` blocks.

## E. Dependency & Runtime

### E1. `arcpy` is not in `requirements.txt`
It cannot be installed via pip. If it's listed, the file is misleading. The correct documentation is "requires ArcGIS Pro 3.x or ArcGIS Server installed; uses bundled Python at `C:\Program Files\ArcGIS\Pro\bin\Python\envs\arcgispro-py3`."

### E2. `arcgis` package version is pinned
The `arcgis` Python API has had breaking changes between major versions. Look for `arcgis==X.Y.Z` not `arcgis>=X` or unpinned.

### E3. Python version compatibility is documented
`arcpy` ships with a specific Python version. As of writing, ArcGIS Pro 3.x bundles Python 3.11. If the Flask app targets a different Python version, that's a deployment problem.

### E4. Required ArcGIS Pro extensions are documented
Some `arcpy` calls require licensed extensions (Spatial Analyst, Network Analyst, 3D Analyst). Code that calls `arcpy.CheckOutExtension("Spatial")` documents this implicitly. Surface it explicitly in the SDLC report.

## F. Deployment Reality Check

### F1. Server-class hosting for `arcpy`
`arcpy` running in a Flask app means the Flask server *also* requires an ArcGIS license and install. That's a meaningful constraint:
- Cannot deploy to typical PaaS (Heroku, App Service, Lambda)
- Requires Windows or Linux server with ArcGIS Server or ArcGIS Pro license
- Per-server licensing cost

Document this in the SDLC report under Deployment.

### F2. Concurrency model is appropriate
`arcpy` is not thread-safe. Flask in production must use `gunicorn` or `uwsgi` with **process workers, not thread workers**, when `arcpy` is in use.

The `arcgis` library is generally thread-safe but individual `GIS` objects may not be.

### F3. Connection pooling / rate limits to ArcGIS Online
ArcGIS Online has request quotas. If this app makes many calls per request and traffic grows, quota becomes a bottleneck and a cost driver.

## G. Insurance Domain Concerns

### G1. Geocoding accuracy is fit-for-purpose
Insurance underwriting often requires rooftop-accurate geocoding. Default geocoders return varying accuracy. The code should specify accuracy thresholds and reject low-confidence results, not silently proceed.

### G2. Coordinate system handling is correct
Insurance risk often depends on distance to features (coastline, fault lines, fire zones). Distance calculations in geographic (lat/lon) coordinates are wrong; the code must project to an appropriate coordinate system first.

Look for: `arcpy.management.Project`, explicit `SpatialReference()` usage, or comments about CRS/projection.

### G3. Data freshness is tracked
Flood zones, fire risk, and crime data have effective dates. If the code uses static datasets, document when they were last refreshed.

### G4. Audit trail
Insurance decisions need to be reproducible. Does the code log: what data was used (with version/timestamp), what algorithm was run, what result was returned, who requested it? If not, that's a compliance gap.

---

## Output Format

In `reports/raw/arcgis_review.md`:

```markdown
# ArcGIS Security & Architecture Review

Date: [date]
Reviewer: Opus
Codebase: [repo name / commit hash]

## Section A — Authentication & Credentials
| Item | Status | Evidence | Note |
|------|--------|----------|------|
| A1   | Fail   | app/config.py:23 | Hardcoded username/password in GIS() call |
| A2   | Unknown | — | No token refresh logic found; impact depends on runtime duration |
[etc.]

## Section B — Input Validation
[...]

## Summary
- Fails: [count] (list by item ID)
- Unknowns: [count]
- High-priority: A1, B2, D1 (or whichever)
```

Once `arcgis_review.md` is written, proceed to Phase 4 (report drafting using the templates).
