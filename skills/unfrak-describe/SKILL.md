---
name: unfrak-describe
description: >-
  Writes the architecture notes for an area once its structure has stopped moving — after `unfrak-lock` has introduced whatever seams the tests needed, and before `unfrak-backfill` starts changing behavior. Descriptive only: how the code is actually built, carrying no promise and owing no test. The agent drafts the wording, which is the opposite of how end-user documentation is authored, but walks the questions only the user can settle one at a time, which is the same as every other stage. Also runs standalone on any area whose architecture notes have gone stale or never existed.
---

# Describing what is actually there

`ARCHITECTURE.md` is the one document in the set that promises nothing. The README says what the software must do, engineering decisions say what the implementation must obey, and both are enforced by tests. Architecture only says how today's code happens to be built — no commitment, no test, and no obligation beyond being *true right now*.

That makes accuracy its only virtue, and timing the main threat to it.

## 1. Why this comes so late
Writing architecture while reading the code feels natural and produces a document that is wrong by the time anyone reads it. `unfrak-lock` introduces seams — takes a dependency as an argument, splits reading from deciding — and every one of those changes the structure a description would describe. Describe first and you have documented a shape that no longer exists.

So this runs after the structure has settled and before `unfrak-backfill` starts moving behavior around. That is the first moment the description can be true, which is the only moment worth writing it.

It is still not the last word. `unfrak-backfill` changes behavior, `unfrak-harden` adds guards, and `unfrak-polish` restructures outright. Each of those owns updating what it invalidates — the standing "keep the architecture current" rule covers that. What this stage owns is the *first construction* for an area that has none, or a rewrite for one whose notes have rotted.

## 2. Take the descriptive pile, and only it
The candidates arrive already sorted. `unfrak-inventory` routed the merely-descriptive ones here, `unfrak-ratify` sent down anything the user called "not a promise" but thought worth knowing, and `unfrak-lock` handed over every candidate rule the user judged descriptive rather than binding.

Do not re-litigate those verdicts. If something in the pile looks like a commitment after all, it goes back to `unfrak-lock` for a verdict and a test, not into this document with firmer wording.

## 3. Earn every line
The pressure here is to transcribe, because everything is true and nothing is contested. Resist it. A description of every function is a document nobody reads, and one nobody reads is one nobody updates, so it is stale within a month and then actively misleading.

Write what a competent newcomer could not work out quickly from the code itself:

- **Shape** — what the pieces are, what each is responsible for, and which way the dependencies point.
- **Non-obvious mechanism** — the flow that is genuinely surprising, or spread across enough files that nobody would assemble it by reading.
- **Deliberate oddity** — something that looks wrong and is not. These are the highest-value lines in the whole document, because they are what stops the next person "fixing" a thing that is load-bearing.
- **Known blind spots** — where the design simply does not cover a case, recorded so nobody mistakes the hole for an oversight.

Leave out anything the code says plainly at a glance, and anything a test already pins — a test is a better description than a paragraph, because it cannot silently go out of date.

## 4. Draft the wording, but walk the questions
**The authorship here is the reverse of `unfrak-ratify`, and inheriting that skill's rule would be a mistake.** End-user documentation is a specification in the user's voice, so the user writes it and a draft is only ever a proposal. Architecture is a description of code the agent has just read closely and the user may not have opened in a year. Making them author it in their own words is ceremony that produces worse text.

**The pacing, though, is the same as every other stage that involves the user, and for the same reason.** Sort the pile in two before writing anything.

- **What reading settles.** Shape, flow, what calls what. Draft it in bulk; it needs no verdict and asking about it wastes the attention the rest needs.
- **What only the user knows.** Whether an oddity is deliberate, what an abandoned-looking path was for, which of two mechanisms is the one being migrated toward, whether a hole is an oversight or a decision. These are questions, and they get walked.

Say how many questions there are before asking the first, then ask **one per message**, numbered as you go. No stacked questions, no "and also, while I have you". A description delivered whole with its uncertainties bundled at the end gets skimmed exactly like a hundred-point ratification does, and a skimmed answer here writes a confident sentence about something nobody actually confirmed.

Each question carries the thing, its `file:line`, **what you inferred and why you are unsure**, and what changes in the document depending on the answer. Marking an inference is not optional and never gets laundered into a flat statement of fact.

Ask before finalising rather than after. An answer routinely replaces a description with an explanation — "routes on heading text rather than the URL" becomes "routes on heading text because the URL is rewritten by the site's own navigation" — and that is a different sentence, not an annotation on the first one. Drafting first and patching later produces prose built around a guess.

## 5. Say what is not true yet
The area still has open register entries at this point — that is the normal state, since `unfrak-backfill` has not run. Describe the code as it *is*, not as it is about to become, and where a known gap makes the current structure temporary, say so and point at the entry.

An architecture document that quietly describes the intended design rather than the built one is the worst outcome available here, because it reads exactly like the useful kind.
