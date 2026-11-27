---
name: mix-graph
description: "Navigate a repo through its local code graph (the codegraph CLI): who calls a symbol and what it calls, what a change affects up to the routes that reach it, which tests cover it, and the symbols of a file. Graphs are built per repo from the AST, for free, with no AI and nothing leaving the machine. Use before grep or opening files to find prior art, exemplars, callers, blast radius, or the path from an entry point to code; whenever another mix-* skill says to consult the graph; and to build, update, or check a graph."
argument-hint: "[status | build | update | callers <symbol> | impact <symbol> | node <symbol or file> | query <terms>] [repo]"
---

# Graph

A code graph answers structural questions (who calls this, what reaches that, what breaks if it
changes) in a few hundred tokens, where grep plus whole-file reads cost thousands. The graph is a
**map, not the territory**: it locates code; the code is the evidence. Every mix skill works
without it; with it, they read less and miss fewer callers.

**Context**: call the Skill tool with `mix-scope` to resolve the project and its repos.
`graph.enabled: false` in `mix.yml` → stop here; callers use grep and Read.

## Where graphs live

One graph per repo, in a `.codegraph/` folder at the repo's root, which codegraph keeps out of git
(`--local-only` makes it ignore its own `.gitignore` too). It cannot live anywhere else. Nothing
else in the repo changes: no hooks, no `.gitignore` edit, no agent instructions, no MCP config.

## Environment

Run every `codegraph` command with telemetry and the background daemon off:

```bash
export CODEGRAPH_TELEMETRY=0 CODEGRAPH_NO_DAEMON=1
```

Shark already sets both for the Agents it starts.

## Availability

`codegraph --version` fails, or is older than 1.6.4 → say so once per session, then fall back to
grep and Read. Offer the install (`npm install -g @colbymchenry/codegraph`, about 300 MB with its
own Node) only during `/mix-setup` or when the user asks.

## Build and update

```bash
codegraph init --local-only --yes "<repo path>"   # first build
codegraph sync --quiet "<repo path>"              # incremental, under a second on most repos
codegraph index --quiet "<repo path>"             # rebuild from scratch, after moving or deleting code
```

Code only: tree-sitter parses locally, no AI, no API key. About 4 s for a 400-file repo. Building
writes only `.codegraph/`, so build a missing graph without asking and say that you did — except
in a read-only run (a review started by Shark), where the graph is used as it is and building,
syncing or removing is refused.

Never run `codegraph install`, `serve`, `daemon` or `telemetry on`: they configure agents, start
servers or send data, and run only when the user asks for them by name.

## Freshness

`codegraph status --json "<repo path>"`: `initialized: false` → build. `pendingChanges` with
anything in it, or code edited in this session → `sync` before the next question about that area.

`status` (as argument): for each repo, print `fresh`, `stale (n pending)`, `missing`, or `no CLI`,
plus files, symbols and routes. Done when every repo has a line.

## Ask the graph

Name **symbols**, not sentences. Run from the repo, or pass `--path "<repo path>"`. Add `--json`
when you will process the answer.

| Question | Command |
|----------|---------|
| Who calls X | `codegraph callers X` |
| What X calls | `codegraph callees X` |
| What changing X affects, up to the routes that reach it | `codegraph impact X --depth 2` |
| X's source and its caller/callee trail | `codegraph node X` |
| The symbols of a file, routes included, with lines | `codegraph node --file <path> --symbols-only` |
| Tests affected by changed files | `git diff --name-only <base> \| codegraph affected --stdin` |
| Types implementing an interface or class | `codegraph implementations X` |
| Where a concept lives, no symbol name yet | `codegraph query "<terms>"`, or `codegraph explore <terms>` for source and paths at once |

- **Ambiguous names**: when several definitions match, narrow with `--file <path or suffix>`.
  An unknown symbol prints "not found": retry once with a name taken from the code (architecture
  doc, glossary, a previous result), then fall back to grep.
- **Hubs**: a symbol with dozens of callers → `impact --depth 1` first; depth 2 on a hub lists
  hundreds of nodes.
- **Routes** are nodes (`GET /users`, kind `route`) for Express, NestJS, Next.js, Laravel, Spring,
  Django, FastAPI, Gin and others, when the framework is in the manifest. `impact` reaching a
  route means a request can reach the code: a **possible** path, not a proven one.
- **Read what it located.** Open the lines it points to; open a file whole only when you will edit
  it or mirror it. Cite findings as `path:Lnn`.
- **Know the blind spots.** The graph does not see an app's own IPC, routes built from text,
  dependency injection, events by name, reflection, or config. No route found means "unknown",
  never "unreachable". Confirm those with grep. Never state a relationship that neither the graph
  nor the code shows.
- **Filter noise**: drop hits in agent tooling (`.claude/`, `.agents/`), generated clients and
  vendored code unless the question is about them.

## Brief subagents

Add this to every subagent prompt that explores code, one line per repo with a graph:

> Code graph for `<repo>` (`<repo path>/.codegraph`): before grep or opening files, run
> `codegraph callers|impact|node "<symbol>" --path <repo path>` (env `CODEGRAPH_TELEMETRY=0
> CODEGRAPH_NO_DAEMON=1`) and open only the lines it locates. No CLI, no graph, or no match →
> grep as usual.

## Worktrees and multi-repo

A git worktree has no graph of its own: query the main checkout's graph with `--path`, knowing it
may be behind the worktree's branch. Keep one graph per repo; calls between repos over HTTP are
not edges, so trace them through the system architecture doc and grep.

Done when the question is answered with cited locations, or the fallback to grep is stated.
