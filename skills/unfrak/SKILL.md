---
name: unfrak
description: >-
  Umbrella workflow for bringing an existing, under-documented, potentially chaotic codebase into Documentation Driven Development. Unfrak splits the code into areas of concern, and works with the user on one area at a time until each area reads as though it had been built under DDD from the start. Sequences the stages — `unfrak-survey`, `unfrak-inventory`, `unfrak-ratify`, `unfrak-register`, `unfrak-lock`, `unfrak-describe`, `unfrak-backfill`, `unfrak-harden`, `unfrak-polish` — and owns the working unfrak record, and closing an area out. `unfrak-design` is a sibling process rather than a stage, because design does not decompose one area at a time. Start here when adopting DDD on code written outside of that process, or when a feature area has no spec; use `new-feature` instead when the spec exists and the behavior is new, or `wrap-up-work` when the docs exist and just need reconciling.
---

# Retrofitting DDD onto existing code

DDD requires the documentation to come first. On an existing codebase, the documentation may not even exist, so the spec has to be *built* before any work in the code can be done. Read the code, propose what the docs should say, have the user confirm or correct it, and ask the user for supplemental reasoning when appropriate. Two things fall out of the initial process: End-user documentation that describes intended behavior, and a register of every place the code does not currently deliver it.

The failure this whole workflow exists to prevent: an agent reads the code, writes confident documentation of what it found, and the user skims and nods. That converts today's bugs into tomorrow's spec, permanently. **Code is evidence of intent, never proof of it.** Only the user can say what the software is supposed to do.

## The codebase is alive
Unfrak runs on working software. Assume other engineers are working on their own, users are relying on current behavior, and feature work continues alongside the retrofit. All this work must be able to continue in parallel.

- **Never end a session red or noisy.** The unfrak must not cost anyone else "green means safe to commit". No failing tests parked for later, no half-edited documentation left in the tree. If there is no way around leaving a temporary mess, make sure the work is done in its own working branch, and the commit is clearly marked as a WIP.
- **Small bites, each independently committable.** Assume the process will be interrupted at any point, and document continuously so the work may be resumed later, and by someone else.
- **Evidence goes stale.** Code read in a previous session may have moved. Re-check `file:line` evidence at ratification time, not just at drafting time.
- **Document, then correct — in that order.** Finding broken behavior mid-unfrak is expected, but fixing it on the spot is not. Problems get recorded and left alone until the spec around it is settled. `unfrak-backfill` is where the fixing happens, deliberately and only after the spec is settled, and existing good behavior is fully enforced by tests.

## 1. Take one area, not the codebase
Have the user pick a bounded feature area — one page, one screen, one integration, one script. The stages below run start-to-finish on that area, end in a committable state, and repeat on the next. Never inventory the whole system at once: a hundred-point review gets rubber-stamped, which is not helpful. We need to establish user ownership of code behavior at every stage.

**Choose an area from `unfrak-survey`**, the stage that ranks what needs retrofit work by what it would cost for that area to be wrong, and how likely that area is to be wrong. Run `unfrak-survey` before having the user select the first area, and again whenever its backlog has gone stale. The user may select any area identified by the survey.

## 2. Keep one working record per area
Open a working file for the selected area (for example `.claude/unfrak/<area>.md`) before the first stage and keep it current through all of them: the candidate points, the verdicts as they are given, what is still unasked, and anything that could not be verified. A serial review may span sessions. Delete the file when the area closes.

## 3. Run the stages in order
With the area chosen by `unfrak-survey`:

1. **`unfrak-inventory`** — read the area, list its candidate behaviors with evidence, and route them by altitude. Involves the user not at all.
2. **`unfrak-ratify`** — walk the user-observable candidates with the user, one at a time, and take a verdict on each.
3. **`unfrak-register`** — record every divergence between what the code does and what the project says it should, as the queue for later fixes.
4. **`unfrak-lock`** — write `TDD_` tests for the ratified behavior the code already delivers, then go after the engineering decisions those tests did not reach and take a verdict on each with the user.
5. **`unfrak-describe`** — write the architecture notes now that the structure has stopped moving, drafted for the user to correct.
6. **`unfrak-backfill`** — treat the ratified documentation as a feature that is only partly built: refactor for testability, close every register entry through `new-feature`, and test every promise, until nothing about the area betrays that it was written before its spec.
7. **`unfrak-harden`** — pin the paths the documentation never mentions: what can destroy data, handle personal information, or call an external service. Write the coverage AGENTS.md requires, then walk each security weakness with the user and record the verdicts.
8. **`unfrak-polish`** — bring the area into conformance with the coding principles AGENTS.md states, every finding citing the rule it serves.

Stages 3 and 4 can interleave with stage 2 as verdicts arrive; do not let them run ahead of it. Note that 3 is fed by both 2 and 4 — a promise the code breaks and a rule the code breaks are the same kind of debt and share one queue.

Stage 6 starts only once stage 2 has no pending verdicts left — backfilling against a spec that is still moving settles open questions by implementing one answer to them.

The rest of the order is load-bearing rather than alphabetical. 5 comes after 4 because locking introduces the seams that change the very structure being described, so describing earlier documents a shape that will not exist. 6 leaves the code doing what it promises; 7 proves the parts nothing ever promised; and only then does 8 restructure any of it. Polishing before hardening restructures dangerous paths that nothing yet covers, and hardening before backfilling pins code a still-open gap may replace.

The first six stages are what make an area *specified*. The last two are what make it *good*, and they are the only stages that may be run on their own, against any area already carrying a ratified spec and a green suite — as may 5, whenever an area's architecture notes have gone stale or never existed.

Architecture is written once at 5 and maintained by whatever invalidates it afterwards. Stages 6, 7 and 8 each change the code and each own re-describing what they changed, rather than leaving a correction pass for the end.

**Design is not in this list, and deliberately so.** `unfrak-design` is a sibling process rather than a stage: it runs across the whole product instead of one area at a time, its verdicts are perceptual rather than test-backed, and its rollout rules are the opposite of the ones here, because a half-migrated visual standard looks worse than either endpoint. Note design observations as you go and hand them over; do not try to settle them from inside a single area.

## 4. Close the area
Commit the documentation, the register entries, and the tests together, so the area's spec and its proof arrive as one reviewable unit. Then run `wrap-up-work` over the area to catch what the stages missed, note follow-ups in `TODO.md`, and delete the working record.

Anything still unverifiable at close — a behavior that needs a live observation, a page that needs capturing — stays in the working record, and the area stays open until it is settled. Do not close an area by guessing the last answer.

A closed area is one that reads as though it had been built under DDD from the beginning: every documented promise delivered and tested, every engineering decision recorded and actually pinned, architecture notes that describe the code as it now stands, no register entries left against it, its dangerous paths covered, and its open security questions either settled or knowingly accepted in writing. An area that is specified and tested but still failing its own promises is *paused*, not closed, and the umbrella keeps it on the list — as is one whose delete path or personal-data handling has still never been executed by a test.

Progress is measured in areas fully ratified, tested, backfilled, and committed — not in documentation drafted or lines written.

## 5. Wind the process down as it finishes
Everything this workflow writes about itself is scaffolding, and scaffolding that outlives the building gets mistaken for the building. Take it down in step with the work, in three independent stages — independent because deleting one early loses information the others do not hold.

**Each area's working record** goes when that area closes, as above.

**The backlog** goes when `unfrak-survey` has nothing left to rank: every surface carries a ratified spec. Do not keep it as a trophy list of completed areas — the end-user documentation is now the map, and a survey that no longer matches the code is worse than no survey at all. If the project grows new surfaces later, the next survey writes a fresh one.

**The register** goes when its last entry is deleted by the fix that closed it, along with the doc-routing entry that points at it. `unfrak-backfill` empties it one area at a time, so if every area is carried through that stage the register never accumulates for long — it exists to hold gaps between the review that found them and the backfill that closes them, and a project that always finishes what it starts keeps it nearly empty by construction.

It can still outlive the backlog. Areas paused mid-backfill, gaps that turned out to be feature-sized, and anything closed before this stage existed all leave entries standing, and a codebase can be completely specified while knowingly failing several of its own promises.

An entry nobody will ever fix is not a gap — it is a document that lies. Take it back through `unfrak-ratify` and settle it: either the code was right all along and the documentation changes to match, or it stays a gap with a fix still owed. What must not happen is a register accruing permanent residents, because that turns a queue into an archive of admitted falsehoods, which is worse than having neither.

**What survives is the point:** the end-user documentation, the engineering decisions, the architecture notes, and the `TDD_` tests. Those are the product. Deleting the rest costs nothing — version control still has every word of it — and that is exactly what makes deletion safe rather than lossy.

Once the last area closes, this workflow goes dormant. New behavior runs through `new-feature`, which starts from documentation by construction, so nothing new should ever need unfrakking. The skills come back only when unspecified code arrives from outside: an acquisition, an inherited service, a vendored dependency somebody started editing.
