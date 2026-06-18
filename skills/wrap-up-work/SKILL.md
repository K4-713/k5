---
name: wrap-up-work
description: >-
  Reconcile end-user documentation and engineering decisions against the actual
  code at the end of a chunk of work. Flags README/doc-vs-code mismatches,
  ensures every documented behavior and every engineering decision has a TDD_
  test, and prunes finished TODO sections. Use when finishing a feature, before
  committing or opening a PR, or when asked to "wrap up", "tidy the docs", or
  "check that the docs match the code".
---

# Wrapping up new work

This is the closing step of the End-User Documentation Driven Development loop.
Its goal is to ensure the code, the end-user documentation, and the tests all
still agree before work is considered done. Make and work through tasks to do
the following, in order.

## 1. Reconcile `README.md` with the code
Look through `README.md` and compare its contents to the current code.

- Identify areas of the code that need either more end-user documentation (which
  should be very high level), or new entries in engineering decisions
  (mechanisms a user would not need explained — because they are either designed
  to be intuitive, or they are not visible to the user).
- Identify parts of `README.md` that need to be corrected.
- If `README.md` must be altered, **do not rewrite it yourself**. Leave
  descriptive placeholders in square brackets in the file, each containing a
  short description of the fix or the undocumented behavior that must be
  addressed.
- Prioritize code behaviors that are currently covered by `TDD_` tests but have
  no corresponding information in `README.md` or the engineering decisions.
- **Wait for the user to fix `README.md` before continuing to the next step.**

## 2. Reconcile the other docs with the code
Review `ARCHITECTURE.md`, `DESIGN.md`, `ENGINEERING_DECISIONS.md`, and
`TODO.md`. Call out every place where the documentation doesn't match the code.
For each mismatch, decide **interactively with the user** which side is more
correct, then change the other side to match.

## 3. Close documentation test gaps
If there are any substantial items in `README.md`, `DESIGN.md`, or
`ARCHITECTURE.md` that don't have `TDD_` tests, write and run those tests to
verify the accuracy of the documentation.

## 4. Enforce the engineering-decision test rule
Confirm every decision in `ENGINEERING_DECISIONS.md` has at least one `TDD_`
test enforcing it. Write any that are missing. If any item is impossible to
test, note that, and explain why.

## 5. Prune the TODO
Remove completely finished sections from `TODO.md`. Leave only sections that
still have unfinished pieces.
