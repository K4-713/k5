---
name: unfrak-finish
description: >-
  Last stage of an unfrak: treat the newly ratified documentation as a feature
  that is only partly built, and close the distance — refactor for testability,
  fix every gap in the register through `new-feature`, and test every promise —
  until the area is indistinguishable from one written under DDD from the start.
  Use after `unfrak-lock`, once ratification is complete and no verdicts are
  still pending.
---

# Finishing the job

The earlier stages deliberately left the code alone. They produced a
specification the user ratified, a register of everywhere the code falls short
of it, and tests for the parts that already worked. That is an honest snapshot,
but it is not DDD — under DDD the documentation came first and the code was
built to satisfy it. This stage closes that distance.

When it ends, nothing about the area should betray that it was written before
its spec: every documented promise is delivered and tested, and the register is
empty of it.

## 1. Do not start early
Two preconditions, both hard:

- **Ratification is complete.** No pending verdicts, no "we'll check that next
  week". Fixing code against a spec that is still moving produces work that has
  to be redone, and worse, it quietly settles open questions by implementing one
  answer.
- **`unfrak-lock` has run.** The behavior that already worked is pinned. Those
  tests are the safety net every change in this stage swings over — without them
  a fix that breaks working behavior looks exactly like a fix that worked.

## 2. Refactor for testability first, and separately
Most gaps cannot be tested where they sit: the code reaches into a page, a
global, a clock, or the network with nothing to hand a test. Run the `refactor`
skill and introduce the seams — as their own commits, behavior unchanged, proven
by the tests from `unfrak-lock`.

Doing this before any behavior changes is what keeps the next step honest. A
commit that both restructures and corrects is one nobody can review, and one that
bisect cannot help you with later.

## 3. Close each gap as its own `new-feature` run
Work the register entries one at a time. Each entry is already a complete brief:
the intended behavior is the spec, and the assertions written when the gap was
found are the failing test to start from. That is exactly the input `new-feature`
expects, so use it rather than improvising — the discipline that writes the test
first matters more here than anywhere, because the code being changed is code
somebody already relies on.

**One gap per commit**, and the register entry is deleted in that same commit. A
commit that closes three gaps cannot be reverted when one of them turns out
wrong.

Order by the cost each entry recorded, not by which is easiest. The easy ones are
tempting and they are how a repair pass ends with the dangerous entries still
open.

## 4. Expect the work to talk back
Fixing reveals things reading did not. When it does, stop and route it:

- A fix that turns out to contradict the documentation → back to
  `unfrak-ratify`. The user settles it; the spec may be what changes.
- A behavior nobody inventoried, found while working in the code → inventory it
  and ratify it. Do not fix your way past an unspecified behavior.
- A gap that turns out to be a feature-sized project → say so plainly rather than
  half-fixing it. It leaves the register only when it is genuinely closed; until
  then the area is not finished, and pretending otherwise is the one outcome this
  stage cannot allow.

## 5. Remember these fixes are live changes
Everything here alters behavior that real users are currently relying on, which
the earlier stages never did. So this stage inherits the project's ordinary rules
for changing working software: migrations paired with rollbacks, deploys that can
be reversed, and anything perceptual confirmed by the user rather than by your
own inspection.

Corrected history is worth calling out specifically. When a gap has been writing
wrong data, fixing the code does not fix what was already stored. Say what the
bad data is, whether it can be reconstructed, and how long the effects persist —
that belongs in the commit message and usually in `TODO.md`.

## 6. Verify compliance, item by item
The area is finished when all of these hold — check them, do not assume them:

- Every end-user documentation line for the area has a `TDD_` test that cites it,
  and the suite is green.
- Every engineering decision recorded for the area has its test.
- The register holds no entries for the area.
- The working record has no unanswered questions and no unverified evidence.
- The architecture notes match what the code now does, not what it did before the
  fixes.

Then close the area as the umbrella describes: commit, run `wrap-up-work`, delete
the working record.

## 7. Do not let finishing become rewriting
The mandate is to make the code deliver its documented behavior — not to
modernise it, restructure it to taste, or fold in improvements nobody ratified.
Those are separate work with separate justification. An unfrak that turns into a
rewrite loses the property that made it safe: at every step, the difference
between what the code does and what it is supposed to do was small enough to see.
