---
name: mix-quick-implement
description: "Small change, one command: locate the code, confirm today's behaviour, settle every open point in a single check-in, write a short spec, implement test-first, harden, and record the outcome. For changes too small for specify → plan → tasks → implement."
disable-model-invocation: true
argument-hint: "<change description or issue reference>"
---

# Quick Implement

The whole flow, compressed for a small change: one skill, **one check-in** with the user, and a
short spec that keeps the change visible next to the full-flow specs.

The text after the command is the change. An issue reference (`#42`, `ABC-123`, a URL) → read
the issue through the tracker in `mix.yml` (MCP, `gh`, `glab`) and use its body as the input.
Empty → ask what to change.

**Context**: call the Skill tool with `mix-scope` for the project: its repos and roles, the
constitution, architecture docs, glossary, and specs folder. Read the constitution and the
architecture doc of the repo you will touch; both apply to every line written here. A git repo is
not required.

## Hard rule: nothing leaves the machine

This skill never pushes and never opens, updates, or comments on a PR. A local commit happens only
when the user approved it at the check-in. Push and PR stay with `/mix-pr`, on the user's request.

## 1. Size gate

A change fits here when **all** of these hold:

- One behaviour, describable in one sentence, with one or two acceptance scenarios.
- One repo, or two with a contract that already exists and does not change.
- A handful of files (about five or fewer, tests included).
- No new dependency, no data migration, no new or changed contract, no new screen or flow.
- At most three open decisions, none of them about scope or security.

Re-check after step 2, when the code is known. A failing criterion → stop, say which one, and
route: unclear cause of something broken → `mix-diagnose`; bigger than this → `/mix-specify
--quick`, passing the spec draft from step 4 as input so nothing found is lost.

**Done when** every criterion is checked against the code, or the user has been routed elsewhere.

## 2. Locate and confirm today's behaviour

Find the code that produces the current behaviour, by domain concept, not just the issue's words
(dispatch a read-only subagent only when the search spans several repos). Read:

- the files the change will edit, end to end;
- the **exemplar**: the closest existing code of the same kind (a sibling component, handler, or
  condition that already does the right thing) — the fix mirrors it;
- the tests that cover the area, to find the seam and the test style.

Then **confirm the behaviour with a signal**, the light version of `mix-diagnose`'s loop: an
existing or new test that asserts today's behaviour, a story/fixture render, a CLI or curl call.
For a bug, it must reproduce the symptom the issue describes. When no signal is reachable in a
few minutes, record why and continue from code evidence.

**Done when** you can cite `repo:path:line` for the code that decides the behaviour, and the
signal (or the reason there is none) is noted.

## 3. Draft the change

From the evidence, settle in your own notes:

- **Change**: the smallest edit that produces the requested behaviour, following the exemplar and
  the repo's installed libraries. Name each file to touch.
- **Test**: the seam and the test that goes red today and green after (call the Skill tool with
  `mix-testing` the first time you choose a seam in the session). Prefer extending an existing
  test file over creating one.
- **Open points**: separate facts (look them up, never ask) from decisions. A low-impact decision
  with an obvious default (the pattern the repo already uses) becomes an assumption, not a
  question.
- **Delivery**: from the config's `git` and `tracker` blocks, the branch name (through `mix-pr`
  naming rules; `[ticket]` from the issue reference when there is one) and the commit message.
  No git → skip.

**Done when** every file to touch, the test, each decision with a recommended answer, and the
delivery names are written down.

## 4. Write the spec and check in once

Create `specs/<NNN-short-name>/spec.md` (next free number, as `/mix-specify` does; `fix-` or
action-noun short name) from `mix-dev-skills/templates/quick-spec.md` when the project has one,
else [quick-spec-template.md](quick-spec-template.md). Fill everything except **Outcome**;
status `Draft`. In a hub, follow its file conventions (e.g. list the spec in the specs
`index.md`).

Then send **one** message, everything the user needs to answer in a single reply:

```
**Quick change: <title>** · spec: `<path>`

**Today**: <one sentence, with repo:path:line>
**Change**: <one sentence> → files: `<path>`, `<path>`
**Test**: <seam and the assertion that goes red today>
**Assumptions**: <defaults taken; omit when none>

❓ **Q1 — <topic>**: <question>? ➡️ Recommended: <answer> — <why>
❓ **Q2 — ...**

**Delivery**: branch `<name>` · commit `<message>` · commit locally at the end? ➡️ Recommended: yes

Reply "go" to accept every recommendation, or answer only what you want different ("Q1: B, no commit").
```

Questions follow `mix-grill`'s rules for wording (a "yes" accepts the recommendation), but there
is one round only, of up to three questions. An answer that opens a new material decision, or
changes the size, is the signal to route out (step 1), not to start a second round. Record each
answer in the spec's **Decisions** and update the plan lines it changes.

**Done when** the spec file exists, the user has replied, and every answer is recorded.

## 5. Implement

Status `In progress`. With git and an approved branch, create it through `mix-pr` `branch`
(never switch branches over uncommitted work: stop and ask). Note the starting commit; without
git, track touched files in the spec's **Outcome**.

1. **Red**: write or extend the test at the agreed seam; run it; see it fail for the right reason.
2. **Green**: the least code that passes it, mirroring the exemplar: same structure, naming,
   imports, libraries, and error handling. A comment only for a non-obvious why, in one line.
3. **Scope**: touch only the planned files. Something else broken becomes a note in **Outcome**.
   A needed file outside the plan is fine when it stays within the size gate; otherwise stop,
   update the spec with what you found, and route to `/mix-specify --quick`.

**Done when** the new test passes and the typecheck and the affected test files run green.

## 6. Harden

Over this change's diff:

1. **Gates**: the repo's full quality gates (lint, typecheck, tests). Failures present before
   your change are reported as pre-existing, not fixed.
2. **Tests**: the `mix-testing` pruning pass over every test the change added or edited.
3. **Noise**: remove narrating comments, debug logs, unused imports, and dead code the change added.
4. **Self-review**: re-read the diff against the constitution, the exemplar, and the spec's
   acceptance scenarios: everything asked is there, nothing unasked is. Call the Skill tool with
   `mix-review` `--fix` only when the diff outgrew the plan or the user asked.

**Done when** the gates are green (save pre-existing failures) and the review found nothing open.

## 7. Close the spec and commit

Fill the spec's **Outcome**: files changed per repo, tests added or changed, the verification
command and its result, the signal from step 2 re-run (for a bug: no longer reproduces), and
notes out of scope. Status `Done`.

Commit approved at the check-in → call the Skill tool with `mix-pr` `commit` with the agreed
message, staging the change's files and its spec when the spec lives in the same repo. Not
approved, or no git → leave the changes in the working tree.

**Done when** the spec has an Outcome and status `Done`, and the commit exists or was declined.

## 8. Report

Spec path; the change in one sentence; files changed; test added and gates result; commit made
(or not); assumptions taken; notes out of scope; next step: `/mix-pr push` / `/mix-pr pr` when
the user chooses, or `/mix-review` for a second look.
