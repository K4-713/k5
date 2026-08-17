---
name: unfrak-lock
description: >-
  Pins an area with tests in two passes: `TDD_` tests for the ratified documentation lines the code already delivers, then the engineering decisions hiding in whatever those tests did not reach — uncovered code no promise explains, and existing tests pinning a rule nobody ever wrote down. Confirmed behavior and confirmed rules both stop being able to regress, while gaps stay in the register rather than as red or skipped tests. Runs once `unfrak-ratify` has settled an area's verdicts, before `unfrak-describe` writes the architecture around it.
---

# Locking behavior and rules with tests

Documentation nobody can check is a wish. This stage turns the ratified lines into tests, and in doing so audits the review itself.

It has a second job, and the order matters, because that job only becomes possible once the first is finished. A ratified README says what the software *promises*. It never says everything the code *guarantees*. The distance between those two is where engineering decisions live, and the tests written for the promises are what makes that distance visible — whatever they fail to reach is either a rule nobody wrote down, or code nobody needs.

## 1. Test only what the code already delivers
Write a `TDD_` test for each documentation line the code satisfies today, citing the line it covers. The test should pass the moment it is written, because it describes working code.

**If it fails, stop.** Either the documentation line is wrong or the review missed something, and both belong back in `unfrak-ratify` — this is one of the main reasons the tests are worth writing at all. Do not adjust the test until it passes; that is how a reading error becomes permanent.

## 2. Write nothing *yet* for a line the code does not meet
Not a failing test, not a skipped one, not a commented-out one. The register entry carries that obligation, and the test gets written in `unfrak-backfill`, by the `new-feature` run that closes the gap — where it belongs, as the failing test that drives the change.

The wait is short by design: `unfrak-backfill` is close behind, not a someday. This stage stops short of it only so that the spec is settled before any code moves.

This is a deliberate trade. An executable reminder is stronger than a document. But a retrofit runs in small bites on a live codebase, alongside other people's work, and it must never end a session with a suite that is red or noisy. A red suite that is *expected* to be red stops carrying information, and it takes "green means safe to commit" down with it for everyone else. The register is the reminder; the suite stays a signal.

## 3. When the code cannot be tested as written, refactor first
Retrofits routinely land on code that has no seam: logic that reaches straight out to a page, a global, a clock, or a network call, with nothing to hand a test. Do not bolt a parallel testable path beside it, and do not add a heavyweight harness dependency to avoid the problem.

Stop and run the `refactor` skill: introduce the seam — take the dependency as an argument, split the reading from the deciding — as its own prep commit, with the behavior unchanged. Then come back and write the test. This is the ordinary cost of retrofitting untested code, and it is worth naming up front when planning an area, because it is usually the largest single piece of work in the whole retrofit.

Seams needed only by gap fixes rather than by these tests can wait for `unfrak-backfill`, which opens with exactly this work.

## 4. Then go after the rules nobody wrote down
With the promises pinned, the area divides into code the documentation explains and code it does not. That second part is the search space, and it has two entrances.

- **Code the tests did not reach, that no documentation line accounts for.** Most uncovered code is just an unexercised path through a promise — that is a thin test, not a missing rule. What you are hunting is behavior *nothing in the README would lead anyone to expect*: a rounding choice, a sign convention, an ordering guarantee, a format, a bound, a fallback. Those are commitments the code has been keeping silently.
- **Tests that already exist with no rule behind them.** A test is somebody having decided something mattered enough to pin it, which makes it far better evidence of intent than implementation code — the closest thing to a written-down commitment that is not documentation. If you cannot name the rule a passing test defends, either the rule is undocumented or the test is ceremony, and both are worth surfacing.

Neither entrance is a licence to enumerate every internal detail. A candidate earns a place on the list only if getting it wrong later would be a bug rather than a surprise.

## 5. Take a verdict on each candidate rule
These are not ratification questions and must not be asked as though they were. Ratify asks *is this what you want?*, a question about desire. Here the user may want the behavior either way; what is undecided is whether the project is **binding itself** to it. One answer earns a test obligation forever, the other earns a sentence and none.

- **Binding** — it becomes an engineering decision with the next `ED-<n>`, and this stage owes it tests.
- **Descriptive** — true today, but nothing is promised. Hand it to `unfrak-describe` for the architecture notes. No test.
- **Binding, but wrong** — the rule the project should hold is not the rule the code keeps. Record the *intended* rule as the engineering decision, and send the divergence to `unfrak-register`, exactly as a broken README promise goes there. **Do not fix it here**, and do not treat it as urgent merely because it is newly visible; it has usually been true for years, and halting ongoing work over it costs more than it saves.
- **Not worth writing** — real, harmless, and of interest to nobody. Drop it. `ARCHITECTURE.md` has to earn its lines the way `README.md` does, and a retrofit that transcribes every implementation detail produces a document nobody reads and that is stale within a month.

**Authorship works differently here than in ratification.** The *decision* is the user's, and silence is not agreement — but the wording can be drafted, because unlike the README this is not a spec written in their voice. Propose it, and let them correct it.

**Pace it by what a mistake costs, not one per message.** Ratify walks points one at a time because user-facing promises are few and each is load-bearing. Internal candidates are many and mostly trivial, and forty of them asked individually will be skimmed — the very failure ratify's pacing exists to prevent, reintroduced by copying it. So ask individually where the binding-versus-descriptive call is genuinely contested or expensive to get wrong, and batch the obvious remainder into a single confirmation. The two mistakes are not symmetric: filing a commitment as merely descriptive silently loses both a promise and its test, while filing a description as binding over-constrains future work with a test nobody needed. The first is worse. The second is not free.

## 6. One rule is rarely one test
Do not treat an engineering decision as satisfied by a single assertion. A rule saying that direction is carried only by the sign of a value needs the positive case, the negative case, the boundary, and evidence that nothing else in the payload carries the same information — otherwise the rule is stated but not pinned.

The bar is *is this rule actually held down*, which is a judgement, not *does a test mention it*, which is a checkbox. The project's own testing rules already imply the shape: the expected case, then edge cases, missing resources, garbage inputs, and the successful prevention of what must not happen.

## 7. Cover the expensive cases first
Within the area, prioritise anything destructive or irreversible, anything handling personal data, and anything that talks to an external service — mocked, always. A retrofit is often the first time this code has been pinned at all; spend the first tests where being wrong costs the most.

This is ordering advice, not the coverage obligation itself. `unfrak-harden` is the stage that goes after those paths systematically, whether or not a promise or a rule happens to run through them.

## 8. Leave the suite better than green
Run the whole suite, not just the new tests, and read the output for warnings as well as failures. A retrofit that leaves new noise behind has taught everyone else to ignore the noise.
