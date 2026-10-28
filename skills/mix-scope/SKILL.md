---
name: mix-scope
description: Resolve or switch the active mix project (scope) and its context, meaning the code repos it spans and its mix-dev-skills folder (config, constitution, architecture, glossary, ADRs, templates) and specs. Use when the user names, lists, creates, or switches a project, company, or scope, and at the start of every other mix-* skill to load context.
argument-hint: "[project name | list | add <path> | new <name>]"
---

# Scope

A **project** (scope) is one product or one company's work: its rules, architecture, glossary,
ADRs, templates, specs, and the **code repos** that implement it (one, or several such as `web`,
`bff`, `api`).

## Layout

Every project has a **base** folder: the repo root (**in-repo** mode, one repo, committed with the
code) or a project folder inside a **hub** (a folder outside the code holding many projects).
The layout under the base is fixed:

```text
<base>/
├── mix-dev-skills/              everything the flow owns that is not a spec
│   ├── mix.yml                  project config (template: mix-setup's config-template.yml)
│   ├── constitution.md          rules
│   ├── architecture.md          repo map (single repo) or system map (multi-repo)
│   ├── architecture/<repo>.md   one map per repo (multi-repo only)
│   ├── glossary.md              domain terms
│   ├── adr/NNNN-slug.md         hard-to-reverse decisions
│   ├── out-of-scope/<concept>.md   rejected requests (mix-triage)
│   ├── triage/<issue>.md        local triage drafts (read-only trackers)
│   └── templates/               optional overrides: spec.md, quick-spec.md, plan.md,
│                                tasks.md, constitution.md, architecture.md, system.md
└── specs/NNN-slug/              spec.md, plan.md, tasks.md, checklists/, delivery.md
```

Files are created lazily, when there is something to write. A skill that uses a template looks in
`mix-dev-skills/templates/` first and falls back to the one bundled with the skill.

A **hub** is marked by `<hub>/mix-dev-skills/hub.yml` (template: [hub-template.yml](hub-template.yml)),
which registers projects at **any path inside the hub**. Each project folder has its own
`mix-dev-skills/` and `specs/`. Code repos live wherever they are; `mix.yml` says where. Known
hubs are listed in `~/.mix-dev-skills/registry.yml` (`hubs: [<absolute path>, ...]`) and
`$MIX_HUB`, so a session started inside a code repo can find its project.

Knowledge the user keeps elsewhere (notes, decision write-ups, incident logs) is never moved:
`mix.yml` lists it under `knowledge:` as paths relative to the base, and skills read it as reference.

## Resolve (default action, and what other skills call)

Take the first that applies:

1. **Named**: the user or the calling skill named a project → look it up in the current hub, then
   in every registered hub.
2. **Inside a hub**: `mix-dev-skills/hub.yml` in the current folder or a parent. Project = the one
   whose folder contains the current folder; else the one whose code root or repos contain it;
   else the hub's `active`.
3. **In-repo**: `mix-dev-skills/mix.yml` at the repo root (git top level, or the current folder).
4. **Inside a project's code**: across registered hubs, the project whose code `root` or repo
   paths contain the current folder. Several match → ask.
5. **Nothing**: the current folder is the base and the only repo; suggest `/mix-setup` once.

**Legacy structures**: when the base or its repos contain Spec Kit (`.specify/`) or Matt Pocock
skills material (`GLOSSARY.md`, `GLOSSARY-MAP.md`, `CONTEXT.md`, `docs/adr/`, `.out-of-scope/`,
`docs/agents/`, `.scratch/`) and no `mix-dev-skills/` equivalent, don't read from it as if it were
mix context: tell the user once and recommend `/mix-migrate`.

Repo paths in `mix.yml` are relative to `root` unless absolute. Expand `~`. State the context in
one compact block and use it for the rest of the session:

```text
Project: nimbus   (hub ~/workspace/knowledge-hub → work/clients/nimbus)
Code:    ~/code/nimbus
Repos:   storefront (online store) · catalog-api (business rules, persistence) · admin-web (back-office)
Docs:    work/clients/nimbus/mix-dev-skills/ · specs work/clients/nimbus/specs/
```

When neither the folder nor a name decides and the hub has several projects, ask which one,
listing them with the `active` one recommended.

## Hub conventions

A hub that is an existing repo has its own rules (`CLAUDE.md` / `AGENTS.md`): file naming, index
files, frontmatter, language, commit policy. Every file a mix skill writes **inside the hub**
follows them (e.g. list a new spec in the folder's `index.md` when the hub keeps one). Those
rules never extend to the code repos, where nothing is pushed or published without the user's
explicit request.

## list

Projects across the current and registered hubs: name, project folder, code root, repos, active
marker, last spec.

## Switch (`/mix-scope <name>`)

Set `active: <name>` in that hub's `hub.yml` and print the resolved context. Unknown name →
offer `add` or `new`.

## add `<path>`

Register an **existing** folder in the hub as a project (e.g. a company folder with notes): add
it to `hub.yml`, then hand off to `/mix-setup` for that project. If the folder holds Spec Kit or
Matt Pocock material, run `/mix-migrate` first.

## new `<name>`

Create a project folder (under the hub's `default_project_dir`), register it, then hand off to
`/mix-setup`. When no hub exists yet: ask where (an existing repo such as a notes vault, or
`~/mix-dev-skills-hub/`), write `<hub>/mix-dev-skills/hub.yml` from the template, and add the hub
to `~/.mix-dev-skills/registry.yml`. If the hub has a `CLAUDE.md`, add one line there pointing to
this skill; otherwise create one with that line.
