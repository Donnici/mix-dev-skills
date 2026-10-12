---
name: mix-tasks
description: "Break the plan into tasks.md: vertical slices per user story, prefactor first, each task naming its file, its exemplar to mirror, and its blockers. Spec Kit's tasks merged with to-tickets."
disable-model-invocation: true
argument-hint: "[feature dir]"
---

# Tasks

Turn `plan.md` into a dependency-ordered `tasks.md` that an agent can execute task by task without
re-reading the whole spec.

**Context**: call the Skill tool with `mix-scope` to resolve the project: its repos (one or
several) and the paths to the constitution, architecture docs, glossary, ADRs, and specs folder.
A git repo is not required.

**Feature**: the folder passed as argument; else the one whose spec **Delivery** line names the
current git branch; else `feature_directory` in the project folder's `.specify/feature.json`
(Spec Kit); else the most recently modified feature folder. Confirm it in one line. Requires
`spec.md` and `plan.md`; if either is missing, name the skill to run.

## 1. Load

`plan.md` and `spec.md` (required); `data-model.md`, `contracts/`, `research.md` if present; the
constitution; the architecture doc for golden files.

## 2. Slice

Organise by **user story**, in priority order. Each story phase is a **vertical slice**: a narrow
but complete path through every layer it needs (data, logic, interface, UI, its tests), so that
when the phase is done the story works and can be demonstrated alone. Never slice horizontally
("all models", then "all services").

- **Prefactor first.** Changes the plan flagged to make the feature easy go in Phase 1, with no
  behaviour change.
- **Foundation** holds only what every story needs. Something one story needs lives in that story.
- **Tests** come only from the plan's **Test Seams**: one test task per seam-behaviour pair, placed
  before the implementation it drives. No test-per-file tasks, no test tasks for seams the plan did
  not agree.
- **Wide refactors** (one mechanical change touching many call sites) use **expand–contract**:
  add the new form beside the old, migrate call sites in batches (one task each), then remove the
  old form in a task blocked by every batch.
- **Multi-repo stories** follow the plan's **Order of Change** inside the story: the contract
  task first, then provider tasks, then consumer tasks (in parallel with the provider when the
  plan builds consumers against a contract mock), then one integration task that verifies the
  story end to end across the repos.
- Each task fits one focused work session and one repo; split anything larger.

## 3. Write each task

Use [tasks-template.md](tasks-template.md). Every task:

- Starts with `- [ ] T###`, numbered in execution order.
- Names its repo (`[api]`, `[web]`) in multi-repo projects.
- Is one imperative action on named files (`in src/features/orders/api.ts`).
- Names the exemplar to **mirror** from the plan's Prior Art or the architecture's golden files.
- Quotes data constraints verbatim from the data model (max length, required, enum values), so
  they are not left to implementation-time judgement.
- Lists its blockers with `(after T###)` when they are not simply the previous phase.
- Marks `[P]` only when it touches different files from every unfinished task it could run with.

Always end with the **Hardening** phase from the template.

## 4. Review with the user

Present the breakdown as a compact list per phase: task, blockers, what it delivers. Ask:

- Is the granularity right (too coarse / too fine)?
- Are the blockers real: does each task depend only on what genuinely gates it?
- Is the MVP (usually US1) the right first cut?
- With a per-story strategy: is each story phase a reviewable PR on its own? Split a story whose
  phase would produce an oversized PR; merge stories too small to be worth a PR.

Iterate until approved, then write `tasks.md`.

## 5. Tickets and delivery

Read the spec's **Delivery** line and the config's `tracker` block.

- **Stories marked "to create"** with a tracker configured and `create_tickets` not `never`:
  draft one ticket per story (title, the story sentence, acceptance criteria as a checklist,
  link to the spec when in-repo). Show the drafts and create them only after the user confirms,
  with whatever this session offers for that tracker (an MCP server, `gh issue create`,
  `glab issue create`, a CLI from `tracker.notes`). Nothing available → write the drafts to
  `<feature>/delivery.md` and ask the user for the codes once they exist.
- **No tracker** but the patterns use `[ticket]` → ask the user for each story's code.
- Fill each story phase's **Delivery** line: ticket, the branch it will ship from (the story
  branch for `per-story` strategies, resolved through the `mix-pr` naming rules; the feature
  branch for `single`; "none" without git), and the repos it touches (one PR per repo). Update the spec's Delivery line with the codes.

## 6. Report

Path, task count per phase and per story, parallel opportunities, MVP scope, tickets created or
collected, the branch/PR each story ships in, and the next step: `/mix-analyze` (recommended) or
`/mix-implement`.
