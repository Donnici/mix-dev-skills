---
name: mix-ticket
description: "Take one ticket or feature from idea to reviewed code in one run: specify, clarify when needed, plan, tasks, analyze, implement (parallel slices when independent), a final review, and the PR when you asked for it. Stops only to approve the spec and when a step cannot settle something alone."
disable-model-invocation: true
argument-hint: "<ticket key | feature description> [--until implement | --until pr]"
---

# Ticket

Run the whole main flow for one ticket in a single session, so the user approves the spec once
and then watches, instead of starting each step by hand. Every step keeps its own rules; this
skill only sequences them and carries the answers forward.

**Context**: call the Skill tool with `mix-scope` to resolve the project: its repos (one or
several), the config (`git`, `tracker`), and the paths to the constitution, architecture docs,
glossary, ADRs, and specs folder. A git repo is not required.

## How a step runs

The steps are command skills (`mix-specify`, `mix-clarify`, `mix-plan`, `mix-tasks`,
`mix-analyze`, `mix-implement`) that the Skill tool cannot start. For each one, open its
`SKILL.md` in the sibling folder of this skill (same skills directory, e.g.
`~/.claude/skills/mix-plan/SKILL.md`, or the plugin's `skills/` folder), read it whole, and follow
it in this session as if the user had typed the command, with the feature folder as argument.
Model-invoked skills (`mix-review`, `mix-pr`, `mix-diagnose`) go through the Skill tool. A step
whose `SKILL.md` cannot be found → stop and give the user the command to run.

**Done when** each step's own "Done when" holds and its `state.yml` values are written before
the next step starts.

## 1. Load the ticket

- **Ticket key** (`ABC-123`, `#123`): read it through the tracker named in the config (MCP tool or
  CLI, read-only): title, description, acceptance criteria, comments, linked tickets. A tracker
  that is unreachable or needs auth → say so and ask the user to paste the ticket.
- **Description**: use it as the feature description.
- Read the knowledge notes related to the ticket (index first), including meeting decisions.

**Done when** you can state the ticket's goal and acceptance criteria in three lines.

## 2. Specify, then the spec checkpoint

Follow `mix-specify` with the ticket text, the key recorded in the **Delivery** line. Its grill
runs with the user as usual. Then follow `mix-clarify` only when `state.yml` says
`next_step: /mix-clarify`.

**Checkpoint (the one planned stop)**: show the spec summary (stories, FRs, out of scope,
assumptions, delivery) and ask, recommended answers first:

1. Approve the spec as written?
2. Commit locally at each delivery boundary without asking again? (recommended: yes; commits use
   the `mix-pr` naming rules and never leave the machine)
3. Open the PR at the end? (recommended: the `--until` argument; with none, yes only when the
   request said so in the user's words, such as "until the PR")

**Done when** the user approved the spec and answered 2 and 3.

## 3. Plan, tasks, analyze

Follow `mix-plan`, `mix-tasks`, then `mix-analyze`. Decisions these steps grill go to the user
as they arise; facts they can look up never do. When `mix-analyze` leaves CRITICAL findings,
follow the skill its `next_step` names, then `mix-analyze` again, at most twice; findings still
open after that → stop and show them.

**Done when** `state.yml` reads `next_step: /mix-implement`.

## 4. Implement

Follow `mix-implement` over all tasks. Answer 2 from the checkpoint stands in for its
per-commit question. Stories or repos with no blocker between them may run as parallel
implementer subagents, as `mix-implement` section 2 allows; two subagents in one repo each work
in their own git worktree (`git worktree add`) on their story's branch. New behaviour stays
behind the feature flag the plan names, when it names one.

**Done when** `state.yml` reads `status: Implemented`, or the run halted with the reason shown.

## 5. Final review

Call the Skill tool with `mix-review` `--fix` over the whole feature diff in every repo touched,
against the spec. Every `missing`, `partial`, or `contradicts` finding left open is listed for
the report as a known gap, never hidden.

**Done when** the review has no open blocking finding, or each one left is in the report.

## 6. Ship

Answer 3 was yes → call the Skill tool with `mix-pr` (ship): the user's request is the approval.
Otherwise skip and name `/mix-pr` as the next step. Never merge.

**Done when** each repo touched has its PR open, or the report names `/mix-pr`.

## 7. Report

```markdown
## Ticket: <key> <title>

**Spec**: <feature folder> · **Status**: <state.yml status>
**PRs**: <repo → URL, with merge order> | not opened (run /mix-pr)
**Feature flag**: <name> | none
**Tests**: <added / deleted in pruning> · **Gates**: <green | pre-existing failures>
**Known gaps**: <requirement → partial or missing, why> | none
**Decisions taken by default**: <assumptions the user may overturn>
**Next step**: <state.yml next_step, or the PR review>
```
