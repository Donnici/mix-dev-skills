# Untangle: [TARGET AS A SHORT TITLE]

**Untangle directory**: `[specs]/[###-untangle-name]/` | **Created**: [DATE]

**Target**: [the whole project | an area | a concern] · **Repos**: [repos in scope]

## Context

[Why now: the changes that keep costing too much, the bugs that keep coming back, the area
agents keep getting wrong.]

## Map

[Per repo: hotspots (most changed, most imported), import cycles, top co-change pairs. Name the
script in `scratch/` that regenerates each.]

## Problems

[Every finding, one line each: `<repo>:<path>:<line>` — what is there — why it is a problem.
Grouped by category: Hidden links, Needless links, Surplus, Special cases. Special cases counted
per repo.]

## Fixes

[Each fix above the problems it solves. Per fix: repos, risk, how behaviour stays the same.]

Example:

- Make the general `Dialog` give focus back to whatever had it before it opened, so the wait and
  the flag can both go. Repos: web. Risk: low. Verified by: `Dialog.test.tsx` focus case, added
  first.
  - `web:ui/LogoutDialog.tsx:30` waits 100ms after closing and hopes the input can take focus.
  - `web:ui/SettingsDialog.tsx:61` sets a global `skipRefocus` flag to stop the logout dialog
    from moving focus.
- Define a `PaymentProvider` interface that Stripe and PayPal both implement, so checkout and
  refunds no longer know which one they use. Repos: api. Risk: medium. Verified by: the checkout
  and refund integration tests.
  - `api:checkout/submit.ts:9` depends directly on `payments/stripe.ts`.
  - `api:refunds/refund.ts:22` wraps every Stripe call in `if (order.provider === "paypal")`.

## Accepted

- [Problem] → [why it stays]

## Slices

| # | Fix | Repos | After | Size |
|---|-----|-------|-------|------|
| 1 | | | — | quick / story |

## Next Step

[`/mix-specify --quick` from this untangle, one story per slice | `/mix-quick-implement` for
slice N]
