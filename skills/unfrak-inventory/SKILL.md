---
name: unfrak-inventory
description: >-
  First stage of a DDD retrofit: read one feature area and list what it actually does, with file:line evidence and an honest confidence marker for each claim, then route every candidate to end-user documentation, engineering decisions, or architecture before any of it reaches the user. Use after `unfrak` has picked an area and before `unfrak-ratify`.
---

# Inventorying what the code actually does

The stage that produces the list everything else works from. Nothing here involves the user, changes any code, or writes any documentation.

## 1. Read the whole area, including its far side
An area is rarely one file. A browser extension's page script has a background half; a page has an endpoint behind it; a scraper has a parser downstream. Follow each thread until you reach storage or a screen, because that is where behavior becomes observable — and observable is what the documentation is about.

## 2. Write each candidate behavior down three ways
For every behavior the area exhibits, record:

- **A plain-language statement**, in user terms — what happens, not how.
- **Evidence** — `file:line` for each claim, so the user can check it in seconds. A statement you cannot point at is a guess; mark it as one or drop it.
- **Confidence** — what you verified by reading versus what you inferred. Say which is which. Never launder an inference into a statement of fact.

## 3. Say plainly what you could not verify
Two failure modes matter here, and both are worse than an incomplete list:

- **Unreachable code documented as behavior.** If you cannot establish that a path runs at all, say so rather than describing it as something the product does.
- **Stale evidence about the outside world.** Selectors into a third-party page, API shapes, response formats — these rot silently. If the project has captured samples, check their age; if there are none, say the claims are unverified and name what would settle it.

Look for a data trail that proves a path lives: rows in a table, files on disk, log lines. Absence of a trail is not proof of death, but presence is proof of life, and it is cheap to check.

## 4. Route by altitude *before* the user sees anything
Sort every candidate using the project's own routing rules — typically:

- **User-observable** — someone can notice or rely on it by using the product → end-user documentation. These, and only these, become questions in `unfrak-ratify`.
- **Binding internal rule** — invisible to users, but a commitment whose violation is a bug → engineering decisions.
- **Merely descriptive** — how today's code happens to work → architecture.

This ordering is the point of the stage. Documentation derived from code drifts toward implementation detail, and the only reliable defence is to route before asking, so the user's attention is spent on promises rather than mechanisms.

Internal and descriptive candidates are still written down — they are filed without ratification, since the user has no verdict to give on them.

## 5. Hand over a countable list
Finish by writing the candidates into the area's working record, grouped so they can be walked in a sensible order, and numbered. `unfrak-ratify` opens by telling the user how many there are, so the list has to be complete before it starts. If the count would run past roughly twenty, the area is too big — split it and inventory the halves separately.
