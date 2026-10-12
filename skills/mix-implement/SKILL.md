---
name: mix-implement
description: "Execute tasks.md task by task, across every repo the feature touches: read the exemplar before writing, use installed libraries, test-first at agreed seams, honour the contracts, then prune tests, strip comment noise, and self-review. Never pushes or opens PRs. Spec Kit's implement merged with implement + tdd."
disable-model-invocation: true
argument-hint: "[feature dir] [task range, e.g. T001-T010 or US1]"
---

# Implement

Build what `tasks.md` describes, so that the diff in each repo looks like it was written by
someone who has worked there for years: same patterns, same libraries, no noise.

**Context**: call the Skill tool with `mix-scope` to resolve the project: its repos (one or
several) and the paths to the constitution, architecture docs, glossary, ADRs, and specs folder.
A git repo is not required.

**Feature**: the folder passed as argument; else the one whose spec **Delivery** line names the
current git branch; else `feature_directory` in the project folder's `.specify/feature.json`
(Spec Kit); else the most recently modified feature folder. Confirm it in one line. No
`tasks.md` → point to `/mix-tasks`. An optional task range limits the run (`T001-T010`, `US1`).

## Hard rule: nothing leaves the machine

This skill **never pushes and never opens, updates, or comments on a PR**, and never asks
`mix-pr` to. Commits are local and happen only after the user explicitly approves each one. When
a unit is ready, report it and tell the user they can run `/mix-pr push` / `/mix-pr pr` when
they choose.

## 1. Load

Read in full: `tasks.md`, `plan.md`, the constitution, and the architecture doc of every repo the
tasks touch (plus the system architecture doc for multi-repo projects). Read `spec.md`,
`data-model.md`, `contracts/`, and the glossary when present. The constitution applies to every
line you write in this session; re-read it if the session gets long.

**Checklist gate**: if `checklists/` has unchecked items, show a table (checklist / total / checked
/ unchecked) and ask whether to proceed. Never edit checklist files.

**Baseline**: in each repo touched, run its quality gates once before changing anything and note
pre-existing failures, so they are not mistaken for yours.

**Change tracking**: per repo, with git, note the starting commit (`git rev-parse HEAD`) and any
files already dirty; the diff since then is "this feature's diff" in that repo. Without git, keep
a `## Files touched` list at the end of `tasks.md` (`<repo>:<path>`), adding each file as you
create or edit it; that list is the diff for hardening and review.

**Delivery**: read the spec's **Delivery** line and each story's Delivery line in `tasks.md`.
Strategy `single` → work on the feature branch in each repo touched (create it through `mix-pr`
`branch` if missing, after the user confirms the name). Per-story strategies → each story works
on its own branch (step 2). Without git, skip every branch and commit step.

## 2. Work the tasks

In order, respecting `(after T###)` blockers and phase checkpoints. Each task names its repo
(`[api]`, `[web]`); run its commands from that repo's folder. With a per-story strategy, switch
to the story's branch in each repo before its first task there, creating it through `mix-pr`
`branch` (from the base branch, the feature branch when stacked, or the blocking story's branch).
Never switch branches over uncommitted work: stop and ask.

For **each task**:

1. **Read the prior art.** Open the task's `mirror` exemplar and every file the task edits. No
   exemplar named → search the task's repo for the closest file of the same kind and read it.
   Note its structure, naming, imports, error handling, and test style; your code follows them.
2. **Check what's installed.** Before writing any capability (formatting, validation, requests,
   state, dates, ids, retries, styling), look it up in that repo's **Libraries to use** and its
   manifest. Use the installed library and the repo's wrapper around it. Search for an existing
   helper before writing a new one. A new dependency is never added here: stop and ask.
3. **Honour the contract.** Code on either side of a repo boundary matches the plan's contract
   exactly: route, method, field names, types, optionality, error shapes, auth. Providers expose
   it, consumers call it through the repo's existing client. A contract that turns out wrong is
   changed in the plan first, with the user, then on both sides.
4. **Test tasks** go red first: write the test at the agreed seam, run it, see it fail for the
   right reason. **Implementation tasks** write the least code that turns it green. Call the Skill
   tool with `mix-testing` the first time you write a test in the session.
5. **Write the simplest version.** Direct code, no speculative parameters, no abstraction with a
   single implementation, no defensive checks for states the types or callers rule out. Names
   explain *what*; a comment appears only for a non-obvious *why*, in one line.
6. **Stay in scope.** Touch only what the task needs. A problem you notice elsewhere becomes a note
   for the report, not an edit.
7. **Verify.** Run the typecheck and the affected test file(s) in that repo. Fix before moving on.
8. **Mark** the task `[X]` in `tasks.md`.

When a task turns out wrong (the plan missed something, the exemplar doesn't fit, a blocker is
missing), stop and tell the user what you found and what you propose. Do not silently redesign.
A failing sequential task halts the run; for `[P]` tasks, finish the others and report the failure.

Large features may run work through implementer subagents, one per repo or per story. Brief them
with **pointers** (feature folder, task IDs, repo path, constitution and architecture paths), not
copies; require them to follow this section's per-task steps and the hard rule above.

## 3. Harden

At each **delivery boundary** (the end of every story with a per-story strategy, or after the last
task with `single`), over that unit's diff in every repo it touched:

1. **Quality gates.** Full suite and all gates per repo; everything green except baseline failures.
2. **Test pruning pass** from the `mix-testing` skill over every test the unit added or changed.
   Delete, merge, and rewrite as it says; re-run the suite.
3. **Comment pass**: list every comment line the diff adds. Keep only those that explain a
   non-obvious why in one or two lines. Remove narrating comments, commented-out code,
   change-history notes, comments addressed to the reviewer, docblocks restating the signature.
4. **Leftovers**: remove debug logs, unused imports and exports, dead branches, unreferenced files.
5. **Self-review**: call the Skill tool with `mix-review` with `--fix`, scoped to this unit's diff
   and its story. Fix every blocking finding and every one you agree with; list the rest with your
   reason. Re-run the gates.
6. **Offer a local commit** (git only): show, per repo, the files and the commit message from the
   `mix-pr` naming rules, and ask. Commit only on an explicit yes. Then continue to the next story,
   or stop if the user declined and the next story needs a different branch.

## 4. Report

Tasks completed; files changed per repo; tests added / deleted / merged in the pruning pass;
comments removed; review findings fixed vs left (with reasons); local commits made; branches
ready to push and the command to do it (`/mix-pr push`, `/mix-pr pr`); things noticed out of
scope; deviations from the plan.
