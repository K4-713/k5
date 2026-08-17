---
name: unfrak-inventory
description: >-
  Opens a DDD retrofit on one feature area: read it, list what it actually does with `file:line` evidence and an honest confidence marker for each claim, then route every candidate by altitude — end-user documentation, engineering decisions, or architecture — before any of it reaches the user. Routing decides which later stage takes the verdict; nothing is settled here. Used by `unfrak` once `unfrak-survey` has picked the area, and before `unfrak-ratify`.
---

# Inventorying what the code actually does

The stage that produces the list everything else works from. Nothing here involves the user, changes any code, or writes any documentation.

## 1. Read the whole area, including its far side
An area rarely exists within one file. A browser extension's page script has a background half; a page has an endpoint behind it; a scraper has a parser downstream. Follow each thread until you reach storage or a screen, because that is where behavior becomes user-observable, and observable is what end-user documentation is about.

## 2. Write each candidate behavior down three ways
For every behavior the area exhibits, record:

- **A plain-language statement**, in user terms — what happens, not how.
- **Evidence** — `file:line` for each claim, so the user can check it in seconds. A statement you cannot point at is a guess; mark it as one or drop it.
- **Confidence** — what you verified by reading versus what you inferred. Say which is which. Never launder an inference into a statement of fact.

## 3. Say plainly what you could not verify
Two failure modes matter here, and both are worse than an incomplete list:

- **Unreachable code documented as behavior.** If you cannot establish that a path runs at all, say so rather than describing it as something the product does.
- **Stale evidence about the outside world.** API shapes, request/response formats, selectors on 3rd-party pages for scraping — these are all examples of moving targets outside of our control. If the project has captured samples, check their age; if there are none, say the claims are unverified and name what would settle it.

If possible, provide detailed instructions for the user to look for a data trail that proves a path lives: Specific rows in a table, files on disk, log lines. Absence of an existing trail is not proof of death, but presence is proof of life, at least to the date of the most recent evidence. The user may also be able to exercise a workflow test manually.

## 4. Route by altitude *before* the user sees anything
Sort every candidate using the project's own routing rules — typically:

- **User-observable** — someone can notice or rely on it by using the product → end-user documentation. These, and only these, become questions in `unfrak-ratify`.
- **Binding internal rule** — invisible to users, but a commitment whose violation is a bug → engineering decisions, decided in `unfrak-lock`.
- **Merely descriptive** — how today's code happens to work → architecture, written in `unfrak-describe`.

This ordering is the point of the stage. Documentation derived from code drifts toward implementation detail, and the only reliable defence is to route before asking, so the user's attention is spent on promises rather than mechanisms.

**Routing is a guess about which stage should ask, never a verdict.** Every pile gets settled with the user eventually, just by a different question and on a different schedule: `unfrak-ratify` asks whether a user-facing behavior is wanted, and `unfrak-lock` asks whether an internal rule is one the project binds itself to or merely something the code presently does. That second question is exactly as much an intent question as the first, and code is evidence of intent, never proof of it — so a candidate landing in the internal pile is not a candidate the user has no say over. Expect your routing to be overturned in both directions, and record these candidates with the same evidence and confidence as the rest.

Design and visual conventions are the exception, and do not belong to this area at all. Note anything you see and hand it to `unfrak-design`, which works across the whole product rather than one area, and would draw the wrong conclusion from a single area's habits.

## 5. Hand over a countable list
Finish by writing the candidates into the area's working record, grouped so they can be walked in a sensible order, and numbered. `unfrak-ratify` opens by telling the user how many there are, so the list has to be complete before it starts. If the count would run past roughly twenty, the area is too big — split it and inventory the portions separately.
