---
name: new-feature
description: >-
  Build a new feature or requirement test-first under End-User Documentation Driven Development: confirm the behavior is specified in the end-user docs, write failing TDD_ tests from those docs, record any binding engineering decisions, implement until the tests pass, then note follow-ups. Use when starting or implementing net-new behavior — as opposed to `refactor` (no behavior change) or `wrap-up-work` (closing out before a PR).
---

# Building a new feature (the forward DDD loop)

Net-new behavior is built test-first: the end-user documentation is the spec, the tests encode it, and the implementation makes the tests pass. Work the steps in order.

## 1. Establish the spec
For user-facing features, the new feature must be referenced and roughly described in the end-user docs (`README.md`), in the "as if it already exists" voice, *before* any code is written.

- If it is already mentioned, confirm that README.md matches what you're about to build, and move on.
- If it is completely missing, **do not author the README lines and do not write usable prose.** The user owns the end-user docs. Instead, insert a bracketed placeholder that says *where* and *what* is missing but is deliberately **not shippable as written**, then stop and wait for the user to fill it in. Use this form:

  ```
  [NEEDS END-USER DOC — <feature>: state what the user does and what they
  observe; cover <the specific aspects that must be specified>. Internal /
  implementation details do not belong here. Replace this entire bracket.]
  ```

  Do not proceed past this step until the user has written the real text. Note: The README.md is meant to be a very high-level doc primarily written for users of the software, and is not itself meant to be a full spec. Aside from mentioning basic things about user-facing features, not much else will be required here. Properly intuitive design typically doesn't require much explanation, though the user may decide to go deeper for complex interactions.

## 2. Decide what is even user-facing (altitude)
A recurring failure is pushing internal mechanisms up into the end-user docs. For every fact you're tempted to document, route it:

1. **Feature summary** — basic description of the existence, general purpose, and usage of all user-facing features → `README.md`, high-level, plain language, often broad statements. (This is the only thing the user must write in step 1.)
2. **User-observable, complex**  — details about features that require explanation for proper usage or interpretation → `README.md`, lower level, still plain language.
3. **User-observable, intuituve usage**  — details about features that a typical user will understand intuitively without a verbose explanation, but a commitment the implementation must obey, where a violation is a bug (enumeration of all visible columns in a report, verbose description of a simple feature)?  → `ENGINEERING_DECISIONS.md` (step 3).
4. **Binding internal rule** — invisible to users but a commitment the implementation must obey, where a violation is a bug (storage invariants, formats, ID/generation rules, platform constraints, security mechanisms)? → `ENGINEERING_DECISIONS.md` (step 3).
5. **Merely descriptive** — just how the code is built today, free to change without breaking a promise? → `ARCHITECTURE.md`, no test.

When unsure, it is almost certainly **not** user-facing — default to an engineering decision over the README.

## 3. Record engineering decisions first, with tests
Before implementing, work with the user to write binding decisions about non-user-facing implementation and/or intuitive feature usage into `ENGINEERING_DECISIONS.md`, each with the next sequential `ED-<n>` id. Cover each one with a `TDD_` test whose comment cites the id, e.g.:

```
// ENGINEERING_DECISIONS.md ED-7
```

## 4. Write failing tests from the docs
Write automated tests that verify the documented behavior. Conventions:

- Name them with a `TDD_` prefix so they're identifiable among other tests.
- Comment each with the `README.md` line(s) it covers (or the `ED-<n>` id for an engineering-decision test).
- Mock everything that contacts an external service, **including the local database**.
- Run the tests now and confirm they **fail for the right reason** (red). A test that passes before implementation is not testing what you think.

## 5. Implement to green
Implement the feature until the tests pass. If existing structures don't support the change, prefer reshaping them over bolting on parallel or short-circuited paths — do that reshaping as a separate prep commit via the `refactor` skill first, then come back here.

## 6. Coverage check
Before calling it done, confirm tests exist for the high-risk categories:

- Any **destructive** code (could delete or overwrite existing data).
- Any code that could handle a user's **PII**.
- Any code that **initiates calls to external services**.

## 7. Note follow-ups, then hand off
Record any remaining work in `TODO.md`. When the broader chunk of work is ready for commit or a PR, run the `wrap-up-work` skill to reconcile the docs against the code and close any remaining test gaps.
