# GitHub Apps Experiment Setup Guide for EMU Environment

## Overview and Safety First

This guide provides a safe, isolated approach to experimenting with GitHub Apps in your GitHub Enterprise Cloud EMU environment without affecting production systems or customers. We'll use your test organization to create a controlled environment for learning and validation.

## Pre-Experiment Checklist

### ✅ Environment Verification
- [ ] Confirm test organization is completely separate from production
- [ ] Verify test org has no customer-facing repositories
- [ ] Ensure test org has appropriate EMU user access
- [ ] Document current authentication methods in use
- [ ] Identify a test repository for initial experiments

### ✅ Required Permissions
- [ ] Organization Owner role in test organization
- [ ] Enterprise Owner role (for enterprise-level features)
- [ ] Access to organization settings and developer settings

### ✅ Safety Boundaries
- [ ] Test organization isolated from production workloads
- [ ] No production secrets or credentials in test environment
- [ ] Separate webhook endpoints for testing
- [ ] Non-production domain for callback URLs

---

## Phase 1: Basic GitHub App Creation (Day 1)

### Step 1: Create Your First GitHub App

1. **Navigate to GitHub App Settings**
   ```
   Test Organization → Settings → Developer settings → GitHub Apps → New GitHub App
   ```

2. **Configure Basic App Information**
   ```yaml
   App Name: "test-github-app-experiment"
   Description: "Isolated experiment for learning GitHub Apps security model"
   Homepage URL: "https://github.com/YOUR-TEST-ORG"
   Callback URL: "https://localhost:8080/callback" # For testing only
   ```

3. **Configure Webhook Settings (Optional for Phase 1)**
   ```yaml
   Webhook URL: "https://httpbin.org/post" # Safe test endpoint
   Webhook Secret: Generate a random 32-character string
   SSL Verification: Enabled
   ```

4. **Set Minimal Permissions (Start Small)**
   ```yaml
   Repository Permissions:
     - Contents: Read
     - Metadata: Read
   
   Account Permissions: None
   Organization Permissions: None
   ```

5. **Complete App Creation**
   - Click "Create GitHub App"
   - **Immediately save the App ID and download the private key**
   - Store these securely (password manager or secure note)

### Step 2: Create Test Repository

1. **Create a new repository in your test organization**
   ```
   Repository Name: "github-app-test-repo"
   Description: "Test repository for GitHub App experiments"
   Visibility: Private
   Initialize with README: Yes
   ```

2. **Add test content**
   ```bash
   # Create a simple test file
   echo "# GitHub App Test" > test-file.md
   echo "This repository is for testing GitHub App functionality" >> test-file.md
   ```

### Step 3: Install the App (Scoped Installation)

1. **Navigate to App Installation**
   ```
   Test Organization → Settings → GitHub Apps → Your App → Install App
   ```

2. **Configure Installation Scope**
   ```yaml
   Installation Target: Your test organization
   Repository Access: "Selected repositories"
   Selected Repositories: Only "github-app-test-repo"
   ```

3. **Complete Installation**
   - Click "Install"
   - Note the installation ID from the URL
   - Verify app appears in organization's installed apps

---

## Phase 2: Authentication Testing (Day 2-3)

### Step 4: Set Up Local Development Environment

1. **Create experiment directory**
   ```bash
   mkdir github-app-experiment
   cd github-app-experiment
   ```

2. **Install required dependencies**
   ```bash
   # For Node.js environment
   npm init -y
   npm install @octokit/app @octokit/rest jsonwebtoken
   
   # Or for Python environment
   pip install PyJWT requests cryptography
   ```

3. **Create environment configuration**
   ```bash
   # Create .env file (never commit this)
   touch .env
   
   # Add your app credentials
   APP_ID=your_app_id_here
   INSTALLATION_ID=your_installation_id_here
   PRIVATE_KEY_PATH=./private-key.pem
   ```

### Step 5: Test JWT Generation and Installation Token

1. **Create test script (Node.js example)**
   ```javascript
   // test-auth.js
   const { App } = require('@octokit/app');
   const fs = require('fs');
   require('dotenv').config();
   
   async function testGitHubAppAuth() {
     try {
       // Initialize GitHub App
       const app = new App({
         appId: process.env.APP_ID,
         privateKey: fs.readFileSync(process.env.PRIVATE_KEY_PATH, 'utf8'),
       });
   
       // Test app-level authentication
       console.log('Testing app-level authentication...');
       const appOctokit = await app.getInstallationOctokit(process.env.INSTALLATION_ID);
       
       // Test API call with minimal permissions
       console.log('Testing API access...');
       const { data: repo } = await appOctokit.rest.repos.get({
         owner: 'YOUR-TEST-ORG',
         repo: 'github-app-test-repo'
       });
       
       console.log('✅ Success! Repository accessed:', repo.name);
       console.log('✅ App authentication working correctly');
       
     } catch (error) {
       console.error('❌ Error:', error.message);
     }
   }
   
   testGitHubAppAuth();
   ```

2. **Run authentication test**
   ```bash
   node test-auth.js
   ```

3. **Verify token characteristics**
   - Check token expiration (should be ~1 hour)
   - Verify scoped access (only test repository)
   - Confirm permission limitations

---

## Phase 3: Permission Testing (Day 4-5)

### Step 6: Test Permission Boundaries

1. **Test read-only access**
   ```javascript
   // test-permissions.js
   async function testPermissionBoundaries() {
     // Test successful read operation
     const { data: contents } = await appOctokit.rest.repos.getContent({
       owner: 'YOUR-TEST-ORG',
       repo: 'github-app-test-repo',
       path: 'README.md'
     });
     console.log('✅ Read access confirmed');
     
     // Test permission boundary (should fail)
     try {
       await appOctokit.rest.repos.createOrUpdateFileContents({
         owner: 'YOUR-TEST-ORG',
         repo: 'github-app-test-repo',
         path: 'test-write.txt',
         message: 'Test write access',
         content: Buffer.from('test content').toString('base64')
       });
       console.log('❌ Unexpected: Write access granted');
     } catch (error) {
       console.log('✅ Expected: Write access properly restricted');
     }
   }
   ```

2. **Test repository scope boundaries**
   ```javascript
   async function testRepositoryScope() {
     // Create another repository in test org
     // Try to access it (should fail - not in installation scope)
     try {
       await appOctokit.rest.repos.get({
         owner: 'YOUR-TEST-ORG',
         repo: 'other-test-repo'
       });
       console.log('❌ Unexpected: Access to non-installed repo');
     } catch (error) {
       console.log('✅ Expected: Repository scope properly enforced');
     }
   }
   ```

### Step 7: Gradual Permission Expansion

1. **Add write permissions to test app**
   ```
   Organization → Settings → GitHub Apps → Your App → Edit
   
   Repository Permissions:
     - Contents: Write (upgrade from Read)
     - Pull requests: Read
   ```

2. **Test new permissions**
   ```javascript
   async function testWritePermissions() {
     try {
       // Test file creation
       await appOctokit.rest.repos.createOrUpdateFileContents({
         owner: 'YOUR-TEST-ORG',
         repo: 'github-app-test-repo',
         path: 'app-created-file.txt',
         message: 'File created by GitHub App',
         content: Buffer.from('Created by GitHub App experiment').toString('base64')
       });
       console.log('✅ Write permissions working correctly');
     } catch (error) {
       console.error('❌ Write permission test failed:', error.message);
     }
   }
   ```

---

## Phase 4: EMU-Specific Testing (Day 6-7)

### Step 8: Test EMU Integration Patterns

1. **Test SAML SSO compatibility**
   ```javascript
   async function testEMUFeatures() {
     // Test app behavior with EMU users
     const { data: collaborators } = await appOctokit.rest.repos.listCollaborators({
       owner: 'YOUR-TEST-ORG',
       repo: 'github-app-test-repo'
     });
     
     console.log('EMU Users with access:', collaborators.map(c => c.login));
     
     // Test audit log visibility
     const { data: events } = await appOctokit.rest.activity.listRepoEvents({
       owner: 'YOUR-TEST-ORG',
       repo: 'github-app-test-repo'
     });
     
     console.log('Recent app events logged:', events.length);
   }
   ```

2. **Test enterprise-level visibility**
   ```bash
   # Check enterprise audit logs
   Enterprise Settings → Audit log → Filter for your app activities
   ```

### Step 9: Test Enterprise-Owned App Features (if available)

1. **Create enterprise-owned app (if permissions allow)**
   ```
   Enterprise Settings → Developer settings → GitHub Apps → New GitHub App
   
   Ownership: Enterprise-owned
   Organizations: Include test organization only
   ```

2. **Compare enterprise vs organization-owned app behavior**
   - Installation process differences
   - Permission inheritance patterns
   - Audit log attribution differences

---

## Phase 5: Webhook and Event Testing (Day 8-9)

### Step 10: Set Up Safe Webhook Testing

1. **Use webhook testing service**
   ```bash
   # Install webhook testing tool
   npm install -g localtunnel
   
   # Create local webhook receiver
   node webhook-server.js &
   
   # Expose with secure tunnel
   lt --port 3000 --subdomain your-test-webhook
   ```

2. **Configure webhook in app**
   ```
   App Settings → Webhooks
   URL: https://your-test-webhook.loca.lt/webhook
   Events: Push, Pull Request (minimal set)
   ```

3. **Test webhook delivery**
   ```javascript
   // webhook-server.js
   const express = require('express');
   const crypto = require('crypto');
   
   const app = express();
   app.use(express.json());
   
   app.post('/webhook', (req, res) => {
     const signature = req.headers['x-hub-signature-256'];
     const payload = JSON.stringify(req.body);
     
     // Verify webhook signature
     const expectedSignature = 'sha256=' + crypto
       .createHmac('sha256', process.env.WEBHOOK_SECRET)
       .update(payload)
       .digest('hex');
     
     if (signature === expectedSignature) {
       console.log('✅ Webhook verified:', req.body.action || req.body.zen);
       res.status(200).send('OK');
     } else {
       console.log('❌ Webhook signature verification failed');
       res.status(401).send('Unauthorized');
     }
   });
   
   app.listen(3000, () => console.log('Webhook server running on port 3000'));
   ```

---

## Phase 6: Security and Audit Testing (Day 10)

### Step 11: Test Security Features

1. **Verify token expiration**
   ```javascript
   async function testTokenExpiration() {
     const token = await app.getInstallationAccessToken({
       installationId: process.env.INSTALLATION_ID
     });
     
     console.log('Token expires at:', new Date(token.expiresAt));
     
     // Test token after expiration (wait or manipulate time)
     // Should automatically refresh
   }
   ```

2. **Test permission revocation**
   ```bash
   # Temporarily remove permissions in app settings
   # Verify existing tokens lose access immediately
   # Re-add permissions and verify access restoration
   ```

### Step 12: Audit Trail Verification

1. **Check organization audit logs**
   ```
   Test Organization → Settings → Audit log
   Filter: Applications, GitHub Apps
   ```

2. **Verify audit events include:**
   - App installation/uninstallation
   - Permission changes
   - Token generation events
   - API calls with app attribution

---

## Phase 7: Comparison Testing (Day 11-12)

### Step 13: Side-by-Side Comparison

1. **Create equivalent PAT for comparison**
   ```
   Test Organization User → Settings → Developer settings → Personal access tokens → Fine-grained tokens
   
   Permissions: Match your GitHub App permissions
   Repository access: Same test repository
   ```

2. **Run identical operations with both auth methods**
   ```javascript
   async function compareAuthMethods() {
     // GitHub App
     const appResult = await appOctokit.rest.repos.get({
       owner: 'YOUR-TEST-ORG',
       repo: 'github-app-test-repo'
     });
     
     // PAT
     const patOctokit = new Octokit({ auth: 'your-fine-grained-pat' });
     const patResult = await patOctokit.rest.repos.get({
       owner: 'YOUR-TEST-ORG',
       repo: 'github-app-test-repo'
     });
     
     console.log('App rate limit remaining:', appResult.headers['x-ratelimit-remaining']);
     console.log('PAT rate limit remaining:', patResult.headers['x-ratelimit-remaining']);
   }
   ```

3. **Document differences observed:**
   - Rate limiting behavior
   - Audit log attribution
   - Token lifecycle management
   - Permission enforcement

---

## Post-Experiment Analysis

### Step 14: Document Findings

1. **Create experiment report**
   ```markdown
   # GitHub App Experiment Results
   
   ## Tested Scenarios
   - [x] Basic authentication
   - [x] Permission boundaries
   - [x] EMU integration
   - [x] Webhook functionality
   - [x] Security features
   - [x] Audit capabilities
   
   ## Key Findings
   - Security improvements observed
   - Operational differences noted
   - EMU-specific behaviors
   - Rate limiting advantages
   
   ## Recommendations
   - Migration strategy
   - Rollout plan
   - Training needs
   ```

### Step 15: Plan Production Rollout

1. **Identify migration candidates**
   - Low-risk integrations first
   - CI/CD automation workflows
   - Third-party tool integrations

2. **Develop migration timeline**
   - Pilot phase with test apps
   - Gradual production migration
   - Classic PAT deprecation plan

---

## Safety Measures and Rollback

### Emergency Procedures

1. **Immediate rollback steps**
   ```bash
   # Uninstall app from test organization
   Test Org → Settings → GitHub Apps → Uninstall
   
   # Revoke app registration if needed
   Test Org → Settings → Developer settings → Delete App
   ```

2. **Clean up test environment**
   ```bash
   # Remove test repositories
   # Delete webhook configurations
   # Clear stored credentials
   # Document lessons learned
   ```

### Success Criteria

- [ ] GitHub App successfully created and installed
- [ ] Authentication working with automatic token rotation
- [ ] Permissions properly scoped and enforced
- [ ] EMU integration functioning correctly
- [ ] Audit trail visibility confirmed
- [ ] Security advantages demonstrated
- [ ] Ready for production pilot

## Next Steps

After successful experiment completion:

1. **Prepare pilot program** for low-risk production integration
2. **Train team members** on GitHub App development patterns
3. **Establish governance policies** for GitHub App approval
4. **Plan migration strategy** from existing authentication methods
5. **Create monitoring and alerting** for GitHub App usage

## Troubleshooting Common Issues

### Authentication Failures
- Verify private key format and path
- Check App ID accuracy
- Confirm installation ID
- Validate clock synchronization for JWT

### Permission Errors
- Review app permission configuration
- Check repository installation scope
- Verify organization policies don't block apps

### EMU-Specific Issues
- Confirm SAML SSO status
- Verify enterprise policies allow GitHub Apps
- Check user provisioning hasn't changed

Remember: This experiment is designed to be completely safe and isolated. If anything goes wrong, simply uninstall the app and delete it – no production systems will be affected.
