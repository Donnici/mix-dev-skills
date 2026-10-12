# Implementation Plan: [FEATURE]

**Spec**: `specs/[###-feature-name]/spec.md` | **Date**: [DATE]

## Summary

[Primary requirement and the technical approach, in three sentences or fewer.]

## Repos Affected

| Repo | Role in this feature | Why it changes |
|------|----------------------|----------------|
| [api] | [provider: new auth endpoints, sessions] | [FR-001–FR-004] |
| [web] | [consumer: login page, session hook] | [US1, US2] |

*(Single-repo projects: one row, or delete this section.)*

## Technical Context

Taken from the architecture docs and the code; nothing here is guessed. One block per repo
affected when stacks differ.

- **Language / framework**: [...]
- **Libraries used by this feature**: [installed library → what it does here]
- **New dependencies**: [none | name, why no installed library covers it, user approval]
- **Storage**: [...]
- **Testing**: [runner, levels used by this feature]
- **Constraints**: [performance, compatibility, limits from the spec]

## Prior Art & Reuse

| Need | Repo | Existing code to reuse or mirror | How |
|------|------|----------------------------------|-----|
| [e.g. list screen with filters] | web | [`src/features/orders/OrderList.tsx`] | [mirror structure] |
| [e.g. date formatting] | web | [`src/lib/date.ts` (dayjs)] | [call directly] |
| [end-to-end shape] | all | [golden path from the system architecture doc] | [mirror layer by layer] |

## Constitution Check

*Gate: passes before design; re-checked after.*

| Principle | Status | Note |
|-----------|--------|------|
| I. Prior Art First | ✅ / ❌ | |
| II. Installed Dependencies First | | |
| III. Simplicity | | |
| IV. Comments | | |
| V. Tests | | |
| VI. Scope Discipline | | |
| VII. Architecture | | |
| VIII. Contracts (multi-repo) | | |
| [project-specific rules] | | |

## Design

### Modules

For each module this feature adds or changes: **name**, **interface** (what callers must know:
inputs, outputs, errors, invariants), and what it hides. Prefer few deep modules over many
shallow ones.

- **[Module]** (`[path]`, new | changed): [interface] — hides [behaviour]

### Data Model *(if data is involved)*

[Entities, fields with constraints (type, required, max length, enum values), relationships,
state transitions. Quote spec rules verbatim.]

### Contracts *(mandatory when more than one repo is affected, or an interface is exposed)*

The agreement between repos, precise enough that each side can be built and tested alone.
Follow the system architecture doc's contract conventions. One block per operation:

```text
POST /v1/auth/login                     provider: api · consumers: web (via bff, if any)
Auth: none → sets session cookie
Request:  { email: string (email, required), password: string (8–128, required) }
200:      { user: { id: string, name: string, email: string } }
401:      { error: "invalid_credentials" }
422:      { error: "validation_error", fields: { [field]: string } }
```

Where the contract is materialised (OpenAPI file, shared types package, types duplicated in each
repo) and who updates it: [...]

### Files

```text
[every file to create or modify, marked (new) or (edit), grouped by repo then layer]
api/
  src/... (new)
web/
  src/... (edit)
```

### Order of Change *(multi-repo)*

[e.g. contract → api → bff → web. Say whether consumers start in parallel against a mock of the
contract, and how the sides are integrated and verified end to end.]

## Test Seams

Agreed with the user. Tests go here and nowhere else.

| Seam | Repo | Level | Covers (FR / scenario) | Misses |
|------|------|-------|------------------------|--------|
| [e.g. POST /orders handler with test DB] | api | integration | FR-001, US1/AC1–3 | UI states |
| [e.g. web client against the contract mock] | web | integration | US1/AC4 | real API behaviour |

## Decisions

- **[Decision]**: [choice] — because [reason]; rejected [alternative] because [reason].

## Validation

[How a human proves the feature works end to end: setup, steps, expected result.]

## Risks

- [Risk] → [mitigation]

## Complexity Tracking

*Only when the Constitution Check has a justified violation.*

| Violation | Why needed | Simpler alternative rejected because |
|-----------|------------|--------------------------------------|
