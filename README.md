# Shared Documentation Repository

This repository serves as a central location for various types of documentation, including guides, AI interaction prompts, Value Stream Mapping exercises, demonstration files, and code coverage reports.

## Guides

This section contains comprehensive guides and tutorials on various topics, primarily focused on developer tools and AI-assisted development.

*   [`compass_artifact_wf-b9a665ad-c608-4ee3-9b67-07e288ff9c8c_text_markdown.md`](compass_artifact_wf-b9a665ad-c608-4ee3-9b67-07e288ff9c8c_text_markdown.md): A detailed guide on GitHub Enterprise PAT strategy, comparing fine-grained vs. classic tokens and outlining migration strategies for enterprises.
*   [`guides/Claude-guide v1.md`](guides/Claude-guide%20v1.md): A comprehensive guide for novice developers on using GitHub Copilot, covering prompting techniques, VS Code integration, CLI usage, WSL integration, documentation generation, context management, best practices, and advanced features.
*   [`guides/GHCP-Guideline_Policy.md`](guides/GHCP-Guideline_Policy.md): A high-level policy and strategy document for deploying GitHub Copilot Enterprise in regulated industries like insurance, focusing on security, compliance, and governance.
*   [`guides/GHCP-Guideline_starter.md`](guides/GHCP-Guideline_starter.md): A practical, developer-facing guide for using GitHub Copilot in an enterprise setting, covering best practices, security, workflows, and prompting techniques.
*   [`guides/Gemini_GitHub_Copilot_Agentic_Mode_Guide_.md`](guides/Gemini_GitHub_Copilot_Agentic_Mode_Guide_.md): An in-depth guide to GitHub Copilot Agent Mode, discussing its effectiveness, compatibility with terminal environments, file handling limitations, optimization with the GitHub Copilot Team plan, and comparisons of different AI models.
*   [`guides/comprehensive-guide-prompt.md`](guides/comprehensive-guide-prompt.md): A template for creating prompts to generate comprehensive technical guides, outlining required components like technical depth, user experience walkthroughs, context management, and practical application guidance.
*   [`guides/comprehensive_GithubApps_Claude.md`](guides/comprehensive_GithubApps_Claude.md): A comprehensive security guide for GitHub Apps targeted at administrators, detailing the security architecture, comparison with PATs, and setup best practices with 2025 updates.
*   [`guides/copilot-agent-context-guide.md`](guides/copilot-agent-context-guide.md): Reference guide for Copilot Agent context types and usage examples.
*   [`guides/copilot-agent-wsl-container-guide.md`](guides/copilot-agent-wsl-container-guide.md): A setup guide for GitHub Copilot Agent Mode with WSL and containers, covering VS Code setup, Agent Mode configuration, WSL terminal usage, container integration strategies (wrapper scripts, volume mounting, Dev Containers), and Maven test execution.
*   [`guides/dev-container-patterns.md`](guides/dev-container-patterns.md): Describes effective Java development container patterns for Windows with WSL, focusing on volume management, user permission management, tool integration (VS Code Remote Containers, Docker Compose), and sync/rebuild patterns.
*   [`guides/dev-containers-quick-start-cheatsheet.md`](guides/dev-containers-quick-start-cheatsheet.md): Quick-start cheat sheet for using Dev Containers, including file operations and WSL-specific instructions.
*   [`guides/dockerfile.txt`](guides/dockerfile.txt): A Dockerfile for creating a Java development environment using Maven and OpenJDK 17, including installation of additional dependencies and creation of a non-root user with sudo privileges.
*   [`guides/fix-permissions-script.sh`](guides/fix-permissions-script.sh): A shell script to fix permissions on mounted volumes within a Docker container, specifically for a 'developer' user and the '/home/developer/project' directory.
*   [`guides/github-copilot-agent-documentation-guide.md`](guides/github-copilot-agent-documentation-guide.md): A guide on using GitHub Copilot Agent Mode in VS Code to automatically document an unfamiliar codebase from a DevOps perspective. It covers setup, creating a documentation structure, and generating content for overview, file relationships, code examples, testing, logging, dependencies, and modernization opportunities.
*   [`guides/github-copilot-agent-mastery.md`](guides/github-copilot-agent-mastery.md): Advanced guide for mastering GitHub Copilot Agent Mode, with best practices for context management and file selection.
*   [`guides/github-copilot-agentic-mode-guide.md`](guides/github-copilot-agentic-mode-guide.md): Guide to Copilot Agentic Mode, including file creation, refactoring, and documentation generation capabilities.
*   [`guides/github-copilot-custom-instructions-guide.md`](guides/github-copilot-custom-instructions-guide.md): A guide to repository-level custom instructions for GitHub Copilot, explaining how to set up `.github/copilot/instructions.md`, prompt templates, and reference files. It covers content structure, recommended patterns, security considerations, and best practices.
*   [`guides/github-copilot-edits-use-case-guide.md`](guides/github-copilot-edits-use-case-guide.md): A guide on using GitHub Copilot Edits (specifically Agent Mode) for generating comprehensive test coverage for a Java application. It outlines a phased approach with prompt templates and best practices.
*   [`guides/github-copilot-for-novice-developers.md`](guides/github-copilot-for-novice-developers.md): A comprehensive guide for beginners on using GitHub Copilot (2025 Edition), covering setup, capabilities (completion, chat, edits, agent mode), prompting techniques, VS Code integration, learning with Copilot, and common challenges.
*   [`guides/github-copilot-guide.md`](guides/github-copilot-guide.md): Comprehensive guide for novice developers on GitHub Copilot, including prompting, context, and workflow tips.
*   [`guides/github-copilot-instructions_md_file_reference.md`](guides/github-copilot-instructions_md_file_reference.md): Reference guide for creating and managing `.github/copilot-instructions.md` files, with best practices and examples.
*   [`guides/github-copilot-knowledge-base.md`](guides/github-copilot-knowledge-base.md): A knowledge base document about GitHub Copilot (as of May 2025), detailing plans, installation, core features (completion, chat, edits), advanced features (Agent Mode, NES, Coding Agent, Workspace), prompting strategies, IDE integrations, CLI support, and enterprise considerations.
*   [`guides/github-copilot-knowledgebase-resources.md`](guides/github-copilot-knowledgebase-resources.md): Resource list and organizational strategy for a GitHub Copilot knowledge base, including content creation frameworks.
*   [`guides/github-copilot-mastery.md`](guides/github-copilot-mastery.md): Comprehensive mastery guide for GitHub Copilot, covering advanced prompting, context control, and workflow integration.
*   [`guides/github-copilot-repo-discovery-guide.md`](guides/github-copilot-repo-discovery-guide.md): Step-by-step guide for using Copilot to discover and understand new Java repositories, with prompts and best practices.
*   [`guides/github-copilot-technical-guide.md`](guides/github-copilot-technical-guide.md): A complete technical guide to GitHub Copilot (2025), covering plans, installation, IDE integration, prompting, context management, operational modes (Chat, Edit, Agent), model selection, CLI usage, knowledge base integration (Enterprise), security, and enterprise administration.
*   [`guides/github-copilot-use-case-guide.md`](guides/github-copilot-use-case-guide.md): A guide to practical applications of GitHub Copilot, covering use cases like test generation, multi-file refactoring, documentation generation, legacy code modernization, API integration, security best practices, performance optimization, and domain-specific development (web, data science, mobile, DevOps).
*   [`guides/github_app_guide.md`](guides/github_app_guide.md): A comprehensive guide to creating GitHub Apps, explaining the benefits over PATs, and walking through the step-by-step creation, configuration, and authentication process.
*   [`guides/github_apps_Gemini.md`](guides/github_apps_Gemini.md): A comprehensive guide to GitHub Apps, focusing on security, comparison with PATs, and administration, likely generated by the Gemini model.
*   [`guides/github_auth_security_matrix.md`](guides/github_auth_security_matrix.md): A security matrix that rates and compares various GitHub authentication methods (GitHub Apps, PATs, OAuth, SSH, etc.) based on criteria like token lifespan, permissions, and auditability.
*   [`guides/implementation_guide.md`](guides/implementation_guide.md): A quick implementation guide for setting up a SharePoint Trivia Game using PowerShell, Power Automate, and a SharePoint web part. *Note: This guide is functionally different from the other developer-focused documents in this repository.*
*   [`guides/troubleshooting-summary.md`](guides/troubleshooting-summary.md): A summary of a persistent Docker permissions issue encountered when running a Maven-based Java project in a Docker container on WSL, and recommends using named volumes as a solution.

## Prompts

This section includes templates and frameworks for crafting effective prompts for AI assistants, particularly for coding and project management tasks.

*   [`guides/github-copilot-tech-debt-prompt.md`](guides/github-copilot-tech-debt-prompt.md): A detailed prompt template for directing an AI assistant to perform a comprehensive technical debt analysis on a repository and generate a prioritized remediation plan.
*   [`prompts/Prompt_template.md`](prompts/Prompt_template.md): A template for creating detailed prompts for AI-assisted coding tasks, emphasizing environment setup, artifact generation, build/deploy scripts, and comprehensive documentation.
*   [`prompts/add2every_message.md`](prompts/add2every_message.md): An "Expert Advisor Framework" outlining principles for an AI assistant to follow when responding to requests, covering analysis, implementation, documentation, security, quality control, communication, web search, code testing, project context adherence, and efficiency.
*   [`prompts/chat_starter_w_GitHub.md`](prompts/chat_starter_w_GitHub.md): Starter prompt for Copilot Chat, outlining repository analysis, testing strategy, and impact analysis requirements.
*   [`prompts/claude_Project_Starter.md`](prompts/claude_Project_Starter.md): A project management framework for the Claude AI, focusing on adaptive budget management, minimalist solution principles, a draft system with self-criticism, and specific analysis requirements.
*   [`prompts/copilot_repo_assessment_prompt.md`](prompts/copilot_repo_assessment_prompt.md): A detailed prompt for GitHub Copilot to perform a comprehensive repository assessment. It includes instructions for setting up a branch and folder structure, creating an index document, and conducting analyses in areas like architecture, pipeline readiness, monitoring, automation, security, and code quality, with final recommendations.
*   [`prompts/heavy_project_prompt.md`](prompts/heavy_project_prompt.md): A prompt framework for an AI assistant (like Claude) that emphasizes deep thinking, self-criticism, and iterative refinement. It includes budget management for "steps", a draft system with mandatory criticism, self-assessment rules, and specific analysis requirements, forbidding superficial or unevidenced claims.
*   [`prompts/hybrid_prompt_4_dev_tasks.md`](prompts/hybrid_prompt_4_dev_tasks.md): Hybrid prompt for development tasks, including repository analysis, refactoring plan, testing strategy, and impact analysis.
*   [`prompts/structured_Claude_Project`](prompts/structured_Claude_Project): Outlines a "Claude-Aligned Problem Solving Framework" that focuses on depth of processing, multidimensional exploration, self-criticism prompts, iterative solution refinement, minimalist principles, transparency requirements, context integration, and a verification checklist. This seems to be a meta-prompt for structuring interactions with an AI model.
*   [`prompts/unit_test_phase_1.md`](prompts/unit_test_phase_1.md): A prompt for GitHub Copilot to generate the first phase of unit tests for a Java application, aiming for 20% code coverage by analyzing a JaCoCo report. It specifies requirements for bulk test generation, verification, and strategic targeting of classes.

## Value Stream Maps (VSM)

This section contains Value Stream Mapping exercises and analyses, often including Mermaid diagrams to visualize processes.

*   [`vsm/Readme.md`](vsm/Readme.md): A placeholder readme for Value Stream Map exercises.
*   [`vsm/cape-certificate-process-diagram2.md`](vsm/cape-certificate-process-diagram2.md): Contains a Value Stream Map (VSM) for a "Cape Certificate Expired Process," visualized using a Mermaid flowchart. It includes process times (PT) and lead times (LT) for each step, along with a summary of process metrics (Total PT, Total LT, Value-Add Ratio) and an analysis of improvement opportunities. This appears to be an iteration of the VSM, excluding CRQ closure for a better ratio.
*   [`vsm/cape-certificate-process-diagramv3.md`](vsm/cape-certificate-process-diagramv3.md): A detailed Flow Engineering analysis of a Cape Certificate renewal process, including a Mermaid diagram, focusing on improving flow efficiency and reducing constraints.
*   [`vsm/optimized_vsm.md`](vsm/optimized_vsm.md): An analysis of an existing Value Stream Map, identifying wait times as the primary bottleneck and proposing a more efficient, automated future state with a Mermaid diagram.
*   [`vsm/project-timeline.md`](vsm/project-timeline.md): A chronological list of activities for a project, detailing times and processes from a Splunk Alert to CRQ closure. It includes notes questioning certain steps, like architectural approval for a certificate.
*   [`vsm/vsm2-2.md`](vsm/vsm2-2.md): Another version of the Cape Certificate Expired Process Value Stream Map, visualized with a Mermaid flowchart. This version includes the CRQ closure step, resulting in a lower Value-Add Ratio (10.2%) compared to diagram2. It analyzes key process steps, waiting times, and improvement opportunities.
*   [`vsm/vsm_0610_143820.md`](vsm/vsm_0610_143820.md): A detailed, generated Value Stream Map visualizing a complex development and deployment process flow using a Mermaid diagram.

## Demos

Demonstration files, often including diagrams or specific examples.

*   [`demos/maven_level_1.md`](demos/maven_level_1.md): A Mermaid diagram illustrating the dependency graph for Apache Maven.

## Dockerfiles

This section contains Dockerfiles for setting up development environments.

*   [`dockerfiles/maven_dev_dockerfile`](dockerfiles/maven_dev_dockerfile): A Dockerfile for creating a Java development environment with Maven and OpenJDK 17, including various dependencies and a non-root user setup.

## Architecture

This section contains documents describing system architecture and data flows.

*   [`dataflow.md`](dataflow.md): A Mermaid diagram illustrating the architecture and data flow of a Spira-Azure OpenAI integration.

## Experiments

This section contains experimental and miscellaneous files.

*   [`experiments/github-app-guide.md`](experiments/github-app-guide.md): A comprehensive, hands-on guide to creating a GitHub App with DevOps best practices, including code examples for authentication, logging, CI/CD pipelines, and more.
*   [`experiments/githubapp.md`](experiments/githubapp.md): A phased, hands-on tutorial for safely experimenting with GitHub Apps in an EMU (Enterprise Managed User) environment, covering creation, authentication, and permission testing.
*   [`experiments/silly.html`](experiments/silly.html): A 3D interactive "DOOM DevOps Team Office" experience built with Three.js, allowing users to walk around a virtual office and interact with characters.

## Code Coverage Reports

This section links to HTML reports detailing code coverage statistics for various JavaScript files. The main index provides a summary and navigation to individual file reports.

*   [`docs/index.html`](docs/index.html): Main index for all code coverage reports.
*   [`docs/claudeAssistant-module.js.html`](docs/claudeAssistant-module.js.html): Coverage report for `claudeAssistant-module.js`.
*   [`docs/claudeAssistant.js.html`](docs/claudeAssistant.js.html): Coverage report for `claudeAssistant.js`.
*   [`docs/common-module.js.html`](docs/common-module.js.html): Coverage report for `common-module.js`.
*   [`docs/common.js.html`](docs/common.js.html): Coverage report for `common.js`.
*   [`docs/constants-module.js.html`](docs/constants-module.js.html): Coverage report for `constants-module.js`.
*   [`docs/constants.js.html`](docs/constants.js.html): Coverage report for `constants.js`.
*   [`docs/requirementDetails-module.js.html`](docs/requirementDetails-module.js.html): Coverage report for `requirementDetails-module.js`.
*   [`docs/riskDetails-module.js.html`](docs/riskDetails-module.js.html): Coverage report for `riskDetails-module.js`.
*   [`docs/taskDetails-module.js.html`](docs/taskDetails-module.js.html): Coverage report for `taskDetails-module.js`.
*   [`docs/taskDetails.js.html`](docs/taskDetails.js.html): Coverage report for `taskDetails.js`.
*   [`docs/testCaseDetails-module.js.html`](docs/testCaseDetails-module.js.html): Coverage report for `testCaseDetails-module.js`.
*   [`docs/testCaseDetails.js.html`](docs/testCaseDetails.js.html): Coverage report for `testCaseDetails.js`.

---
*Note: Some files are listed with "(Needs a description. Content not reviewed yet.)" as their content was not reviewed in detail during the initial information gathering phase. These descriptions can be updated as the files are reviewed.*
