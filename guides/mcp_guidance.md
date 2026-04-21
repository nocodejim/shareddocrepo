# The MCP Implementation Playbook: A Capability-Driven Approach

**Document Version:** 2.0
**Original:** November 2025 (v1.0)
**Revised:** April 20, 2026 — aligned with the official MCP Registry (AAIF / Linux Foundation), 2025-12-11 `server.json` schema, and 2026 MCP identity patterns.

This model is not about how long it takes, but about what must be true before you can safely proceed to the next step. It's a series of gates to pass through.

---

## What Changed in v2.0

MCP moved from a single-vendor project to a neutral-foundation standard in December 2025 (donated to the Agentic AI Foundation under the Linux Foundation). An official registry, a frozen subregistry API (v0.1), and a canonical `server.json` schema now exist. The playbook's gates are unchanged in spirit, but each gate now calls out the **public standard** it should conform to, so an MVP built at Gate 1 isn't rewritten at Gate 2 or 3. Gate 0 adds a fifth commitment (conformance), Gate 3 updates identity to match current practice (GitHub OIDC, DNS verification, claim-based authorization, OAuth 2.1 + PKCE), and MCP-specific threats (tool poisoning, prompt injection via tool descriptions, tool squatting) are now named explicitly.

---

## Gate 0: The Unwavering Commitment Check

This is the foundational go/no-go decision. Do not pass this gate until leadership and key stakeholders can answer an unequivocal "YES" to these five questions. This isn't a project, it's a statement of organizational policy.

### Critical Questions

**On Governance:** Do we commit to establishing a formal vetting process and a single governance council as the only authorized body for approving AI data sources, starting now?

**On Operational Friction:** Do we accept that mandatory Human-in-the-Loop (HITL) controls for high-risk actions are a non-negotiable cost of security, and can we identify the business processes that must accommodate this friction?

**On Architecture:** Do we commit the technical resources to enforce a zero-trust, gateway-centric architecture — proxy-mediated communication, no direct model-to-data-source paths, and no bypass of existing secure network controls?

**On Trust:** Do we agree that the principle of a private trust registry is mandatory, and that any un-registered server communicating with our models will be treated as a security incident?

**On Conformance (new in v2):** Do we commit to building our private trust registry as a **conforming subregistry of the official MCP Registry** (AAIF / Linux Foundation) — same `server.json` schema, same v0.1 API shape — so our investment is portable and our clients interoperate with the broader ecosystem by default?

**If the answer to any of these is "no" or "maybe," the initiative must halt. Proceeding creates unacceptable risk or unacceptable rework.**

---

## Gate 1: Minimum Viable Product (MVP) — The "Golden Path" Pilot

The goal is to get a single, high-value, low-risk pilot running securely in the shortest time possible. This is about proving the pattern, not building the final enterprise system.

### Action: Define the Governance MVP

**Prescription:** The governance council is formed. They create a one-page "Pilot Vetting Checklist" on a wiki. The process is manual. Approval is an email. This is your V1 governance.

### Action: Implement the Trust Registry MVP — standards-conformant from day one

**Prescription:** Create a single, securely stored configuration file (or locked-down database table) containing exactly **one** entry: the pilot MCP server.

Even at one entry, structure it as a valid `server.json` against the official 2025-12-11 schema, with a reverse-DNS `name` (e.g., `com.yourcompany/pilot-server`). Store any internal-only fields (ExpressRoute compatibility, security review, data classification) under the schema's `_meta` slot with a reverse-DNS key you own. The API Gateway is hardcoded to check against this single entry. This keeps the MVP one file while guaranteeing that Gate 2's API surface and Gate 3's federation options have zero migration cost.

### Action: Implement the HITL MVP

**Prescription:** For the pilot's high-risk actions, the "interception" is a call to a simple serverless function. This function sends a formatted message to a specific Slack channel or secure email group with "Approve" and "Deny" buttons. Clicking a button triggers another function to complete or discard the action. HITL runs at the **tool-call layer** (per-invocation, not per-session), so the gate applies to each discrete action the model asks the server to perform. This is your V1 HITL workflow — auditable and secure enough for a pilot.

### Action: Deploy the Architecture MVP

**Prescription:** Use Infrastructure as Code (Terraform, CloudFormation, Bicep) to deploy the pilot architecture. A single API Gateway acting as an MCP-aware proxy, a single isolated VPC/VNet segment for the one MCP server, and strict firewall rules allowing communication only between the gateway and that server. This template is the "golden path." No direct client-to-server paths — all traffic mediates through the gateway so tool-level authorization, rate limits, and audit can be enforced centrally.

### Outcome of Gate 1

A functional, secure, end-to-end MCP pilot is live. You have proven the security model works in practice, delivered business value, and — critically — the pilot's registry entry already conforms to the public standard, so no rewrite is owed at Gate 2.

---

## Gate 2: Templatize & Scale — The "Factory"

The goal is to take the successful "golden path" pilot and build the tools to replicate it rapidly and reliably. This is where you build for speed.

### Action: Automate the Trust Registry — expose the subregistry API

**Prescription:** Build an internal API around the V1 registry store that exposes the **official MCP Registry v0.1 subregistry contract**:

- `GET /v0.1/servers`
- `GET /v0.1/servers/{serverName}/versions/latest`
- `GET /v0.1/servers/{serverName}/versions/{version}`

Same response shape as the upstream registry. The payoff: any MCP client that already talks to the public registry (Copilot, Claude, custom clients) works against our registry with no client-side adapter. The governance council (and automated processes) use write endpoints to add/remove entries; the API Gateway reads via the same v0.1 endpoints.

### Action: Productize the Architecture

**Prescription:** Convert the MVP IaC scripts into a self-service module or template. A new team wanting to deploy an MCP server runs one command to get their own secure, pre-configured network segment and server stub that automatically registers against the central registry and connects through the central gateway.

### Action: Formalize the HITL System

**Prescription:** Replace the Slack/email MVP with a dedicated web dashboard showing the queue of pending actions and a formal audit trail of all approvals and denials. Persist tool-call arguments alongside the decision record so a reviewer can see exactly what the model asked to do, not just that something was approved.

### Action: Streamline Governance

**Prescription:** Move the vetting checklist into an automated workflow tool (Jira, ServiceNow). Submitting a request for a new MCP server is a ticket following a defined approval chain. Wire the approval state into the registry write API so "approved in the ticket system" and "present in `/v0.1/servers`" cannot drift.

### Outcome of Gate 2

You have a "factory" process. Onboarding a new, secure MCP server is no longer a bespoke project but a standardized, fast, and repeatable process — and the registry speaks the same protocol as the public ecosystem.

---

## Gate 3: Harden & Optimize — The "Fortress"

Your MCP ecosystem is now growing rapidly. The focus shifts from enabling speed to ensuring enterprise-grade resilience and proactive security.

### Action: Enhance Network Intelligence

**Prescription:** Implement advanced monitoring and alerting at the API Gateway. Automatically flag anomalous traffic patterns — a server suddenly requesting 1000× more data, new tool names appearing in traffic that aren't in the registry, cross-server call chains that don't match declared capabilities.

### Action: Mature the Trust Registry — adopt 2026 identity patterns

**Prescription:** Evolve from registry-as-allowlist to **cryptographically-verified server identity** using the patterns the public ecosystem has converged on:

- **GitHub OIDC** for publishers whose servers live in GitHub — no long-lived secrets; short-lived tokens minted per workflow run, scoped to a specific repository and namespace.
- **DNS verification** for custom-domain namespaces (e.g., `com.yourcompany/*`) — a TXT record proves ownership and is the same mechanism the upstream registry uses for `mcp-publisher login dns`.
- **Claim-based authorization per entry** — gate access to individual registry entries on JWT claims (team, environment, risk tier), not just "is the server in the registry." This is the Q1 2026 pattern emerging from private-subregistry implementations.
- **OAuth 2.1 + PKCE** for user-facing MCP authentication flows; no implicit flow, no bare client secrets.
- **Short-lived credentials end-to-end** — GitHub App installation tokens (1h), gateway-issued per-session tokens, Key Vault remote signing so private keys never leave the vault.

### Action: Defend Against MCP-Specific Threats

**Prescription:** Name the threats explicitly so detections and reviews can target them:

- **Tool poisoning** — a registered server updates its tool set to include malicious tools. Detection: diff declared `capabilities.tools` against observed tool names; alert on drift. Prevention: treat capability changes as a re-review trigger, not a silent update.
- **Prompt injection via tool descriptions** — attacker-controlled text in a tool's `description` field steers the model. Prevention: sanitize descriptions at registry write time; scan for instruction-like patterns; require human review for any description containing imperatives.
- **Tool squatting / namespace collision** — an internal-looking name (`com.ourcompany/billing`) registered without DNS proof. Prevention: DNS verification (above) is mandatory for `com.yourcompany/*` namespaces; reject submissions that can't prove it.
- **Confused-deputy at the gateway** — the gateway holds broad credentials and is asked to act on behalf of a less-privileged caller. Prevention: tool-level authorization; gateway scopes its downstream calls to the caller's identity, not its own.

### Action: Implement Proactive Governance

**Prescription:** Run automated checks to ensure all deployed MCP servers still comply with the original vetting criteria:

- Patch levels and dependency CVEs (CVSS ≥ 7.0 auto-flag).
- Owner still employed and still in the responsible team.
- Annual security re-review not expired (enforced via `_meta.security_review.expiration_date`).
- `_meta.network_requirements.expressroute_compatible` still true for the current network topology.

Flag non-compliant servers for review or automatic revocation (set `status: "deleted"` in the registry; the entry stays queryable for audit).

### Outcome of Gate 3

The registry is no longer just an allowlist — it's the source of truth for **who** each server is, **what** it's allowed to do, and **whether** its compliance is current. Every claim is cryptographically backed, every threat class has a named defender, and posture degrades loudly rather than silently.

---

## Summary

This prescriptive, capability-gated approach ensures security is baked in at every stage without imposing arbitrary delays. You move as fast as you can prove you are safe — and in v2, "safe" explicitly includes "interoperable with the standards the rest of the ecosystem is converging on."

---

## References

**Official MCP Registry (AAIF / Linux Foundation):**
- Registry: https://registry.modelcontextprotocol.io/
- `server.json` schema (2025-12-11): https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json
- Subregistry OpenAPI (v0.1): https://github.com/modelcontextprotocol/registry/blob/main/docs/reference/api/openapi.yaml
- Moderation policy: https://modelcontextprotocol.io/registry/moderation-policy
- 2026 roadmap: https://blog.modelcontextprotocol.io/posts/2026-mcp-roadmap/

**Identity & Auth patterns:**
- GitHub Apps authentication: https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/about-authentication-with-a-github-app
- GitHub Actions OIDC: https://docs.github.com/en/actions/concepts/security/openid-connect
- OAuth 2.1 draft: https://datatracker.ietf.org/doc/draft-ietf-oauth-v2-1/

**Enterprise & governance context:**
- GitHub Copilot — configure an MCP registry for your organization: https://docs.github.com/en/copilot/how-tos/administer-copilot/manage-mcp-usage/configure-mcp-registry
- Enterprise-grade MCP security (arXiv): https://arxiv.org/html/2504.08623v2
- Windows MCP security posture: https://blogs.windows.com/windowsexperience/2025/05/19/securing-the-model-context-protocol-building-a-safer-agentic-future-on-windows/

**Companion document:**
- `guides/mcp/github_app_stepbystep.md` — concrete implementation guide for building a subregistry aligned with this playbook.

---

**Document Version:** 2.0
**Last Updated:** April 20, 2026
**Next Review:** After the upstream registry exits preview or the next major schema revision, whichever comes first.
