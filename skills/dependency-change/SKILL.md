---
name: dependency-change
description: >-
  Use when adding, upgrading, replacing, or removing a third-party dependency. Enforces: prefer not adding new production dependencies (favor existing code, the standard library, and open standards); keep dependencies current; remove unused ones completely; ensure anything that contacts an external service is tested with mocks; and credit every add, update, or removal wherever the project tracks attribution.
---

# Changing a dependency

Every dependency is a long-term liability. Each add, update, or removal is a deliberate, reviewable change — not an incidental side effect of other work.

## Before adding a new dependency
- **Prefer not to.** Avoid introducing new dependencies to production code. First check whether existing structures, the standard library, or an open standard already cover the need, and prefer those.
- If a new dependency is genuinely warranted, confirm it is actively maintained and current, has a license compatible with this project, and is the smallest, most standard option that fits.

## When updating
- Keep third-party dependencies current — move toward the latest stable version.
- Review the changelog for breaking changes, run the full test suite, and resolve any fallout before committing.

## When removing
- Remove a dependency as soon as it is no longer needed.
- Remove it **completely**: from the manifest, the lockfile, and any leftover imports or usages. Confirm nothing still references it.

## Always: attribution
- Whenever a dependency is introduced, updated, or removed, make sure it is properly credited, so attribution stays accurate. This is required for every dependency change.
- Follow the license tracking process named in the project's own `AGENTS.md` — projects differ, and some generate their credits from the build rather than by hand. If no such process is named there, track them in `LICENSE.md`.

## Tests
- If the dependency causes code to initiate calls to an external service, that code must have test coverage, and the external service must be mocked (including the local database). See the coverage rules in the `new-feature` skill.

## Keep it reviewable
- Keep dependency changes easy to review and to roll back — ideally in their own commit, separate from feature logic (the same separate-commit discipline as the `refactor` skill).
