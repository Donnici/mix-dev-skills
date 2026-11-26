# mix-dev-skills

**English** · [Português](README.pt-BR.md)

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-d97757)](#installation)
[![SKILL.md](https://img.shields.io/badge/format-SKILL.md-555)](https://github.com/anthropics/skills)

Spec-driven development skills for Claude Code (and any agent that reads `SKILL.md`). The base
is the [Spec Kit](https://github.com/github/spec-kit) flow, refined with
[Matt Pocock's skills](https://github.com/mattpocock/skills) and with rules that target the most
common problems in AI-written pull requests: too many comments, redundant tests, and code that
ignores the patterns and libraries the repository already uses.

**What makes it different**

- **Multi-repo by default.** One spec can span web, BFF and API. The plan defines the contract
  between repos (route, fields, types, errors, auth) before either side is written.
- **Reuse before writing.** Every task points to an existing file to imitate, and the
  constitution requires installed dependencies first.
- **Review that knows AI smells.** Six review axes (patterns, spec, tests, bugs, security,
  architecture) in parallel, each finding verified before it is reported, plus a mandatory
  test-pruning pass.
- **Nothing reaches a remote without you.** Only `/mix-pr` pushes or opens PRs, and only when you
  ask.
- **One hub, many projects.** Keep specs and rules outside the code, one scope per client or
  company.

## Quick start

```bash
claude plugin marketplace add Donnici/mix-dev-skills
claude plugin install mix-dev-skills@mix-dev-skills
```

Then, in each repository:

```text
/mix-setup                         map the repo, its conventions and its rules
/mix-quick-implement "<issue>"     small change: one check-in, short spec, test-first
/mix-ticket COR-123                full flow from ticket to PR in one session
/mix-flow                          which skill to use, and when
```

## The flow

```text
/mix-scope <project>   pick the active project (each with its own rules, docs, specs and repos)
/mix-setup             once per project: repos and roles, conventions, architecture, constitution
    ▼
/mix-specify → /mix-clarify → /mix-plan → /mix-tasks → /mix-analyze → /mix-implement
   spec.md       questions      plan.md     tasks.md      checks        code + local commit
                                contracts   per repo                    (never push/PR)
    ▼
/mix-pr   (branch, commit, push and PR in one go)  →  /mix-review  →  /mix-retro (comments become rules)
```

A small change (one behaviour, a few files, no new contract or dependency)? Use
`/mix-quick-implement "<issue>"`: one command, one round of questions, a short spec in `specs/`
and an implementation with tests all the way through.

Want the whole flow at once? `/mix-ticket COR-123` goes from spec to PR in the same session: you
approve the spec once and it continues with plan, tasks, analyze, implementation (independent
slices in parallel), a final review and the PR, if you asked for it.

| Skill | What it does | Type |
|-------|--------------|------|
| `/mix-scope` | Shows, switches (`/mix-scope lumen`), lists or creates projects in the hub. Every other skill resolves its context through it. | command + automatic |
| `/mix-setup` | Asks hub or in-repo, the root folder and the role of each repo (web, bff, api...), branch/PR/ticket patterns, and writes a map of each repo (`package.json`, libraries by purpose, patterns, golden files) and, with several repos, the integration map (contracts, end-to-end golden path). Creates the constitution. | command |
| `/mix-constitution` | Creates or changes the rules (MUST/SHOULD), versioned. | command + automatic |
| `/mix-specify` | Explores the code, sets delivery (branch, tickets, strategy), grills the decisions, writes `spec.md`, keeps the glossary and ADRs. | command |
| `/mix-clarify` | Ambiguity sweep of the spec (Spec Kit taxonomy) + questions + spec update. | command |
| `/mix-plan` | Which repos change and why, reuse inventory, constitution gate, **cross-repo contracts first** (route, fields, types, errors, auth), design per repo, test seams. | command |
| `/mix-tasks` | Vertical slices per story; inside a story: contract → provider → consumer → integration; each task with repo, file, exemplar and blockers; creates or collects tickets. | command |
| `/mix-analyze` | Consistency spec ↔ plan ↔ tasks; only writes `state.yml`. | command |
| `/mix-implement` | Implements task by task in each repo, reading the exemplar first and honouring the contracts; after each delivery: test pruning, comment cleanup, self-review and a **local commit only with your approval**. Never pushes or opens a PR. | command |
| `/mix-quick-implement` | Shortcut for small changes: finds the code, confirms current behaviour, does **a single check-in** (change, test, decisions with a recommended answer, branch and commit), writes a short spec, implements test-first, prunes and records the outcome in the spec. A change that grows is handed to `/mix-specify --quick` without losing what was gathered. | command |
| `/mix-review` | Review on 6 axes (Patterns, Spec, Tests, Bugs, Security, Architecture) with five severities (critical to info) and a `--profile quick` (one pass) or `deep` (parallel subagents and verification of each critical/high finding); fixes, creates convergence tasks or comments on the PR; with `--report`, only reads and returns summary, security, adherence and findings as a versioned JSON block (`mix-review-result`), without asking, changing or publishing anything. | command + automatic |
| `/mix-pr` | One command, no approval: creates the branch, commits, pushes and opens the PR (one per repo; single, per story or stacked) and shows link, title and description. Want changes? Ask in chat and it edits the PR. Also owns the naming conventions. | command + automatic |
| `/mix-ticket` | From ticket (or idea) to PR in one session: reads the ticket from the tracker, runs specify, clarify when needed, plan, tasks and analyze, stops **once** for you to approve the spec, implements (independent slices in parallel, in worktrees), runs the final review and opens the PR when you asked. Never merges. | command |
| `mix-land` | Gets open PRs ready to merge: lists CI, conflicts and comments; classifies each CI failure (this PR, inherited from base, flaky, infra); reproduces before fixing; drafts replies to reviewers in your tone (`pr_reply_tone`); gives the merge order across repos. Pushes only through `/mix-pr` and on your request. | command + automatic |
| `mix-housekeep` | Cleans worktrees and branches of merged PRs (never anything with work in it), lists what is left to push, and aligns the specs' `state.yml` and `index.md` with the real PR status. `--dry-run` only shows the plan. | command + automatic |
| `/mix-retro` | Turns recurring PR comments into lint/CI checks, rules or context. | command |
| `/mix-triage` | Triage of issues (and external PRs): category and state, duplicates and past rejections, reproduction, grill and an agent-ready brief. Nothing is written to the tracker without confirmation; a read-only tracker gets local drafts. | command |
| `mix-diagnose` | Hard bugs and performance regressions: first a feedback loop that goes red on the bug, then hypotheses, instrumentation, a fix with a regression test and cleanup. Works across repos. | command + automatic |
| `mix-spike` | Technical investigation before the spec: maps how the repos handle the subject today, runs a throwaway proof of concept, compares options and writes `spike.md` with a phased recommendation. Continues into `/mix-specify --quick` when it becomes a feature. | command + automatic |
| `/mix-untangle` | Structural debt of a codebase or an area, across repos: maps hotspots, imports and what changes together in git; lists hidden couplings, unnecessary couplings, leftover code and special cases; redesigns from today's requirements and writes `untangle.md` with each fix above the problems it solves, in behaviour-preserving slices. Does not change code; continues via `/mix-specify --quick` (one story per slice) or `/mix-quick-implement`. | command |
| `/mix-explain` | Explains something in clear technical language (Brazilian Portuguese by default): a spec with plan, tasks and evidence (`/mix-explain spec 0014`), an ADR, a file, a doc, a URL or a topic. Without arguments, explains the agent's last answer. Writes nothing. | command |
| `/mix-self-improve` | Reads the `/insights` report, session history and your setup (CLAUDE.md, skills, hooks, MCP, settings); explains how you use Claude, strengths and weaknesses, new ways to use it, and proposes evidence-backed improvements (rules, skills, hooks, routines), applied one at a time with your approval. `routine` runs without questions. | command |
| `/mix-migrate` | Moves Spec Kit and Matt Pocock structures to the mix layout (`mix-dev-skills/` + `specs/`), converting constitution and configuration and fixing links. | command |
| `mix-grill` | Interview primitive: rounds, a recommended answer, facts belong to the agent and decisions belong to you. | automatic |
| `mix-testing` | Testing reference: seams, mocks, anti-patterns and the pruning pass. | automatic |
| `/mix-flow` | Router: which skill to use in each situation. | command |

"Command" = runs only when you type it (uses no context). "Automatic" = the agent or another
skill may call it on its own.

> The skills' instructions are in English and the agent talks to you in your own language.
> `/mix-explain` and `/mix-self-improve` default to Brazilian Portuguese; ask in another language
> to switch.

## Installation

**Ask Claude Code** (from any folder):

> Install the skills from https://github.com/Donnici/mix-dev-skills following INSTALL.md.

**Claude Code plugin** (updates itself):

```bash
claude plugin marketplace add Donnici/mix-dev-skills
claude plugin install mix-dev-skills@mix-dev-skills
```

**Script** (copies to `~/.claude/skills`; `--project` for the current repo only; `--target DIR`
for other agents):

```bash
git clone --depth 1 https://github.com/Donnici/mix-dev-skills /tmp/mix-dev-skills
/tmp/mix-dev-skills/install.sh
```

**skills.sh** (Cursor, Codex, OpenCode, etc.): `npx skills@latest add Donnici/mix-dev-skills`

Then, in each repository: `/mix-setup`.

## Default rules (constitution)

`/mix-setup` creates `constitution.md` with these principles and adds the repo-specific rules it
finds. Edit it with `/mix-constitution "<rule>"`.

1. **Prior art first**: before creating any file, find and read the closest equivalent in the
   repo and copy its structure, names, error handling and location.
2. **Installed dependencies first**: check `package.json` (or the equivalent manifest) and use
   the library already installed for each purpose; a new dependency needs a reason and approval.
3. **Simplicity**: the simplest code that meets the spec; no abstraction with a single
   implementation; no defensive validation of what the types already guarantee.
4. **Comments only when relevant**: only the non-obvious *why*, in one line; no comments
   narrating the code, no commented-out code, no change history.
5. **Tests that pay for themselves**: behaviour through the public interface at the agreed
   seams; each behaviour tested once; a **mandatory pruning pass** after implementation removes
   redundant, tautological, trivial or implementation-coupled tests.
6. **Scope discipline**: the diff contains only what the spec and tasks ask for.
7. **Architecture consistency**: layers, names and patterns from `architecture.md` and the ADRs.
8. **Cross-repo contracts** (multi-repo): defined in the plan before either side; provider and
   consumer match exactly.

## Branches, PRs and tickets

Configured in `/mix-setup`, adjustable per feature in `/mix-specify`:

- **Branch pattern**: fixed text + `[variables]`. Default `spec/[NNN]-[slug]`
  (e.g. `spec/001-alpha-login`). Presets: `[type]/[slug]` (feat, fix, chore...),
  `[type]/[ticket]-[slug]`, or custom, e.g. `jane/[ticket]`.
  `[NNN]`, `[slug]` and `[story]` fill themselves; `[type]` is inferred;
  `[ticket]` and custom variables come from the branch, spec or commits, and are asked only when
  nothing provides them.
- **Delivery strategy**:
  - `single`: one branch and one PR for the whole feature.
  - `per-story`: one branch and one PR per story, straight to the base, in small continuous
    deliveries.
  - `per-story-stacked`: a feature branch with a macro PR; story PRs target it.
- **Tickets** (Jira, Linear, GitHub, GitLab, other): you give the codes you already have, or
  `/mix-tasks` creates the story tickets (through the available MCP/CLI, always with
  confirmation).

## Project hub (several companies, several repos)

The skills do not have to live inside the code repository. A **hub** is a folder outside the
code: an existing repo (a notes vault, a central repo) or a new folder (`~/mix-dev-skills-hub/`).
Each **project** (scope) is a folder at **any path** inside the hub, with its own
`mix-dev-skills/` folder and its own `specs/`; the **code repos** stay wherever they are on disk:

```yaml
# ~/workspace/knowledge-hub/mix-dev-skills/hub.yml
active: nimbus
projects:
  nimbus: { path: work/clients/nimbus }
  orbit:  { path: work/clients/orbit }
  lumen:  { path: work/clients/lumen }
```

```yaml
# ~/workspace/knowledge-hub/work/clients/nimbus/mix-dev-skills/mix.yml (excerpt)
knowledge: [index.md, files]          # company notes, read as reference and never moved
root: ~/code/nimbus                   # code lives elsewhere
repos:
  - { name: storefront, path: storefront, role: Online store, owns: [pages, hooks, calls to catalog-api] }
  - { name: catalog-api, path: catalog-api, role: Web service, owns: [business rules, services, database, auth] }
integrations:
  - { from: storefront, to: catalog-api, via: REST/JSON }
```

- **Scope**: `/mix-scope orbit` switches the active project. Opening a session inside
  `~/code/partner-x/orbit` selects the Orbit project automatically (the hub is registered in
  `~/.mix-dev-skills/registry.yml`).
- **Existing folder**: `/mix-scope add work/clients/nimbus` registers a folder that already
  exists; its notes go into `knowledge:` and the code location becomes `root`. The conventions in
  the hub's `CLAUDE.md` (names, `index.md`, frontmatter) apply to everything the skills write
  there.
- **End-to-end feature**: `/mix-specify authentication` produces a single spec; `/mix-plan`
  decides that the login page and hooks go in the frontend, and the rules, service and database
  in the API (plus the intermediate route in the BFF, if there is one). It also defines the
  **contract** between them (route, method, fields, types, errors, auth). `/mix-implement`
  builds both sides against the same contract and checks the integration. Branches and PRs are
  per repo, with the same branch name and links between sibling PRs.

## Migrating from Spec Kit or Matt Pocock's skills

The mix skills neither read nor write Spec Kit (`.specify/`) or Matt Pocock structures
(`GLOSSARY.md`, `docs/adr/`, `.out-of-scope/`, `docs/agents/`, `.scratch/`). When they find one,
they recommend **`/mix-migrate`**, which:

- inventories everything and shows the plan (source → destination → action) before touching
  anything (`--dry-run` to stop there);
- converts the Spec Kit constitution to the mix format without losing any rule, moves the
  glossary, ADRs (renumbering if there are several folders) and `out-of-scope`, and carries
  tracker and label settings into `mix.yml`;
- keeps specs in `specs/`, only adding the Delivery line;
- removes `speckit-*` scripts, hooks and commands only with your confirmation, uses `git mv` to
  keep history, fixes links to old paths and never pushes.

## No git?

Git is optional. Without a git repository nothing blocks: branch/commit/PR steps are skipped,
the planned names go to `delivery.md` and the review uses the list of touched files.

## Nothing ships without you

`/mix-implement` never pushes or opens a PR, and commits locally only after you approve each
commit. Push and PR happen only when you run `/mix-pr` (or ask in chat): it creates the branch,
commits, pushes and opens the PR in one go, without asking for confirmation, and shows each PR's
link, title and description. To adjust the title or description, ask in chat.

## Spec state

Each skill in the flow records where the spec stopped in `specs/NNN-slug/state.yml`, next to the
spec, with or without git, and its report states the same next step:

```yaml
status: Planned          # Specified | Clarified | Planned | Tasked | Analyzed | Implementing | Implemented
next_step: /mix-tasks    # /mix-clarify | /mix-plan | /mix-tasks | /mix-analyze | /mix-implement | /mix-quick-implement | none
prs:                     # optional; written by /mix-pr
  - https://github.com/acme/web/pull/5
```

Each skill changes only its own fields and keeps the rest of the file. `/mix-pr` appends the link
of each PR it opens, and `/mix-quick-implement <spec folder>` resumes a short spec. The Status
field left the spec templates: state lives only in this file.

## Generated files

Everything that is not a spec lives in a `mix-dev-skills/` folder; specs live in `specs/` next to
it. Both sit at the repo root (in-repo) or in the project folder inside the hub:

```text
<base>/
├── mix-dev-skills/
│   ├── mix.yml                  code root, repos, roles, notes, conventions
│   ├── constitution.md          rules (MUST / SHOULD), versioned
│   ├── architecture.md          map of the repo, or of the system when there are several repos
│   ├── architecture/<repo>.md   map of each repo (multi-repo)
│   ├── glossary.md              domain terms
│   ├── adr/                     decisions that are hard to reverse
│   ├── out-of-scope/            rejected requests (triage)
│   ├── triage/                  triage drafts (read-only tracker)
│   └── templates/               project templates (override the defaults)
└── specs/NNN-slug/              spec.md, plan.md, tasks.md, state.yml, checklists/, delivery.md
                                 (with /mix-quick-implement, only a short spec.md with the Outcome and state.yml;
                                 in a spike, only spike.md; in an untangle, only untangle.md)

<hub>/mix-dev-skills/hub.yml     projects (name → folder) + active
~/.mix-dev-skills/registry.yml   known hubs (to find the project from the code repo)
```

## Where each part came from

| mix-dev-skills | Spec Kit | Matt Pocock | New |
|----------------|----------|-------------|-----|
| `mix-scope` | — | — | project hub, active scope, context resolution |
| `mix-setup` | — | `setup-matt-pocock-skills` (explore → confirm → write) | per-repo map, integration map, libraries by purpose, golden files, branch/PR/ticket conventions |
| `mix-constitution` | `constitution` (versioning, placeholders) | `retro` (automated check > written rule), `writing-for-agents` (positive, checkable rules) | default principles with their rules |
| `mix-specify` | `specify` (template, numbering, quality checklist) | `grill-with-docs`, `domain-modeling`, `to-spec` (problem/solution, out of scope) | Current Behaviour, delivery/tickets |
| `mix-clarify` | `clarify` (coverage taxonomy, incremental integration) | `grilling` (rounds per boundary) | — |
| `mix-grill` | `clarify` (question format, "why it matters") | `grilling` (design tree, facts vs decisions) | material questions vs defaults |
| `mix-plan` | `plan` (technical context, constitution check, complexity tracking) | `codebase-design` (deep modules, seams), `to-spec` (testing decisions) | mandatory reuse inventory |
| `mix-tasks` | `tasks` (format, phases per story, [P]) | `to-tickets` (vertical slices, blockers, prefactor, expand–contract) | exemplar per task, hardening phase, tickets per story |
| `mix-analyze` | `analyze` | — | reuse, exemplar and redundant-test checks |
| `mix-implement` | `implement` (checklist gate, phases, mark [X]) | `implement`, `tdd` | exemplar reading per task, test pruning, comment pass, ship per story |
| `mix-review` | `converge` (missing/partial/contradicts/unrequested, append-only) | `code-review` (parallel axes, Fowler smells) | Tests, Bugs, Security and Architecture axes, AI smells, finding verification, quick/deep profiles, `--fix/--tasks/--comment/--report` |
| `mix-testing` | — | `tdd`, `tests.md`, `mocking.md` | pruning pass, redundancy across levels |
| `mix-pr` | — | — | pattern-based names with variables, single/per-story/stacked strategies |
| `mix-retro` | — | `retro` | PR comments as input |
| `mix-triage` | — | `triage` (+ `AGENT-BRIEF.md`, `OUT-OF-SCOPE.md`) | tracker labels and access via `mix.yml`, read-only mode, worktree verification, multi-repo |
| `mix-quick-implement` | `specify`, `implement` (compacted) | `diagnosing-bugs` (signal before fix), `tdd` | size gate, single check-in, short spec with Outcome |
| `mix-diagnose` | — | `diagnosing-bugs` (+ HITL script) | project context and incident notes, cross-repo/contract bugs, no commit/push without approval |
| `mix-explain` | — | `wait-what` (re-explain the last message) | targets (spec, ADR, file, URL, topic), sourced evidence; writing rules adapted from [Português Técnico Simplificado](https://github.com/nosportugal/portugues-tecnico-simplificado-skill) (NOS, MIT) for pt-BR |
| `mix-self-improve` | — | — | `/insights` report as input; modes, evidence limits and state inspired by the `improve-system` skill from [buildpartner-plugin](https://github.com/austinmarchese/buildpartner-plugin) (own text, no copying) |
| `mix-ticket` | — | — | orchestrates the main flow in one session, with a single checkpoint at the spec |
| `mix-land` | — | — | CI failure classification, reproduce before fixing, replies in the configured tone, merge order |
| `mix-housekeep` | — | — | safe cleanup of worktrees and branches, spec sync with PR status |
| `mix-spike` | — | — | investigation with proof of concept and phased recommendation (`spike.md`) |
| `mix-untangle` | — | `codebase-design` (deep modules) | adapted from the `untangle-codebase` skill in [caldoai/skills](https://github.com/caldoai/skills) (Maze, MIT): the "does it change together?" question, special cases as a design signal, decision log; here diagnosis and redesign only, multi-repo, in slices that continue through the flow |
| `mix-migrate` | — | — | migration of Spec Kit and Matt Pocock structures to the mix layout |
| `mix-flow` | — | `ask-matt` | — |

Left out (use the originals if you need them): `checklist` and `taskstoissues` (covered by
`/mix-tasks`) from Spec Kit; `prototype`, `wayfinder`, `research` and similar from Matt Pocock.
Spec Kit's extensions/hooks and bash/PowerShell scripts were also removed: the skills are
self-contained and depend on neither the `specify` CLI nor git.

## Contributing

Issues and pull requests are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) and the
[Code of Conduct](CODE_OF_CONDUCT.md). To report a security problem (for example, a skill that
could be used for prompt injection or data leakage), follow [SECURITY.md](SECURITY.md) instead of
opening a public issue.

## License

MIT. Derived from Spec Kit (© GitHub, Inc.), mattpocock/skills (© Matt Pocock),
portugues-tecnico-simplificado-skill (© Dustin Yuchen Teng, Thiago Machado, NOS Comunicações)
and caldoai/skills (© Maze), all MIT; see [CREDITS.md](CREDITS.md).
