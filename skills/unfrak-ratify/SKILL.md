---
name: unfrak-ratify
description: >-
  Walks the inventoried user-observable behaviors with the user one at a time, takes a verdict on each (right / wrong / not a promise), and turns the confirmed ones into end-user documentation in the user's own words. Use after `unfrak-inventory` has produced a numbered list, and alongside `unfrak-register` for anything the user says is wrong.
---

# Ratifying behavior with the user

The stage where recovered behavior becomes a spec — or gets rejected. It is the only stage that can tell intent from accident, because only the user knows which is which.

## 1. Open with the size of the job
Say how many points the area holds and how they group before asking the first one. The user is agreeing to a workload and needs to see it.

Say what this stage is *not* asking about, too, so the count is honest and the deferral is visible. Internal rules and architecture notes are not settled here, but they are not settled without the user either — `unfrak-lock` takes a verdict on each internal rule, and `unfrak-describe` puts the descriptive notes in front of them to correct. Give the size of those piles as well, and say which stage they are waiting for.

## 2. Ask one point per message
Number as you go — "3 of 16" — and give:

- the behavior, in a few sentences of plain language;
- the evidence, so it can be checked;
- the question: *is this what you want?*

No tables. No stacked questions. No second point smuggled into the same message. A wall of points gets skimmed, and skimming is how wrong behavior gets ratified — which is the one outcome this entire workflow exists to prevent.

Re-check the evidence as you ask. It was gathered earlier, possibly much earlier, and a `file:line` that has moved makes the question wrong.

## 3. Take one of four verdicts

- **Right** — it becomes an end-user documentation line. **The user authors or approves the final wording**; a draft you wrote is a proposal, never the spec. Silence is not approval.
- **Wrong** — the code does X, the user wants Y. The documentation records **Y**. The divergence goes to `unfrak-register`. Do not document X as intended, and do not quietly fix the code mid-review.
- **Not a promise** — accidental, obsolete, or nobody's commitment. Keep it out of the end-user docs; describe it in architecture if it is worth knowing, or queue it for deletion.
- **Pending** — the answer needs an observation nobody can make right now: a live workflow, a page that must be captured, a case that only occurs monthly. Park it with exactly what would settle it, and let the area stay open. A guess recorded as a verdict is worse than an open question.

Record each verdict in the working file as it is given, with the reasoning the user offered. The reasoning is often more valuable later than the verdict — it is what tells the next person whether a changed circumstance reopens the decision.

## 4. Follow the answer where it leads
A verdict frequently exposes a decision nobody had made. When the user's answer implies a further behavioral fork, ask it as its own numbered follow-up rather than deciding it yourself or bundling it into the next point.

When an answer contradicts something you asserted earlier in the review, correct it plainly and immediately, and fix the working record. A review built on an uncorrected mistake ratifies the mistake.

## 5. Draft the documentation, then hand it over
Once the area's points are settled, propose the documentation block — plainly marked as a proposal — and say explicitly which lines describe **intent the code does not yet meet**, so nobody mistakes the doc for a description of today's behavior. The user edits it into their own words. What they write is the spec; what you drafted was scaffolding.
