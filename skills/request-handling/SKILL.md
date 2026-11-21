---
name: request-handling
description: >-
  Apply the "Requests between systems" rules in AGENTS.md when building or changing anything that sends or receives a request: a shared sender or receiver, a new request type, or an existing exchange being audited (as `unfrak-harden` and `unfrak-polish` do). Carries the reasoning behind each rule, the choices every project has to make and record, how to size a trace reference, and the checklists for a sender, a receiver, and a new request type. Use whenever data crosses from one part of a system to another — an extension to its server, a page to its API, a job to a third party.
---

# Handling requests between systems

The rules are in AGENTS.md under "Requests between systems", and they bind. This skill is the why, the per-project choices, and the checklists.

The failure these rules exist to prevent is quiet loss. A sender logs "sent" and moves on; the receiver refuses the batch over one bad value, says so only in its own log, and the sender drops it. Every part reports success at its own step, nobody notices for a day, and the data is recovered — if at all — from a console log that happened to print the whole payload. Nothing in that chain was a crash. Each step did something locally reasonable, and together they lost data. The rules close each link: the receiver says which outcome happened, the sender holds the data until it hears "stored", a rejection is kept rather than dropped, both sides log enough to find it again, and a retry can never duplicate what already landed.

The second failure is the opposite: duplication. A phone goes into a tunnel, the request times out after the server stored it, and the retry — or the person's own second tap — stores it again. Retries and duplicate-safety are one design, never two.

## 1. The outcomes

Every exchange ends in exactly one of four, and the receiver says which, explicitly:

| Outcome | Meaning | Sender does |
|---|---|---|
| **Stored** | Everything was accepted (a recognised repeat counts) | Forget it; log the result |
| **Partly stored** | Some rows accepted, the rest turned away | Forget the stored rows; set the rest aside as rejected |
| **Rejected** | Understood, and refused; sending it again gets the same answer | Set aside, keep, tell a person; never retry automatically |
| **Not handled** | Unreachable, broken, or timed out | Hold and retry in the project's pattern |

Avoid partial success: all-or-nothing is simpler for both ends and leaves nothing half-recorded. When a partial outcome cannot be avoided, the reply names which rows were stored, by position, and nothing about why the others were not.

Never infer the outcome from something else — a log level, an HTTP status chosen for another reason, a "success" that quietly skipped rows. A receiver that skips a row has partly stored the request, and must say so.

## 2. Replies stay thin; the receiver's log stays full

A reply is the outcome and the trace reference. No reasons: not which check failed, not which field, not the offending value — whether or not the caller authenticated. A valid credential is not proof that the caller is not an attacker, and every reason handed back is a step on the map for getting a bad request through. (This comes from payments systems, where any request may be hostile.)

Debugging and recovery work from the reference instead. The receiver logs every failed request in full under it:

- **Secrets redacted** — never the key, password, or token itself. A short hash fingerprint (the first few characters of a hash) is enough to tell the current credential from an old one or garbage.
- **Size capped** — logging before authenticating otherwise lets anyone fill the disk. Keep the head, record the full size, mark it truncated.
- **Stored as data** — the request in its own structured field, never interpolated into log text, so a value carrying a newline cannot forge a log line.
- **Limited retention** — failed requests will carry personal information eventually; keep them as long as debugging and recovery need, then delete them.
- **In a store of its own,** holding: reference, time, action, sender (where it can be identified), sender version, outcome, reason, and the redacted request. With the full request on the server, an operator can replay a rejected one after a fix without depending on the sender at all.

The one failure a receiver can never log is the request that never reached it. That one only the sender has — which is why the sender holds.

## 3. The sender holds

Held means **durable**: storage that survives a crash, a restart, a closed browser. Memory is not holding.

- **In order, one at a time, oldest first.** New writes queue behind held ones; nothing overtakes. The receiver sees changes in the order they happened, and a struggling receiver is never flooded while it recovers.
- **Rejected writes are set aside, not dropped.** Never retried automatically — they would only be rejected again — and never deleted, because a rejection almost always means a bug, and the data is what you will want once it is fixed. A rejected write leaves the hold only when a person replays it or discards it on purpose.
- **Bounded.** The hold has a size limit and warns a person as it nears it, rather than growing forever or silently dropping the oldest.
- **One way out.** Every write in the project leaves through the same held path. A send that bypasses it is a write that can be lost, and a codebase-wide test should prove there is none.
- **Findable.** The person on the sending side can find everything being held, for whatever reason. How it is surfaced — a badge, a panel, a page, a blocking screen — is the project's choice; that it can be found is not.

## 4. Retries

Only **not handled** is retried. The pattern is a per-project choice, recorded as an engineering decision:

- **Simplest:** three tries, a short fixed delay apart.
- **Fullest:** many tries, with delays that grow (doubling, with some randomness so many senders do not retry in step), and a cap on total retry time.

At a set point in the pattern the person is told the service is degraded. When the pattern runs out, sending pauses rather than looping forever, the person is told, and it resumes on a new write joining the queue, a periodic light check, or the person choosing to try again — then the pattern starts over.

## 5. Duplicates

Every write can arrive twice, and the second time changes nothing and is reported as **stored**, so the sender lets go. A repeat reported as rejected would set aside data that is already safe.

Recognise repeats by what the data **is** wherever possible — a natural key, such as an order's number or a bet's round and position. That catches repeats the sender never knew it sent: the same page recorded twice, two tabs, a reload. Where the data has no natural key, the sender makes an ID **when the person starts the action** — when the form is shown, not when the request is sent — and keeps it through every retry, so the person's own second tap carries the same ID as the first.

Anything that adds to a running total is where this bites. Audit those first.

**A person's press is the duplicate's most common source, so the page answers it in two stages.** First it stops the control from sending again: disabled and marked busy (`aria-busy` or the platform's equivalent), which reads as "not now" on even the smallest control. Second, it shows the new state only when a reply confirms it. Showing it on the press instead is the bug this rule exists for: a failure then looks exactly like a success, and the person acts on a state that was never stored.

Tiny controls cannot carry a message, and do not have to. On failure the control returns to its last confirmed state — a quantity that never changed snaps back, and that is itself the signal — and the reason goes to one notice area the whole page shares, announced to assistive technology (an ARIA live region on the web). A brief cue on the control, such as a flash as it snaps back, helps the eye find the row; it is perceptual, so each project settles it by eye rather than by rule. A stepper that disabled itself after every press would be miserable to use, so it may instead fold further presses into one pending value, shown as pending, and send once for the result; the confirmed value still changes only on the reply. A write held for a retry leaves its control waiting rather than re-enabled, so a held write never invites a second press.

## 6. Timeouts

Every request has one; a timeout is **not handled**. Size it with room above the receiver's slowest normal request, and short enough that one hung request cannot stall the one-at-a-time queue for long. The receiver's own processing limit must be shorter, so a request the sender abandoned is not still running.

**A timeout does not mean the receiver did not process the request.** The data may have landed after the sender gave up. This is the case the duplicate rules exist for, and it gets its own test.

## 7. Reads

A read is never held and replayed: by the time its answer arrives it may be stale, and nobody is waiting for it any more. A read that is not handled retries briefly — the project's pattern, capped short, because someone is waiting — then the person is told the answer is missing. Never silence; never an old or default answer shown as if it were current.

## 8. Tracing

Every request carries a **trace reference**: random (from a secure random source, never a hash of the content — two different writes with equal content must not share one), made once when the action starts, kept through every retry, and written by sender and receiver alike. Searching for it tells the whole story.

Keep it short enough for a person to read and type. Use Crockford's base32 (digits and capitals without I, L, O, U: nothing to misread, case-insensitive on input), and size it from the number of references the logs hold at once — requests per day × days of retention — so that the chance of any collision in that window stays under about 1%. A rare collision only means two entries to tell apart by their timestamps.

| References held at once | Characters (base32) | Chance of any collision |
|---|---|---|
| 10,000 | 7 (35 bits) | ~0.15% |
| 100,000 | 8 (40 bits) | ~0.5% |
| 1,000,000 | 10 (50 bits) | ~0.04% |

**The trace reference is never used to detect duplicates.** It is sized for people, and a collision there would make the receiver skip a real write as a repeat — lost data rather than an ambiguous lookup. Duplicate detection uses the natural key, or a separate machine ID long enough not to collide (16 base32 characters or more), carried in the request body and never read by anyone.

Every "sent" log line, with its timestamp, is followed by a result line for the same request with its own: stored, partly stored, rejected, not handled, or timed out. "Sent" keeps meaning sent; the result line is what says whether it landed. Logs carry the action and the sender as well as the reference, and never a secret.

## 9. Versions

Sender and receiver deploy separately, and held writes can wait for days, so mismatched versions are a normal state.

- Every request names the version that sent it, and the receiver logs it.
- An unknown action is rejected.
- An unknown field is a **per-instance setting**: strict rejects the request (it is held, so strictness costs only a wait); permissive accepts the known fields and logs each unknown one as a warning — never silently, since that is how a sender comes to believe data was stored that never was. Production runs strict; a development instance may run permissive while request shapes are being worked out. **Unset means strict.**
- Deploy the receiver before the senders that need it, and keep accepting a request's old shape until nothing in that shape is still held anywhere.

## 10. What each project chooses, and records

These are engineering decisions, one `ED-<n>` each, with tests where they bind:

- the retry pattern, the point at which the person is told, and how hard that is to miss;
- the timeout, and the receiver's processing limit beneath it;
- the trace reference's length, from volume × retention;
- how long failed requests are kept;
- the hold's size limit;
- the unknown-field setting each instance runs;
- how held requests are surfaced to be found (and whether a person may edit a held write before replaying it — a project's option, never a k5 requirement).

## 11. Checklists

**The shared sender** — tested once, thoroughly, with retry delays on a simulated clock:

- [ ] Every write goes through it; a codebase-wide test proves no send bypasses it
- [ ] Holds durably, in order, one at a time, oldest first; new writes wait behind held ones
- [ ] Stored → forgotten, result logged · Partly stored → the rest set aside · Rejected → set aside, not retried, findable · Not handled → retried in the pattern
- [ ] Pattern exhausted → pauses, tells the person, resumes on a new write, a check, or the person
- [ ] Timeout set; timed-out-but-stored → the retry creates no duplicate
- [ ] Hold is bounded and warns
- [ ] Trace reference made at action start, kept through retries, in every log line
- [ ] "Sent" line followed by a result line, both timestamped; no secret in any log
- [ ] Names its version in every request

**The shared receiver:**

- [ ] Replies with the outcome and reference only — no reasons, before or after authentication
- [ ] Logs every failed request in full: redacted, capped, structured, retained for a limit
- [ ] A repeat is reported as stored and changes nothing
- [ ] Processing limit shorter than the senders' timeout
- [ ] Unknown action rejected; unknown field per the instance's setting, strict when unset; tested under both

**Each new request type** — only what is its own:

- [ ] Goes through the shared path (the codebase-wide test covers it)
- [ ] Its handler treats a repeat as a repeat: sent twice, stored once — by natural key, or a machine ID made at action start
- [ ] If it is a read: a missing answer is told to the person, never shown as silence or as an old answer
- [ ] If a person's press sends it: the control stops sending again at once, shows the new state only on a confirming reply, and otherwise returns to its last confirmed state with the reason in the page's shared, announced notice area

**Auditing an existing area** (`unfrak-inventory`, `unfrak-harden`, `unfrak-polish`): list every request the area sends or receives — its direction, read or write, whether it goes through the shared path, and what it does with each of the four outcomes — and hold each one to the checklists above. A write that can be lost, duplicated, or dropped on a rejection is a data-loss finding, ranked with the destructive paths, not a style note.
