---
name: unfrak-design
description: >-
  Recovers or establishes a design standard for a codebase that has none written down — enumerating what each design axis actually uses, reading the shape of that distribution to tell a real convention from drift from chaos, and settling each axis with the user into a `DESIGN.md` worth standardising against. A sibling of the `unfrak` family rather than one of its stages: it runs across the whole product instead of one area at a time, its verdicts come from perception rather than a green suite, and its rollout rules are the opposite of the family's. Runs standalone, or ahead of `unfrak-polish` so that stage has a real standard to enforce.
---

# Unfrakking the design

Every other retrofit stage is archaeological: the intent is in the code, and the work is recovering it. Design is often not like that. A codebase can reach considerable size with no design thought at all, in which case there is nothing to recover and the honest output is not "here is what the design is" but "here are the six button styles actually in use, which one wins?"

That makes this partly a legislative process rather than a purely investigative one, and it is why this is a sibling of the `unfrak` family rather than a stage inside it.

## 1. Know why this is not an unfrak stage
Three structural differences, each of which would break something if this were folded into the sequence.

- **It does not decompose by area.** The umbrella's whole spine is one bounded area at a time. Colour, spacing, type scale, component vocabulary, copy tone and interaction idiom are cross-cutting by nature, and a standard derived from one area would be wrong for the product.
- **Its verdicts are perceptual.** Every stage in the family ends at a green suite. Most of what matters here cannot be asserted, which is why `confirm-by-eye` exists. Use it for anything whose success is a matter of how something looks or feels.
- **Its rollout rule is inverted.** The family ships one gap per commit and treats a half-finished area as fine, because the remainder is honestly recorded. Design does not work that way: a half-migrated visual standard looks worse than either endpoint, so partial adoption is a visible regression rather than honest progress. Sequence migrations to land as coherent units, even when that means a larger change than the family would normally allow.

## 2. Enumerate per axis before judging anything
Split the surface into axes and handle each on its own. Typically colour, spacing and layout rhythm, type scale and weight, component vocabulary (what a button, a card, a field actually is), interaction and motion, iconography, and copy tone.

For each axis, list the values actually in use and count them, with `file:line` evidence. This is deliberately mechanical, and it is the only part of the process that is.

## 3. Let the distribution choose the mode
The state of a codebase is not one point on a spectrum — it is a point per axis, and most real projects are coherent on some and chaotic on others, usually because different axes were laid down by different people at different times. So read each axis separately and let its shape decide how to proceed.

- **One dominant value, a few strays** — a real convention exists and was never written down. Recover it. The strays are drift, and each is a candidate fix rather than evidence against the rule.
- **Two or three clusters** — competing conventions, usually eras or authors. The user picks the winner; the counts tell them what changing their mind would cost.
- **Flat scatter, no mode** — there is nothing to recover. You are helping decide, so propose something defensible and say plainly that it is a proposal rather than a finding.

Report the counts alongside the question every time. "Thirty-seven places use one value and four use another" answers the question almost by itself, and it is also the migration estimate.

## 4. Settle each axis with the user
The user decides; you supply evidence and a recommendation. The question differs by mode — *is this the rule you have been following?* when recovering, *which of these wins?* when there are clusters, *does this work for you?* when proposing.

Where the honest answer is that nothing coherent exists, say so plainly rather than dressing the most common accident up as an intention. Inferring a design from a frequency count and presenting it as recovered intent is this process's version of ratifying today's bugs as tomorrow's spec.

Record each settled axis with the reasoning, not just the value. A palette with no rationale gets overturned by the next person with an opinion; one that says what it is for survives.

## 5. Write the standard, then record the distance
`DESIGN.md` states what the product *should* look and behave like, so it is prescriptive like the README rather than descriptive like the architecture notes. Write it that way: the rule, what it is for, and enough of the boundary that someone can tell conformance from violation.

Then record the gap between the standard and the code. Everything that does not yet conform is a known distance, recorded the way `unfrak-register` records intent gaps, and closed deliberately — not swept up in the same pass that wrote the standard.

Writing the standard and adopting it are separate work. A design unfrak that restyles the whole product in one motion produces exactly the unreviewable diff the rest of this workflow is built to avoid, with the added property that everyone can see it.

## 6. Hand it to the stage that enforces it
`unfrak-polish` audits an area against the written rules and needs every finding to cite one. Today it can only cite `AGENTS.md`. Once `DESIGN.md` exists it has a real standard for anything user-facing, so run this first where an area's design conformance is going to matter.

Accessibility sits across both: it is a stated guideline that `unfrak-polish` already audits, and it constrains this process's choices — a contrast ratio or a target size is not a matter of taste, and a standard that fails on those is not a standard worth writing.
