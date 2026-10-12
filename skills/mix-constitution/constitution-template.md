# [PROJECT_NAME] Constitution

The rules every agent follows when it specifies, plans, implements, or reviews code in this
repository. `MUST` rules are gates: a plan that breaks one is rejected, and a diff that breaks one
is a blocking review finding. `SHOULD` rules are defaults that may be broken with a written reason.

Repository map (stack, libraries, patterns, exemplar files): [ARCHITECTURE_PATH]

## Core Principles

### I. Prior Art First

Every change starts by finding the code it resembles.

- Before writing a new file, function, component, hook, endpoint, or test, the agent MUST search
  the repository for the closest existing equivalent and read it.
- New code MUST mirror the exemplar's structure, naming, error handling, and file placement.
  The exemplars per kind of change are listed in the architecture doc.
- Existing helpers, utilities, and shared modules MUST be reused instead of re-implemented.
  A near-duplicate of something that already exists is a defect.
- When two existing patterns conflict, follow the one used by the most recently changed code
  and flag the conflict to the user.

**Rationale**: AI-generated code drifts from local conventions unless it is anchored to a
concrete example. The repository is the style guide.

### II. Installed Dependencies First

- Before implementing any capability (dates, validation, HTTP, forms, state, styling, testing,
  logging, etc.), the agent MUST check the dependency manifest ([MANIFEST_FILES]) and use the
  library already installed for that purpose.
- A new dependency MUST be justified in the plan (why no installed library or small local
  function covers it) and approved by the user before it is added.
- Use the project's package manager ([PACKAGE_MANAGER]) and its lockfile; never mix managers.

**Rationale**: Duplicate libraries for the same job fragment the codebase and bloat bundles.

### III. Simplicity

- Write the simplest code that satisfies the spec: direct control flow, few layers, plain data.
- Abstractions (interfaces, factories, generic helpers, config options, extension points) are
  added only when a second real use exists today. One implementation means no abstraction.
- Prefer deep modules: a small interface hiding real behaviour. A wrapper that only forwards
  calls is removed.
- Handle the errors that can actually happen at this point in the system; trust internal
  invariants and types instead of re-validating them at every layer.

**Rationale**: Every extra layer is code a reviewer must read and a future change must touch.

### IV. Comments Earn Their Place

- Code explains *what* through names and structure. A comment exists only to explain a *why*
  the code cannot show: a non-obvious constraint, a workaround with its cause, a business rule
  with its source.
- Comments are one line, two at most. Docblocks only on public APIs where the repo already uses
  them, and they add information the signature does not.
- The final diff contains no narrating comments ("// increment counter", "// call the API"),
  no commented-out code, no TODOs without an owner or ticket, and no comments addressed to the
  reviewer or describing the change history.

**Rationale**: Comment noise is the most frequent review complaint on AI-written PRs.

### V. Tests That Earn Their Place

- Tests verify observable behaviour through public interfaces at the seams agreed in the plan.
- Each behaviour is covered once, at the highest seam that can observe it. A unit test that
  repeats what an integration test already proves is removed.
- Expected values come from an independent source (a literal, a worked example, the spec),
  never recomputed the way the code computes them.
- Mock only at system boundaries (network, third-party services, time, randomness).
- After implementation, the agent MUST run a pruning pass over the tests it wrote: remove
  redundant, tautological, implementation-coupled, and trivial tests (getters, constants,
  framework behaviour), and merge tests that differ only in data into one table-driven test.

**Rationale**: Redundant tests slow every future change without catching more bugs.

### VI. Scope Discipline

- The diff contains only what the spec and tasks call for. Opportunistic refactors, renames,
  formatting churn, and "while I'm here" fixes go into a separate, proposed task.
- No speculative features, flags, or parameters for needs the spec does not state.
- Public interfaces, file layout, and naming of untouched code stay as they are.

**Rationale**: Small, focused diffs are reviewable; mixed diffs hide defects.

### VII. Consistency With the Architecture

- New code MUST follow the layering, folder structure, naming, and patterns recorded in the
  architecture doc and in the ADRs ([ADR_PATH]).
- Domain terms come from the glossary ([GLOSSARY_PATH]) when it exists; code, tests, and specs use the same words.
- A change that needs to break an architectural rule MUST record the reason in the plan's
  Complexity Tracking table, and an ADR if it is hard to reverse.

### VIII. Contracts Between Repos *(multi-repo projects)*

- Every interaction between repos is defined in the plan's Contracts before either side is
  built: operation, auth, request and response fields with types and constraints, error shapes.
- Provider and consumer MUST match the contract exactly. A field, status, or route that exists on
  only one side is a defect. A contract change is made in the plan first, then on both sides in
  the same feature.
- Contracts follow the conventions in the system architecture doc (naming, casing, errors,
  pagination) and are materialised where the project keeps them (schema file, shared types).

**Rationale**: End-to-end features break at the seams between repos, not inside them.

[ADDITIONAL_PRINCIPLES]

## Quality Gates

Commands an agent runs, per repo, before declaring work done. All MUST pass.

[QUALITY_GATE_COMMANDS]

## Project-Specific Rules

[PROJECT_SPECIFIC_RULES]

## Repo-Specific Rules *(multi-repo projects; remove otherwise)*

[REPO_SPECIFIC_RULES]

## Governance

- This constitution overrides conflicting guidance in specs, plans, tasks, and agent defaults.
- Changes reach a remote only with the user's explicit approval: agents never push or open PRs
  on their own.
- Amendments go through `/mix-constitution`, which versions them semantically:
  MAJOR = a principle removed or redefined; MINOR = a principle or section added or materially
  expanded; PATCH = wording and clarifications.
- `/mix-plan` checks every plan against these principles; `/mix-review` checks every diff.
- Recurring review findings are turned into rules (or automated checks) through `/mix-retro`.

**Version**: [CONSTITUTION_VERSION] | **Ratified**: [RATIFICATION_DATE] | **Last Amended**: [LAST_AMENDED_DATE]
