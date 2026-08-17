---
name: unfrak-survey
description: >-
  Runs ahead of everything else in an unfrak: find every part of the codebase that still has no ratified specification, judge each on both what it would cost to be wrong there and how likely wrong code is, and leave behind a ranked backlog of areas to work through. Use before `unfrak` picks an area, and again whenever the backlog has gone stale — not for inventorying or documenting any single area, which is `unfrak-inventory`.
---

# Surveying what still needs unfraking

An unfrak runs one area at a time, which only works if somebody decided *which* area. This stage makes that decision explicit and re-checkable instead of letting it default to whatever was most recently annoying.

It produces one artifact: a ranked backlog. It documents nothing, asks the user no ratification questions, and changes no code.

## 1. Find the areas by their surfaces, not their files
Audit the entire codebase, and break it down into areas. An area is a thing a user would name: a page, a screen, an integration, a scheduled job, a command, a feature set. Start from the surfaces the product exposes — routes, entry points, scripts, endpoints, menu items — and gather the code behind each.

Size areas to roughly five to twenty user-observable behaviors. Anything larger gets split before it enters the backlog; anything much smaller gets folded into its neighbour. A file count is not an area, and neither is a directory.

Note explicitly:
* Anything that belongs to no surface at all — dead code, half-finished features, orphaned endpoints. Those are candidates for deletion, not for documentation, and saying so here saves someone the work of ratifying them later.
* Inter-area dependencies. This should have a strong influence on the user's perception of the refactor risk of picking an area. 

## 2. Establish each area's current state
For each area, record what already exists:

- **Specified?** Does the end-user documentation describe this at all, and does the description still match the code?
- **Tested?** Are there tests that cite a documented behavior, as opposed to tests that merely exercise internals?
- **Evidence of drift?** Bug reports, `TODO`/`FIXME` comments, comments admitting confusion, workarounds, or a git history full of one-line corrections.

The three states worth distinguishing: **no spec and no tests** (the true unfrak), **tests but no spec** (behavior is pinned but nobody ratified it — the tests may be enshrining bugs), and **spec but no tests** (promises that are not enforced).

## 3. Judge each area on four axes
Keep these qualitative — High / Medium / Low. Invented precision here is worse than none, because it hides the reasoning that actually matters.

- **Cost of being wrong.** Security, privacy, data loss or corruption, expendature of resources (3rd party API calls, compute power), financial transactions, anything irreversible, anything a user acts on. An area that alters PII, deletes real data, spends resources, or handles finances outranks anything read-only.
- **Likelihood of being wrong.** No tests, heavy churn, many hands, dependence on a third party that changes without warning (3rd party integrations and page scrapers rot quietly), and any drift evidence found above.
- **Reach.** How much else assumes or depends on this area's correct behavior. Shared helpers and data that other features read are worth more than a leaf page, because a wrong assumption here is wrong in many places at once.
- **Cost to unfrak.** Size, whether the code has a seam to test against or needs a refactor first, and whether ratifying it needs observations nobody can make on demand (a live workflow, a monthly job, a captured page).

## 4. Rank, and say why
Order by **cost of being wrong × likelihood of being wrong** first, then reach. Cost to unfrak is a tiebreaker, never a veto: an expensive area that fails dangerously still outranks a cheap safe one.

Two deliberate exceptions:

- **The first area should be one that proves the process**, not the scariest one on the list. Something small, self-contained, and ratifiable in one sitting. A process nobody trusts yet should not be introduced on code that can widely disrupt operations or cause outages.
- **An area about to be changed may jump the queue.** Depending on the situation, unfrakking undocumented code immediately before the same code is rewritten could be nearly free, or it could be not worth bothering with at all prior to the rewrite. If DDD is adopted prior to the rewrite, the user-facing documentation for that area comes first in either case, so starting with an unfrak survey and inventory may be the easiest option. The real decision point likely hinges on how much of the existing behavior of the current area is intended to be preserved through the rewrite: If the area starts with mostly the correct behavior, unfrakking first might be the better call. Either way, this should be surfaced and left to the user to decide.

Write one line per area explaining its position. The ranking is a judgment; the reasoning is what lets someone disagree with it usefully.

## 5. Record the backlog, and let the user overrule it
Keep it with the unfrak working records (`.claude/unfrak/backlog.md` or the project's equivalent), listing per area: its surfaces, current state, the four judgments, and its one-line rationale. Mark areas as they are completed rather than deleting them — unlike the intent-gap register, this list is a map, and the covered ground is part of it.

Keep a **declined** section: areas the user has said are not worth unfrakking, with the reason and the date. Without it, every re-survey resurrects the same arguments.

Then present the ranking and let the user either choose a single area to work on now, or reorder the list completely. They know what is important to the project, what's likely coming on the roadmap, which parts of the code have been fragile or mysterious, and what is no longer important to the team. None of this will be in the code, and requires a user's judgement.

## 6. Re-survey when the map goes stale
Re-run after a few areas are closed, when a release adds surfaces, or when the ranking starts producing obviously wrong answers. The backlog is a living map, not a plan: The code must be re-audited and re-prioritied with a user for the map to be meaningful.

## 7. Delete the backlog when there is nothing left to rank
When every surface carries a ratified spec, this file has no job: the end-user documentation is the map now. **Delete it** rather than keeping it as a record of completed areas. Unfrak should clean up after itself as soon as there is no outstanding unfrak work to keep track of.
