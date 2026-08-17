---
name: unfrak-register
description: >-
  Records every place the code does not do what the project says it should — whether that is a promise the user ratified or an internal rule they said the project binds itself to — as a durable register of intent gaps with evidence, cost, and the tests that will prove each one closed. Use whenever `unfrak-ratify` or `unfrak-lock` returns a "wrong" verdict, and when closing an entry after a later fix.
---

# The intent-gap register

Once the documentation states what the software is *supposed* to do, every place the code falls short becomes a known, named gap rather than a vague sense that things are off. The register is where those live. It is the honest ledger of the distance between the spec and the software.

It lives in one document (`INTENT_GAPS.md`, or whatever the project already uses), and it is a queue: entries are added when a verdict says the code is wrong, and removed by the fixes that close them.

## What earns an entry
Anything the user said is wrong — whether it looks like a bug, an oversimplification, or a decision that has been outgrown. The distinction does not matter here. What matters is that the project now states something the code does not deliver.

That comes from two stages, not one. `unfrak-ratify` produces gaps against **end-user promises**: the README says X, the code does Y. `unfrak-lock` produces gaps against **engineering decisions**: the project binds itself to a rule the code keeps in three places and breaks in a fourth. Both are the same kind of debt and belong in the same queue, because both are documented intent the software does not honour. The second kind has usually been true for years and is newly visible rather than newly broken, which is a reason to record it rather than a reason to treat it as urgent.

What does *not* earn an entry: behavior the user does not care about (that is "not a promise" — drop it or describe it in architecture), and behavior nobody has ratified yet (that is still a pending question).

## What an entry contains
- **What the code does today**, with `file:line` evidence.
- **What it should do instead** — in the user's terms for a promise, in the rule's own terms for an engineering decision.
- **What it costs while unfixed** — wrong numbers, lost data, a signal that never fires, user confusion. Be concrete: this is what a reader uses to decide whether to fix it this week or next quarter. If the cost is already realised in stored data, say so, and say whether it can be reconstructed.
- **What it belongs to** — the documentation line, or the `ED-<n>` — so the entry and the thing it violates stay connected.
- **What a test would have to assert to prove it closed.** Write the cases out. This is the test deliberately *not* written during `unfrak-lock`, and capturing it now means the eventual fix starts with its failing test already specified — by someone who had the whole area in their head.
- **Confidence about reachability**, when it is in doubt. An entry that may never fire in practice is still worth recording, but say so plainly rather than letting it compete with gaps that bite daily.

## Do not fix it here
Recording a gap is not permission to close it. The fix is separate work with its own review, its own tests, and its own place in someone's schedule — and mixing it into a documentation pass produces a commit nobody can review. The register exists precisely so the gap can be left alone safely.

## Closing an entry
An entry closes when the code matches the documentation line: the fix runs through `new-feature` (the register entry supplies the spec and the failing test it starts from), and the entry is **deleted** in the same commit. A register that accumulates entries marked "done" stops being a queue and becomes an archive nobody reads.

An entry nobody intends to fix is not a gap — it is a document that lies. Take it back through `unfrak-ratify` and settle it: either the code was right all along and the documentation changes to match, or the fix is still owed and the entry stays. Permanent residents turn the register into an archive of admitted falsehoods, which is worse than keeping no register at all.

## Closing the register
When the last entry is gone, **delete the file** and the doc-routing entry that points at it. It is created by the first gap and should disappear with the last one: an empty register left lying around reads as a standing promise that gaps are being tracked somewhere, by someone. Version control keeps every entry that ever existed, so nothing is lost by removing it.
