# Artifact 4 — Compliance Risk Summary: GitHub Copilot Business (EMU) for US Financial Services

## Top 5 Data Residency and Privacy Risks

### 1. Multi-cloud sub-processor sprawl defeats single-vendor security assumptions

Selecting a non-default model (Claude or Gemini) routes developer code prompts outside the Microsoft Azure compliance boundary entirely. Claude models may traverse three separate sub-processors simultaneously — Anthropic PBC, AWS Bedrock, and GCP Vertex AI — with cross-region inference across multiple US data centers. Gemini routes to GCP, whose sub-processor listing includes processing locations in Belgium and Singapore alongside the United States. Organizations whose board-approved technology risk frameworks, vendor risk assessments, or regulatory filings describe Copilot as a "Microsoft/Azure" service are making a materially inaccurate representation if non-OpenAI models are enabled. The total sub-processor count for AI inference alone is seven entities, each with distinct data handling commitments and contractual terms that the customer cannot directly negotiate — GitHub holds all provider agreements, and the customer's only contractual relationship is with GitHub via the DPA.

**Regulatory frameworks implicated**: GLBA Safeguards Rule (16 CFR Part 314) requires financial institutions to oversee service providers that access customer information. NYDFS 23 NYCRR 500 §500.11 requires TPSP policies addressing each provider's cybersecurity practices. NAIC Model Law #668 requires due diligence for third-party service providers handling NPI. The cascading sub-processor model makes it operationally difficult to satisfy these requirements for each downstream provider, since the customer has no direct contractual access, audit rights, or incident notification relationship with OpenAI, Anthropic, AWS, Google, or Fireworks AI.

### 2. Anthropic's ZDR gap for preview features creates a moving compliance target

Anthropic's zero data retention agreement with GitHub explicitly excludes preview and beta features. When GitHub launches new Claude model variants (which has happened frequently — Claude 3.5, 3.7, Haiku, Sonnet 4, 4.5, 4.6, Opus 4.5, 4.6 have all appeared in rapid succession), they may initially enter as previews before reaching GA. During the preview period, Anthropic may retain prompt data per its own policies, which include potential use for safety monitoring and model evaluation. GitHub states it will update its documentation as ZDR coverage changes, but compliance teams would need to monitor this page continuously to maintain an accurate data retention posture. For organizations subject to examination by NYDFS or state insurance regulators, the inability to provide a definitive retention commitment for all data flows at any given point in time is a documentation risk during regulatory examinations.

### 3. No native NPI detection or prompt-level DLP creates a NYDFS compliance gap

The NYDFS October 2024 Industry Letter on AI Cybersecurity Risks specifically recommends that covered entities implement monitoring to detect unusual query behaviors that might indicate attempts to extract NPI, and blocking queries that might expose NPI. GitHub Copilot Business provides no native capability for this. Content exclusion policies prevent Copilot from reading specified files, but they cannot prevent a developer from manually pasting customer data, database query results, or other NPI into a Copilot Chat prompt. There is no prompt-level content inspection, no regex or pattern-matching filter for NPI formats (SSNs, account numbers, policy numbers), and no integration point for enterprise DLP tools within the Copilot data path. Organizations would need to implement supplemental tooling — either at the network proxy layer, the IDE extension layer, or via a third-party Copilot security product — to address this gap. The cost and operational complexity of such tooling should be factored into deployment planning.

### 4. Documented critical vulnerabilities demonstrate active threat surface

The CamoLeak vulnerability (CVSS 9.6, June 2025, fixed August 2025) demonstrated that hidden prompt injection via pull request comments could silently exfiltrate secrets and source code from private repositories. The RoguePilot attack showed that crafted GitHub Issues could achieve repository takeover via GITHUB_TOKEN exfiltration. GitGuardian's quantitative research found that Copilot-using repositories exhibit 40% higher secret leakage rates than traditional development. These are not theoretical risks — they represent demonstrated attack vectors against production Copilot deployments. For financial institutions subject to SEC Regulation S-P, FINRA Rules 3110 and 3120 (supervision requirements), and NYDFS incident reporting obligations under §500.17, the question is not whether Copilot introduces risk but whether existing controls adequately detect and respond to Copilot-specific attack patterns. Most enterprise SIEM and DLP configurations do not monitor for prompt injection or AI-mediated exfiltration.

### 5. Absence of FedRAMP Moderate authorization may be a procurement blocker

GitHub Enterprise Cloud currently holds only FedRAMP Tailored LI-SaaS authorization. FedRAMP Moderate — the baseline required by many federal financial regulators and commonly adopted as a procurement threshold by large financial institutions even where not strictly required — has been announced as a goal but carries no confirmed timeline. For organizations whose procurement policies require FedRAMP Moderate or equivalent for any service processing sensitive data, this remains a blocking gap. The SOC 2 Type II and ISO 27001 certifications now in scope for Copilot are meaningful but are not substitutes for the full NIST 800-53 control baseline that FedRAMP Moderate requires.

## Recommended Due Diligence Actions

**Immediate (pre-deployment)**:
- Restrict Copilot models to OpenAI/Microsoft fine-tuned only at the enterprise policy level, confining all data to the Azure compliance boundary
- Configure content exclusions for all repositories containing NPI, customer data schemas, API keys, connection strings, and test fixtures with real data
- Request GitHub's SOC 2 Type II report via Enterprise Cloud compliance settings and review for controls relevant to AI inference data handling
- Review the GitHub DPA, GitHub Generative AI Services Terms (effective March 5, 2026), and the complete sub-processor list; document each AI sub-processor in the enterprise TPRM program

**Operational (ongoing)**:
- Deploy supplemental prompt-monitoring/DLP tooling to satisfy NYDFS NPI detection expectations
- Establish a monitoring process for GitHub's sub-processor list (30-day advance notice for additions); create a rapid-assessment workflow for new AI providers
- Train developers on NPI avoidance in Copilot prompts, as specifically recommended by NYDFS
- Enable duplicate detection filter in "Block" mode (required for Microsoft's IP indemnification under the Copilot Copyright Commitment)
- Disable Copilot Free tier organization-wide to prevent developers from using less-protected individual plans

**Governance (periodic)**:
- Include Copilot in the enterprise's annual AI risk assessment under NYDFS 23 NYCRR 500
- Document the multi-provider architecture in board-level technology risk reporting
- Reassess when GitHub enables new model providers or features (monitor github.blog/changelog and github.com/customer-terms/updates)

## Open Questions Requiring Direct Engagement with GitHub/Microsoft

The following questions could not be answered from publicly available sources and would require direct engagement with GitHub Enterprise Sales, Microsoft Account Management, or formal vendor security questionnaire responses:

1. **Which specific Azure regions process Copilot inference?** The documentation says "nearest data centre" but does not enumerate regions. Understanding the exact US regions is relevant for data residency documentation.

2. **Does any OpenAI model inference for Copilot run on non-Azure infrastructure?** OpenAI's inference footprint now spans Oracle Cloud, CoreWeave, and emerging Stargate facilities. Whether Copilot traffic touches these is undocumented.

3. **What is the exact duration of Anthropic prompt caching?** GitHub uses prompt caching across all three Anthropic hosting providers. The cache lifetime is not documented and may be relevant for strict retention calculations.

4. **Can retention periods be customized via enterprise agreement?** Public documentation shows fixed, non-configurable retention. Custom terms may be available for large enterprise customers but are not publicly documented.

5. **Does OpenAI personnel access to telemetry data (documented in the Copilot Business Privacy Statement) extend to Anthropic and Google personnel?** The privacy statement references OpenAI specifically but is silent on other providers.

6. **What is GitHub's incident notification SLA for AI-specific security events?** The DPA covers breach notification generally, but Copilot-specific incidents (prompt injection, model-mediated exfiltration) may warrant distinct notification commitments.

7. **Is Fireworks AI currently processing any Copilot Business traffic?** Listed as a sub-processor but with minimal public documentation about its role. Financial services risk assessments require clarity on whether this provider is active or dormant.
