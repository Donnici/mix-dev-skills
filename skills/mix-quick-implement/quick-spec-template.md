# Quick Change: [TITLE]

**Directory**: `[specs]/[###-short-name]/` | **Created**: [DATE] | **Status**: Draft | **Flow**: quick

**Input**: "[original issue text or reference]"

**Delivery**: branch `[name or "none"]` · ticket [KEY-1 or "none"] · commit [approved | declined]

## Problem

[Who sees what today, and why it is wrong. One or two sentences.]

## Current Behaviour

[What the code does today, with evidence: `repo:path:line` and the signal that confirmed it
(test, render, command), or why no signal was reachable.]

## Change

[The behaviour after the change, from the user's perspective. One or two sentences.]

**Acceptance**:

1. **Given** [state], **When** [action], **Then** [observable outcome]

## Plan

- `[repo]:[path]`: [what changes]. Mirrors `[exemplar path]`.
- Test: `[repo]:[test path]`: [the assertion that goes red today].

## Decisions

- Q: [question] → A: [answer] *(or: assumption: [default taken])*

## Outcome

- **Files**: `[repo]:[path]`, ...
- **Tests**: [added / changed]
- **Verification**: `[command]` → [result]; original signal re-run → [result]
- **Commit**: [hash and message | not committed]
- **Notes**: [things noticed out of scope; omit when none]
