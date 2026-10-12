---
name: mix-plan
description: "Write the feature's plan.md: reuse inventory from the existing code, constitution gate, deep-module design, agreed test seams, and decisions grilled with you. Spec Kit's plan merged with codebase-design."
disable-model-invocation: true
argument-hint: "[feature dir] [technical direction]"
---

# Plan

Turn the spec into a technical plan that an implementer can follow without re-deciding anything,
built from the code that already exists. Text after the command is technical direction from the
user (e.g. "use the existing queue"); treat it as decided.

**Context**: call the Skill tool with `mix-scope` to resolve the project: its repos (one or
several) and the paths to the constitution, architecture docs, glossary, ADRs, and specs folder.
A git repo is not required.

**Feature**: the folder passed as argument; else the one whose spec **Delivery** line names the
current git branch; else `feature_directory` in the project folder's `.specify/feature.json`
(Spec Kit); else the most recently modified feature folder. Confirm it in one line. No `spec.md` →
stop and point to `/mix-specify`.

## 1. Load

Read `spec.md`, the constitution, the glossary, relevant ADRs, the architecture docs (the system
map for multi-repo projects, and each repo's doc), and the knowledge notes related to this
feature (architecture decisions, integration notes, known constraints). If they are missing, say that plans are much weaker
without them and recommend `/mix-setup` first; continue only if the user says so.

If the spec still has `[NEEDS CLARIFICATION]` markers on material decisions, stop and recommend
`/mix-clarify`.

## 2. Decide which repos change

From the spec and each repo's **role** and **owns** in the config, decide which repos this
feature touches and what each one's part is: UI and client logic where the UI lives, business
rules and persistence where they live, translation and aggregation in a BFF when one sits
between. Fill **Repos Affected**. Ask only when ownership is genuinely ambiguous.

## 3. Find the prior art

Dispatch read-only subagents in parallel, one per repo affected when there are several. Find:

- The closest existing feature to this one, end to end (multi-repo: start from the system doc's
  golden path). Its structure is the default shape of this plan.
- Every existing module, helper, hook, component, and service this feature can reuse.
- The installed library for each capability the feature needs (check the manifest, not memory).
- The golden files for each kind of file this plan will add.

Fill **Prior Art & Reuse** and **Technical Context** in `plan.md` (template:
[plan-template.md](plan-template.md)). Done when every capability the spec needs maps to existing
code, an installed library, or an explicit "new" with a reason.

## 4. Constitution gate

Check the approach against every principle. A violation is either removed by changing the
approach, or justified in **Complexity Tracking** with the simpler alternative and why it fails.
An unjustified violation stops the plan.

## 5. Design

Read [DESIGN.md](DESIGN.md) for the module vocabulary, then:

- **Contracts first** when more than one repo changes: define every operation between repos
  (route, method, auth, request and response fields with types and constraints, error shapes) in
  the repo's existing contract style, before designing either side. Confirm them with the user;
  they are the interface both sides are built and tested against.
- Define the modules per repo, their interfaces, and the data model. Mirror the prior art;
  deviate only for a reason you write down.
- List every file to create or edit, grouped by repo, and the **Order of Change**.
- Propose **test seams**: the fewest, highest seams that cover the spec's acceptance scenarios.
  Call the Skill tool with `mix-testing` for seam guidance.
- Resolve unknowns: facts by research (record decision / rationale / alternatives in **Decisions**;
  use `research.md` only if findings are long), choices by asking. Call the Skill tool with
  `mix-grill` for the open technical decisions and the test seams; the user confirms the seams
  before the plan is final.
- Offer an ADR for any decision that is hard to reverse, surprising, and a real trade-off.

## 6. Re-check and write

Re-run the constitution gate against the finished design. Write `plan.md`. Keep data model and
contracts inline unless they are long; then split into `data-model.md` and `contracts/`.

The plan contains decisions and interfaces, not implementation code. Small snippets are allowed
only where a type shape or state machine says it more precisely than prose.

## 7. Report

Plan path, repos affected, contracts defined, reuse highlights (what is being reused instead of written), new dependencies (if any),
constitution status, agreed seams, ADRs created, and the next step: `/mix-tasks`.
