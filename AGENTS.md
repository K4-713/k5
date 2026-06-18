# Overview
This project will take a Documentation Driven Development approach, in which the end-user documentation is written as if the software already exists, and is then used (by humans or agents) as directions to create the software.

# Project Documentation
- See README.md

# Architecture
- See ARCHITECTURE.md (descriptive: how the current code is built)

# Engineering Decisions
- See ENGINEERING_DECISIONS.md — binding, non-user-facing engineering decisions that the
  implementation must adhere to. Prescriptive and test-backed like README.md, but for the
  system's internals rather than user-observable behavior. A statement is an *engineering decision*
  (belongs here, with a test) if it is a requirement we are committing to; it is *architecture*
  (belongs in ARCHITECTURE.md, no test obligation) if it merely describes how today's code works.

# Design
- See DESIGN.md (visual / UX design brief)

# Security Notes
- See SECURITY_NOTES.md — working threat-model notes for protecting sensitive user data
  (exploratory, not binding). Decisions graduate from here to ENGINEERING_DECISIONS.md /
  README.md / DESIGN.md when actually chosen.

# Next Steps
- See TODO.md

# Coding Practices
Project requirements are defined by the end-user documentation. To implement these requirements:
* First, before any code is written for a new feature or requirement, write automated tests that verify the behavior outlined in the end-user documentation. Initially, these tests will fail.
  * These tests will not be the only automated tests, so they should be easily identifiable by a TDD_ prefix in the test name, and commented with the line(s) in the documentation covered by this test
* A feature may also carry binding engineering decisions that users never see (storage invariants, platform constraints, generation rules, etc.). Record these in ENGINEERING_DECISIONS.md *before* implementing, and cover each one with a TDD_ test whose comment cites the decision ID (e.g. `// ENGINEERING_DECISIONS.md ED-3`) rather than a README line.
* Implement the new feature(s)
* Once the feature is implemented, the documentation tests will pass, and keeping those tests will prevent regressions.
* Always note next steps for implementation, if any, in TODO.md

# Guidelines
* Update code comments when relevant changes are made to the code
* Keep ARCHITECTURE.md current
* Use best practices relating to data security
* Use best practices relating to accessibility
* Prefer performant and battery-conscious solutions
* Prefer human-readability over source code brevity, both in structure and in naming
* Code should be modular and reused wherever possible, rather than duplicated. Common patterns should be abstracted out to short reusable helper functions
* Avoid defining "magic numbers" or string constants in the code which could be system settings or config variables
* Config variables containing secrets must not be copied to committed code
* Reuse existing structures, functions, and patterns when writing new features. If existing structures don't support needed behavior, prefer refactoring those structures to add support over parallelizing or short-circuiting existing structures
* Code should be easy to deploy, and must provide a path to roll back
* Use open standards whenever possible

## Dependencies
* 3rd party dependencies must be kept current
* Avoid introducing new dependencies to production code
* Dependencies must be removed when no longer needed
* Whenever a dependency is introduced, updated, or removed, make sure it is properly credited in LICENSE.md

## Logging
* Always log key events for system visibility
* Always use the appropriate log level
  * Errors should be reserved for system-level problems that represent an unexpected outage or partial loss of functionality, which may require developer attention to address
  * Use Warnings for events that are unexpected, not optimal, and/or poorly handled, but that do not represent a system outage or loss of functionality that a user would notice.
  * Info should be used to enable things like counting, tracking, or monitoring performance, and general system activity audits
  * Debug should be saved for verbose logs that are usually not wanted unless there is a problem that requires temporary in-depth troubleshooting
* Changing log level must be achievable via a settings change, rather than a code deploy

## Automated Testing
* Write tests to ensure adherence to the end-user documentation, to uncover bugs in existing code, and to prevent future regressions
* When tests fail, start by looking for bugs in the code covered by the test
* Automated tests must mock everything that may contact external services, including the local database
* All potentially destructive code (code that could delete or overwrite existing data) must have test coverage
* All code that could possibly handle a user's Personally Identifiable Information (PII) must have test coverage
* All code initiating calls to external services must have test coverage
* Examine test run output for errors and warnings, and address them appropriately
  * If they are warnings or errors we are intentionally throwing or expecting as part of the test, try to catch them gracefully before they make it to test output
  * If they are errors or warnings thrown by the test infrastructure, or unexpected messages from the code we are testing, diagnose and address the underlying issue being described
* Test the things we expect to happen. Also test things like edge cases, missing resources, garbage inputs, and successful prevention of things we don't want to happen.

# Workflows
Detailed, step-by-step procedures live as skills, so they load only when needed.
Invoke the matching skill at the right moment:
* `refactor` — when restructuring existing code without changing its observable behavior. Keeps the refactor in its own commit, separate from feature work, and re-verifies behavior with the existing tests.
* `wrap-up-work` — when finishing a chunk of work, before committing or opening a PR. Reconciles the documentation against the code and closes `TDD_` test gaps.
