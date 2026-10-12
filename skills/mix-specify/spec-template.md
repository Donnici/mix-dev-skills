# Feature Specification: [FEATURE NAME]

**Feature directory**: `[specs]/[###-feature-name]/` | **Created**: [DATE] | **Status**: Draft

**Input**: "[original user description]"

**Delivery**: strategy [single | per-story | per-story-stacked] · branch `[feature branch or "none"]`
· tickets: feature [KEY-1 or "none"]; US1 [KEY-2 | "to create"]; US2 [...]

## Problem Statement

[The problem from the user's perspective: who has it, when, and what it costs them today.]

## Solution

[The solution from the user's perspective, in a short paragraph. No technology.]

## Current Behaviour

[What the product does today in this area, verified in the code. "Nothing yet" for greenfield.
This anchors the spec in reality and is the only section that may name existing screens or
flows.]

## User Scenarios & Testing *(mandatory)*

<!-- Stories are prioritised journeys. Each one, implemented alone, is a viable increment that can
be built, tested, and demonstrated independently. -->

### User Story 1 - [Brief Title] (Priority: P1)

As a [actor], I want [capability], so that [benefit].

**Why this priority**: [value and why it ranks here]

**Independent Test**: [how this story alone is verified, and the value it delivers]

**Acceptance Scenarios**:

1. **Given** [state], **When** [action], **Then** [observable outcome]
2. **Given** [state], **When** [action], **Then** [observable outcome]

---

### User Story 2 - [Brief Title] (Priority: P2)

...

### Edge Cases

- What happens when [boundary condition]?
- How does the system respond to [error scenario]?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST [specific, testable capability]
- **FR-002**: Users MUST be able to [key interaction]

### Key Entities *(include if the feature involves data)*

- **[Entity]**: [what it represents, key attributes, relationships; no storage details]

## Success Criteria *(mandatory)*

- **SC-001**: [measurable, technology-agnostic outcome, e.g. "Users finish checkout in under 3 minutes"]

## Out of Scope

- [Things a reader might reasonably expect that this feature deliberately does not do]

## Assumptions

- [Defaults taken for low-impact decisions, each overturnable]

## Clarifications

### Session [YYYY-MM-DD]

- Q: [question] → A: [answer]
