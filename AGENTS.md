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

# Intent Gaps
- See INTENT_GAPS.md — places where the code does not yet do what README.md says it
  should, each with the cost of leaving it and the assertions that will prove it closed.
  Created and maintained by the `unfrak` workflow; a queue, not an archive, so an
  entry is deleted by the commit that closes it. Absent until a retrofit finds a gap,
  and deleted again — along with this entry — once the last one is closed.

# Next Steps
- See TODO.md

# Routing facts to the right document
Before recording any behavior, rule, or detail, decide where it belongs. Filing
internal mechanisms into the end-user docs is a recurring mistake — guard against it.
Ask, in order:
1. Can a user observe or rely on this just by using the product — without reading code, internal docs, or tests? Does it change what they do, see, or can expect? → If yes, it belongs in README.md, stated high-level and in plain user language (what they can do and what happens, never how it works internally).
2. Otherwise, is it a rule the implementation must obey — a commitment whose violation would be a bug (storage invariants, formats, ID/generation rules, platform constraints, security mechanisms)? → If yes, it belongs in ENGINEERING_DECISIONS.md, with the next ED-<n> id and a TDD_ test.
3. Otherwise it merely describes how the code is built today and could change without breaking a promise → ARCHITECTURE.md (descriptive, no test).

Default to the lowest altitude that fits. When unsure whether something is user-facing,
it almost certainly is not — prefer an engineering decision over the README. The README
earns each line: if deleting a sentence would not stop a user from doing or expecting
something, it does not belong there.
* "Your export downloads as a CSV you can open in any spreadsheet" → README; "export rows are UTF-8 with a BOM and CRLF line endings" → engineering decision.
* "You stay signed in across restarts" → README; "session tokens live in the OS keychain and rotate every 24h" → engineering decision.

# Coding Practices
Project requirements are defined by the end-user documentation, and features are built
test-first under Documentation Driven Development. The detailed procedure is the
`new-feature` skill; the binding rules are:
* Behavior is specified in the end-user docs before it is built, and the user — not the agent — authors those docs.
* Automated tests (TDD_ prefix) are written from the documented behavior and must fail before implementation.
* Binding, non-user-facing decisions are recorded in ENGINEERING_DECISIONS.md, each with a TDD_ test, before implementing.
* Implement until the documentation tests pass; keep the tests to prevent regressions.
* Note remaining work in TODO.md.

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
* Whenever a dependency is introduced, updated, or removed, make sure it is properly credited. If no license tracking process is named in the project's own AGENTS.md, track them in LICENSE.md.
* When making any of these changes, follow the `dependency-change` skill

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
* `new-feature` — when starting or implementing net-new behavior. Walks the test-first DDD loop: confirm the spec in the end-user docs, write failing `TDD_` tests, record engineering decisions, implement to green, update `TODO.md`.
* `refactor` — when restructuring existing code without changing its observable behavior. Keeps the refactor in its own commit, separate from feature work, and re-verifies behavior with the existing tests.
* `dependency-change` — when adding, upgrading, replacing, or removing a third-party dependency. Enforces the dependency rules below, including crediting the change wherever this project tracks attribution.
* `wrap-up-work` — when finishing a chunk of work, before committing or opening a PR. Reconciles the documentation against the code and closes `TDD_` test gaps.
* `confirm-by-eye` — when iterating on a change that can only be judged perceptually (look, motion, feel, sound, timing) and cannot be pinned by a `TDD_` test. Isolates one change at a time, gives the user an A/B toggle in the real running product, and treats the user's perception — not the agent's own probe — as the verdict.
* `unfrak` — when adopting DDD on code that was written before it, or on a feature area that has no spec at all. The umbrella workflow: takes one area at a time and runs its eight stages, each of which is its own skill.
  * `unfrak-survey` — finds what still has no ratified spec and ranks it by what being wrong there would cost and how likely wrong is, leaving a backlog to work through. Run before the first area, and again when the backlog goes stale.
  * `unfrak-inventory` — reads the area and lists what it actually does, with `file:line` evidence and honest confidence, routed to end-user docs / engineering decisions / architecture before the user sees any of it.
  * `unfrak-ratify` — walks the user-observable candidates with the user one at a time, taking a verdict on each: right, wrong, not a promise, or pending. The user authors the resulting documentation.
  * `unfrak-register` — records every place the code does not do what the user says it should, with the cost of leaving it and the test that will prove it closed.
  * `unfrak-lock` — writes `TDD_` tests for the ratified behavior the code already delivers, and deliberately none for behavior it does not, so a retrofit never leaves the suite red or noisy.
  * `unfrak-backfill` — treats the ratified documentation as a feature that is only partly built: refactors for testability, closes every register entry through `new-feature`, and tests every promise, until the area reads as though it had been written under DDD from the start.
  * `unfrak-harden` — covers what the documentation never promised: the paths that can destroy data, handle PII, or call an external service. Writes the test coverage required above, then walks each security weakness with the user one at a time and records the verdicts, with their reasoning, in `SECURITY_NOTES.md`.
  * `unfrak-polish` — brings the area into conformance with the coding practices, guidelines, logging, accessibility, and performance rules stated above, every finding citing the rule it serves. Proposes the ranked list before any code moves, then fixes what the user approves under `refactor`.
