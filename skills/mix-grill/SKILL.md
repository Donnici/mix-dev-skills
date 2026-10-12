---
name: mix-grill
description: Interview the user in rounds of recommended-answer questions until every material decision in a plan, spec, or idea is settled. Use when the user says "grill me", wants to stress-test a design, or when mix-specify, mix-clarify, or mix-plan has open decisions.
---

# Grill

Interview the user relentlessly until you reach a shared understanding. Map the subject as a
**design tree**: every decision branches into the decisions that hang off it.

## Facts are yours, decisions are theirs

Before asking anything, separate the open items:

- **Facts** (how the code works today, which library is installed, what an API returns, what a
  config says) are your job. Look them up in the repo, docs, or tools; dispatch a read-only
  subagent for wide searches. Never ask the user for something you could find.
- **Decisions** (scope, behaviour, trade-offs, priorities, naming) belong to the user. Put each one
  to them and wait.
- **Low-impact decisions** with a reasonable default (standard error messages, conventional
  pagination, the pattern the repo already uses) are not asked. Take the default and record it as
  an assumption so the user can see and overturn it.

A decision is **material** when its answer changes scope, data shape, user-visible behaviour,
security or privacy, test design, or rework risk. Prioritise: scope > security/privacy > user
experience > technical detail.

## Rounds

The **frontier** is every material decision whose prerequisites are already settled. Ask the
whole frontier in one round, then wait. A question whose answer depends on another question still
open belongs to a later round. A running lookup is an unsettled prerequisite: only the questions
downstream of it wait; ask the rest now.

Format each round:

```
❓ **Q1 — <short topic>**: <full question ending in "?">
_Why it matters_: <one sentence: what goes wrong or changes depending on the answer>

| Option | Answer | Implication |
|--------|--------|-------------|
| A | ... | ... |
| B | ... | ... |

➡️ **Recommended: A** — <one or two sentences of reasoning from the repo, the constitution, or common practice>

---

❓ **Q2 — ...**
```

- Word each question so "yes" accepts the recommendation; the user may also answer "Q1: B, Q2: yes".
- Use a table only when there are 2–5 discrete options; otherwise give a suggested short answer.
- Everyday wording. A reader who never saw the spec must understand the question line alone.
- Keep rounds to five questions or fewer; if the frontier is larger, ask the highest-impact five.

## Between rounds

- Record each answer the moment it lands, in the artifact the calling skill owns (spec, plan) or
  in a running list when grilling stands alone.
- When an answer resolves a domain term, follow the glossary rule below.
- Recompute the frontier: settled decisions unblock new ones.
- Challenge contradictions immediately: with earlier answers, with the glossary, or with the
  code ("the code cancels whole Orders, but you said partial cancellation is possible: which?").

## Glossary and ADRs

Both live in the project's `mix-dev-skills/` folder (resolved by `mix-scope`): `glossary.md` and
`adr/`.

- When the user uses a vague or overloaded term ("account" for both Customer and User), propose one
  canonical term. Once agreed, add it to `mix-dev-skills/glossary.md` (create it lazily) as
  `**Term**: one or two sentence definition` plus `_Avoid_: synonyms`. Only project-specific
  domain concepts belong there, never implementation details.
- Offer an ADR (`mix-dev-skills/adr/NNNN-slug.md`) only when a decision is hard to reverse, surprising
  without context, and the result of a real trade-off. An ADR can be one paragraph: context,
  decision, why.

## Done

Stop when the frontier is empty, or the user says stop. Then summarise: decisions made,
assumptions taken by default, anything deliberately deferred and why. Do not act on the outcome
until the user confirms the summary.
