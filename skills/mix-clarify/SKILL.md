---
name: mix-clarify
description: "Scan an existing spec for ambiguity and gaps with Spec Kit's coverage taxonomy, grill you on what matters, and write each answer back into the spec. Run before /mix-plan."
disable-model-invocation: true
argument-hint: "[feature dir] [focus area]"
---

# Clarify

Reduce ambiguity in an existing spec and record the clarifications in it. Run before `/mix-plan`;
skipping it is allowed but raises rework risk, so say so once.

**Context**: call the Skill tool with `mix-scope` to resolve the project: its repos (one or
several) and the paths to the constitution, architecture docs, glossary, ADRs, and specs folder.
A git repo is not required.

**Feature**: the folder in the project's `specs/` passed as argument; else the one whose spec
**Delivery** line names the current git branch; else the most recently modified one. Confirm it in one line. If there is
no `spec.md`, stop and point to `/mix-specify`.

## 1. Load

Read `spec.md`, `checklists/requirements.md`, the constitution, the glossary, and the architecture
docs if present, plus the knowledge notes related to this feature (index first). Knowledge docs
often already answer a gap; check them before asking.

## 2. Coverage scan

Mark each category **Clear / Partial / Missing** (internal map, shown only if nothing is asked):

- **Scope & behaviour**: core goals, explicit out-of-scope, distinct actors and roles.
- **Domain & data**: entities, identity and uniqueness, lifecycle and state transitions, volume.
- **Interaction & UX**: critical journeys, error / empty / loading states, accessibility, i18n.
- **Non-functional**: performance, scale, reliability, observability, security & privacy,
  compliance.
- **Integrations**: external services and their failure modes, import/export formats.
- **Edge cases & failures**: negative paths, rate limits, concurrent edits, partial failure.
- **Constraints & trade-offs**: stated constraints, rejected alternatives.
- **Terminology**: terms that drift or conflict with the glossary.
- **Completion signals**: are acceptance scenarios testable? Is "done" measurable?
- **Placeholders**: TODOs, `[NEEDS CLARIFICATION]`, vague adjectives ("fast", "intuitive",
  "robust") with no measure.

Before turning a gap into a question, check whether the code or docs already answer it; facts are
yours to find.

## 3. Grill

Each Partial or Missing category becomes a candidate question when its answer would change
architecture, data model, task breakdown, test design, UX behaviour, or compliance. Drop
questions about implementation method or tech stack: those belong to `/mix-plan`. Rank by
impact × uncertainty.

Call the Skill tool with `mix-grill` with that ranked list. Aim for ten questions or fewer across
the session; the user can stop at any time ("done", "proceed").

## 4. Integrate each answer immediately

After every accepted answer:

1. Append `- Q: <question> → A: <answer>` under `## Clarifications` / `### Session <today>`.
2. Apply it to the section it belongs to: functional → Functional Requirements; actor or journey →
   User Stories; data → Key Entities; non-functional → a measurable Success Criterion; failure →
   Edge Cases; terminology → normalise the term across the whole spec and the glossary.
3. Replace any statement the answer invalidates; leave no contradiction behind.
4. Save the spec.

## 5. Re-validate

If `checklists/requirements.md` exists, re-evaluate each checkbox against the updated spec and
toggle only the markers whose state changed. Note before/after pass counts.

## 6. Report

Questions asked and answered; sections touched; checklist before → after; a coverage table per
category (Resolved / Clear / Deferred / Outstanding); and a recommendation: `/mix-plan` now, or
another `/mix-clarify` pass if high-impact items are still Outstanding.
