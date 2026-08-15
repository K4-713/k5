# k5
A shared, reusable workflow that enables and enforces End-User Documentation Driven Development (DDD) across all of your projects.

## Description

k5 is meant to be consumed by your other repositories as a git submodule, so the workflow lives in one place instead of being copy-pasted into every project. It has two halves:

- **Enforce — always-on guardrails (`AGENTS.md`).** Coding practices, guidelines, dependency rules, logging levels, and testing requirements that must apply to *every* change. Consuming projects load these into context at all times via an `@import`.
- **Enable — on-demand procedures (`skills/`).** Step-by-step workflows that load only when the relevant moment arrives:
  - [`new-feature`](skills/new-feature/SKILL.md) — run when building net-new behavior, to walk the test-first DDD loop (spec → failing tests → engineering decisions → implement to green).
  - [`wrap-up-work`](skills/wrap-up-work/SKILL.md) — run when finishing a chunk of work (before committing or opening a PR) to reconcile the documentation against the code and close `TDD_` test gaps.
  - [`refactor`](skills/refactor/SKILL.md) — run when restructuring existing code without changing its observable behavior.
  - [`dependency-change`](skills/dependency-change/SKILL.md) — run when adding, upgrading, replacing, or removing a third-party dependency.
  - [`confirm-by-eye`](skills/confirm-by-eye/SKILL.md) — run when iterating on a change that can only be judged perceptually (look, motion, feel, sound, timing) and has no definitive `TDD_` test: one change at a time, an A/B toggle in the real product, the user's perception as the verdict.
  - [`unfrak`](skills/unfrak/SKILL.md) — run when adopting DDD on code written before it, or on a feature area with no spec at all. An umbrella over eight stages, each its own skill, taken one feature area at a time: [`unfrak-survey`](skills/unfrak-survey/SKILL.md) ranks what still lacks a ratified spec; [`unfrak-inventory`](skills/unfrak-inventory/SKILL.md) reads an area and lists what it actually does; [`unfrak-ratify`](skills/unfrak-ratify/SKILL.md) walks those findings with the user for a verdict on each; [`unfrak-register`](skills/unfrak-register/SKILL.md) records where the code falls short of them; [`unfrak-lock`](skills/unfrak-lock/SKILL.md) pins the behavior that already works; and [`unfrak-backfill`](skills/unfrak-backfill/SKILL.md) closes the gaps. Two further stages leave the area better than merely specified: [`unfrak-harden`](skills/unfrak-harden/SKILL.md) covers what the docs never promised — the paths that destroy data, touch PII, or call out — and walks each security weakness with the user; then [`unfrak-polish`](skills/unfrak-polish/SKILL.md) brings the code into conformance with the practices `AGENTS.md` states, citing the rule behind every finding.

The split matters because `AGENTS.md` content is always in the agent's context, while a skill's body loads on demand. Rules that must always hold live in `AGENTS.md`; procedures invoked at a specific moment live as skills.

## Repository layout

```
AGENTS.md                     # always-on guardrails (imported by consumers)
install.sh                    # setup: links k5's skills into .claude/skills/ (consumers and k5 itself)
skills/
  new-feature/SKILL.md        # test-first forward DDD loop for net-new behavior
  wrap-up-work/SKILL.md       # end-of-work doc/code/test reconciliation
  refactor/SKILL.md           # safe, test-backed refactoring procedure
  dependency-change/SKILL.md  # add/upgrade/remove a dependency (keeps credits accurate)
  confirm-by-eye/SKILL.md     # user-in-the-loop verification for perceptual changes
  unfrak/SKILL.md             # umbrella: retrofit DDD onto existing code, one area at a time
  unfrak-survey/SKILL.md      # rank the areas that still have no ratified spec
  unfrak-inventory/SKILL.md   # list what an area actually does, with evidence
  unfrak-ratify/SKILL.md      # take the user's verdict on each behavior, one at a time
  unfrak-register/SKILL.md    # record where the code falls short of the ratified spec
  unfrak-lock/SKILL.md        # test the ratified behavior the code already delivers
  unfrak-backfill/SKILL.md    # close every registered gap until the area matches its spec
  unfrak-harden/SKILL.md      # cover the destructive / PII / external paths; walk weaknesses
  unfrak-polish/SKILL.md      # conform the area to the stated coding practices
.claude/skills/               # symlinks so this repo discovers its own skills
```

## Formatting, and what k5 does not decide

`AGENTS.md` carries formatting *defaults* — prose as one line per paragraph, UTF-8, LF, final newline — and one rule about them: whatever the consuming project states wins, and the project's preference is the one to enforce. k5 holds no opinion on indentation, tabs against spaces, or any language's code style, because those belong to the project and its existing tree.

k5 ships no shared `.editorconfig`. Each project carries its own, so that a project with mixed indentation is not forced into a convention that would make every editor reformat its files on save. k5 has one for itself on the same terms — it governs this repo only.

## Developing k5

After adding or removing a skill here, run `./install.sh` from this repo's root to refresh k5's own `.claude/skills/` links, and commit them. The script detects which layout it is running in — a consuming project (where it sits at `<project>/.claude/shared`) or k5 itself (where it sits at the repo root) — and writes the right links for each. Skipping this step is invisible in consuming projects but leaves k5's own sessions unable to see the skill that was just added.

**That detection is positional, so it cannot see both layouts at once.** When you are working on k5 *through* a consuming project — the usual case, since that is where the submodule is checked out — the script always takes the consuming-project branch, refreshes that project's links, and leaves k5's own tracked links untouched however many times you run it. Refresh them by hand from k5's root:

```sh
for s in skills/*/; do n=$(basename "$s"); [ -f "$s/SKILL.md" ] || continue;
    ln -snf "../../skills/$n" ".claude/skills/$n"; done
```

Then commit the links. Worth teaching the script to take a flag instead.

## Using k5 in another project

From the root of a project that should adopt the workflow:

```sh
# 1. Add k5 as a submodule.
git submodule add <k5-remote-url> .claude/shared

# 2. Link k5's required skills into .claude/skills/ (one command for all of them;
#    re-run anytime to pick up newly added k5 skills). Your own skills there are
#    left untouched.
.claude/shared/install.sh

# 3. Load the always-on guardrails by importing them from CLAUDE.md.
#    (Add this line to the project's CLAUDE.md or AGENTS.md.)
echo '@.claude/shared/AGENTS.md' >> CLAUDE.md

# 4. Commit the wiring.
git add .gitmodules .claude CLAUDE.md
git commit -m "Adopt k5 shared DDD workflow"
```

Anyone cloning the consuming project afterward runs `git submodule update --init` to populate `.claude/shared`. Skills are scanned at session start, so start a fresh Claude Code session to pick them up.

To update the workflow everywhere, push changes here, then in each consuming project bump the submodule and re-link: `git -C .claude/shared pull && .claude/shared/install.sh && git add .claude`.

## Required vs. optional skills

The skills k5 provides are **required**: `install.sh` links them into the project's `.claude/skills/`, and those symlinks are committed, so everyone who clones the project gets them, pinned to the submodule's commit.

Anyone is still free to use **their own** skills alongside them:

- **Personal skills** in `~/.claude/skills/` are always available to that person in every project, with no setup — the natural home for skills they like to carry around. Nothing here interferes with them.
- **Extra project-local skills** can be added directly to `.claude/skills/`. `install.sh` only manages k5's links and never touches other entries, so they coexist. On a name clash the required k5 skill wins: the script warns and skips rather than overwriting your file, so you rename yours to hand the name over.
