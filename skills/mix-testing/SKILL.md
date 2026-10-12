---
name: mix-testing
description: Reference for writing tests worth keeping and pruning the rest. Use when choosing test seams, writing tests test-first (TDD, red-green), deciding what to mock, or auditing a change for redundant, tautological, or implementation-coupled tests.
---

# Testing

Tests verify **behaviour through public interfaces**. Code can change entirely; tests shouldn't.
A good test reads like a specification ("user can check out with a valid cart") and survives
refactors because it doesn't care about internal structure. Examples: [EXAMPLES.md](EXAMPLES.md).

Read the test section of the repo's architecture doc (path from `mix-scope`) and the golden
test files it lists first: new tests copy the repo's runner, location, naming, fixtures, and helpers.

## Seams

A **seam** is the public boundary a test observes behaviour at, without reaching inside.

- Tests go only at **agreed seams**, chosen in `/mix-plan` and confirmed by the user. Proposing a
  seam: one line on what it catches and what it misses.
- Prefer the **highest** seam that can observe the behaviour, and the fewest seams overall. An
  existing seam beats a new one.
- One behaviour, one test, at one seam. If an integration test proves it, no unit test repeats it.
- Unit tests are for logic dense enough to deserve isolation: calculations, parsers, state
  machines, branching rules.

## Mocking

Mock only at **system boundaries**: external APIs, third-party services, time, randomness, and
sometimes the database or filesystem (prefer a real test DB or in-memory stand-in when the repo
has one). Your own modules and internal collaborators are never mocked. Design boundaries for
injection: pass the client in rather than constructing it inside.

## Anti-patterns

- **Implementation-coupled**: mocks internal collaborators, tests private methods, asserts call
  counts or order, or verifies through a side channel (querying the DB instead of the interface).
  The tell: it breaks on a refactor when behaviour hasn't changed.
- **Tautological**: the expected value is recomputed the way the code computes it, or a constant
  is asserted equal to itself. It passes by construction. Expected values come from an
  independent source: a literal, a worked example, the spec.
- **Redundant**: asserts what another test in the suite already proves, at the same or a higher
  seam. Includes the same scenario re-tested at unit, integration, and e2e levels.
- **Trivial**: tests the language, the framework, a getter, a type, a constant, or that a
  component "renders" with no behavioural assertion.
- **Copy-paste variants**: several tests differing only in input data. Merge into one
  table-driven test (`it.each`, parametrize).
- **Horizontal slicing**: writing all tests first, then all code. Work in vertical slices instead.

## The TDD loop

When building test-first:

- **Red before green.** One failing test at an agreed seam, then only the code to pass it.
- **One slice at a time.** Each test is a tracer bullet: the next one responds to what the last
  cycle taught you. No speculative tests for behaviour not yet specified.
- Run the single test file each cycle; the whole suite once at the end.
- Refactoring is not part of the loop; it belongs to the review stage.

## Pruning pass

Run after implementation, over every test the change added or modified. For each test, answer:

1. Which spec behaviour (FR / acceptance scenario) does it prove? None → delete.
2. Does another test already prove it at the same or a higher seam? Yes → delete the lower one.
3. Would it fail if the behaviour broke? Would it **stay green** through a behaviour-preserving
   refactor? If not both → rewrite against the interface, or delete.
4. Is the expected value independent of the implementation? No → replace with a literal.
5. Does it differ from a sibling only in data? Yes → merge into a table-driven test.

Then run the suite, confirm it is green, and report: tests added, deleted, merged, rewritten, and
which spec behaviours each remaining test covers. Coverage of a requirement matters; raw test
count does not.
