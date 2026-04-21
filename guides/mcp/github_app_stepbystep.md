# MCP Trust Registry Implementation Guide

## GitHub Apps Authentication + Official MCP Registry v0.1 Conformance

**Project:** MCP-Ignite
**Document Version:** 2.0
**Original Draft:** November 17, 2025 (v1.0)
**Revised:** April 20, 2026 (v2.0 — aligns with official MCP Registry standard)
**Purpose:** Stand up an enterprise MCP Trust Registry that conforms to the official MCP Registry subregistry API, authenticated via GitHub Apps (no PATs), with governance workflows.

---

## What Changed in v2.0

The November 2025 draft predated the official MCP Registry GA and used a custom server-entry schema. Since then:

- **MCP project governance moved to the Agentic AI Foundation (AAIF) / Linux Foundation** (December 2025). The canonical registry is run by a neutral foundation, not a single vendor.
- **Official `server.json` schema** is now stable at `https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json`, with camelCase field names and reverse-DNS namespacing (e.g., `io.github.owner/server-name` or `com.company/server-name`).
- **Subregistry API v0.1** is frozen — enterprise registries that expose `/v0.1/servers` in the same shape as upstream can be consumed by any MCP client that already talks to the public registry.
- **GitHub Action `actions/create-github-app-token` v3** replaces v2; the `client-id` input is preferred over `app-id`.
- **Webhook secret leak incident (Sept 2025 – Jan 2026)** — any GitHub App webhook secret active during that window must be rotated.
- **A public webhook-leak remediation, the query-parameter auth sunset, the Authorizations API sunset, and mandatory 2FA (May 2, 2026)** land inside the window this guide targets — call-outs added.

This revision preserves the governance intent of v1 (security baseline, CODEOWNERS, validation workflow) but swaps the custom schema for the official one and moves all internal-only metadata into the schema's `_meta` extension slot under a reverse-DNS key we own (`com.mcp-ignite.governance/v1`). That keeps the registry interoperable with upstream tooling while retaining our security-review, network, and compliance data.

---

## Table of Contents

1. [Overview & Outcome Goals](#overview--outcome-goals)
2. [How This Aligns With the Official MCP Registry](#how-this-aligns-with-the-official-mcp-registry)
3. [Phase 1: GitHub App Creation & Configuration](#phase-1-github-app-creation--configuration)
4. [Phase 2: Trust Registry Repository Setup](#phase-2-trust-registry-repository-setup)
5. [Phase 3: Subregistry API Surface](#phase-3-subregistry-api-surface)
6. [Phase 4: Test & Validate](#phase-4-test--validate)
7. [Security Callouts (2026 update)](#security-callouts-2026-update)
8. [Migration Notes from v1](#migration-notes-from-v1)
9. [References](#references)

---

## Overview & Outcome Goals

### Goals

1. **Conform to the official MCP Registry v0.1 subregistry contract** so clients pointed at our registry work without custom adapters.
2. **Replace PATs with GitHub Apps** for all automation touching the registry repo.
3. **Preserve internal governance data** (security review, ExpressRoute compatibility, data-handling attributes) by placing it inside the official schema's `_meta` extension slot under `com.mcp-ignite.governance/v1`.
4. **Document control points** at the GitHub, workflow, registry, and server layers.

### Success criteria

- ✅ `server.json` entries validate against the official 2025-12-11 schema.
- ✅ Registry HTTP surface responds to `GET /v0.1/servers`, `GET /v0.1/servers/{name}/versions/latest`, and `GET /v0.1/servers/{name}/versions/{version}` with the upstream-shaped response.
- ✅ GitHub App private key stored in Azure Key Vault with Octokit sign-only integration (key never leaves the vault).
- ✅ No PATs in any workflow; `create-github-app-token@v3` with `client-id` input.
- ✅ Full audit trail on every submission, approval, and rejection.
- ✅ CODEOWNERS enforces Security Director + Director Oversight sign-off on approved/ and policy changes.

---

## How This Aligns With the Official MCP Registry

The official MCP Registry is a **metadata-only index** of MCP servers at `https://registry.modelcontextprotocol.io/`, governed by AAIF. It does not host package artifacts — those live in npm, PyPI, OCI registries, etc. — and it has deliberately minimal moderation. Enterprises building internal trust registries are expected to:

1. **Speak the same wire protocol** — subregistry API v0.1 — so standard MCP clients can consume our registry.
2. **Use the same `server.json` shape** — same schema, same field names, same namespacing rules — so entries can be mirrored up to the official registry later (or pulled down from it) without translation.
3. **Layer their own moderation on top.** Upstream is permissive by design; the trust, approval, and compliance logic is ours to add.

Our registry is therefore a **private subregistry**: same contract, stricter policy. When upstream adds fields we don't care about, our schema validator will accept them; when we add internal governance data, it lives under `_meta` where upstream ignores it.

---

## Phase 1: GitHub App Creation & Configuration

### Step 1: Create the GitHub App

**Why GitHub Apps?**
- Fine-grained, installation-scoped permissions instead of user-bound PATs.
- Enterprise-level permissions (Organization Installations, Custom Properties, SSO/SCIM, People Management) are now generally available — see the July 2025 changelog and the subsequent enterprise expansions.
- Eliminates the class of PAT incidents the security team flagged in summer 2025.

#### Actions

1. **Navigate to the MCP-Ignite organization settings:**
   ```
   URL: https://github.com/organizations/MCP-Ignite/settings/apps
   Click: "New GitHub App"
   ```

2. **App registration:**
   ```
   GitHub App Name:  MCP-Registry-Manager
   Description:      Manages MCP Trust Registry with governance workflows
   Homepage URL:     https://github.com/MCP-Ignite
   Callback URL:     [leave blank]
   ```

3. **Webhook configuration:**
   ```
   Webhook:         Active
   Webhook URL:     [configure post-deploy]
   Webhook Secret:  [generate; store in Key Vault]
   ```

   > **⚠️ 2026 security note:** GitHub disclosed that webhook secrets were inadvertently exposed in HTTP headers between September 2025 and January 2026. Any GitHub App webhook secret that was active during that window MUST be rotated before reuse. Verify the incident status and rotate if required.

4. **Repository permissions (fine-grained):**
   ```
   Contents:       Read & Write
   Pull Requests:  Read & Write
   Metadata:       Read-only
   Workflows:      Read & Write
   ```

5. **Organization permissions:**
   ```
   Members:        Read-only
   Administration: Read-only
   ```

6. **Subscribe to events:**
   ```
   ☑ Pull Request
   ☑ Pull Request Review
   ☑ Pull Request Review Comment
   ☑ Push
   ☑ Workflow Run
   ```

7. **Installation scope:**
   ```
   ● Only on this account (MCP-Ignite)
   ```

### Step 2: Generate & secure the private key

Private keys must never be hardcoded or stored next to source. In v2 the recommended pattern is **Azure Key Vault with remote JWT signing**: the PEM is imported into the vault and never exfiltrated, and Octokit uses a custom JWT signing function backed by Key Vault's sign operation.

#### Actions

1. **Generate:**
   - On the app settings page → Private keys → *Generate a private key*.
   - Download the `.pem`, upload it immediately to Key Vault, then delete the local copy.

2. **Store in Azure Key Vault (production path):**
   ```bash
   az keyvault key import \
     --vault-name "mcp-ignite-vault" \
     --name "github-app-signing-key" \
     --pem-file /path/to/downloaded-key.pem \
     --protection software

   az keyvault secret set \
     --vault-name "mcp-ignite-vault" \
     --name "github-app-client-id" \
     --value "Iv23li..."   # the Client ID from the App settings page
   ```

   The signing key is imported as a **key** (not a secret). Workflows call Key Vault's `sign` operation rather than downloading the PEM, so the key material never leaves the vault.

3. **Octokit remote-signing pattern (Node 24):**
   ```js
   import { App } from "octokit";
   import { signJwtWithKeyVault } from "./keyvault-signer.js";

   const app = new App({
     clientId: process.env.MCP_REGISTRY_CLIENT_ID,
     privateKey: undefined,
     auth: { signJwt: signJwtWithKeyVault },
   });
   ```

4. **Testing / dev fallback (GitHub-hosted secrets):**
   ```
   Secret:    MCP_REGISTRY_APP_PRIVATE_KEY   (full PEM contents)
   Variable:  MCP_REGISTRY_APP_CLIENT_ID     (Client ID — preferred over App ID in v3+)
   ```
   Use this only in dev; migrate to Key Vault before the pilot ships.

5. **Record app metadata:**
   ```
   App ID (legacy):     [from settings]
   Client ID:           [from settings — used by create-github-app-token@v3]
   Installation ID:     [populated after install]
   Signing key:         Azure Key Vault "mcp-ignite-vault" / "github-app-signing-key"
   Created by:          [name]
   Created date:        [date]
   ```

### Step 3: Install the app

Installation access tokens expire **after 1 hour** (unchanged). `actions/create-github-app-token@v3` regenerates tokens per job automatically.

1. **Install on MCP-Ignite:**
   - App settings → *Install App* → MCP-Ignite organization.
   - Repository access: *Only select repositories* → `mcp-trust-registry`.

2. **Record the Installation ID** from the install URL:
   ```
   https://github.com/organizations/MCP-Ignite/settings/installations/<INSTALLATION_ID>
   ```

3. **Verify:**
   ```bash
   gh api /app/installations/<INSTALLATION_ID> \
     --jq '.id, .account.login, .permissions'
   ```

---

## Phase 2: Trust Registry Repository Setup

### Repository structure

```
mcp-trust-registry/
├── .github/
│   └── workflows/
│       ├── validate-submission.yml       # schema + baseline + duplicate checks
│       ├── approve-server.yml            # pending → approved on label
│       ├── publish-api-snapshot.yml      # emits /v0.1/servers JSON to Pages
│       └── audit-changes.yml             # signed audit log of every write
├── registry/
│   ├── approved/                         # one <server-name>.json per entry
│   ├── pending/                          # submissions under review
│   ├── rejected/                         # rejections + reason
│   └── schemas/
│       └── governance-meta.schema.json   # OUR _meta extension schema
├── api/                                  # generated; committed only for preview
│   └── v0.1/
│       ├── servers.json
│       └── servers/<name>/versions/*.json
├── docs/
│   ├── SUBMISSION_GUIDELINES.md
│   ├── APPROVAL_PROCESS.md
│   ├── SECURITY_REQUIREMENTS.md
│   └── INTEGRATION_GUIDE.md
├── policies/
│   ├── baseline-security-criteria.md
│   ├── network-policy.md
│   └── data-handling-policy.md
├── scripts/
│   ├── validate.sh                       # ajv against official + governance schemas
│   └── build-api-snapshot.ts             # assembles /v0.1/servers response
├── CODEOWNERS
├── README.md
└── EXPERIMENT-RESULTS.md
```

Note: the **source of truth** is one `server.json` file per approved entry under `registry/approved/`. The `api/v0.1/` tree is a generated snapshot that serves the subregistry API (see Phase 3).

### Step 4: Create the registry repository

```bash
gh auth login   # user-scoped, only for repo creation

gh repo create MCP-Ignite/mcp-trust-registry \
  --private \
  --description "MCP Trust Registry — subregistry conforming to MCP Registry API v0.1" \
  --clone

cd mcp-trust-registry

mkdir -p .github/workflows
mkdir -p registry/{approved,pending,rejected,schemas}
mkdir -p api/v0.1/servers
mkdir -p docs policies scripts
```

### Step 5: Adopt the official `server.json` schema

We do **not** invent a schema. Entries reference the canonical schema and add our governance fields under `_meta`.

An approved entry (`registry/approved/com.mcp-ignite.test-filesystem-reader.json`):

```json
{
  "$schema": "https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json",
  "name": "com.mcp-ignite/test-filesystem-reader",
  "title": "Test Filesystem Reader",
  "description": "Read-only MCP server for local filesystem access — pilot phase, dummy data only.",
  "version": "1.0.0",
  "websiteUrl": "https://github.com/MCP-Ignite/test-mcp-server",
  "repository": {
    "url": "https://github.com/MCP-Ignite/test-mcp-server",
    "source": "github"
  },
  "packages": [
    {
      "registryType": "npm",
      "identifier": "@mcp-ignite/test-filesystem-reader",
      "version": "1.0.0",
      "transport": { "type": "stdio" }
    }
  ],
  "_meta": {
    "com.mcp-ignite.governance/v1": {
      "security_review": {
        "reviewed_by": "Frank (Security Director)",
        "review_date": "2026-04-20",
        "baseline_met": true,
        "compliance_verified": true,
        "risk_level": "low",
        "notes": "Pilot. Dummy data only. No Cincinnati code. Read-only local FS. No network.",
        "expiration_date": "2027-04-20"
      },
      "network_requirements": {
        "requires_internet": false,
        "expressroute_compatible": true,
        "allowed_domains": [],
        "firewall_rules_required": []
      },
      "authentication": {
        "type": "none",
        "required": false,
        "supports_sso": false,
        "credential_storage": "none"
      },
      "data_handling": {
        "pii_exposure": false,
        "data_residency": "local-only",
        "encryption_at_rest": false,
        "encryption_in_transit": false
      },
      "capabilities": {
        "tools":     ["read_file", "list_directory", "get_file_metadata"],
        "resources": ["file://local/test-data"],
        "prompts":   []
      },
      "maintenance": {
        "support_contact": "mcp-ignite@yourcompany.com",
        "sla": "Best effort during pilot",
        "deprecation_date": null
      }
    }
  }
}
```

Key points:

- **`name`** is reverse-DNS, using a domain we own (`com.mcp-ignite/…`). DNS verification (see Phase 3) proves ownership so the entry could be federated to the upstream registry without collision. For servers authored on github.com by a user, the `io.github.<user>/<server>` form is used instead.
- **All** enterprise-only fields live under `_meta["com.mcp-ignite.governance/v1"]`. Upstream tooling ignores unknown `_meta` keys, and the reverse-DNS namespacing is the convention the spec reserves for extensions.
- **No** `capabilities`, `network_requirements`, `security_review`, etc. at the top level — those were custom in v1 and are not in the official schema.

### Step 6: Governance-extension schema

`registry/schemas/governance-meta.schema.json` validates only the `_meta["com.mcp-ignite.governance/v1"]` block. The official `server.json` schema is pulled from `https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json` by the validator.

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "MCP-Ignite governance metadata (v1)",
  "description": "Internal governance fields stored under _meta['com.mcp-ignite.governance/v1'] on each server.json.",
  "type": "object",
  "required": ["security_review", "network_requirements", "authentication"],
  "properties": {
    "security_review": {
      "type": "object",
      "required": ["reviewed_by", "review_date", "baseline_met", "compliance_verified"],
      "properties": {
        "reviewed_by":         { "type": "string" },
        "review_date":         { "type": "string", "format": "date" },
        "baseline_met":        { "type": "boolean" },
        "compliance_verified": { "type": "boolean" },
        "risk_level":          { "type": "string", "enum": ["low", "medium", "high"] },
        "notes":               { "type": "string" },
        "expiration_date":     { "type": "string", "format": "date" }
      }
    },
    "network_requirements": {
      "type": "object",
      "required": ["requires_internet", "expressroute_compatible"],
      "properties": {
        "requires_internet":        { "type": "boolean" },
        "expressroute_compatible":  { "type": "boolean" },
        "allowed_domains":          { "type": "array", "items": { "type": "string", "format": "hostname" } },
        "firewall_rules_required": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "protocol":    { "type": "string" },
              "port":        { "type": "integer" },
              "destination": { "type": "string" }
            }
          }
        }
      }
    },
    "authentication": {
      "type": "object",
      "required": ["type", "required"],
      "properties": {
        "type":               { "type": "string", "enum": ["none", "api-key", "oauth", "certificate", "github-app"] },
        "required":           { "type": "boolean" },
        "supports_sso":       { "type": "boolean" },
        "credential_storage": { "type": "string", "enum": ["key-vault", "environment", "config-file", "none"] }
      }
    },
    "data_handling": {
      "type": "object",
      "properties": {
        "pii_exposure":          { "type": "boolean" },
        "data_residency":        { "type": "string" },
        "encryption_at_rest":    { "type": "boolean" },
        "encryption_in_transit": { "type": "boolean" }
      }
    },
    "capabilities": {
      "type": "object",
      "properties": {
        "tools":     { "type": "array", "items": { "type": "string" } },
        "resources": { "type": "array", "items": { "type": "string" } },
        "prompts":   { "type": "array", "items": { "type": "string" } }
      }
    },
    "maintenance": {
      "type": "object",
      "properties": {
        "support_contact":  { "type": "string", "format": "email" },
        "sla":              { "type": "string" },
        "deprecation_date": { "type": ["string", "null"], "format": "date" }
      }
    }
  }
}
```

### Step 7: Baseline security policy

The `policies/baseline-security-criteria.md` from v1 remains **largely unchanged** — it is internal policy, not registry schema. Two v2.0 updates:

- Section 2 (Authentication & Authorization): prefer GitHub App client-id flows; note that OAuth 2.1 + PKCE remains the standard for user-facing MCP authentication.
- Section 7 (Dependency Security): note that GitHub now offers **OIDC for Dependabot and code scanning** (April 2026), which our scanning stack should adopt instead of long-lived registry credentials.

The full baseline content (10 sections, risk matrix, exceptions, review cadence) from v1 carries forward verbatim and is omitted here for brevity — keep the v1 text; update only the two notes above.

### Step 8: Validation workflow (GitHub Actions)

`.github/workflows/validate-submission.yml` — runs on PRs touching `registry/pending/**`.

```yaml
name: Validate MCP Server Submission

on:
  pull_request:
    paths:
      - 'registry/pending/**'
      - 'registry/schemas/**'
    types: [opened, synchronize, reopened]

permissions:
  contents: read
  pull-requests: write
  issues: write

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Generate App Token
        id: app-token
        uses: actions/create-github-app-token@v3     # v3 required — v2 is EOL
        with:
          client-id:   ${{ vars.MCP_REGISTRY_APP_CLIENT_ID }}   # client-id preferred over app-id in v3.1+
          private-key: ${{ secrets.MCP_REGISTRY_APP_PRIVATE_KEY }}

      - uses: actions/setup-node@v4
        with:
          node-version: '24'    # matches create-github-app-token@v3 runtime

      - name: Install validators
        run: npm install -g ajv-cli ajv-formats

      - name: Validate against official MCP server.json schema (2025-12-11)
        id: schema-validation
        run: |
          echo "## Schema Validation (official 2025-12-11)" >> $GITHUB_STEP_SUMMARY
          PASSED=true
          curl -sSfL -o /tmp/server.schema.json \
            https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json
          for file in registry/pending/*.json; do
            [ -f "$file" ] || continue
            if ajv validate -s /tmp/server.schema.json -d "$file" --strict=false \
               -r "https://json-schema.org/draft/2020-12/schema"; then
              echo "✅ $(basename $file) conforms to official schema" >> $GITHUB_STEP_SUMMARY
            else
              echo "❌ $(basename $file) does NOT conform to official schema" >> $GITHUB_STEP_SUMMARY
              PASSED=false
            fi
          done
          echo "VALIDATION_PASSED=$PASSED" >> $GITHUB_OUTPUT

      - name: Validate _meta governance extension
        id: meta-validation
        run: |
          echo "## Governance _meta Validation" >> $GITHUB_STEP_SUMMARY
          PASSED=true
          for file in registry/pending/*.json; do
            [ -f "$file" ] || continue
            jq '._meta["com.mcp-ignite.governance/v1"] // empty' "$file" > /tmp/meta.json
            if [ -s /tmp/meta.json ]; then
              if ajv validate -s registry/schemas/governance-meta.schema.json -d /tmp/meta.json --strict=false; then
                echo "✅ $(basename $file) _meta valid" >> $GITHUB_STEP_SUMMARY
              else
                echo "❌ $(basename $file) _meta invalid" >> $GITHUB_STEP_SUMMARY
                PASSED=false
              fi
            else
              echo "❌ $(basename $file) missing _meta['com.mcp-ignite.governance/v1']" >> $GITHUB_STEP_SUMMARY
              PASSED=false
            fi
          done
          echo "META_PASSED=$PASSED" >> $GITHUB_OUTPUT

      - name: Security baseline checks
        id: security-check
        run: |
          echo "## Security Baseline" >> $GITHUB_STEP_SUMMARY
          PASSED=true
          for file in registry/pending/*.json; do
            [ -f "$file" ] || continue
            META='._meta["com.mcp-ignite.governance/v1"]'
            baseline=$(jq -r "$META.security_review.baseline_met"        "$file")
            compliance=$(jq -r "$META.security_review.compliance_verified" "$file")
            expressroute=$(jq -r "$META.network_requirements.expressroute_compatible" "$file")

            [ "$baseline"     = "true" ] || { echo "❌ baseline_met != true";           PASSED=false; }
            [ "$compliance"   = "true" ] || echo "⚠️ compliance_verified != true"
            [ "$expressroute" = "true" ] || { echo "❌ expressroute_compatible != true"; PASSED=false; }
          done
          echo "SECURITY_PASSED=$PASSED" >> $GITHUB_OUTPUT

      - name: Duplicate check (against registry/approved)
        id: duplicate-check
        run: |
          DUP=false
          for file in registry/pending/*.json; do
            [ -f "$file" ] || continue
            name=$(jq -r '.name'    "$file")
            ver=$(jq  -r '.version' "$file")
            if ls registry/approved/ 2>/dev/null | grep -q .; then
              for approved in registry/approved/*.json; do
                a_name=$(jq -r '.name'    "$approved")
                a_ver=$(jq  -r '.version' "$approved")
                if [ "$name" = "$a_name" ] && [ "$ver" = "$a_ver" ]; then
                  echo "❌ duplicate: $name@$ver already approved"
                  DUP=true
                fi
              done
            fi
          done
          echo "DUPLICATE_FOUND=$DUP" >> $GITHUB_OUTPUT

      - name: Post PR report
        if: always()
        uses: actions/github-script@v7
        with:
          github-token: ${{ steps.app-token.outputs.token }}
          script: |
            const schema   = '${{ steps.schema-validation.outputs.VALIDATION_PASSED }}' === 'true';
            const meta     = '${{ steps.meta-validation.outputs.META_PASSED }}'          === 'true';
            const security = '${{ steps.security-check.outputs.SECURITY_PASSED }}'       === 'true';
            const noDup    = '${{ steps.duplicate-check.outputs.DUPLICATE_FOUND }}'      === 'false';
            const ok = schema && meta && security && noDup;
            const body = [
              '## 🤖 Automated Validation Report',
              '',
              '| Check | Status |',
              '|-------|--------|',
              `| Official MCP schema (2025-12-11) | ${schema   ? '✅' : '❌'} |`,
              `| Governance _meta extension      | ${meta     ? '✅' : '❌'} |`,
              `| Security baseline               | ${security ? '✅' : '❌'} |`,
              `| Duplicate check                 | ${noDup    ? '✅' : '❌'} |`,
              `| **Overall**                     | **${ok ? '✅ PASSED' : '❌ FAILED'}** |`,
              '',
              ok
                ? '### Next steps\n1. Assign: @frank @sean\n2. Complete security checklist.\n3. On approval, PR merges and the server.json moves `pending/` → `approved/`.'
                : '### Issues found\nSee Actions logs. Fix and push to resubmit.',
              '',
              `*MCP-Registry-Manager · Run ${context.runId}*`,
            ].join('\n');
            const pr = context.payload.pull_request.number;
            await github.rest.issues.createComment({ ...context.repo, issue_number: pr, body });
            await github.rest.issues.addLabels({
              ...context.repo,
              issue_number: pr,
              labels: ok ? ['validation-passed', 'awaiting-security-review'] : ['validation-failed', 'needs-changes'],
            });

      - name: Fail if validation failed
        if: |
          steps.schema-validation.outputs.VALIDATION_PASSED != 'true' ||
          steps.meta-validation.outputs.META_PASSED        != 'true' ||
          steps.security-check.outputs.SECURITY_PASSED     != 'true' ||
          steps.duplicate-check.outputs.DUPLICATE_FOUND    != 'false'
        run: exit 1
```

### Step 9: CODEOWNERS

Same structure as v1 — ownership by path, security-director sign-off on everything that can ship to approved:

```
# MCP Trust Registry — ownership
/registry/pending/**     @frank @sean
/registry/approved/**    @frank @sean @grant
/policies/**             @frank @sean
/registry/schemas/**     @frank @grant
/.github/workflows/**    @grant @ryan-evans
/api/**                  @grant @ryan-evans
/docs/**                 @jim-ball @toby
/CODEOWNERS              @frank @sean
```

---

## Phase 3: Subregistry API Surface

To be consumable by any MCP client that speaks the official registry protocol, expose **three endpoints** in the upstream-compatible shape:

| Method & Path | Purpose |
|--|--|
| `GET /v0.1/servers` | List all approved servers (paginated per upstream spec) |
| `GET /v0.1/servers/{serverName}/versions/latest` | Latest version of a given server |
| `GET /v0.1/servers/{serverName}/versions/{version}` | Specific version |

The response body for each is the `server.json` shape already stored in `registry/approved/`, lightly wrapped per the OpenAPI spec (see the `openapi.yaml` reference in §[References](#references)).

### Step 10: Build & publish the API snapshot

For the pilot, serve the API statically from GitHub Pages or an Azure blob fronted by the VNet. A `publish-api-snapshot.yml` workflow on push-to-main:

1. Reads every `registry/approved/*.json`.
2. Generates `api/v0.1/servers.json` (list) and per-server/version files under `api/v0.1/servers/<name>/versions/<version>.json`.
3. Writes a `latest` pointer per server.
4. Commits the `api/` tree (or uploads it to the hosting target) so clients can resolve URLs like
   `https://mcp-registry.mcp-ignite.internal/v0.1/servers/com.mcp-ignite/test-filesystem-reader/versions/latest`.

### Step 11: Namespace ownership (DNS verification)

Entries named under `com.mcp-ignite/…` prove ownership via DNS. This matches how `mcp-publisher login dns` authenticates against the upstream registry. Add a TXT record on `mcp-ignite.com`:

```
_mcp-publisher.mcp-ignite.com  TXT  "v=mcp1; key=<public-key-fingerprint>"
```

This enables future federation: the same verified namespace can publish upstream without collision.

---

## Phase 4: Test & Validate

### Step 12: Create the test submission

Add `registry/pending/com.mcp-ignite.test-filesystem-reader.json` with the content shown in Step 5, commit on a feature branch, open a PR. The workflow runs all four checks (official schema, governance `_meta`, security baseline, duplicates) and posts the consolidated report.

```bash
git checkout -b test/first-server-submission
# ... add file ...
git add registry/pending/com.mcp-ignite.test-filesystem-reader.json
git commit -m "Submit test-filesystem-reader v1.0.0"
git push -u origin test/first-server-submission

gh pr create \
  --title "Test: First MCP server submission (official schema)" \
  --body "Validates the v2 workflow against the official 2025-12-11 server.json schema." \
  --reviewer frank,sean \
  --label "test,awaiting-review"
```

### Step 13: Monitor

```bash
gh run list --workflow=validate-submission.yml --limit 5
gh run view <RUN_ID> --log
```

Verify in the run logs:
- Token generated via `create-github-app-token@v3` with `client-id` input (no App-ID fallback).
- Schema fetched from `static.modelcontextprotocol.io/schemas/2025-12-11/…`.
- `_meta` governance block validated.
- No PAT present anywhere.

### Step 14: Results document

`EXPERIMENT-RESULTS.md` from v1 carries forward — update the header to note v2 alignment, and add:

- **Schema conformance:** `server.json` validates against `2025-12-11` official schema.
- **API conformance:** `GET /v0.1/servers` returns upstream-shaped payload.
- **Auth modernization:** `create-github-app-token@v3` with `client-id`; private key in Key Vault, used via Octokit sign-only.
- **Outstanding:** federation with upstream (deferred until DNS namespace signed off by Frank), self-hosted runners in Azure VNet (coordinate with Grant).

---

## Security Callouts (2026 update)

1. **Never use PATs.** GitHub Apps with installation tokens only.
2. **Private keys live in Azure Key Vault.** Prefer **remote JWT signing** (Octokit custom `signJwt`) so the key never leaves the vault. Rotate annually.
3. **Installation tokens last 1 hour.** `create-github-app-token@v3` handles regeneration; for long-running jobs, re-issue.
4. **Webhook secrets: rotate.** GitHub's Sept 2025 – Jan 2026 header-exposure incident affected any active webhook secret in that window. Rotate before this app handles production traffic.
5. **GitHub API deprecations landing in 2026:**
   - Query-parameter auth (`?access_token=…`) removed — use HTTP Basic.
   - Authorizations API (OAuth authorization endpoints) fully sunset.
   - Organization API fields `advanced_security_enabled_for_new_repositories` and `dependabot_alerts_enabled_for_new_repositories` removed **April 21, 2026** — migrate to the Code Security Configurations API (this lands the day after this doc is revised, so plan to ship before then).
   - **2FA mandatory May 2, 2026** for all accounts; confirm bot/service accounts are compliant.
6. **OIDC where possible.** Actions → cloud (Azure/AWS/GCP) should use OIDC, not stored credentials. As of April 2026 OIDC is also available for **Dependabot and code scanning** against private registries — adopt instead of long-lived credentials.
7. **Action version pinning.** Pin `create-github-app-token@v3` (or a SHA); v2 is end-of-line.
8. **Self-hosted runners for ExpressRoute compliance.** GitHub-hosted runners egress to the public internet. Moving the registry workflow onto self-hosted runners inside the Azure VNet is the path to full ExpressRoute conformance.
9. **Baseline security criteria enforced in CI.** The validation workflow fails any PR missing `baseline_met: true` or `expressroute_compatible: true` in the governance `_meta`.
10. **Conditional Access.** GitHub Apps respect org-level CA policies; no exemptions without Frank's written approval.

---

## Migration Notes from v1

If you have a v1 registry already in flight:

| v1 location | v2 location |
|--|--|
| top-level `author`, `security_review`, `capabilities`, `network_requirements`, `authentication`, `data_handling`, `deployment`, `maintenance` | `_meta["com.mcp-ignite.governance/v1"]` |
| `name` as `[a-z0-9-]+` | `name` as reverse-DNS (`com.mcp-ignite/<slug>` or `io.github.<user>/<slug>`) |
| no `$schema` | `$schema: https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json` |
| no `packages` / `remotes` | required: at least one `packages[]` entry (or `remotes[]`) per official schema |
| `repository` as string URL | `repository: { url, source }` object |
| `actions/create-github-app-token@v2` with `app-id` | `@v3` with `client-id` |
| Private key in GitHub Secrets only | Key Vault with Octokit remote-signing (prod); Secrets fallback only in dev |
| Custom validation-only workflow | Validation **+** API snapshot publisher, conforming to `/v0.1/servers` subregistry contract |

A one-shot migration script (`scripts/migrate-v1-to-v2.ts`) should:
1. Read each v1 entry.
2. Move custom fields into `_meta["com.mcp-ignite.governance/v1"]`.
3. Rewrite `name` to `com.mcp-ignite/<old-name>`.
4. Wrap `repository` as `{ url, source: "github" }`.
5. Emit a stub `packages[]` entry (marked `TODO` if we don't know the actual package yet — the schema requires something).
6. Add the `$schema` reference.

---

## References

### Official MCP Registry

- Registry (public): https://registry.modelcontextprotocol.io/
- Registry docs: https://registry.modelcontextprotocol.io/docs
- `server.json` spec: https://github.com/modelcontextprotocol/registry/blob/main/docs/reference/server-json/generic-server-json.md
- `server.schema.json` (pinned): https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json
- Schema changelog: https://github.com/modelcontextprotocol/registry/blob/main/docs/reference/server-json/CHANGELOG.md
- OpenAPI (subregistry contract): https://github.com/modelcontextprotocol/registry/blob/main/docs/reference/api/openapi.yaml
- Moderation policy: https://modelcontextprotocol.io/registry/moderation-policy
- 2026 roadmap: https://blog.modelcontextprotocol.io/posts/2026-mcp-roadmap/
- Publishing quickstart: https://modelcontextprotocol.io/registry/quickstart

### GitHub Apps & Actions

- GitHub Apps authentication: https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/about-authentication-with-a-github-app
- Managing private keys: https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/managing-private-keys-for-github-apps
- Installation access tokens: https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-an-installation-access-token-for-a-github-app
- `actions/create-github-app-token`: https://github.com/actions/create-github-app-token
- Enterprise-level GitHub Apps (July 2025): https://github.blog/changelog/2025-07-01-enterprise-level-access-for-github-apps-and-installation-automation-apis/
- OIDC concepts: https://docs.github.com/en/actions/concepts/security/openid-connect
- OIDC for Dependabot & code scanning (April 2026): https://github.blog/changelog/2026-04-14-oidc-support-for-dependabot-and-code-scanning/
- Webhook signature validation: https://docs.github.com/en/webhooks/using-webhooks/validating-webhook-deliveries
- REST API breaking changes (2026-03-10): https://docs.github.com/en/rest/about-the-rest-api/breaking-changes?apiVersion=2026-03-10

### Copilot / MCP client configuration

- Configure an MCP Registry for your organization (GitHub Copilot): https://docs.github.com/en/copilot/how-tos/administer-copilot/manage-mcp-usage/configure-mcp-registry

### Security & Compliance (carried over from v1)

- NIST Cybersecurity Framework
- OWASP Top 10
- CIS Controls
- Financial Services Sector Cybersecurity Profile
- Internal Security Standards Document (ISD-2024-001)

---

## Appendix: Quick reference

### Canonical server.json fields (2025-12-11 schema)

| Field | Type | Required | Notes |
|--|--|--|--|
| `$schema` | string | recommended | `https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json` |
| `name` | string | yes | reverse-DNS: `io.github.<user>/<slug>` or `com.<company>/<slug>` |
| `title` | string | no | display name |
| `description` | string | yes |  |
| `version` | string | yes | semver |
| `websiteUrl` | string | no |  |
| `repository` | object | no | `{ url, source, subfolder?, id? }` |
| `packages` | array | one of packages/remotes | per-registry entries (npm, PyPI, NuGet, OCI, MCPB, GH releases) |
| `remotes` | array | one of packages/remotes | remote endpoints; URL template vars supported since 2025-12-11 |
| `_meta` | object | no | reverse-DNS-namespaced custom extensions |

### Publisher CLI (upstream-facing)

```bash
# Install
npm install -g @modelcontextprotocol/publisher

# Authenticate (pick one)
mcp-publisher login github           # OAuth — interactive
mcp-publisher login github-oidc      # GitHub Actions (requires id-token: write)
mcp-publisher login dns --domain mcp-ignite.com --private-key <key>

# Publish
mcp-publisher init     # generate server.json template
mcp-publisher publish  # upload metadata to upstream (only runs when federation is approved)
```

### Key Vault secret operations

```bash
az keyvault key import   --vault-name mcp-ignite-vault --name github-app-signing-key --pem-file key.pem --protection software
az keyvault secret set   --vault-name mcp-ignite-vault --name github-app-client-id   --value "Iv23li..."
az keyvault key list     --vault-name mcp-ignite-vault
```

---

## Support & Contacts

- **Security:** Frank (Director)
- **Infrastructure:** Grant (Lead)
- **Network/ExpressRoute:** Keith
- **Project:** Toby (Lead)
- **Technical:** Jim Ball, Ryan Evans

### External

- MCP Registry GitHub: https://github.com/modelcontextprotocol/registry
- AAIF / Linux Foundation MCP governance: https://modelcontextprotocol.io/
- GitHub Enterprise Support

---

**Document Status:** Ready for review
**Version:** 2.0
**Last Updated:** April 20, 2026
**Next Review:** After v2 pilot sign-off from Frank & Sean

---

*Part of the MCP-Ignite project. Changes in v2.0 align the registry with the official MCP Registry v0.1 subregistry contract (AAIF / Linux Foundation), the 2025-12-11 server.schema.json, and the 2026 GitHub Apps/Actions posture.*
