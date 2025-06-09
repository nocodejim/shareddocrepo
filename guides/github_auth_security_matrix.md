# GitHub Authentication Methods Security Matrix & Rating System

## Security Rating Rubric

**Rating Scale: 1-5 (1 = Poor, 2 = Fair, 3 = Good, 4 = Very Good, 5 = Excellent)**

### Security Criteria Definitions

| Criteria | Definition | Weight |
|----------|------------|---------|
| **Token Lifespan** | How long credentials remain valid without refresh | High |
| **Permission Granularity** | Precision of access control and least privilege enforcement | High |
| **Audit & Visibility** | Quality of logging, attribution, and monitoring capabilities | High |
| **Blast Radius** | Scope of access if credentials are compromised | Critical |
| **User Dependency** | Resilience to user account lifecycle changes | Medium |
| **Revocation Speed** | How quickly access can be terminated | High |
| **Rate Limiting** | API rate limits and performance considerations | Medium |
| **Admin Control** | Organizational oversight and policy enforcement | High |
| **Compliance Features** | Built-in compliance and governance capabilities | Medium |
| **Compromise Detection** | Ability to detect and respond to security incidents | High |

## Complete Authentication Methods Matrix

| Authentication Method | Token Lifespan | Permission Granularity | Audit & Visibility | Blast Radius | User Dependency | Revocation Speed | Rate Limiting | Admin Control | Compliance Features | Compromise Detection | **Overall Score** |
|----------------------|---------------|----------------------|-------------------|--------------|-----------------|------------------|---------------|---------------|-------------------|-------------------|------------------|
| **GitHub Apps** | 5 (1hr max) | 5 (50+ permissions) | 5 (comprehensive) | 5 (installation-scoped) | 5 (independent) | 5 (immediate) | 5 (15k/hr) | 5 (full control) | 5 (enterprise-grade) | 5 (SHA-256 tracking) | **5.0** |
| **GitHub Apps + Enterprise SSO** | 5 (1hr max) | 5 (50+ permissions) | 5 (comprehensive) | 5 (installation-scoped) | 5 (independent) | 5 (immediate) | 5 (15k/hr) | 5 (full control) | 5 (enterprise-grade) | 5 (SHA-256 tracking) | **5.0** |
| **GitHub Apps + OIDC** | 5 (1hr max) | 5 (50+ permissions) | 5 (comprehensive) | 5 (installation-scoped) | 5 (independent) | 5 (immediate) | 5 (15k/hr) | 5 (full control) | 5 (enterprise-grade) | 5 (SHA-256 tracking) | **5.0** |
| **Fine-grained PAT** | 3 (user-defined) | 5 (50+ permissions) | 4 (good attribution) | 4 (repo-specific) | 2 (user-dependent) | 4 (fast) | 3 (5k/hr) | 4 (approval workflows) | 4 (good tracking) | 4 (token ID tracking) | **3.7** |
| **Fine-grained PAT + MFA** | 3 (user-defined) | 5 (50+ permissions) | 4 (good attribution) | 4 (repo-specific) | 2 (user-dependent) | 4 (fast) | 3 (5k/hr) | 4 (approval workflows) | 4 (good tracking) | 4 (token ID tracking) | **3.7** |
| **Fine-grained PAT + SSO** | 3 (user-defined) | 5 (50+ permissions) | 4 (good attribution) | 4 (repo-specific) | 2 (user-dependent) | 4 (fast) | 3 (5k/hr) | 5 (SSO control) | 5 (SSO compliance) | 4 (token ID tracking) | **3.9** |
| **Classic PAT** | 1 (no expiration) | 1 (broad scopes) | 2 (basic logging) | 1 (all user repos) | 1 (user-dependent) | 3 (manual) | 3 (5k/hr) | 1 (no control) | 1 (minimal) | 2 (basic tracking) | **1.6** |
| **Classic PAT + MFA** | 1 (no expiration) | 1 (broad scopes) | 2 (basic logging) | 1 (all user repos) | 1 (user-dependent) | 3 (manual) | 3 (5k/hr) | 2 (MFA required) | 2 (basic) | 3 (MFA protection) | **1.9** |
| **Classic PAT + SSO** | 1 (no expiration) | 1 (broad scopes) | 3 (SSO logging) | 1 (all user repos) | 1 (user-dependent) | 4 (SSO revoke) | 3 (5k/hr) | 4 (SSO control) | 4 (SSO compliance) | 3 (SSO monitoring) | **2.5** |
| **OAuth Apps** | 2 (refresh tokens) | 2 (OAuth scopes) | 3 (OAuth flows) | 2 (user scope) | 2 (user-dependent) | 3 (OAuth revoke) | 3 (5k/hr) | 3 (app approval) | 3 (OAuth standard) | 3 (OAuth tracking) | **2.6** |
| **OAuth Apps + SSO** | 2 (refresh tokens) | 2 (OAuth scopes) | 4 (SSO + OAuth) | 2 (user scope) | 2 (user-dependent) | 4 (SSO revoke) | 3 (5k/hr) | 4 (SSO control) | 4 (SSO compliance) | 4 (SSO monitoring) | **3.1** |
| **GitHub Actions GITHUB_TOKEN** | 5 (job duration) | 4 (job-scoped) | 4 (workflow logs) | 4 (repo-scoped) | 4 (workflow-scoped) | 5 (automatic) | 4 (10k/hr) | 4 (workflow control) | 4 (workflow audit) | 4 (workflow tracking) | **4.2** |
| **GitHub Actions OIDC** | 5 (short-lived) | 4 (claim-based) | 5 (comprehensive) | 5 (claim-scoped) | 5 (workflow-based) | 5 (automatic) | 4 (10k/hr) | 5 (policy-based) | 5 (OIDC standard) | 5 (claim verification) | **4.8** |
| **SSH Keys** | 1 (no expiration) | 3 (repo access) | 2 (basic Git logs) | 3 (user repos) | 2 (user-dependent) | 3 (manual) | 4 (Git protocol) | 2 (limited control) | 2 (basic) | 2 (key-based) | **2.4** |
| **SSH Keys + Certificate Authority** | 4 (certificate expiry) | 3 (repo access) | 4 (CA logging) | 3 (user repos) | 2 (user-dependent) | 4 (CA revoke) | 4 (Git protocol) | 4 (CA control) | 4 (certificate audit) | 4 (CA monitoring) | **3.6** |
| **Deploy Keys** | 1 (no expiration) | 4 (repo-specific) | 2 (basic logs) | 4 (single repo) | 4 (repo-scoped) | 3 (manual) | 4 (Git protocol) | 3 (repo control) | 2 (basic) | 2 (key-based) | **2.9** |
| **Machine Users + Classic PAT** | 1 (no expiration) | 1 (broad scopes) | 2 (user attribution) | 1 (all accessible) | 3 (dedicated account) | 3 (manual) | 3 (5k/hr) | 2 (user management) | 2 (basic) | 2 (basic tracking) | **2.0** |
| **Machine Users + Fine-grained PAT** | 3 (user-defined) | 5 (50+ permissions) | 3 (user attribution) | 4 (repo-specific) | 3 (dedicated account) | 4 (fast) | 3 (5k/hr) | 3 (user + token mgmt) | 3 (better tracking) | 4 (token ID tracking) | **3.5** |
| **Username/Password** | 1 (session-based) | 1 (full access) | 1 (basic logs) | 1 (full account) | 1 (user-dependent) | 2 (password change) | 2 (limited) | 1 (no control) | 1 (deprecated) | 1 (poor) | **1.1** |
| **Username/Password + MFA** | 1 (session-based) | 1 (full access) | 2 (MFA logs) | 1 (full account) | 1 (user-dependent) | 3 (MFA disable) | 2 (limited) | 2 (MFA required) | 2 (basic) | 3 (MFA protection) | **1.8** |

## Security Risk Classifications

### **EXCELLENT (4.5-5.0)** - Recommended for All Use Cases
- **GitHub Apps (all variants)**
- **GitHub Actions OIDC**

### **VERY GOOD (3.5-4.4)** - Recommended for Most Use Cases
- **GitHub Actions GITHUB_TOKEN**
- **Fine-grained PAT + SSO**
- **SSH Keys + Certificate Authority**

### **GOOD (2.5-3.4)** - Acceptable with Controls
- **Fine-grained PAT (all variants)**
- **Machine Users + Fine-grained PAT**
- **OAuth Apps + SSO**

### **FAIR (1.5-2.4)** - Legacy/Transitional Use Only
- **Deploy Keys**
- **SSH Keys**
- **Classic PAT + SSO**
- **Machine Users + Classic PAT**

### **POOR (1.0-1.4)** - Avoid/Deprecated
- **Classic PAT**
- **Classic PAT + MFA**
- **Username/Password (all variants)**

## Detailed Analysis by Use Case

### **CI/CD Automation (Recommended)**
1. **GitHub Actions OIDC** (4.8) - Zero secrets, automatic rotation
2. **GitHub Apps** (5.0) - Fine-grained permissions, enterprise control
3. **GitHub Actions GITHUB_TOKEN** (4.2) - Built-in, automatic

### **Third-Party Integrations (Recommended)**
1. **GitHub Apps** (5.0) - Purpose-built for integrations
2. **GitHub Apps + Enterprise SSO** (5.0) - Additional identity controls
3. **OAuth Apps + SSO** (3.1) - Standard OAuth with SSO benefits

### **Developer Personal Use (Recommended)**
1. **Fine-grained PAT + SSO** (3.9) - User-friendly with org controls
2. **Fine-grained PAT + MFA** (3.7) - Personal protection
3. **SSH Keys + Certificate Authority** (3.6) - Git-focused with expiry

### **Enterprise Automation (Recommended)**
1. **GitHub Apps + Enterprise SSO** (5.0) - Full enterprise integration
2. **GitHub Apps + OIDC** (5.0) - Standards-based identity
3. **Machine Users + Fine-grained PAT** (3.5) - Legacy system compatibility

## Migration Priority Matrix

| Current Method | Target Method | Priority | Effort | Security Gain |
|----------------|---------------|----------|---------|---------------|
| Classic PAT → GitHub Apps | **GitHub Apps** | **Critical** | Medium | +3.4 points |
| Classic PAT → Fine-grained PAT | **Fine-grained PAT** | High | Low | +2.1 points |
| OAuth Apps → GitHub Apps | **GitHub Apps** | High | Medium | +2.4 points |
| SSH Keys → Certificate Authority | **SSH + CA** | Medium | Medium | +1.2 points |
| Username/Password → Any Modern | **Any 3.5+** | **Critical** | Low | +2.4+ points |

## Key Security Recommendations

### **Immediate Actions**
1. **Audit all Classic PATs** - Highest risk authentication method
2. **Implement GitHub Apps** for all automation and integrations
3. **Enable SSO/SAML** where available for additional control layer
4. **Migrate from Username/Password** to any token-based method

### **Medium-term Goals**
1. **Deploy Certificate Authority** for SSH key management
2. **Implement OIDC workflows** for CI/CD where possible
3. **Establish governance policies** for token approval and rotation
4. **Enable audit log streaming** for comprehensive monitoring

### **Long-term Strategy**
1. **Achieve GitHub Apps-first** authentication architecture
2. **Eliminate all Classic PATs** from production systems
3. **Implement zero-trust principles** with short-lived credentials
4. **Establish continuous compliance monitoring** across all auth methods

## Notes
- Ratings are cumulative across all security criteria
- Enterprise features significantly improve scores where available
- SSO/SAML integration provides consistent security uplift
- OIDC represents the future direction for secure authentication
- Regular token rotation and monitoring are assumed best practices