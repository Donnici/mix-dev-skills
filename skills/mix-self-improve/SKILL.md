---
name: mix-self-improve
description: "Coach the user on how they use Claude Code: reads the /insights report, the session history, and the setup (CLAUDE.md, skills, hooks, MCP, settings), explains usage patterns, strengths, and friction, and proposes evidence-backed improvements (rules, skills, hooks, routines, features) applied one at a time on approval."
disable-model-invocation: true
argument-hint: "[routine | apply | <days>]"
---

# Self-Improve

Show the user how they have been using Claude, what works, what costs them time, and what to
change. Every finding rests on evidence from their own report, sessions, or files. Small notes
are recorded; changes to their setup happen one at a time, after a yes.

**Context**: call the Skill tool with `mix-scope` to resolve the active project, when there is
one: its constitution and `CLAUDE.md` become targets for project rules. Without a project, work
at user level (`~/.claude/`). A git repo is not required.

**Arguments**:

- none: full run, asking about each suggestion.
- `<days>`: full run over that window instead of the default.
- `routine`: started by a schedule with nobody watching. Ask nothing, apply nothing, keep every
  suggestion in `waiting`, and print the summary.
- `apply`: read nothing new; go straight to step 6 with the suggestions in `waiting`.

## Hard rule: everything stays local

Read only local files. Send nothing anywhere: no session content leaves the machine, in a request,
a commit, or a PR. Quote the user's prompts only as short paraphrases in the report.

## State

The run keeps its notes in `~/.mix-dev-skills/self-improve/state.json`, created on the first run:

```json
{
  "last_run_at": "2026-11-14T10:00:00Z",
  "watching": [
    { "type": "new_skill", "target": "release-notes", "note": "Writes release notes by hand from the git log.", "dates": ["2026-11-03", "2026-11-10"] }
  ],
  "waiting": [
    {
      "type": "instruction",
      "target": "~/.claude/CLAUDE.md",
      "title": "Add the rule: answer in pt-BR",
      "why": "You asked for Portuguese answers in 5 sessions across 4 days.",
      "plan": "Append to ~/.claude/CLAUDE.md: `Answer in Brazilian Portuguese unless the prompt is in English.`",
      "since": "2026-11-14"
    }
  ],
  "declined": [{ "type": "hook", "target": "format-on-save" }]
}
```

**Done when** the state file is read, or this is known to be the first run.

## 1. Read the /insights report

Claude Code's built-in `/insights` command writes an HTML report to
`~/.claude/usage-data/report.html` and per-session analyses to `~/.claude/usage-data/facets/`.
A skill cannot run that command itself.

- **Report missing or older than 7 days**: by hand, ask once with AskUserQuestion: "Rodar
  `/insights` agora" (recommended: stop here and tell the user to type `/insights`, then
  `/mix-self-improve` again) or "Seguir sem o relatório" (use only the session history). With
  `routine`, continue without the report and say so in the summary.
- **Report present**: extract its text (strip the HTML) and read every section: usage overview,
  what works, friction, suggestions, and any CLAUDE.md additions it proposes. Read the facets for
  goals, friction, and outcomes per session.

Treat the report as a lead, not proof: confirm each claim you reuse in step 3.

**Done when** the report findings are listed with their section, or the run continues without
them by the user's choice.

## 2. Inventory the setup

Read, noting what exists and what each item is for:

- **Instructions**: `~/.claude/CLAUDE.md` and the files it imports; the active project's
  `CLAUDE.md` and constitution; memory folders under `~/.claude/projects/*/memory/`.
- **Skills**: `~/.claude/skills/*/SKILL.md`, the project's `.claude/skills/`, and plugin skills
  (`~/.claude/plugins/`). Mark which ones the user owns; `mix-*` and plugin skills are owned by
  their source repos.
- **Settings**: `~/.claude/settings.json` and project `.claude/settings*.json`: hooks,
  permissions, status line, model, env.
- **MCP servers**: `~/.claude.json` (`mcpServers`, per-project entries) and `.mcp.json`.
- **Routines**: scheduled agents and loops, when the `schedule` skill can list them.

**Done when** each category has its list, or "none".

## 3. Read the session history

Default window: since `last_run_at`, else the last 30 days. Read the JSONL files changed in that
window under `~/.claude/projects/*/`, skipping this session. Search them instead of reading
whole files, and skip tool output. Look for:

- **Work**: which projects, what kinds of tasks, how sessions start and end.
- **Repeats**: the same request typed by hand on several days; the same correction given again
  ("não", "errado", "já falei", "de novo", "I said"); the same instruction repeated.
- **Friction**: interrupted or abandoned tasks, permission prompts denied or approved again and
  again, long back-and-forth on one problem, errors the agent hit repeatedly.
- **Features**: plan mode, subagents, skills run (which `mix-*` and which never), hooks firing,
  worktrees, `/loop`, routines, memory, MCP tools called vs configured.

For each pattern, add its dates to the matching `watching` entry, or start one. Drop `watching`
entries with no date in the last 30 days.

**Done when** every pattern has its dates in `watching`.

## 4. Explain the usage

Write the report in the user's language (default pt-BR): short sentences, one idea each, active
voice, numbers and dates unambiguous, each claim with its evidence (days, projects, file).

```markdown
## Como você tem usado o Claude ([janela])

**Em resumo**: [2-3 frases: foco principal, o que mais funciona, o maior custo]

### Como você trabalha
- [Projetos, tipos de tarefa, como as sessões começam, skills e recursos mais usados]

### Pontos positivos
- [Hábito que funciona]: [evidência]

### Pontos negativos
- [Atrito]: [evidência] → [o que causa e quanto custa]

### Novos jeitos de usar
- [Recurso ou prática que você ainda não usa]: [onde ajudaria, com um caso real das sessões]
```

Candidates for "Novos jeitos de usar": plan mode before large changes, subagents for parallel
searches, skills for repeated workflows, hooks for checks the user does by hand, routines
(`/schedule`, `/loop`) for recurring work, worktrees for parallel tasks, memory for facts the
user repeats, MCP servers for tools used by copy-paste, and the `mix-*` flow skills the user
never ran. Name only the ones a real session shows a use for.

**Done when** every section has at least one item with evidence, or says "nada a apontar".

## 5. Find the improvements

A pattern becomes a suggestion when it meets the bar for its type:

| Type | What it is | Bar | Applied through |
|------|------------|-----|-----------------|
| `instruction` | A line for a `CLAUDE.md` (user or project) | Told 3 times | direct edit |
| `rule` | A MUST/SHOULD for the project constitution | Same review or correction 2 times in one project | Skill tool with `mix-constitution` |
| `new_skill` | A repeated task that could be a skill | Same task by hand on 3 days | Skill tool with `skill-creator` when available, else a new `SKILL.md` |
| `skill_fix` | A change to a skill the user owns | Same correction 2 times | direct edit of that skill |
| `upstream_fix` | A change to a `mix-*` or plugin skill | Same correction 2 times | a written proposal for its source repo |
| `hook` | An automatic check or action | Same manual step on 3 days | Skill tool with `update-config` |
| `routine` | A recurring job | Same request on a regular cadence, 3 times | Skill tool with `schedule` or `loop` |
| `permission` | An allowlist entry | Same prompt approved on 3 days | Skill tool with `update-config` |
| `mcp` | Add, fix, or remove a server | Data copied by hand 3 times, or a server unused for 30 days | instructions for `claude mcp` |
| `retire` | A user-owned skill or rule nobody uses | Not run or not relevant in 30 days | move to `~/.mix-dev-skills/self-improve/retired/` |
| `contradiction` | Two instructions that disagree | Both places named | the user's pick |

On the first run, include one `routine` suggestion to run `/mix-self-improve routine` weekly.

Drop a suggestion with no evidence, one that matches `declined` (same type and target, or the
same idea), or one already in `waiting`. Rank new ones after `waiting` by frequency, recency, time
saved, and ease of undo. Offer at most 5 per run; the rest stay in `watching`.

Each suggestion has a `title` starting with a verb, a one-line `why` with the evidence, and a
`plan` precise enough to apply later without searching again.

**Done when** the ranked list is written to `waiting` in memory.

## 6. Ask about each suggestion

With `routine`, skip to step 7. Otherwise take the suggestions one at a time: show the title and
the why in one or two sentences, then ask with AskUserQuestion: "Aplicar" (recommended), "Agora
não", "Não sugerir de novo". For `contradiction`, offer one option per way to settle it.

On "Aplicar", show the exact edit, then apply it through the route in the step 5 table:

- Edit only user-level files (`~/.claude/`) and the active project's files.
- Never edit an installed `mix-*` or plugin skill: `install.sh` and plugin updates overwrite
  them. An `upstream_fix` is printed as a proposal (file, step, new text) for its source repo.
- A new skill never overwrites an existing folder.
- `retire` moves the folder; it deletes nothing.

"Agora não" keeps it in `waiting`; "Não sugerir de novo" moves it to `declined`. A change you
cannot make safely stays in `waiting` with the reason.

**Done when** each offered suggestion is applied, waiting, or declined.

## 7. Save and summarize

Write `state.json` with `last_run_at` (this run's start; unchanged with `apply`), `watching`,
`waiting`, and `declined`. Then print, leaving out empty lines:

```markdown
## Self-improve: [data]

**Relatório /insights**: [usado, de AAAA-MM-DD | não usado]
**Aplicado**: [n]
- [título]
**Esperando sua resposta**: [n]. Rode `/mix-self-improve apply` para decidir.
**Em observação**: [n] padrões ainda abaixo do limite.
```

When a skill, hook, or setting changed, add: "Reinicie a sessão para o Claude carregar a
mudança." When nothing met a bar, say "Nada para mudar nesta rodada."

**Done when** the state file is saved and the summary is printed.
