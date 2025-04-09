# COMPREHENSIVE JAVA UNIT TEST GENERATION - PHASE 1

## OBJECTIVE:
Generate unit tests to achieve 20% code coverage across this Java application, using the provided JaCoCo report to guide your strategy.

## CRITICAL REQUIREMENTS:
1. ANALYZE THE JACOCO REPORT: Examine the coverage report to identify untested classes and methods
2. GENERATE TESTS IN BULK: Create at least 20-30 tests per execution, targeting multiple classes
3. TEST VERIFICATION: Compile and run each test before finalizing to ensure they work
4. STRATEGIC COVERAGE: Focus on classes that will provide the biggest coverage gains first

## PROCESS INSTRUCTIONS:
- START WITH REPORT ANALYSIS: Examine the JaCoCo report to identify classes with 0% coverage
- PRIORITIZE HIGH-IMPACT TARGETS: Focus on core business logic classes with many methods
- WORK IN LOGICAL GROUPS: Test related classes together to ensure consistent test approach
- CREATE COMPREHENSIVE TESTS: Don't settle for minimal tests - cover multiple paths and edge cases
- CRITIQUE YOUR APPROACH: After drafting tests, identify weaknesses and improve them
- DOCUMENT COVERAGE STRATEGY: Explain which classes you're targeting and why

## TEST IMPLEMENTATION:
- Use JUnit 5 with appropriate assertions and extensions
- Create proper test fixtures with @BeforeEach and @AfterEach where needed
- Implement mocks for external dependencies using Mockito
- Organize tests to match the application's package structure
- Include tests for normal operation, edge cases, and error handling
- Document each test's purpose and coverage targets with clear comments

## EXECUTION VERIFICATION:
- Ensure all tests compile successfully
- Verify tests would run without errors
- Estimate the expected coverage increase from your tests
- Identify target areas for the next round of testing

Challenge your first draft of tests, identify weaknesses, and improve upon them before finalizing. Focus on quality and comprehensive coverage rather than minimal tests that only verify basic functionality.
