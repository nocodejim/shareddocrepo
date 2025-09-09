# GitHub Copilot Automated Analysis Instructions

## Setup Instructions

Before starting, I'll create a temporary analysis environment that won't affect your system:

```bash
# Navigate to your cincinnati-repos directory
cd /path/to/cincinnati-repos

# Create analysis structure
mkdir -p .analysis/{scripts,temp,output}
mkdir -p docs/{repository-analysis,vendor-patterns,devops-roadmap}

# Create a Python virtual environment for any Python-based analysis
python -m venv .analysis/venv

# Create Docker container for Java analysis tools (if needed)
cat > .analysis/docker-compose.yml << 'EOF'
version: '3.8'
services:
  analyzer:
    image: openjdk:11-jdk-slim
    volumes:
      - .:/workspace
    working_dir: /workspace
    command: tail -f /dev/null
EOF
```

## Automated Analysis Script

Create and execute this master analysis script that requires minimal interaction:

```bash
#!/bin/bash
# save as: .analysis/scripts/analyze-all.sh

BASE_DIR=$(pwd)
REPOS_FILE="${BASE_DIR}/.analysis/temp/repos.txt"
OUTPUT_DIR="${BASE_DIR}/docs"
ANALYSIS_LOG="${BASE_DIR}/.analysis/analysis.log"

# Function to analyze without prompting
analyze_repo() {
    local repo=$1
    echo "Analyzing ${repo}..." | tee -a ${ANALYSIS_LOG}
    
    # Create analysis file
    cat > "${OUTPUT_DIR}/repository-analysis/${repo}.md" << 'TEMPLATE'
# ${repo} Analysis
## Service Profile
[Analysis will be populated here]
TEMPLATE
    
    # Run non-interactive analysis commands
    cd "${BASE_DIR}/${repo}"
    
    # Check for build files (no prompt)
    [ -f "pom.xml" ] && echo "Maven project detected" >> "${OUTPUT_DIR}/repository-analysis/${repo}.md"
    [ -f "build.gradle" ] && echo "Gradle project detected" >> "${OUTPUT_DIR}/repository-analysis/${repo}.md"
    
    # Check for CI/CD files
    [ -d ".github" ] && echo "GitHub Actions present" >> "${OUTPUT_DIR}/repository-analysis/${repo}.md"
    [ -f "Jenkinsfile" ] && echo "Jenkins pipeline present" >> "${OUTPUT_DIR}/repository-analysis/${repo}.md"
    
    # Security scan (read-only)
    find . -type f -name "*.properties" -o -name "*.yml" -o -name "*.yaml" | \
        xargs grep -l "password\|secret\|key" 2>/dev/null | \
        wc -l > "${BASE_DIR}/.analysis/temp/${repo}-secrets.txt"
    
    cd "${BASE_DIR}"
}

# Generate repository list
ls -d */ | sed 's|/||g' | grep -v docs | grep -v .analysis > ${REPOS_FILE}

# Process all repositories
while IFS= read -r repo; do
    analyze_repo "$repo"
done < ${REPOS_FILE}

echo "Analysis complete. Check ${OUTPUT_DIR} for results."
```

## Copilot Chat Commands (Minimal Interaction)

Use these commands in sequence with Copilot Chat to minimize interruptions:

### 1. Initial Bulk Analysis (Single Command)
```
@workspace /analyze Please analyze all Java repositories in this folder following these rules:
1. DO NOT make any changes to files
2. DO NOT install anything globally
3. DO NOT prompt me for each repository
4. Create all output in the docs/ folder
5. For each repository, check for: build files, CI/CD configs, Docker files, security patterns, dependencies
6. Create a summary file at docs/master-index.md
7. Group findings by DevOps principles: CI/CD, Security, Observability, IaC
8. Skip any interactive prompts - make reasonable assumptions
9. If you need to run commands, batch them into a single script
```

### 2. Pattern Detection (Single Command)
```
@workspace Please identify patterns across all repositories without prompting:
1. Find common dependencies across pom.xml/build.gradle files
2. Identify shared code patterns
3. Detect similar third-party integrations
4. List all external API endpoints being called
5. Output to docs/vendor-patterns/integration-patterns.md
6. DO NOT modify any files, only read and analyze
```

### 3. Security Scan (Single Command)
```
@workspace Run a security analysis across all repos:
1. Find potential hardcoded credentials (just note locations, don't display values)
2. Check for outdated dependencies
3. Identify missing security headers in REST controllers
4. Find PII/PHI handling code
5. Output findings to docs/security-critical.md
6. Use grep/find commands only - no file modifications
7. Batch all commands into a single script if needed
```

### 4. DevOps Readiness Assessment (Single Command)
```
@workspace Assess DevOps readiness for all repositories:
1. Check for Dockerfile presence and quality
2. Identify services with/without CI/CD pipelines
3. Find services missing health check endpoints
4. Detect logging framework usage
5. Create prioritized list in docs/devops-backlog.md
6. Format as user stories aligned with DevOps principles
7. No file modifications - analysis only
```

## PowerShell Alternative (Windows)

```powershell
# save as: .analysis/scripts/analyze-all.ps1

$BaseDir = Get-Location
$OutputDir = "$BaseDir\docs"
$TempDir = "$BaseDir\.analysis\temp"

# Create directories
@("docs\repository-analysis", "docs\vendor-patterns", "docs\devops-roadmap", ".analysis\temp") | ForEach-Object {
    New-Item -ItemType Directory -Force -Path $_
}

# Function to analyze repository
function Analyze-Repository {
    param($RepoName)
    
    Write-Host "Analyzing $RepoName..." -ForegroundColor Green
    
    $RepoPath = "$BaseDir\$RepoName"
    $OutputFile = "$OutputDir\repository-analysis\$RepoName.md"
    
    # Initialize report
    @"
# $RepoName Analysis
## Service Profile
"@ | Out-File $OutputFile
    
    # Check for build files
    if (Test-Path "$RepoPath\pom.xml") { Add-Content $OutputFile "- Build: Maven" }
    if (Test-Path "$RepoPath\build.gradle") { Add-Content $OutputFile "- Build: Gradle" }
    if (Test-Path "$RepoPath\Dockerfile") { Add-Content $OutputFile "- Container: Docker" }
    
    # Check for CI/CD
    if (Test-Path "$RepoPath\.github") { Add-Content $OutputFile "- CI/CD: GitHub Actions" }
    if (Test-Path "$RepoPath\Jenkinsfile") { Add-Content $OutputFile "- CI/CD: Jenkins" }
    
    # Count potential security issues (read-only)
    $SecurityCount = (Get-ChildItem -Path $RepoPath -Include *.properties,*.yml,*.yaml -Recurse -ErrorAction SilentlyContinue | 
        Select-String -Pattern "password|secret|key" -SimpleMatch | 
        Measure-Object).Count
    
    Add-Content $OutputFile "`n## Security Scan`n- Potential sensitive strings: $SecurityCount"
}

# Get all directories (repositories)
$Repos = Get-ChildItem -Directory -Exclude docs,.analysis,.*

# Analyze each repository
foreach ($Repo in $Repos) {
    Analyze-Repository -RepoName $Repo.Name
}

Write-Host "`nAnalysis complete. Results in $OutputDir" -ForegroundColor Cyan
```

## Copilot Workspace Instructions

For Copilot Workspace, create a `.github/copilot-instructions.md` file:

```markdown
# Copilot Analysis Instructions

When analyzing this repository collection:

## Constraints
- NEVER install packages globally
- NEVER modify existing code files
- NEVER prompt for confirmation on read operations
- ONLY write to the docs/ directory
- Use virtual environments or containers for any tools

## Automated Analysis Approach
1. First, scan all repositories and create an inventory
2. Batch similar operations together
3. Create scripts that can run unattended
4. Output structured markdown for all findings

## Output Structure
Always organize findings into:
- DevOps principle alignment
- Business impact
- Technical categorization
- Priority (P0-P4)

## Non-Interactive Operations
- Use `find`, `grep`, `awk` for file analysis
- Read files without prompting
- Make reasonable assumptions about patterns
- Skip operations requiring user input
- Batch multiple operations into single scripts

## Safe Operations Whitelist
- Reading any file in the repository
- Creating new files in docs/ directory
- Running analysis in Docker containers
- Using Python virtual environments
- Creating temporary files in .analysis/
```

## Execution Flow

1. **Start the analysis with a single compound command:**
```bash
# Create and run everything at once
bash -c 'mkdir -p docs/{repository-analysis,vendor-patterns,devops-roadmap} .analysis/{scripts,temp,output} && \
echo "Starting automated analysis..." && \
for dir in */; do \
  [[ "$dir" == "docs/" || "$dir" == ".analysis/" ]] && continue; \
  repo=${dir%/}; \
  echo "# $repo Analysis" > "docs/repository-analysis/${repo}.md"; \
  echo "Processed $repo"; \
done && \
echo "Initial structure created. Run detailed analysis now."'
```

2. **Have Copilot execute the analysis:**
```
@workspace Please run the comprehensive analysis now using the structure we created. For each repository in docs/repository-analysis/, populate it with the actual analysis following our template. Do not prompt me - make reasonable assumptions and complete the full analysis.
```

## Key Principles for Minimal Interaction

1. **Batch Operations**: Combine multiple analyses into single scripts
2. **Assume Defaults**: Don't ask for choices, use sensible defaults
3. **Read-Only First**: All analysis should be read-only initially
4. **Fail Silently**: Skip items that would require prompts
5. **Log Everything**: Write all findings to files, not console
6. **Use Containers**: For any tools, use Docker containers
7. **Virtual Environments**: Python analysis in venv only

## Post-Analysis Commands

After the automated analysis completes:

```bash
# Generate summary reports
find docs/repository-analysis -name "*.md" | xargs grep -l "P0" > docs/critical-issues.txt
find docs/repository-analysis -name "*.md" | xargs grep -l "CI/CD: GitHub Actions" > docs/cicd-ready.txt
find docs/repository-analysis -name "*.md" | xargs grep -l "Security" | wc -l > docs/security-concerns-count.txt
```

---

Remember: The goal is to complete the entire analysis with minimal interaction. If Copilot asks for permission, remind it to batch operations and use the non-interactive approach outlined here.