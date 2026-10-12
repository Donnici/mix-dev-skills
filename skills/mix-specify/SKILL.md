---
name: mix-specify
description: "Turn a feature idea into a spec: explores the code, grills you on the material decisions, captures tickets and branch strategy, keeps the glossary and ADRs current, then validates the spec. Spec Kit's specify merged with grill-with-docs."
disable-model-invocation: true
argument-hint: "<feature description> [--quick]"
---

# Specify

The text after the command is the feature description. If it is empty, ask what is to be
specified.

A spec says **what** users need and **why**, never **how**. It is written for a product reader,
in the project's domain language, and every requirement in it is testable.

`--quick`: the conversation already settled the decisions. Skip step 4's interview and
synthesise the spec from what was discussed; still run delivery and validation.

**Context**: call the Skill tool with `mix-scope` to resolve the project: its repos (one or
several) and the paths to the constitution, architecture docs, glossary, ADRs, and specs folder.
A git repo is not required. With nothing set up, suggest `/mix-setup` once and continue on defaults.

## 1. Create the feature folder

- Short name: 2–4 words, action-noun, kebab-case, keeping technical terms (`user-auth`,
  `oauth2-api-integration`, `fix-payment-timeout`).
- Number: next free 3-digit prefix in the project's `specs/` (`003-user-auth`). If the folder already
  uses timestamp prefixes, follow that.
- Create `specs/<NNN-short-name>/spec.md` under the project's base, from
  `mix-dev-skills/templates/spec.md` when the project has one, else [spec-template.md](spec-template.md). In a hub,
  follow the hub's file conventions (e.g. list the new spec in the specs `index.md`).
- One feature per invocation.

## 2. Load context and explore

Read, when they exist: the constitution, the architecture docs, the glossary, ADRs that touch this
area. From the project's **knowledge** docs, read the index first, then every note whose title or
summary relates to this feature (prior decisions, domain rules, incidents, setup quirks).

Explore the code the feature touches, in every repo of the project (one subagent per repo when
there are several), until you can write **Current Behaviour** from evidence:
which screens, flows, entities, and rules exist, and what the feature changes about them.
Dispatch a read-only subagent for wide searches. If a related spec exists, read it and note
overlaps.

## 3. Delivery

Settle how this feature ships, from the config's `git` and `tracker` blocks:

- **Strategy**: confirm the configured one (`single`, `per-story`, `per-story-stacked`) or take the
  user's override. If the user said "use this code for the branch", that is `single` with that
  branch.
- **Tickets**: when the branch or PR patterns use `[ticket]`, or a tracker is configured, ask for
  the feature ticket and any story tickets the user already has. Stories without tickets are
  marked "to create"; `/mix-tasks` creates or collects them once stories are final.
- **Branch**: with git enabled and a strategy that has a feature branch (`single`,
  `per-story-stacked`), call the Skill tool with `mix-pr` to create it now. For `per-story`,
  story branches come later, in `/mix-implement`. Without git, skip.

Record all of it in the spec's **Delivery** line.

## 4. Grill the material decisions

From the description and the exploration, list the open items, separating facts (look them up)
from decisions (ask). Call the Skill tool with `mix-grill` and run it until the frontier of
**material** decisions is empty. Typical material areas:

- Scope boundaries: what is in, what is explicitly out.
- Actors and permissions, when more than one reading is plausible.
- Behaviour on edge cases, empty states, failures, concurrent edits.
- Data lifecycle: what is created, changed, deleted, retained, and by whom.
- Security, privacy, and compliance, when legally or financially significant.
- How success will be measured.
- How the feature splits into stories, when the user brought existing stories or tickets: map
  them one-to-one to user stories rather than inventing a different split.

Low-impact items get a reasonable default recorded under **Assumptions**: standard error messages,
conventional pagination, the auth the app already uses, the pattern the repo already follows.

Record each answer in the spec as it lands. Sharpen domain terms into the glossary and offer ADRs
as the `mix-grill` skill describes.

Done when no material decision is open; at most three `[NEEDS CLARIFICATION: question]` markers
may remain, and only for decisions the user explicitly deferred.

## 5. Write the spec

Fill every mandatory section; delete optional sections that do not apply (no "N/A").

- **User stories**: prioritised (P1 first), each independently testable and valuable alone, and
  each a sensible unit to ship as its own PR. Cover every actor and journey the grilling
  surfaced; err on more stories, smaller.
- **Functional requirements**: `FR-###`, each testable and unambiguous. A requirement that cannot
  fail a test is rewritten.
- **Success criteria**: `SC-###`, measurable and technology-agnostic ("results appear in under a
  second for 95% of searches", never "API p95 < 200ms" or "Redis hit rate").
- **Out of Scope**: anything a reader might expect that this feature will not do.
- Glossary terms everywhere; one name per concept.
- No frameworks, libraries, APIs, file paths, or code. Those belong to `/mix-plan`.

## 6. Validate

Create `<feature>/checklists/requirements.md` and check the spec against it:

```markdown
# Spec Quality Checklist: [FEATURE]

## Content
- [ ] No implementation details (languages, frameworks, APIs, file paths)
- [ ] Written for a product reader, in glossary terms
- [ ] Current Behaviour is backed by the code
- [ ] All mandatory sections complete; empty optional sections removed

## Requirements
- [ ] No [NEEDS CLARIFICATION] markers remain, or each is an explicit user deferral
- [ ] Every FR is testable and unambiguous
- [ ] Success criteria are measurable and technology-agnostic
- [ ] Every story has acceptance scenarios and an independent test
- [ ] Edge cases and failure paths identified
- [ ] Scope bounded: Out of Scope filled
- [ ] Assumptions listed

## Readiness
- [ ] Every FR is traceable to at least one story
- [ ] No requirement contradicts the constitution
- [ ] Delivery line filled (strategy, branch, tickets)
```

For each failing item, fix the spec and re-check, up to three passes. Items still failing go into
a Notes section of the checklist and are reported to the user.

## 7. Report

Feature folder, spec path, delivery (strategy, branch, tickets), checklist result, decisions vs
assumptions count, glossary terms and ADRs added, and the next step: `/mix-clarify` if markers or
weak areas remain, else `/mix-plan`.
