---
name: confirm-by-eye
description: >-
  Iterate on a change whose success is perceptual or subjective — look, motion,
  feel, sound, timing — and cannot be pinned by a definitive TDD_ test. Isolate
  one change at a time, give the user an A/B toggle to flip in the real running
  product, and let the user's perception be the verdict. Use when a fix can only
  be judged by eye/ear, as opposed to `new-feature` (testable behavior),
  `refactor` (no behavior change), or `wrap-up-work` (closing out).
---

# Confirming a change by eye (the human-in-the-loop loop)

Some changes cannot be settled by a test: how a flame looks in motion, whether
audio feels punchy, whether an animation reads as smooth. TDD does not apply to
the *perceptual* delta — so the user's perception in the real running product is
the only ground truth. This loop keeps that honest. Its cardinal rule: **you do
not get to declare a perceptual change "fixed" — only the user does.**

This exists because the failure mode is seductive: you make a change, render your
own probe, see the result you expected, and call it solved — while the user,
looking at the real thing, sees no difference at all. That is confirmation bias,
not verification.

## 1. First, carve off everything that IS testable
This loop is a scalpel, not an excuse to skip TDD. Before invoking it, split the
work:
- Binding, testable sub-parts (a value is conserved, an event fires, a field is
  present, a mapping round-trips) → still go through `new-feature`: record the
  engineering decision and write the `TDD_` test.
- Only the genuinely perceptual remainder — the part with no definitive
  assertion — is what this loop covers.
If you can write a test for it, write the test instead.

## 2. Change exactly ONE thing
No bundling. If you change six things and the user sees no difference, neither of
you can tell which five were inert. One isolated change per round, so the effect
is attributable to it and nothing else.

## 3. Make the change cheaply A/B-able for the user
The user must be able to see the change *toggle*, in the real running product, at
their own settings and scenes:
- **Preferred: an A/B toggle** — a debug flag/uniform/setting the user flips on
  and off live. Flipping it is the un-fakeable test: if the product looks/feels
  identical with it on and off, the change is inert (go to step 6).
- If a toggle is impractical, capture before/after from the *user's* scenario,
  not an invented one. Captures you generate are your own sanity check, never
  proof of a fix.

## 4. Hand it over — describe the change, never the verdict
State plainly what you changed, mechanically, and what to look for. Then stop and
let the user judge. Do **not** write "fixed", "solved", "done", or "that should
do it". The change is not resolved until the user says it reads different.

## 5. Diagnose from the user's view, not your probe
When you need to reproduce the problem, reproduce the *user's* actual scene,
inputs, and settings — ask for their screenshot or recording of the real thing.
A self-built probe that "shows the bug" can be a scene the user never hits.

## 6. An inert toggle means STOP and re-diagnose
If the user flips the toggle and sees no difference, do not restate the theory or
pile on another change. An inert change is strong evidence your causal model is
wrong (the code path may not even execute — instrument it and check). Go back to
the user's observation and re-diagnose before touching more code.

## 7. When the user confirms, capture it
Once the user confirms the change reads right:
- Fold the confirmed value into a named constant (no magic numbers) with a short
  comment noting it was user-confirmed and when.
- If a binding invariant emerged (something a future change must not break),
  record it as an engineering decision — and, if any part of it *became*
  testable, add the `TDD_` test now.
- Retire the debug toggle, or leave it behind a debug flag if it earns its keep.

One-time verification means the knowledge ends up in the code and docs, so it is
not re-litigated next session.

## The cadence, in one line
One change → an A/B toggle → the user previews in the real product → the user
gives the verdict → capture it → next change.
