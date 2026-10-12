---
name: mix-scope
description: Resolve or switch the active mix project (scope) and its context, meaning the code repos it spans and the paths to its constitution, architecture docs, knowledge docs, glossary, ADRs, and specs. Use when the user names, lists, creates, or switches a project, company, or scope, and at the start of every other mix-* skill to load context.
argument-hint: "[project name | list | add <path> | new <name>]"
---

# Scope

A **project** (scope) is one product or one company's work: its rules, architecture, knowledge,
glossary, ADRs, specs, and the **code repos** that implement it (one, or several such as `web`,
`bff`, `api`). Each project has a `mix.yml` (template: the `mix-setup` skill's
`config-template.yml`). Where `mix.yml` lives:

- **In-repo**: `docs/ai/mix.yml` inside a single code repo. One project, committed with the code.
- **Hub**: any folder outside the code with a `mix-hub.yml` at its root (template:
  [hub-template.yml](hub-template.yml)). The hub registers projects at **any path inside it**
  (`work/clients/nimbus`), and each project folder holds its own `mix.yml`. A hub
  can be a folder created for this (default `~/.mix-dev/`) or an existing repo such as a notes
  vault. Code repos live wherever they are; each project's `mix.yml` says where.

Hubs are listed in `~/.mix-dev/registry.yml` (`hubs: [<absolute path>, ...]`) and in `$MIX_HUB`,
so a session started inside a code repo can still find its project.

## Resolve (default action, and what other skills call)

Take the first that applies:

1. **Named**: the user or the calling skill named a project → look it up in the current hub, then
   in every registered hub.
2. **Inside a hub**: `mix-hub.yml` in the current folder or a parent. Project = the one whose
   folder contains the current folder; else the one whose code root or repos contain it; else the
   hub's `active`.
3. **In-repo**: `docs/ai/mix.yml` at the repo root (git top level, or the current folder).
4. **Inside a project's code**: across registered hubs, the project whose code `root` or repo
   paths contain the current folder. Several match → ask.
5. **Nothing**: defaults `docs/ai/constitution.md` (or `.specify/memory/constitution.md`),
   `docs/ai/architecture.md`, `GLOSSARY.md`, `docs/adr/`, `specs/`, the current folder as the only
   repo; suggest `/mix-setup` once.

Paths inside `mix.yml` are relative to the folder holding it (a project folder, or the repo root
for in-repo); code repo paths are relative to `root` unless absolute. Expand `~`.

State the context in one compact block and use it for the rest of the session:

```text
Project: nimbus   (hub ~/workspace/knowledge-hub → work/clients/nimbus)
Code:    ~/code/nimbus
Repos:   storefront (online store) · catalog-api (business rules, persistence) · admin-web (back-office)
Docs:    constitution .specify/memory/constitution.md · architecture · knowledge files/ · specs specs/
```

When neither the folder nor a name decides and the hub has several projects, ask which one,
listing them with the `active` one recommended.

## Hub conventions

A hub that is an existing repo has its own rules (`CLAUDE.md` / `AGENTS.md`): file naming, index
files, frontmatter, language, commit policy. Every file a mix skill writes **inside the hub**
(specs, docs, glossary, ADRs) follows them: e.g. add new specs to the folder's `index.md` when the
hub keeps one. Those rules never extend to the code repos, where nothing is pushed or published
without the user's explicit request.

## list

Projects across the current and registered hubs: name, project folder, code root, repos, active
marker, last spec.

## Switch (`/mix-scope <name>`)

Set `active: <name>` in that hub's `mix-hub.yml` and print the resolved context. Unknown name →
offer `add` or `new`.

## add `<path>`

Register an **existing** folder in the hub as a project (e.g. a company folder that already has
specs and notes): add it to `mix-hub.yml` with its path, then hand off to `/mix-setup` for that
project, which maps the folder's existing layout instead of creating a new one.

## new `<name>`

Create a project folder (under the hub's `default_project_dir`), register it, then hand off to
`/mix-setup`. When no hub exists yet: ask where (an existing repo such as a notes vault, or
`~/.mix-dev/`), write `mix-hub.yml` from the template, and add the hub to
`~/.mix-dev/registry.yml`. If the hub has a `CLAUDE.md`, add one line there pointing to this skill;
otherwise create one with that line.
