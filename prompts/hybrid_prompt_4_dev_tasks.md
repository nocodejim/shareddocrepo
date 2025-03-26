###This needs to be santized to make it general but I wanted to start saving all of my conversations starters to find patterns and develop templates


I've attached a GitHub repository to this chat that needs a couple of bugs corrected. I'd like you to analyze all JavaScript files, package.json, and manifest.yaml files to identify what should be happening when compared to the similar files from the AzureOpenAI implementation.

A couple of the problems that now exist:
Risk screen isn't available so I can't create mitigations based on the risks- We have not enabled that functionality.  Following the current patterns and the riskDetails.js from the AzureOpenAI completed version of this file (attached as a project knowledge document)
Create test steps does nothing when clicking it in the interface, there is nothing in the console at all , so that I believe it isn't enabled or there is a broken reference somewhere in the manifest or testCaseDetals.js

Create a unit test to insure that every menu item is active and available.  
Create an Updated riskDetails.test.js that properly tests and covers all new functionality added to the riskDetails page
When responding to my requests, please adhere to these principles for optimal results:

1. Analysis & Planning First
Begin by thoroughly understanding my goals before proposing solutions
Identify critical constraints, dependencies, and requirements
Present a brief analysis of the problem space before diving into solutions
When multiple approaches exist, summarize top 2-3 options with clear tradeoffs
2. Implementation Excellence
Favor proven, established patterns over novel approaches
Construct solutions that are simple, maintainable, and extensible
Use existing code patterns when available - consistency trumps optimization
Reuse working code whenever possible; don't reinvent what already works
For any technical implementation, include appropriate error handling
When making significant changes, explain your reasoning
3. Documentation Standards
Include clear, concise comments that explain "why" not just "what"
Document assumptions, limitations, and prerequisites
For complex code, provide a brief overview of how components interact
Use consistent naming conventions that are self-documenting
Add usage examples for non-trivial implementations
4. Security & Best Practices
Consider security implications in all technical advice
Highlight potential vulnerabilities or edge cases
Follow the principle of least privilege in system design
Validate all inputs and handle errors gracefully
Flag any code that might have unintended consequences
5. Quality Control
Verify all syntax before presenting code solutions
Double-check that variable names are consistent
Ensure file paths match established project structures
Validate that examples actually work in the specified environment
Test edge cases in complex logic
6. Communication Style
Present information in order of importance, not complexity
Use clear section headers for longer responses
Prioritize actionable advice over theoretical exploration
Focus responses on the specific question asked
Keep explanations concise but complete
7. Web Search & Information Verification
When searching the web, use multiple authoritative sources to validate information
Clearly cite sources with links when providing information from the internet
Distinguish between verified facts from searches and logical inferences
Be transparent about the recency and reliability of found information
Synthesize information across sources rather than relying on a single source
8. Code Testing & Verification
Use the analysis tool to validate code solutions before presenting them
Share test results and execution outputs when relevant
For complex solutions, demonstrate edge case handling through testing
If you have simulation capabilities, use them to verify recommendations
Acknowledge limitations in testing and suggest additional validation approaches
9. Project Context Adherence
Treat all attached project files, GitHub repositories, and documentation as authoritative
Always reference and adhere to established project patterns and conventions
Before suggesting changes, verify compatibility with the existing project structure
Use terminology and naming conventions consistent with project documentation
Never contradict established project requirements or knowledge files
10. Efficiency & Economy
Prioritize solutions that minimize computational resources
Structure responses to avoid unnecessary repetition or verbosity
Consolidate similar concepts to reduce overall response length
For code solutions, favor efficiency and readability over clever optimizations
Skip theoretical explanations unless specifically requested
When I'm asking for help with an existing project, always begin by understanding what's already working before suggesting changes. For creative tasks, seek clarification on style and constraints before proceeding. For analytical tasks, establish evaluation criteria upfront.

Remember: simple, elegant, well-documented, secure outcomes are the priority, while respecting existing project knowledge, efficiently using resources, and verifying information through testing and reliable sources.

Repository Analysis
- Examine the overall structure of the repository
- Identify key JavaScript files and their purposes
- Note any patterns in how utilities are currently organized in both the github repo (under development) and the attached project files from the Azure-OpenAI implementation that this project is based on
Refactoring Plan
- Create a detailed plan for fixing the teststeps problem and how you will implement the risk details and tests

Execution
- For 2-3 of the most impactful development opportunities, please:
  * Write the exact code that should be added to each of the files we are updating
  * Show the before/after changes for the affected file
  * Include any necessary import statements and manifest.yaml updates needed
Testing Strategy
- Outline how these changes should be tested to ensure functionality isn't broken
- Include specific test cases that would verify the refactored code works as expected
- Suggest any automated tests that should be added or modified
Impact Analysis
Model these recommended fixes and state the impact to the project and the confidence in your work

Please be precise in your analysis and recommendations, and consider how these changes align with the existing code style and patterns in the repository. Provide code snippets with proper syntax highlighting where appropriate.
