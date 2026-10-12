# Migration Mapping

Destinations are relative to the project's **base** (repo root, or the project folder in a hub).
Actions: **move** (same content, new place), **convert** (rewrite into the mix format, keeping
every rule and fact), **merge** (combine with an existing mix file), **config** (values go into
`mix-dev-skills/mix.yml`, source removed), **remove** (tooling with no mix equivalent), **keep**
(stays where it is).

## Spec Kit

| Source | Destination | Action |
|--------|-------------|--------|
| `.specify/memory/constitution.md` | `mix-dev-skills/constitution.md` | convert |
| `.specify/templates/*-template.md` | `mix-dev-skills/templates/{spec,plan,tasks,constitution}.md` | convert, only if the user customised them and wants to keep the customisations; else remove |
| `.specify/feature.json`, `init-options.json`, `integration*.json` | — | remove |
| `.specify/scripts/`, `.specify/workflows/`, `.specify/integrations/` | — | remove |
| `.specify/extensions.yml`, `.specify/extensions/` | — | remove, after listing every hook so the user knows what stops running |
| `specs/NNN-*/` (any Spec Kit feature folder) | `specs/NNN-*/` | keep (move only if it lived elsewhere); normalise, see below |
| `.claude/skills/speckit-*`, `.claude/commands/speckit*`, other agents' `speckit` prompts/commands (`.github/prompts/`, `.cursor/commands/`, `.windsurf/`, `.gemini/commands/`, ...) | — | remove (project-local copies only) |
| `<!-- SPECKIT START -->…<!-- SPECKIT END -->` block in `CLAUDE.md` / `AGENTS.md` / agent context files | — | remove; the mix pointer block replaces it |

**Constitution conversion**: map each Spec Kit principle onto the closest mix principle (extend
it with the original MUST/SHOULD text) or keep it as an additional principle; move tech-stack and
workflow sections into **Project-Specific Rules** and **Quality Gates**. Nothing the original
requires may be lost. Ask whether to add the mix default principles the original lacks
(recommended: yes). Version: next MAJOR of the original (`2.1.0` → `3.0.0`), with the original
ratification date.

**Spec normalisation** (per feature folder, in place): add the spec's **Delivery** line
(`strategy single · branch <the feature's branch if known, else "none"> · tickets none`) under the
header; leave `research.md`, `data-model.md`, `contracts/`, `quickstart.md`, and `checklists/`
as they are (mix skills read them); `tasks.md` and checklists keep their format. Content is not
rewritten.

## Matt Pocock skills

| Source | Destination | Action |
|--------|-------------|--------|
| `GLOSSARY.md` or `CONTEXT.md` at the root | `mix-dev-skills/glossary.md` | move |
| `GLOSSARY-MAP.md` + per-context `GLOSSARY.md` / `CONTEXT.md` files | `mix-dev-skills/glossary.md` | merge: one `## <Context>` section per context, the map's relationships as a closing section |
| `docs/adr/*.md`, `src/*/docs/adr/*.md` | `mix-dev-skills/adr/NNNN-slug.md` | move; renumber into one sequence when several folders exist (keep relative order, record old → new numbers) |
| `.out-of-scope/*.md` | `mix-dev-skills/out-of-scope/*.md` | move |
| `docs/agents/issue-tracker.md` | `tracker.type`, `tracker.notes`, `tracker.triage_prs` in `mix.yml` | config |
| `docs/agents/triage-labels.md` | `tracker.labels` in `mix.yml` | config |
| `docs/agents/domain.md` | — | remove (the mix layout replaces it) |
| `.scratch/<feature>/` spec or plan file | `specs/NNN-<feature>/spec.md` | move; numbered after existing specs; mark the spec `Status: Migrated` so `/mix-clarify` normalises it |
| `.scratch/<feature>/issues/NN-*.md` | `specs/NNN-<feature>/tickets/NN-*.md` | move |
| `## Agent skills` block in `CLAUDE.md` / `AGENTS.md` | — | remove; the mix pointer block replaces it |
| Project-local Matt skill copies (`.claude/skills/<skill>/`, `.agents/skills/...`) | — | remove only if the user asks (they may still use them) |
| Research notes, prototypes, handoff files | — | keep (knowledge; offer to list them under `knowledge:` in `mix.yml`) |

## Conflicts

- A destination file already exists → **merge**, never overwrite: glossary terms are unioned
  (same term, different definitions → ask); ADRs are appended to the sequence; constitution rules
  are merged through the conversion rules above.
- Two sources map to one destination (a root `GLOSSARY.md` and a `CONTEXT.md`) → merge, and say so.
- A source in a **code repo** while the project lives in a hub → ask: **copy** into the hub and
  leave the repo untouched (recommended when the team still uses that structure), or **move**.
