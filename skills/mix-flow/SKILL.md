---
name: mix-flow
description: "Which mix-* skill fits your situation, and the order of the spec-driven flow."
disable-model-invocation: true
---

# Flow

Before recommending a skill or saying a step can be skipped, read that skill's `SKILL.md`; the
summaries here are for orientation.

## Projects, repos, hub

A **project** (scope) is one product or one company's work: its own rules, architecture docs,
knowledge notes, glossary, ADRs, specs, and one or more code **repos** (e.g. `web`, `bff`, `api`),
wherever they are on disk. Projects live either **in-repo** (`docs/ai/` of a single repo) or in a
**hub**: a folder outside the code (an existing notes repo, or `~/.mix-dev/`) where each project
is a folder at any path, e.g. `work/clients/<company>/`. Existing material in that
folder (a Spec Kit constitution, `specs/`, notes) is adopted, not duplicated.

- **`/mix-scope`**: show the active project; `/mix-scope lumen` switches; `list`; `new <name>`.
  Every other skill resolves its context through it.

## Once per project

**`/mix-setup`** asks hub vs in-repo, the root folder and each repo's role, branch/PR/ticket
conventions; maps each repo's stack, installed libraries, patterns, and golden files; for
multi-repo projects also maps how the repos integrate (contracts, golden path across repos); and
creates the constitution with the default rules. Re-run after big structural changes.

## Main flow: idea → reviewed code

1. **`/mix-specify <idea>`**: explores every repo, settles delivery (strategy, tickets, feature
   branch), grills you on material decisions, writes `spec.md`, keeps glossary and ADRs current.
   `--quick` when the conversation already settled everything.
2. **`/mix-clarify`** *(recommended)*: coverage scan of the spec, more questions, answers written
   back.
3. **`/mix-plan`**: which repos change and why, reuse inventory, constitution gate, **contracts
   between repos first**, module design per repo, agreed test seams → `plan.md`.
4. **`/mix-tasks`**: vertical slices per story; inside a story: contract → provider → consumer →
   integration; each task tagged with its repo and exemplar → `tasks.md`; tickets per story.
5. **`/mix-analyze`** *(recommended)*: read-only consistency check, including both sides of every
   contract.
6. **`/mix-implement`**: builds task by task in each repo; at each delivery boundary prunes tests,
   strips comment noise, self-reviews, and offers a **local** commit. It never pushes or opens PRs.
7. **`/mix-pr push` / `/mix-pr pr`**: you decide when work leaves the machine; one PR per repo,
   linked to its siblings with the merge order.
8. **`/mix-review`**: on any PR or branch, across repos. `--tasks` appends convergence tasks; run
   `/mix-implement` again to close them.
9. **`/mix-retro <PR#>`**: turn repeated review comments into checks and rules.

Keep steps 1–4 in one session when you can. Start `/mix-implement` in a fresh session for large
features; `tasks.md` carries everything it needs.

## Delivery strategies

Chosen in `/mix-setup`, overridable per feature in `/mix-specify`:

- **single**: one branch per repo touched, one PR per repo for the feature.
- **per-story**: each story on its own branch and PR (per repo touched), to the base branch.
- **per-story-stacked**: a feature branch with a macro PR; each story PR targets it.

Names follow the configured patterns: fixed text plus `[variables]`. Default `spec/[NNN]-[slug]`
(e.g. `spec/001-alpha-login`). `[ticket]` and custom variables are asked when needed.

## No git?

Supported. Branch/commit/PR steps are skipped, planned names go to `<feature>/delivery.md`, and
review works from the files the feature touched.

## Small changes

A bug fix or a one-file change doesn't need the full flow. Implement directly, then run
`/mix-review` on the diff. The constitution and architecture docs still apply.

## Anytime

- **`/mix-constitution <rule>`**: add or change a rule.
- **`mix-grill`**: "grill me on this" for any plan or design.
- **`mix-testing`**: how to choose seams and which tests to delete.

## Files

```text
~/.mix-dev/registry.yml                  hubs to search when a session starts inside a code repo

Hub (e.g. ~/workspace/knowledge-hub)
  mix-hub.yml                            projects (name → folder) + active
  <project folder>/mix.yml               code root, repos, roles, paths, conventions
  <project folder>/...                   constitution, architecture docs, knowledge, glossary,
                                         ADRs, specs/NNN-slug/ — wherever mix.yml points

In-repo
  docs/ai/mix.yml, docs/ai/constitution.md, docs/ai/architecture.md, GLOSSARY.md, docs/adr/,
  specs/NNN-slug/
```

Repos already using Spec Kit: `.specify/memory/constitution.md` is read when no mix constitution
exists, and `specs/` keeps the same layout.
