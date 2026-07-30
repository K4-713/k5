#!/usr/bin/env sh
# install.sh — surface k5's required skills into a consuming project.
#
# After adding k5 as a submodule at .claude/shared, run from the project:
#     .claude/shared/install.sh
#
# Run it from k5's own root (./install.sh) to refresh k5's self-links the same
# way, so this repo's sessions discover the skills it ships.
#
# Creates one symlink per k5 skill in .claude/skills/, so Claude Code discovers
# them. Safe to re-run: it picks up newly added k5 skills and prunes links to
# skills k5 has removed. It only manages its own links — any other skills you
# keep in .claude/skills/ are left untouched, and it never overwrites a real
# file or directory.

set -eu

# Resolve paths relative to this script, so it works from any working directory.
script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
shared_skills_dir="$script_dir/skills"

# Two layouts run this script, and the links differ between them:
#   * a consuming project — the script sits at <project>/.claude/shared, so the
#     links belong in the .claude/ directory above it and point back down
#     through shared/.
#   * k5 itself — the script sits at the repo root, so the links belong in k5's
#     own .claude/ and reach the skills one level further up.
# Detect by whether the parent directory is the .claude/ of a consuming project.
parent_dir=$(dirname "$script_dir")
if [ "$(basename "$parent_dir")" = ".claude" ]; then
    claude_dir="$parent_dir"                        # <project>/.claude
    link_target_prefix="../shared/skills"
else
    claude_dir="$script_dir/.claude"                # <k5>/.claude
    link_target_prefix="../../skills"
fi
skills_dir="$claude_dir/skills"

mkdir -p "$skills_dir"

linked=0
skipped=0

# 1. Link every k5 skill (a directory holding a SKILL.md) into .claude/skills/.
for skill_path in "$shared_skills_dir"/*/; do
    [ -f "${skill_path}SKILL.md" ] || continue
    name=$(basename "$skill_path")
    link="$skills_dir/$name"

    if [ -L "$link" ] || [ ! -e "$link" ]; then
        # Our own (possibly stale) symlink, or nothing there yet — safe to set.
        ln -snf "$link_target_prefix/$name" "$link"
        linked=$((linked + 1))
    else
        # A real file/dir with the same name — someone's own skill. Don't
        # destroy it; the required k5 skill wins only once they move theirs.
        printf 'WARN: %s exists and is not a symlink; skipping so your file is not overwritten (rename it to let the required k5 skill take over).\n' "$link" >&2
        skipped=$((skipped + 1))
    fi
done

# 2. Prune our links to skills k5 no longer provides, touching nothing else.
for link in "$skills_dir"/*; do
    [ -L "$link" ] || continue
    case "$(readlink "$link")" in
        "$link_target_prefix"/*)
            name=$(basename "$link")
            if [ ! -d "$shared_skills_dir/$name" ]; then
                rm "$link"
                printf 'pruned stale k5 skill link: %s\n' "$name"
            fi
            ;;
    esac
done

printf 'k5: linked %d skill(s), skipped %d.\n' "$linked" "$skipped"
