# Design Vocabulary

Use these terms exactly in plans and reviews.

- **Module**: anything with an interface and an implementation — a function, class, package, or
  vertical slice.
- **Interface**: everything a caller must know to use the module correctly: types, but also
  invariants, ordering, error modes, configuration, performance.
- **Depth**: behaviour a caller gets per unit of interface learned. **Deep** = small interface,
  lots hidden. **Shallow** = the interface is nearly as complex as the implementation.
- **Seam**: the place a module's interface lives, where behaviour can be altered or observed
  without editing inside. Tests live at seams.
- **Adapter**: a concrete thing satisfying an interface at a seam (Postgres repo, in-memory fake).

## Principles

- **The deletion test.** Imagine deleting the module. If complexity vanishes, it was a
  pass-through: don't create it. If complexity reappears across callers, it earns its place.
- **The interface is the test surface.** If a test needs to reach past the interface, the module
  is the wrong shape.
- **One adapter is a hypothetical seam; two adapters is a real one.** Add a port/interface only
  when two implementations exist today (typically production + test fake).
- **Accept dependencies, don't create them.** Boundaries (HTTP clients, SDKs, clock) are passed in.
- **Return results rather than mutating.** `calculateDiscount(cart): Discount` over
  `applyDiscount(cart): void`.
- **Make the change easy, then make the easy change.** When existing code fights the feature,
  plan a small prefactor first, as its own task, with no behaviour change.

## Dependency categories

How a module's dependencies are handled at its seam:

1. **In-process** (pure logic, in-memory): test directly, no adapter.
2. **Local-substitutable** (DB with a test instance, in-memory filesystem): test with the stand-in.
3. **Remote but owned** (your own services): a port at the seam, HTTP adapter in production,
   in-memory adapter in tests.
4. **True external** (Stripe, Twilio): injected port, mocked in tests.
