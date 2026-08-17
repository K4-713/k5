---
name: unfrak-harden
description: >-
  Proves the paths that can destroy data, handle personal information, or call an external service — the ones end-user documentation never mentions — by writing the coverage AGENTS.md requires, then walking each security weakness with the user one at a time and recording the verdicts in SECURITY_NOTES.md. Use after `unfrak-backfill` has closed an area's gaps, and before `unfrak-polish`. Also runs standalone on any area already under DDD whose dangerous paths have never been pinned.
---

# Hardening the dangerous paths

By the time an area reaches this stage it has a ratified spec, every promise delivered, and a green suite. None of that says the code is safe. A suite built from end-user documentation tests what the software *promises*; it does not test what the software can destroy, leak, or send somewhere it should not. Those paths are rarely in the documentation at all, because nobody writes "and it does not delete your data" as a feature.

The failure this stage exists to prevent: an area comes out of `unfrak-backfill` complete and green, and that green gets read as *this is safe*. It means *this does what it says*. The delete path, the path that touches personal data, and the call to the third party may never have been executed by a test at all.

Two halves, with deliberately different rules. The coverage obligations are written down in AGENTS.md and are not a judgment call — find them and satisfy them. The weaknesses are judgment, they usually change behavior, and every one of them is the user's call.

## 1. Do not start early
`unfrak-backfill` must have closed the area: ratification complete, register empty of it, promises delivered and pinned. Two reasons, and both matter.

Those tests are the net. This stage changes code that is dangerous by definition, and without the existing tests a hardening change that breaks working behavior looks exactly like one that worked.

And hardening code that is about to be rewritten is wasted work. A gap still open in the register may replace the very path you are pinning.

Run standalone only on an area that is already specified and tested — the same precondition, reached by a different route.

## 2. Find the dangerous paths; do not recall them
Walk the area's real entry points and enumerate, with `file:line` evidence and an honest confidence marker for each, exactly as `unfrak-inventory` does. Three categories, from AGENTS.md:

- **Destructive** — anything that deletes, overwrites, or truncates data that already exists. Look past the obvious `DELETE`: bulk updates, an upsert that replaces rather than merges, a cache eviction that discards the only copy, a migration, a "reset" or "sync" that treats one side as authoritative, and any statement whose `WHERE` clause you cannot prove is narrow.
- **Personal information** — anything that could handle a user's PII, which is wider than anything that *stores* it. Reading, rendering, transmitting, caching, and **logging** all count, and logs and error messages are where PII leaks in code that never meant to keep any.
- **External calls** — anything initiating a call off-box, including the ones made on the user's behalf by a browser extension or a background worker.

Note anything that is dangerous only in combination — a narrow delete driven by an identifier that arrives unvalidated is one finding, not two.

## 3. Write the missing coverage; this half is not a question
AGENTS.md requires test coverage for all three categories. Coverage is additive and changes no behavior, so write it rather than proposing it. Everything that may contact an external service is mocked, the local database included.

Test the prevention, not just the action. The valuable assertion is usually that the dangerous thing *refuses*: that the delete declines when its guard is not met, that a malformed identifier is rejected before it reaches a query, that a failed call leaves stored data untouched. Cover the expected case, then the edge cases, missing resources, garbage inputs, and the successful prevention of what must not happen.

**Never put real personal data in a fixture.** Synthetic values only. A retrofit that pins PII handling by committing somebody's actual information into the test suite has made the problem permanent, searchable, and much harder to undo than what it set out to fix. The same goes for secrets: a credential does not become safe by being in a test.

**If one of these tests fails, stop.** You have found a bug, not written a bad test. Do not adjust the assertion until it passes — that is how a real defect becomes a permanent feature of the suite. Route it: a weakness goes to step 4, a contradiction with the documentation goes back to `unfrak-ratify`.

## 4. Walk each weakness with the user, one at a time
The coverage pass is the best weakness-finder there is; expect most findings to come out of step 3 rather than from reading.

A weakness is **not** a register entry. The register holds places where the code does not do what the user said it should. A weakness is almost always something nobody has ever stated an intention about, which is exactly why it needs asking rather than filing.

One finding per message, numbered as you go. Give the path, what it would take to actually reach it, and what it would cost if reached — separately, because a severe outcome behind an unreachable path and a mild one behind a wide-open door deserve different answers. Then take a verdict:

- **Fix it** — proceed under step 5.
- **Accept it** — a real risk, knowingly carried.
- **Not a weakness** — your reading was wrong, or a control you did not see already covers it. Correct the working record.
- **Needs more thought** — park it with what would settle it, exactly as `unfrak-ratify` parks a pending verdict.

Record every verdict in `SECURITY_NOTES.md`, which AGENTS.md defines as working threat-model notes: exploratory, not binding, graduating to `ENGINEERING_DECISIONS.md`, `README.md`, or `DESIGN.md` once something is actually chosen. **Record the reasoning, especially for "accept".** An accepted risk with its reasoning is a decision; the same risk without it is an unexploded question that the next person reopens from scratch.

## 5. A fix that changes behavior is a documentation change first
Hardening gets no exemption from DDD. Route the fix by what it changes:

- **User-observable** — a new auth gate, a redacted field, a refusal where something was previously allowed. It is a README line the user authors and ratifies, then built through `new-feature`.
- **Internal only** — a bounds check, a parameterised query, a guard clause, a narrowed scope. It is an `ENGINEERING_DECISIONS.md` entry with the next `ED-<n>` and its `TDD_` test.

Urgency is an argument for doing it *now*. It is never an argument for doing it undocumented, and a hole worth closing immediately is worth a line saying it is closed.

## 6. Keep findings inside the project's own documents
These findings describe live weaknesses in software the user is running. Write them where the project keeps its own notes, and keep the detail proportionate: what is wrong and what closes it, not a working exploit reproduced in a commit message, a test name, or a public issue title. The test's assertion that the hole is shut is the durable artifact; the recipe for opening it is not.

If something turns out to be both severe and genuinely reachable, say so to the user plainly and immediately rather than filing it in order and continuing down the list.

## 7. Leave the suite green and quiet
Run the whole suite, not only the new tests, and read the warnings as well as the failures. Tests for dangerous paths are noisy by nature — deliberately triggered failures, rejected inputs, mocked errors — so catch what the test intends before it reaches the output. A hardening pass that leaves new noise behind has taught everyone to ignore the one part of the suite that most needed reading.
