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
  - [`dependency-change`](skills/dependency-change/SKILL.md) — run when adding,
    upgrading, replacing, or removing a third-party dependency.

The split matters because `AGENTS.md` content is always in the agent's context,
while a skill's body loads on demand. Rules that must always hold live in
`AGENTS.md`; procedures invoked at a specific moment live as skills.

## Repository layout

```
AGENTS.md                     # always-on guardrails (imported by consumers)
install.sh                    # consumer setup: links k5's skills into .claude/skills/
skills/
  new-feature/SKILL.md        # test-first forward DDD loop for net-new behavior
  wrap-up-work/SKILL.md       # end-of-work doc/code/test reconciliation
  refactor/SKILL.md           # safe, test-backed refactoring procedure
  dependency-change/SKILL.md  # add/upgrade/remove a dependency (credits LICENSE.md)
.claude/skills/               # symlinks so this repo discovers its own skills
```

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

Anyone cloning the consuming project afterward runs
`git submodule update --init` to populate `.claude/shared`. Skills are scanned at
session start, so start a fresh Claude Code session to pick them up.

To update the workflow everywhere, push changes here, then in each consuming
project bump the submodule and re-link:
`git -C .claude/shared pull && .claude/shared/install.sh && git add .claude`.

## Required vs. optional skills

The skills k5 provides are **required**: `install.sh` links them into the
project's `.claude/skills/`, and those symlinks are committed, so everyone who
clones the project gets them, pinned to the submodule's commit.

Anyone is still free to use **their own** skills alongside them:

- **Personal skills** in `~/.claude/skills/` are always available to that person
  in every project, with no setup — the natural home for skills they like to
  carry around. Nothing here interferes with them.
- **Extra project-local skills** can be added directly to `.claude/skills/`.
  `install.sh` only manages k5's links and never touches other entries, so they
  coexist. On a name clash the required k5 skill wins: the script warns and skips
  rather than overwriting your file, so you rename yours to hand the name over.
