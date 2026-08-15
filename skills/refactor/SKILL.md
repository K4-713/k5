---
name: refactor
description: >-
  Guide a targeted refactor under the DDD workflow: keep refactors separate from feature work (as their own prep commit), make sure the target has thorough test coverage first, then refactor and re-verify that behavior is unchanged using those same tests. Use when asked to refactor, clean up, simplify, or restructure existing code without changing its observable behavior.
---

# Refactoring

Refactoring changes the shape of the code without changing its observable behavior. Treat it as a distinct kind of work from feature development.

## When to refactor
Refactor to:

- Comply with new requirements or objectives
- Simplify existing code
- Improve performance
- Remove or update old dependencies
- Remove deprecated features and general cruft

## How to refactor safely

1. **Keep it separate from feature development.** If a new feature requires refactoring, do the required refactor as its own prep commit *before* working on the feature directly.
2. **Keep it targeted.** Confine each refactoring commit to one or two improvements.
3. **Cover before you change.** First make sure the targeted code has thorough test coverage for all expected behavior in that part of the system.
4. **Refactor.**
5. **Re-verify with the same tests.** Reuse the tests from step 3 to confirm the refactor did not change any expected system behavior.

It is not unusual to uncover and fix pre-existing bugs during this process. Document any such fixes in the commit message.
