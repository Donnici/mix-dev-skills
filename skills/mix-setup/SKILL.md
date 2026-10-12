---
name: mix-setup
description: "Configure a project for the mix-* flow: in one repo or in a hub of projects spanning several repos (web, bff, api); branch/PR/ticket conventions; a map of each repo's stack, libraries, patterns and golden files; how the repos integrate; and the constitution. Run once per project, and again after large changes."
disable-model-invocation: true
argument-hint: "[project name] [focus area]"
---

# Setup

Produce the per-project context every other `mix-*` skill reads, all inside the project's
`mix-dev-skills/` folder (layout: the `mix-scope` skill):

- **Config** (`mix.yml`, template: [config-template.yml](config-template.yml)): code root, repos
  and their roles, knowledge pointers, branch/PR/ticket conventions.
- **Architecture docs**: per repo, what it is and how code is written there
  ([architecture-template.md](architecture-template.md)); for multi-repo projects, a system map of
  how the repos integrate ([system-template.md](system-template.md)).
- **Constitution**: the rules agents follow (written through the `mix-constitution` skill).
- A short pointer so every session finds them.

The value of this skill is **evidence**. Every line of an architecture doc traces to a file you
read. Write what the code does, not what a typical project of this stack would do.

Git is optional throughout. A repo that isn't a git repo skips git steps; say so once.

## 1. Where does this project live?

Call the Skill tool with `mix-scope` to see what already exists. **If it reports Spec Kit or Matt
Pocock material** (`.specify/`, `GLOSSARY.md`, `docs/adr/`, `.out-of-scope/`, `docs/agents/`,
...), stop and recommend `/mix-migrate` first; setup continues on the migrated structure.

Then ask, recommended first:

- **Hub** (recommended when the project spans several repos, when the user keeps several
  projects or companies, or when the company doesn't use this flow): the project's
  `mix-dev-skills/` and `specs/` live in a project folder inside a hub, outside the code. The hub
  may be an existing repo (a notes vault, a company-knowledge repo) or a new folder (default
  `~/mix-dev-skills-hub/`). Nothing is written inside the code repos.
- **In-repo** (one repo, team adopts the flow): `mix-dev-skills/` and `specs/` at the repo root,
  committed with the code.

Hub: the project folder is either an **existing folder** the user points at
(`work/clients/nimbus`), registered through `mix-scope add <path>`, or a new one through
`mix-scope new <name>`. Make sure the hub is listed in `~/.mix-dev-skills/registry.yml`.

Inventory the project folder for material that stays where it is:

- Notes and reference docs (`files/`, `docs/`, `notes/`, an `index.md`) → `knowledge:` in
  `mix.yml`, read as reference, never moved.
- A file naming the code location (`context.yml` with `workspaceRoot`, a `.env` with `ROOT`, ...)
  → the proposed `root`.
- The hub's `CLAUDE.md` / `AGENTS.md`: its conventions (naming, index files, frontmatter,
  language, commit policy) apply to every file written in the project folder.

## 2. Repos

Ask for the **root** folder that holds the project's code (default: the location found in step 1,
else the current folder). It can be anywhere on disk; repos outside it get absolute paths. List
its subfolders and the manifests found in each, then propose the repo list: name, path, role, what it
owns, inferred from manifests, READMEs, and the project's knowledge docs ("`web/`: Next.js app
with pages and a landing page → role: web platform"). The user confirms or corrects roles and
marks folders to `ignore` (shared tooling, docs, unrelated apps).

A single-repo project has one entry whose path is the root.

## 3. Explore

Read whatever exists; assume nothing. Dispatch one read-only subagent **per repo** in parallel
(small single repos you read directly), each returning findings with file paths for:

1. **Manifests and tooling**: `package.json` (dependencies, devDependencies, scripts, workspaces,
   engines), the lockfile (decides the package manager), `tsconfig*`, lint/format/test configs,
   `pyproject.toml` / `go.mod` / `Cargo.toml` / `pom.xml` / `Gemfile` / `composer.json` when
   present, `Dockerfile`, CI workflows (the commands CI runs are the quality gates).
2. **Docs**: `README*`, `CONTRIBUTING*`, `docs/`, `CLAUDE.md` / `AGENTS.md`, `.cursor/rules`,
   `.github/copilot-instructions.md`, the project's glossary and ADRs. Existing written rules are
   inputs to the constitution.
3. **Structure**: the tree two to three levels deep; entry points; grouping by layer or feature;
   import aliases.
4. **Patterns**: for each kind of module (pages, components, hooks, endpoints, services,
   repositories, jobs, migrations, tests), open three or more real examples and record the shared
   shape. The **exemplar** is the most recently modified clean example (`git log` when available).
5. **Library purposes**: each runtime dependency's job and where the repo wraps it (e.g.
   `src/lib/http.ts` around axios). Duplicate libraries for the same job.
6. **Test style**: runner, location, naming, fixtures, mocking, the level the repo favours.
7. **Comment style**: how much the codebase comments today.
8. **Git conventions** (git repos only): recent branch names
   (`git branch -a --sort=-committerdate | head -30`), merged PR titles when `gh` works
   (`gh pr list --state merged -L 20 --json title,headRefName`), commit style
   (`git log --oneline -30`), PR template, default branch.
9. **Tracker**: ticket keys in branches, PR titles, commits (`ABC-123` → Jira/Linear, `#123` →
   GitHub); tracker MCP tools or CLIs available in this session.

**Multi-repo only**, after the per-repo reports, trace the integrations yourself:

10. **Who calls whom**: HTTP clients and base-URL env vars in callers; routes, controllers, or
    resolvers in callees; OpenAPI/GraphQL schemas; shared type packages; message topics.
11. **Contract conventions**: route naming, payload casing, dates, money, ids, pagination, error
    shape, auth propagation, how types cross the repo line.
12. **End-to-end golden path**: one existing feature followed from the screen to the database,
    file by file across repos.

Done when every row of each template is filled with evidence or marked "not used", and you have
a proposal for each config field.

## 4. Ask

Rounds, recommended answer first so "yes" accepts. One section at a time.

**A. Branch naming** (skip when no repo uses git). Detected pattern first if found:

| Option | Pattern | Example |
|--------|---------|---------|
| A (default) | `spec/[NNN]-[slug]` | `spec/001-alpha-login` |
| B | `[type]/[slug]` (feat, fix, chore, ...) | `feat/alpha-login` |
| C | `[type]/[ticket]-[slug]` | `feat/ABC-123-alpha-login` |
| Custom | fixed text + `[variables]` | `jane/[ticket]` |

One-line rule: fixed text is kept; `[NNN]`/`[slug]`/`[story]` are filled automatically; `[type]`
is inferred and confirmed; `[ticket]` and any other variable is asked each time. No answer → A.
Multi-repo: the same branch name is used in every repo a feature touches; ask only if repos need
different base branches.

**B. Delivery strategy**: `single` (default; one branch and PR per repo touched), `per-story` (a
branch and PR per story per repo touched), or `per-story-stacked` (feature branch with a macro
PR; story PRs target it). Then story branch pattern, PR title pattern (`[type]: [title]`, or
`[ticket] [title]` with tickets), commit style (detected, else conventional).

**C. Tracker**: none / Jira / Linear / GitHub / GitLab / other, a sample key, whether agents may
write to it or only read (`access`), and whether `/mix-tasks` creates story tickets (`ask` by
default; `never` when read-only). If the user will use `/mix-triage`: keep the default triage
labels? (recommended: yes; otherwise collect the existing label names so no duplicates are
created), and should external PRs be triaged too (default no). "Other" → record the user's
description in `notes`.

**D. Architecture**: the drafts (key tables if long), each **inconsistency** with a recommended
**Preferred** pattern, and the **project-specific rules** found in docs and code. Multi-repo:
also the integration table and the usual order of change across repos.

## 5. Write

1. `mix-dev-skills/mix.yml` under the project's base (the repo root, or the project folder in a
   hub).
2. Architecture docs in `mix-dev-skills/`, from the templates (a project override in
   `mix-dev-skills/templates/` wins over the bundled one). Single repo: `architecture.md`.
   Multi-repo: the system map as `architecture.md` plus `architecture/<repo>.md` per repo.
   Existing docs are updated in place: keep hand-written sections, refresh evidence-backed ones,
   list what changed. In a hub, follow its file conventions (e.g. list new files in the folder's
   `index.md` when the hub keeps one).
3. Call the Skill tool with `mix-constitution`, passing the confirmed project-specific rules
   (per repo where they differ), the quality-gate commands per repo, manifests, and package
   managers. It writes `mix-dev-skills/constitution.md`.
4. The pointer. In-repo: a block in `CLAUDE.md` (or `AGENTS.md` when only that exists; neither →
   ask which). Hub: the hub's `CLAUDE.md`, leaving code repos untouched.

   ```markdown
   ## Engineering context

   - mix-dev-skills: resolve the project with the `mix-scope` skill before planning or coding.
   - Read `mix-dev-skills/constitution.md` (rules) and `mix-dev-skills/architecture.md` (stack,
     libraries, patterns, golden files; for multi-repo projects, how the repos integrate).
   - Before creating any file, find and read the closest existing example of its kind.
   - Use installed libraries for their listed purpose; ask before adding a dependency.
   ```

## 6. Report

Files written, repos and roles, conventions chosen (sample branch name and PR title),
inconsistencies resolved, and the next step: `/mix-specify <feature>`, or `/mix-flow`.
