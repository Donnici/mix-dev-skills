---
name: mix-migrate
description: "Move a project's Spec Kit (.specify/, speckit commands) and Matt Pocock skills (GLOSSARY.md, docs/adr/, .out-of-scope/, docs/agents/, .scratch/) structures into the mix-dev-skills layout, converting the constitution and config and updating references."
disable-model-invocation: true
argument-hint: "[path] [--dry-run]"
---

# Migrate

Bring an existing project onto the mix layout (defined in the `mix-scope` skill): config, rules,
architecture, glossary, ADRs, and templates under `mix-dev-skills/`, specs under `specs/`. The
mapping for every known source is in [MAPPING.md](MAPPING.md).

`--dry-run`: run steps 1–3 and stop after showing the plan.

## 1. Find the base

Call the Skill tool with `mix-scope`. The **base** is the resolved project's base; with no project
yet, the path given, else the current folder (ask whether the project should live in-repo or in
a hub, as `/mix-setup` does). Sources are searched in the base and, for hub projects, in each
code repo of the project.

## 2. Inventory

List every source from [MAPPING.md](MAPPING.md) that exists, plus anything that looks like either
structure but isn't in the mapping (report it as **unknown**, never guess). For each: path,
file count, last modified, and whether it lives in a git repo. Also note mix files that already
exist at the destinations.

Done when every match is listed. Nothing found → say the project has no legacy structure and stop.

## 3. Plan and decide

Show the plan as one table: source → destination → action (move / convert / merge / config /
remove / keep), with conflicts marked. Then settle, in one round with recommendations
(`mix-grill` format):

- Constitution: add the mix default principles the original lacks? (recommended: yes)
- Customised Spec Kit templates: keep as project overrides in `mix-dev-skills/templates/`, or drop?
- Removals: confirm each group (Spec Kit tooling and scripts, extensions and their hooks, agent
  command copies, context-file blocks).
- Sources inside code repos for a hub project: copy (repo untouched) or move?
- Unknown items: leave, or map where?

Wait for answers. Nothing is changed before this point.

## 4. Execute

In this order, so nothing referenced is removed before its replacement exists:

1. Create `mix-dev-skills/` and write `mix.yml` (new from the setup template's shape, or merged
   into the existing one) with any **config** values.
2. **Move** files. Inside a git repo use `git mv` so history follows; elsewhere copy, verify the
   copy (same file count and bytes), then delete the source.
3. **Convert** and **merge** per [MAPPING.md](MAPPING.md). Show the converted constitution as a
   diff against the original and get approval before writing it.
4. **Update references**: search every Markdown and config file in the base (and touched repos)
   for the old paths and ADR numbers, and rewrite them to the new ones.
5. Replace removed context-file blocks with the mix pointer block (the one `/mix-setup` writes).
6. **Remove** what the user approved, last.

## 5. Verify

- Every inventoried source is accounted for: moved, converted, merged, configured, removed, or
  kept, with the reason.
- File counts match for every move (sources vs destinations).
- No reference to an old path remains (search again).
- Resolving with `mix-scope` now shows the new layout and no legacy warning.
- Each migrated spec folder opens with its Delivery line and is listed in `specs/`.

## 6. Report

The table from step 3 with the final outcome per row, ADR renumbering (old → new), constitution
version change, removed hooks, and anything left in place. Next steps: `/mix-setup` to map the
architecture (if not done), `/mix-clarify` on specs marked `Migrated`. Propose a commit message
(`chore: migrate to mix-dev-skills layout`); commit only when the user approves, and never push.
