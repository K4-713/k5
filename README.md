# k5
A shared, reusable workflow that enables and enforces End-User Documentation
Driven Development (DDD) across all of your projects.

## Description

k5 is meant to be consumed by your other repositories as a git
submodule, so the workflow lives in one place instead of being copy-pasted into
every project. It has two halves:

- **Enforce — always-on guardrails (`AGENTS.md`).** Coding practices, guidelines,
  dependency rules, logging levels, and testing requirements that must apply to
  *every* change. Consuming projects load these into context at all times via an
  `@import`.
- **Enable — on-demand procedures (`skills/`).** Step-by-step workflows that load
  only when the relevant moment arrives:
  - [`new-feature`](skills/new-feature/SKILL.md) — run when building net-new
    behavior, to walk the test-first DDD loop (spec → failing tests →
    engineering decisions → implement to green).
  - [`wrap-up-work`](skills/wrap-up-work/SKILL.md) — run when finishing a chunk
    of work (before committing or opening a PR) to reconcile the documentation
    against the code and close `TDD_` test gaps.
  - [`refactor`](skills/refactor/SKILL.md) — run when restructuring existing
    code without changing its observable behavior.

The split matters because `AGENTS.md` content is always in the agent's context,
while a skill's body loads on demand. Rules that must always hold live in
`AGENTS.md`; procedures invoked at a specific moment live as skills.

## Repository layout

```
AGENTS.md                     # always-on guardrails (imported by consumers)
skills/
  new-feature/SKILL.md        # test-first forward DDD loop for net-new behavior
  wrap-up-work/SKILL.md       # end-of-work doc/code/test reconciliation
  refactor/SKILL.md           # safe, test-backed refactoring procedure
.claude/skills/               # symlinks so this repo discovers its own skills
```

## Using k5 in another project

From the root of a project that should adopt the workflow:

```sh
# 1. Add k5 as a submodule.
git submodule add <k5-remote-url> .claude/shared

# 2. Surface each skill into the path Claude Code scans (.claude/skills/).
mkdir -p .claude/skills
ln -snf ../shared/skills/new-feature  .claude/skills/new-feature
ln -snf ../shared/skills/wrap-up-work .claude/skills/wrap-up-work
ln -snf ../shared/skills/refactor     .claude/skills/refactor

# 3. Load the always-on guardrails by importing them from CLAUDE.md.
#    (Add this line to the project's CLAUDE.md or AGENTS.md.)
echo '@.claude/shared/AGENTS.md' >> CLAUDE.md

# 4. Commit the wiring.
git add .gitmodules .claude CLAUDE.md
git commit -m "Adopt k5 shared DDD workflow"
```

Anyone cloning the consuming project afterward runs
`git submodule update --init` to populate `.claude/shared`. Skills are scanned at
session start, so start a fresh Claude Code session to pick them up.

To update the workflow everywhere, push changes here, then in each consuming
project bump the submodule: `git -C .claude/shared pull && git add .claude/shared`.
