---
name: unfrak-lock
description: >-
  Fifth stage of a DDD retrofit: write TDD_ tests for the ratified documentation
  lines the code already delivers — and only those — so confirmed behavior cannot
  regress, while gaps stay in the register rather than as red or skipped tests.
  Use after `unfrak-ratify` has settled an area's verdicts, and before
  `unfrak-finish` closes those gaps.
---

# Locking ratified behavior with tests

Documentation nobody can check is a wish. This stage turns the ratified lines
into tests, and in doing so audits the review itself.

## 1. Test only what the code already delivers
Write a `TDD_` test for each documentation line the code satisfies today, citing
the line it covers. The test should pass the moment it is written, because it
describes working code.

**If it fails, stop.** Either the documentation line is wrong or the review
missed something, and both belong back in `unfrak-ratify` — this is one of the
main reasons the tests are worth writing at all. Do not adjust the test until it
passes; that is how a reading error becomes permanent.

## 2. Write nothing *yet* for a line the code does not meet
Not a failing test, not a skipped one, not a commented-out one. The register
entry carries that obligation, and the test gets written in `unfrak-finish`, by
the `new-feature` run that closes the gap — where it belongs, as the failing test
that drives the change.

The wait is short by design: `unfrak-finish` is the next stage, not a someday.
This stage stops short of it only so that the spec is settled before any code
moves.

This is a deliberate trade. An executable reminder is stronger than a document.
But a retrofit runs in small bites on a live codebase, alongside other people's
work, and it must never end a session with a suite that is red or noisy. A red
suite that is *expected* to be red stops carrying information, and it takes
"green means safe to commit" down with it for everyone else. The register is the
reminder; the suite stays a signal.

## 3. When the code cannot be tested as written, refactor first
Retrofits routinely land on code that has no seam: logic that reaches straight
out to a page, a global, a clock, or a network call, with nothing to hand a test.
Do not bolt a parallel testable path beside it, and do not add a heavyweight
harness dependency to avoid the problem.

Stop and run the `refactor` skill: introduce the seam — take the dependency as an
argument, split the reading from the deciding — as its own prep commit, with the
behavior unchanged. Then come back and write the test. This is the ordinary cost
of retrofitting untested code, and it is worth naming up front when planning an
area, because it is usually the largest single piece of work in the whole
retrofit.

Seams needed only by gap fixes rather than by these tests can wait for
`unfrak-finish`, which opens with exactly this work.

## 4. Cover the expensive cases first
Within the area, prioritise tests for anything destructive or irreversible,
anything handling personal data, and anything that talks to an external service —
mocked, always. A retrofit is often the first time this code has been pinned at
all; spend the first tests where being wrong costs the most.

## 5. Leave the suite better than green
Run the whole suite, not just the new tests, and read the output for warnings as
well as failures. A retrofit that leaves new noise behind has taught everyone
else to ignore the noise.
