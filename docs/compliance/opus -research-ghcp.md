# GitHub Copilot Business in EMU: Infrastructure, data routing, and compliance risk for financial services

**GitHub Copilot Business routes developer code to at least six distinct AI sub-processors across three cloud ecosystems — Azure, AWS, and GCP — creating a multi-layered data custody chain that financial services organizations must evaluate individually under GLBA, NYDFS 23 NYCRR 500, and state insurance data security laws.** This complexity is not immediately apparent from marketing materials, which emphasize Microsoft's security posture while obscuring the reality that selecting a Claude or Gemini model sends prompts entirely outside the Azure compliance boundary. For an EMU-deployed organization, the identity and access controls are strong, but the AI inference infrastructure is identical to non-EMU deployments — EMU adds no additional data isolation at the model layer. Organizations subject to NYDFS oversight face a particularly demanding posture: the October 2024 industry letter effectively requires AI-specific risk assessments, third-party service provider due diligence for each sub-processor, and NPI monitoring capabilities that GitHub does not natively provide.

---

## 1. OpenAI and Azure: a dual-path architecture GitHub does not fully explain

GitHub's primary Copilot infrastructure runs within **Microsoft Azure tenants owned by GitHub**. The proxy layer — accessible via `copilot-proxy.githubusercontent.com` and `*.business.githubcopilot.com` — mediates all traffic between developer IDEs and model endpoints. Users never connect directly to any model provider's API.

However, the model hosting documentation reveals a critical architectural distinction. **OpenAI models fine-tuned by Microsoft** (Raptor mini, Goldeneye) are deployed on a *"GitHub managed Azure OpenAI tenant"* — a dedicated instance within Azure. By contrast, **standard OpenAI models** (GPT-4.1, GPT-5.x family, Codex variants) are described as *"hosted by OpenAI and GitHub's Azure infrastructure"* — phrasing that deliberately encompasses both GitHub's Azure tenant and OpenAI's own endpoints.

The sub-processor list confirms this dual-path architecture. **OpenAI is listed as a separate sub-processor from Microsoft (Azure)**, both providing "AI Inference and AI Services" with processing location listed as "United States." If all inference ran exclusively through GitHub's Azure OpenAI tenant, listing OpenAI as an independent sub-processor would be unnecessary — Microsoft (Azure) would suffice. The implication is that some OpenAI model traffic routes to OpenAI's own API infrastructure, which as of 2025 spans Azure, Oracle Cloud, AWS, and CoreWeave, with proprietary Stargate data centers under construction.

**Specific Azure regions are not disclosed.** GitHub confirms that Copilot requests are *"processed by the nearest data centre"* based on proximity, but this routing is capacity-based and not configurable. Even GitHub Enterprise Cloud with Data Residency (GHE.com) carries an explicit warning: organizations should *"carefully weigh the considerations of using GitHub Copilot in a data resident deployment, which may include certain data not stored in-region."*

The contractual chain is documented: **GitHub acts as data processor** (or subprocessor to enterprise customers who are themselves processors) under the GitHub Data Protection Agreement. GitHub maintains a **zero data retention (ZDR) agreement with OpenAI**, and OpenAI commits that it *"does not train models on customer business data."* The GitHub DPA — substantially rewritten in September 2023 and updated via new "GitHub Generative AI Services Terms" effective March 5, 2026 — covers Copilot Business explicitly. Organizations purchasing through Microsoft are governed by the Microsoft Product Terms for GitHub Offerings rather than the GitHub General Terms.

**Source classification**: Model hosting page (docs.github.com/en/copilot/reference/ai-models/model-hosting) — Official Documentation. Sub-processor list (docs.github.com/en/site-policy/privacy-policies/github-subprocessors) — DPA/Legal. GitHub DPA (github.com/customer-terms/github-data-protection-agreement) — DPA/Legal. Copilot Business Privacy Statement (docs.github.com/en/site-policy/privacy-policies/github-copilot-business-privacy-statement) — DPA/Legal.

**Gap**: GitHub does not enumerate which Azure regions process Copilot inference, whether OpenAI's non-Azure infrastructure (Oracle, CoreWeave, emerging Stargate facilities) handles any Copilot traffic, or the exact boundary between "hosted by OpenAI" and "GitHub's Azure infrastructure."

---

## 2. Anthropic Claude endpoints leave the Azure boundary entirely

Claude models available in GitHub Copilot Business as of early 2026 include **Claude Haiku 4.5, Claude Sonnet 4 and 4.5, Claude Sonnet 4.6, Claude Opus 4.5, and Claude Opus 4.6** (the latter in preview). The multi-model capability launched at GitHub Universe in October 2024, with Claude 3.5 Sonnet entering public preview on November 1, 2024, and Claude 3.5 and 3.7 Sonnet reaching general availability on April 4, 2025.

**When a Copilot Business user selects any Claude model, their prompts and metadata leave the Microsoft/Azure ecosystem entirely.** Claude models are hosted across three providers simultaneously: Amazon Web Services (via Bedrock), Anthropic PBC (direct 1P API), and Google Cloud Platform (via Vertex AI). Anthropic's own announcement at launch specifically stated Claude *"runs on GitHub Copilot via Amazon Bedrock, leveraging Bedrock's cross-region inference"* — meaning traffic may route dynamically across multiple AWS commercial regions including us-east-1 (N. Virginia), us-west-2 (Oregon), and us-east-2 (Ohio).

The data protection posture differs from the OpenAI path in important ways:

- **GitHub maintains a ZDR agreement with Anthropic, but only for generally available features.** Beta and preview features — including tool search via the Messages API — are explicitly excluded. For those features, Anthropic may retain data per its own ZDR documentation. GitHub states it *"will update this page as ZDR coverage changes,"* making this a moving target for compliance teams.
- **Amazon Bedrock** provides its own commitment: *"Amazon Bedrock doesn't store or log your prompts and completions. Amazon Bedrock doesn't use your prompts and completions to train any AWS models and doesn't distribute them to third parties."*
- **Google Cloud** (for Claude models hosted on Vertex AI): *"Google commits to not training on GitHub data as part of their service terms."* GitHub is additionally exempt from prompt logging for abuse monitoring on GCP.
- GitHub uses **prompt caching** across all three Anthropic providers — a performance optimization that creates temporary data copies, distinct from deliberate retention but potentially relevant under strict compliance frameworks.

**Anthropic PBC is listed as an official sub-processor** on GitHub's sub-processor list (processing location: United States). Amazon Web Services and Google Cloud Platform are also listed. The sub-processor chain for a single Claude inference request could therefore span: Customer → GitHub (processor) → AWS Bedrock / Anthropic PBC / GCP (sub-processors), with cross-region inference potentially touching multiple US data centers.

**EMU admin controls**: Enterprise owners can disable Claude models enterprise-wide via Copilot settings. Per the November 2025 policy update, unconfigured model policies default to **Disabled**, meaning Claude models require affirmative enablement. This is the primary risk control available — organizations concerned about data leaving the Azure boundary can restrict users to OpenAI/Microsoft models only.

**Sources**: Model hosting page — Official Documentation. Anthropic launch announcement (anthropic.com/news/github-copilot) — Official Documentation. GitHub changelog entries for Claude GA (github.blog/changelog/2025-04-04) — Official Documentation. Anthropic data residency documentation (platform.claude.com/docs/en/build-with-claude/data-residency) — Official Documentation.

---

## 3. Google Gemini adds a third cloud ecosystem to the data path

Gemini models in Copilot Business include **Gemini 2.5 Pro (GA since August 2025), Gemini 3 Pro, Gemini 3 Flash, and Gemini 3.1 Pro** (the latter three in various preview stages). The integration began with Gemini 2.0 Flash entering public preview on February 5, 2025, and reaching GA on April 4, 2025.

All Gemini models are hosted exclusively on **Google Cloud Platform**. GitHub's model hosting page states: *"When using Gemini models, prompts and metadata are sent to GCP."* Google's Vertex AI Generative AI service operates across multiple US regions including us-central1 (Iowa), us-east1 (South Carolina), us-east4 (N. Virginia), and us-west1 (Oregon), though GitHub does not disclose which specific GCP regions serve Copilot traffic.

Google's data commitment for Copilot is documented: *"Gemini doesn't use your prompts, or its responses, as data to train its models."* GitHub is exempt from prompt logging for abuse monitoring on GCP. However, unlike OpenAI and Anthropic, **there is no explicit "zero data retention" term documented for Google** — the commitment focuses on no-training and no-logging rather than a formal ZDR agreement.

**Google Cloud Platform is listed as a sub-processor** with processing locations documented as **"United States, Belgium, Singapore."** The Belgium and Singapore locations are notable — while GitHub's US-based financial services customers likely receive inference from US regions, the sub-processor listing does not restrict GCP processing to the United States exclusively.

The sub-processor and DPA chain mirrors the Anthropic path: Customer → GitHub (governed by GitHub DPA) → Google Cloud Platform (sub-processor governed by GitHub-Google provider agreement). The same EMU admin model-level controls apply — Gemini must be explicitly enabled, and enterprise-level policies cascade to all organizations.

**Material compliance finding**: Enabling Gemini changes the data routing from Microsoft's Azure ecosystem to Google's GCP ecosystem. Organizations whose security architecture, vendor risk assessments, or board-approved technology risk frameworks assume all Copilot data remains within Microsoft infrastructure must reassess if Gemini models are enabled.

---

## 4. What data leaves the developer environment — tracing the full prompt lifecycle

### Prompt payload construction

When a developer triggers Copilot in their IDE, the extension assembles a prompt from multiple sources: **the current file content** (lines before and after the cursor), **neighboring and related files** in the project, **content from open editor tabs**, **repository URLs and file paths**, and all standard code artifacts including comments, docstrings, and import statements. GitHub's documentation confirms: *"GitHub Copilot can gather various elements to identify relevant context, including content in the file you are editing, neighboring or related files within a project, repository URLs, or file paths."* A proxy-side algorithm then optimizes the assembled context, *"respecting size limits and privacy considerations."*

For Copilot Chat, the payload additionally includes the chat prompt text, any highlighted code selection, conversation history, general workspace information (frameworks, languages, dependencies), and for Chat on GitHub.com, retrieved context from codebase semantic search and optionally Bing search results.

**Gap**: GitHub does not publicly disclose exact token window sizes or the maximum number of lines/files included in prompts. The VS Code extension documentation notes workspace indexes have file-count limits (~750 indexable files for auto-builds), but completion context windows are undocumented.

### Repository-level indexing

GitHub performs **automatic repository indexing** when Copilot Chat has repository context. The index is built from the default branch, shared across all users with repository access, and can cover unlimited repositories. Crucially, **retrieval happens on-platform before prompt construction** — relevant code snippets are retrieved from the index and assembled into the prompt, but the index itself is not transmitted to model endpoints. Repository content is therefore not stored by any third-party AI provider.

Content exclusion policies are respected at the index level: *"If a semantic code search index is created for a repository that is included in a content exclusion policy, data is filtered according to the policy before being passed to Copilot Chat."* VS Code also maintains a separate local workspace index for the `#codebase` semantic search tool, where *"parts of the index might be stored on your machine and parts might come from remote sources."*

### Telemetry and metadata

Beyond prompts, GitHub collects **User Engagement Data** for all plans: pseudonymous identifiers, accepted/dismissed suggestion events, error messages, system logs, and product usage metrics (latency, feature engagement). This data is retained for **24 months** and is *"required for the use of GitHub Copilot"* — it cannot be disabled. It is shared with Microsoft for service provision and improvement.

Access to telemetry is restricted to *"named GitHub personnel, Microsoft personnel working on Azure/Copilot teams, and employees of OpenAI working on Copilot."* Whether OpenAI employee access still applies in the current multi-model era is not clearly documented.

### Training data: a contractual prohibition, not a toggle

For Copilot Business and Enterprise, GitHub states unequivocally: *"GitHub does not use either Copilot Business or Enterprise data to train its models."* This is the default and only behavior — there is no opt-in. The prohibition extends to all third-party model providers through provider agreements. Each provider's commitment is documented on the model hosting page. This is backed by the GitHub DPA, which establishes GitHub as a processor permitted to use data only to provide the service.

**This is distinct from Copilot Free/Pro/Pro+**, where as of April 24, 2026, GitHub may use interaction data for AI model training unless the user opts out. Business and Enterprise plans are explicitly excluded from this change. This divergence makes the EMU deployment model additionally protective — EMU managed accounts cannot sign up for Copilot Individual, eliminating the risk of developers accidentally using a less-protected tier.

### EMU-specific data isolation

EMU adds **identity-layer isolation** (accounts provisioned via SCIM from the enterprise IdP, restricted to enterprise resources, unable to interact with public GitHub.com) and **network-layer controls** (corporate proxy headers restricting traffic to the managed enterprise). However, **the underlying Copilot data pipeline is identical** — EMU organizations receive the same inference routing, the same retention policies, and the same provider commitments as non-EMU Business orgs. EMU's value is in preventing shadow IT and ensuring centralized governance, not in providing different data handling at the AI layer.

### Content exclusion controls

Enterprise and organization admins can configure **content exclusion policies** targeting entire repositories, specific file paths and directories, or file patterns using wildcards (e.g., `*.cfg`, `secrets.json`). When exclusions apply, inline suggestions are unavailable in excluded files, excluded content does not inform suggestions in other files, and excluded files are not reviewed in code review.

Key limitations for compliance teams:

- Content exclusions are **not supported** in Copilot CLI, the coding agent, Agent mode, or Edit mode
- Copilot may still use **semantic information** from excluded files if provided indirectly by the IDE (type information, hover definitions, build config)
- Exclusions do **not prevent a developer from manually typing or pasting sensitive data** into a Copilot chat prompt
- Changes take up to **30 minutes** to propagate to IDEs

---

## 5. Data retention: fixed periods with no enterprise configurability

### Retention schedule for Copilot Business and Enterprise

| Data category | IDE (code editor) | Outside IDE (github.com, Mobile, CLI) | Coding Agent |
|---|---|---|---|
| **Prompts & Suggestions** | Not retained (discarded after response) | Retained **28 days** (for chat thread history) | Retained for **life of account** |
| **User Engagement Data** | **24 months** | **24 months** | **24 months** |
| **Feedback Data** | As long as needed for intended purpose | As long as needed | As long as needed |
| **last_activity_at API** | **90 days** (non-modifiable) | **90 days** | **90 days** |

### Retention by AI model provider

All third-party providers operate under agreements that impose restrictions on their own retention:

| Provider | Retention posture | Training commitment | Notable caveats |
|---|---|---|---|
| **OpenAI** | Full ZDR agreement | No training on customer data | — |
| **Microsoft Azure (fine-tuned models)** | GitHub's own Azure tenant | No training | Under GitHub's direct control |
| **Anthropic PBC** | ZDR for GA features **only** | No training | **Preview features not covered by ZDR** |
| **Amazon Bedrock** | No storage, no logging | No training | Hosts some Anthropic models |
| **Google Cloud Platform** | No-training + no abuse-monitoring logging | No training | **No explicit ZDR term documented** |
| **xAI** | Strictest ZDR: RAM-only, immediate deletion | No training | Out of scope per task requirements |

The Anthropic preview-feature gap and the absence of a formal GCP ZDR term are the two most significant discrepancies across providers. GitHub uses **prompt caching** across Anthropic PBC, Amazon Bedrock, and Google Cloud, which creates temporary data copies that are technically distinct from "retention" but may warrant analysis under strict regulatory frameworks.

### Configurability

**Retention periods are not configurable** for Business or EMU customers. No admin controls exist to adjust prompt retention windows, engagement data retention, or provider-level caching behavior. Content exclusions control what data is *sent*, not how long it is *stored*. Custom enterprise agreements negotiated directly with GitHub Sales may contain terms not publicly documented, but no evidence of configurable retention was found in any public source.

### Documentation map

Retention commitments are spread across multiple documents: the **GitHub DPA** (github.com/customer-terms/github-data-protection-agreement), the **Copilot Business Privacy Statement** (now redirecting to the Copilot Trust Center at copilot.github.trust.page), the **model hosting page** (docs.github.com/en/copilot/reference/ai-models/model-hosting), the **plans comparison page** (github.com/features/copilot/plans), and the **GitHub Generative AI Services Terms** (effective March 5, 2026, replacing the deprecated Copilot Product Specific Terms). The sub-processor list is at docs.github.com/en/site-policy/privacy-policies/github-subprocessors. Organizations should monitor github.com/customer-terms/updates for change notifications.

---

## 6. Financial services compliance: certifications, regulatory landscape, and quantified risk

### Certifications now in scope for Copilot Business

GitHub Copilot Business achieved **SOC 2 Type II** coverage as of December 2024 (covering the April 1 – September 30, 2024 audit period) and was added to GitHub's **ISO/IEC 27001:2013** ISMS scope in May 2024. Additional certifications include SOC 1 Type II, SOC 3, and CSA STAR Level 2. Reports are downloadable by enterprise owners via the GitHub Enterprise Cloud compliance settings tab.

**FedRAMP Moderate authorization has not been achieved.** GitHub Enterprise Cloud holds only FedRAMP Tailored LI-SaaS authorization; Moderate is being pursued but no timeline is confirmed. **HITRUST certification is absent** for GitHub Copilot. ISO 27017 and ISO 27018 (cloud-specific controls) are not confirmed in scope. For organizations that require FedRAMP Moderate as a procurement threshold, this remains a blocking gap.

### Regulatory guidance directly applicable to Copilot deployment

No US financial regulator has issued guidance specifically addressing AI coding assistants. However, several frameworks apply directly:

**NYDFS Industry Letter on AI Cybersecurity Risks (October 16, 2024)** is the most directly applicable regulatory document. It states that 23 NYCRR Part 500 *"already requires"* covered entities to assess AI-related cybersecurity risks and manage them through existing controls. Key requirements include: risk assessments covering the organization's own AI use and AI technologies used by third-party service providers; additional contractual *"representations and warranties relating to the secure use of NPI"* when TPSPs use AI; developer training on *"drafting queries to avoid disclosing NPI"*; and monitoring to *"detect unusual query behaviors that might indicate an attempt to extract NPI."*

**FINRA Regulatory Notice 24-09** applies FINRA's technologically neutral rules to AI tools. Rule 3110 (Supervision) requires policies for technology governance, model risk management, and data privacy. FINRA's 2026 Annual Oversight Report extends this to AI agents and autonomy risks.

**OCC Interagency Third-Party Risk Management Guidance (June 2023)** requires full-lifecycle management of third-party relationships including AI vendors. OCC Bulletin 2025-26 clarified that model risk management guidance allows risk-based, flexible application. Copilot is arguably not a "model" under OCC's MRM definition (it does not produce quantitative estimates used for decision-making), but it is unambiguously a third-party relationship requiring TPRM lifecycle management.

**NAIC Insurance Data Security Model Law (#668)**, now enacted in 24+ states, requires due diligence in selecting third-party service providers and ensuring they implement appropriate measures to protect NPI. The multi-layered sub-processor chain (GitHub → Azure → OpenAI/Anthropic/GCP) makes this due diligence significantly more complex than a typical vendor relationship.

### The sub-processor chain creates cascading third-party risk

The complete list of AI-related sub-processors authorized to process Copilot data includes **seven entities**: Microsoft (Azure), OpenAI, Anthropic PBC, Amazon Web Services, Google Cloud Platform, xAI, and Fireworks AI. Processing locations extend to the United States, Belgium, Singapore, Iceland, and Germany. GitHub publishes new sub-processors 30 days in advance, but organizations must have processes to monitor, assess, and potentially object to additions.

For **GLBA Safeguards Rule** purposes, the critical question is whether source code constitutes or contains NPI. Source code *can* contain NPI in multiple scenarios: hardcoded database connection strings, embedded test data with real customer information, business logic comments describing customer data handling, configuration files with API keys to NPI-containing systems, and schema definitions revealing NPI data structures. If code sent to Copilot contains NPI, the entire sub-processor chain becomes a GLBA compliance surface.

Under **23 NYCRR 500 §500.11** (as amended November 2023), GitHub qualifies as a Third-Party Service Provider. The regulation requires covered entities' TPSP policies to address: access controls including MFA (EMU directly satisfies this), encryption for NPI in transit and at rest (GitHub uses TLS; Azure provides at-rest encryption), cybersecurity event notification, and representations/warranties addressing the TPSP's cybersecurity policies.

**A critical compliance gap exists**: GitHub Copilot Business does not natively provide **content-level monitoring of prompts for NPI detection**. The NYDFS guidance specifically recommends monitoring for *"unusual query behaviors that might indicate an attempt to extract NPI"* and *"blocking queries from personnel that might expose NPI."* Organizations will likely need supplemental DLP or prompt-monitoring tooling to satisfy this expectation.

### Known security incidents relevant to risk assessment

**CamoLeak (June 2025, fixed August 2025)**: A **CVSS 9.6 critical vulnerability** that allowed silent exfiltration of secrets and source code from private repositories via prompt injection combined with a content security policy bypass. Hidden comments in pull requests injected malicious prompts, instructing Copilot to search private repos for sensitive artifacts and exfiltrate data via GitHub's Camo image proxy. GitHub remediated by disabling image rendering in Copilot Chat entirely.

**RoguePilot (2025)**: Discovered by Orca Security, this passive prompt injection via GitHub Issues could achieve full repository takeover through Codespaces. Attacker-crafted hidden instructions in Issues were automatically processed by Copilot, leading to GITHUB_TOKEN exfiltration. Fixed after responsible disclosure.

**Elevated secret leakage**: GitGuardian research documented that repositories using Copilot exhibit **6.4% secret leakage rates — 40% higher** than the 4.6% baseline in traditional development. This quantified, ongoing risk suggests AI-assisted coding creates systematic pressure toward credential exposure.

**Microsoft Copilot/Bing caching incident (November 2024)**: Microsoft Copilot and Bing caching mechanisms inadvertently made private GitHub repository data publicly accessible, impacting ~16,000 organizations and exposing IP, access keys, and security tokens. While this involved Microsoft Copilot (not GitHub Copilot), it demonstrates the risks of code data entering AI ecosystems broadly.

### Risk mitigations for deployment

Recommended controls for a financial services EMU deployment, mapped to regulatory requirements:

- **Restrict models to Azure-hosted only** — Disable Claude, Gemini, and other non-Azure models at the enterprise policy level to keep all inference within the Microsoft compliance boundary (satisfies TPSP simplification requirements)
- **Configure content exclusions aggressively** — Exclude repositories containing customer data schemas, connection strings, API keys, and test data with real NPI; use file pattern wildcards for configuration files
- **Deploy supplemental DLP for prompt monitoring** — Address the NYDFS gap by implementing tooling that inspects Copilot prompts for NPI patterns before transmission
- **Enable duplicate detection filter in "Block" mode** — Required for Microsoft's IP indemnification (Copilot Copyright Commitment) and reduces copyright risk
- **Conduct per-sub-processor vendor risk assessments** — Document each AI provider in the TPRM program; leverage SOC 2 Type II reports (downloadable from GitHub Enterprise settings)
- **Disable Copilot Free tier organization-wide** — Copilot Free/Pro/Pro+ have weaker privacy protections; as of April 2026, data from these tiers may be used for training
- **Train developers on NPI avoidance** — Per NYDFS guidance, developers should be trained to avoid exposing NPI in prompts, including not pasting customer data into chat
- **Monitor GitHub's sub-processor list** — Establish a process to review the 30-day advance notice for new sub-processors and assess compliance implications

---

## Conclusion: strong contractual protections, complex operational reality

GitHub Copilot Business in an EMU deployment offers **substantive contractual protections** — no training on customer data, zero data retention agreements with most providers, SOC 2 Type II and ISO 27001 coverage, and granular enterprise policy controls including per-model enablement. The EMU identity model provides strong access governance that directly satisfies NYDFS MFA and access control requirements.

The operational reality, however, involves **six or more AI inference sub-processors spanning three cloud ecosystems** with varying data commitments. The Anthropic ZDR gap for preview features, the absence of a formal Google ZDR term, the non-configurable retention periods, and the documented CVSS 9.6 vulnerability history create genuine compliance complexity. **The most effective single risk mitigation is restricting models to OpenAI/Microsoft fine-tuned models only**, which confines data to the Azure ecosystem and the strongest ZDR agreements — at the cost of losing access to Claude and Gemini capabilities.

For organizations subject to NYDFS 23 NYCRR 500, the October 2024 industry letter creates de facto requirements that GitHub's native capabilities do not fully address, particularly around NPI prompt monitoring. The absence of FedRAMP Moderate authorization may be a blocking factor for some institutions. Financial services organizations should treat Copilot deployment as a **full TPRM lifecycle engagement** — not a simple SaaS procurement — and budget for supplemental monitoring, training, and ongoing sub-processor surveillance accordingly.