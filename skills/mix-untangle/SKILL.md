---
name: mix-untangle
description: "Map the structural debt of a codebase or one area of it, across repos: hidden links, needless links, surplus, and special cases; redesign from today's requirements; and write untangle.md, a decision log with each fix above the problems it solves, ordered into reviewable slices. Changes no code; the fixes ship through the main flow."
disable-model-invocation: true
argument-hint: "[area or concern to focus on]"
---

# Untangle

Structural debt makes every change cost more: agents read more to change less, break things
without noticing, and take longer to find root causes. This skill finds that debt and designs
its removal. It ends in an `untangle.md` a person can approve, and changes nothing in the code
repos: the fixes ship as specs, slice by slice, through the main flow.

One question drives every step: **should these pieces change together?** Pieces that change
together belong together, pieces that change for different reasons stay untied, and everything
depends on what changes less than itself.

**Context**: call the Skill tool with `mix-scope` to resolve the project: its repos, the
constitution, the architecture docs, the glossary, the knowledge notes, and the specs folder.
A git repo is not required; without one, skip the co-change evidence.

## 1. Frame

The argument names an area (`checkout`, `the bff`) or a concern (`error handling`, `auth`);
with no argument, the target is every repo of the project. For a large target, propose starting
where leverage is highest (the most-changed and most-imported code) and confirm in one line.

Create `specs/<NNN-untangle-short-name>/untangle.md` under the project's base from
`mix-dev-skills/templates/untangle.md` when the project has one, else
[untangle-template.md](untangle-template.md), numbered like specs. In a hub, follow its file
conventions (list it in the specs index when the hub keeps one).

**Done when** **Target**, **Repos**, and **Context** are filled.

## 2. Map

Per repo in the target (one read-only subagent per repo when there are several), write throwaway
scripts in a `scratch/` folder inside the untangle directory, never in the code repos, that
produce:

- **A skeleton**: every module with its exports and signatures, bodies stripped, so the whole
  target fits in context.
- **An import graph**: what imports what, at folder level, with cycles and the most-imported
  modules.
- **Co-change evidence** (with git): the files that change most often, and the file pairs that
  change in the same commits most often, over the last year.

Read the architecture docs and the knowledge notes on the target (index first) for the intended
design and known incidents.

**Done when** **Map** lists, per repo, the hotspots, the cycles, and the top co-change pairs, and
names the command that regenerates each.

## 3. List every problem

Change nothing yet. Read the target through the skeleton and the graph, opening bodies where the
skeleton cannot answer, and record every place the code gets the driving question wrong. Each
entry is one line: `<repo>:<path>:<line>`, what is there, and why it is a problem. Use one
read-only subagent per repo or area and merge their lists.

**Hidden links**: pieces that must change together while the code does not show it.

- Copies of logic or values: change one and the others must follow, but nothing says so.
- A module that reads a global, a file, or an env value another module sets.
- A feature split across folders by layer, or related code spread over distant folders.
- A call order or convention callers must just know.
- Across repos: a contract duplicated by hand on each side (types, routes, field names, enums).

**Needless links**: pieces tied together that change for different reasons.

- Callers that depend on another module's internals.
- Stable code that imports something more volatile (check against the graph and churn).
- A general function with a parameter only one workflow understands.
- A shallow module: an interface as complex as its implementation, so callers change with it.

**Surplus**: pieces with no reason of their own to change.

- Pass-through wrappers, and abstractions with a single implementation.
- Extension points, flags, and config for things that never vary.
- Dead code: unused exports, files, branches, parameters.
- Comments that restate the code, and tests that cannot fail or repeat the implementation
  (judge them with the Skill tool `mix-testing`).

**Special cases**: code that exists for one situation instead of following from the design. Each
is a requirement the design never accounted for, so record them all; they drive step 4.

- An `if` for one value, a parameter for one caller.
- A swallowed exception, a retry, a sleep or timeout that waits for something to be ready.
- A disabled or skipped test.

**Done when** **Problems** has every finding with its location and category, and the special
cases are counted per repo.

## 4. Redesign

Work out the fixes as if the system had known today's requirements from the start. Look for the
one fix behind several problems, which often looks nothing like them; do not fix special cases
one by one. Test every fix against the driving question, even one that reads better in the code:
it must leave pieces that change together in one place, untie the ones that do not, and point
every dependency at something that changes less.

Write each fix above the problems it solves, as in the template's example, with its repos, its
risk, and how behaviour stays the same (an existing test, or a characterization test the fix
adds first). A special case the redesign does not remove stays, with the requirement it serves.
A problem not worth its fix goes to **Accepted** with the reason. Decisions that are the user's
(a contract change between repos, a public API break, a new dependency) go through the Skill
tool with `mix-grill`.

**Done when** every problem sits under exactly one fix or under **Accepted**, and every fix
names how its behaviour is verified.

## 5. Check

Start fresh read-only subagents with the map and the target, not the decision log, and ask them
for hidden links, needless links, surplus, and special cases. Then give a second subagent the
fixes and ask it to challenge each one against the driving question. Add what survives to steps
3 and 4 and run this step again.

**Done when** a round brings no new finding worth fixing and no fix that fails the challenge.

## 6. Order into slices

Sequence the fixes so each is one reviewable PR per repo, with no behaviour change:

- Fixes that others depend on go first; a fix that removes many special cases goes early.
- Wide mechanical changes use expand–contract: the new form beside the old, call sites migrated
  in batches, the old form removed last.
- Across repos, the contract first, then the provider, then the consumers.
- Fixes in the same files are sequential; the rest are marked parallel.

**Done when** **Slices** lists every fix in order, each with its repos, blockers, and size
(small: a `/mix-quick-implement`; larger: a story in a spec).

## 7. Report

The untangle path, the special-case count per repo, the fixes in order with the problems each
removes, what was accepted, and the next step: `/mix-specify --quick` from this `untangle.md`,
one story per slice, each with "observable behaviour unchanged" as a requirement; or
`/mix-quick-implement` for a slice that is small. Delete `scratch/` when the user does not want
the scripts kept, after asking.
