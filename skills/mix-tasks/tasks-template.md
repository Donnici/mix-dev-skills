# Tasks: [FEATURE NAME]

**Input**: `specs/[###-feature-name]/` (spec.md, plan.md)

Format: `- [ ] T### [P?] [US#?] [repo] <action> in <file> — mirror <exemplar> (after T###)`

- `[P]`: parallelisable (different files, no unfinished dependency).
- `[repo]`: the repo the task runs in (`[api]`, `[web]`); omit in single-repo projects.
- `[US#]`: user story, only in story phases.
- `mirror`: the existing file to copy the shape of. Omit only when nothing similar exists.
- `(after ...)`: blocking tasks; omit when the only dependency is the previous phase.

## Phase 1: Prefactor *(omit if none)*

Behaviour-preserving changes that make the feature easy to add. Existing tests stay green.

- [ ] T001 [action] in [file]

## Phase 2: Foundation *(omit if none)*

Shared prerequisites every story needs: schema, shared types, config. Nothing story-specific.

- [ ] T002 [action] in [file] — mirror [exemplar]

**Checkpoint**: stories can start.

## Phase 3: User Story 1 — [Title] (P1) 🎯 MVP

**Goal**: [what this story delivers]
**Done when**: [the story's independent test passes]
**Delivery**: ticket [KEY-2 | none] · branch `[story branch | feature branch | none]` in [api, web] · PRs [links, once the user opens them]

- [ ] T003 [US1] [api] Contract: [operation] as in plan.md in [contract file / types] *(multi-repo)*
- [ ] T004 [US1] [api] Test: [behaviour] at seam [seam from plan] in [test file] — mirror [test exemplar]
- [ ] T005 [US1] [api] [action] in [file] — mirror [exemplar]
- [ ] T006 [P] [US1] [web] [action] in [file] — mirror [exemplar] (after T003)
- [ ] T007 [US1] Integrate: [web] against the running [api]; verify [acceptance scenario] (after T005, T006)

**Checkpoint**: US1 works and is demonstrable on its own.

## Phase 4: User Story 2 — [Title] (P2)

...

## Final Phase: Hardening

With a per-story strategy these run at the end of every story phase, before its PR.

- [ ] T0XX Run the test pruning pass over tests added in this feature (mix-testing)
- [ ] T0XX Remove comments that violate Constitution IV; remove debug logs and dead code
- [ ] T0XX Run all quality gates from the constitution
- [ ] T0XX Self-review the diff with mix-review and fix findings

## Dependencies

[Story order and any cross-story edges. Stories should be independent; say so when they are.]
