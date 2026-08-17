---
name: unfrak-polish
description: >-
  The last stage an unfrak runs on an area: bring it into conformance with the coding principles AGENTS.md actually states — readability, modularity and reuse, no magic numbers, logging levels, accessibility, and performance — by auditing against the written rules, proposing the whole ranked list before any code moves, and fixing what the user approves under the `refactor` skill. Use after `unfrak-harden`. Also runs standalone on any area already under DDD with a green suite.
---

# Polishing to the stated principles

An area can be fully specified, fully tested, and fully hardened while still being unpleasant to work in: the same logic copied into four places, a timeout buried as a bare number, a helper nobody could name, an error logged at debug. None of that breaks a promise, so no earlier stage has any grounds to touch it. This stage does, and it is the last thing an unfrak does to an area.

The failure this stage exists to prevent is the obvious one: an agent turned loose to "clean up" rewrites a working codebase to its own preferences, produces a diff nobody can review, and calls the result an improvement. The guard against that is a single rule, and everything below is downstream of it.

**Every finding cites the written principle it serves.** If you cannot name the rule — quote it — the finding is taste, and taste is not in scope. It does not matter how strongly you feel about it.

## 1. Do not start early
`unfrak-harden` must have run. Polish restructures code, and restructuring a dangerous path whose tests do not exist yet is how a retrofit ends by quietly breaking the delete guard nobody had pinned.

The suite must be green before you begin, because green before and green after is the *entire* proof that this stage changed nothing. Starting from a red or noisy suite means there is no proof available, and the work cannot be done honestly.

Standalone runs need the same two things: tests that cover the area, and a suite that passes.

## 2. Audit against the rules, and only the rules
The principles in scope are the ones AGENTS.md states. Read them there rather than from memory — a project's own AGENTS.md may add to them or be more specific, and where it is, it wins.

- **Guidelines** — human-readability over brevity in both structure and naming; modular code reused rather than duplicated, with common patterns abstracted into short helpers; reusing and extending existing structures instead of parallelising or short-circuiting them; comments that match the code they describe; and **no magic numbers or string constants that ought to be settings or config variables**.
- **Logging** — key events logged at all; the *right* level per AGENTS.md's definitions, which are precise and worth rereading (errors mean a system-level problem needing attention, warnings mean unexpected but not user-visible, info means countable activity, debug means verbose troubleshooting); and log level changeable by a settings change rather than a deploy.
- **Accessibility** — best practice on anything rendering a user interface, including UI a browser extension injects into somebody else's page.
- **Performance and battery** — polling, batching, redundant work, and anything that keeps a device awake or busy more than it needs to be.

Gather findings with `file:line` evidence, the principle each one cites, and what it costs to leave. Duplication that has already drifted between copies costs more than duplication that has not; a magic number somebody will eventually change in three of four places costs more than one used once.

## 3. Propose the whole list before moving any code
Rank by what leaving it costs, not by what it takes to fix. Easiest-first is how a polish pass spends its whole budget on trivia.

Present the ranked list and get approval on scope. Group by kind rather than listing fifty items flat — the user is approving a shape of work, not adjudicating each rename. Mark clearly which items are behavior-preserving and which are not, because the second group leaves this skill entirely (step 5).

Expect some to come back as deliberate. Code often looks non-conformant because of a constraint that is not visible in it, and the answer is frequently a comment explaining why rather than a change. **Record those**, so the next polish pass does not raise them again.

If the list is enormous, say so rather than working through it. An area with hundreds of findings is not asking for a polish pass; it is telling you something about how it was built, and that is worth a conversation.

## 4. Fix under the `refactor` skill, in small commits
Run `refactor` for the work itself — this stage decides *what* and *why*, that skill governs *how*. Behavior unchanged, proven by the existing tests.

**One kind of change per commit.** A commit that renames variables *and* extracts helpers *and* moves constants to config is unreviewable, and bisect cannot help anyone with it later. Group the approved findings by kind and work them a kind at a time.

**If a test has to change, stop.** Exactly one of two things is true. Either the test was asserting on the implementation rather than the behavior — in which case fixing the test is its own commit with its own reasoning, and it is a finding in its own right. Or the change is not behavior-preserving after all, and it belongs in step 5. Editing a test to match refactored code, in the same commit as the refactor, destroys the only evidence that the refactor was safe.

## 5. Some of these are not refactors, and they leave this skill
Three of the four rule groups routinely produce items that change observable behavior. Route them; do not smuggle them through as cleanup.

- **Accessibility** fixes usually change what a user perceives — labels, focus order, announcements, contrast. That is user-observable behavior, so it is a README line the user ratifies and a `new-feature` run, not a quiet improvement.
- **Performance and battery** items split cleanly. Moving a hardcoded interval into config *is* a refactor and belongs here. Changing what that interval should be is a decision the user makes, and often a documented one.
- **Logging** is mostly internal and safe: adding a missing log, correcting a level. But "log level changeable by settings rather than a deploy" can be feature-sized on a project that never built the setting. When it is, it is an engineering decision and a `new-feature` run, or a `TODO.md` entry — not something to improvise midway through a rename commit.

## 6. Correct the architecture notes you invalidate
This is the stage most likely to make `ARCHITECTURE.md` wrong, because extracting helpers, consolidating duplicated logic and moving constants into config all change the shape the notes describe. Whatever this pass restructures, it also re-describes, in the same commit as the change — that is the standing obligation to keep the architecture current, landing on the stage that broke it.

Where a finding is one those notes explicitly justify — an oddity recorded as deliberate — treat that as a strong signal it is not a finding at all. Take it back to the user before rewriting something a previous stage went out of its way to explain.

## 7. Know when to stop
Conformance to the stated principles is the finish line, not beauty. When every approved finding is closed and the remaining ones were ratified as deliberate, the area is done, even if you can still see things you would have written differently.

Check `TODO.md` before starting and do not polish code that is scheduled for deletion or rewrite. Perfecting something on its way out is the purest form of wasted motion this workflow can produce.

The test of a finished area is not that it matches your taste. It is that the next person who opens it finds what the standards told them to expect.
