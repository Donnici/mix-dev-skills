# Test Examples

TypeScript for illustration; the same shapes apply in any language.

## Behaviour vs implementation

```typescript
// Keep: observable behaviour through the interface
test("user can check out with a valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});

// Delete: coupled to an internal collaborator
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

## Verify through the interface, not a side channel

```typescript
// Rewrite: bypasses the interface
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// Keep
test("created user can be retrieved", async () => {
  const user = await createUser({ name: "Alice" });
  expect((await getUser(user.id)).name).toBe("Alice");
});
```

## Tautological

```typescript
// Rewrite: expected value recomputed like the code does it
test("calculateTotal sums line items", () => {
  const items = [{ price: 10 }, { price: 5 }];
  expect(calculateTotal(items)).toBe(items.reduce((s, i) => s + i.price, 0));
});

// Keep
test("calculateTotal sums line items", () => {
  expect(calculateTotal([{ price: 10 }, { price: 5 }])).toBe(15);
});
```

## Copy-paste variants → one table

```typescript
// Merge these three...
test("rejects empty email", () => expect(isValidEmail("")).toBe(false));
test("rejects missing @", () => expect(isValidEmail("a.com")).toBe(false));
test("accepts normal email", () => expect(isValidEmail("a@b.com")).toBe(true));

// ...into one
test.each([
  ["", false],
  ["a.com", false],
  ["a@b.com", true],
])("isValidEmail(%j) is %s", (input, expected) => {
  expect(isValidEmail(input)).toBe(expected);
});
```

## Redundant across levels

An e2e test already proves "submitting the form creates the order and shows the confirmation".
A component test asserting the confirmation text appears after submit, with the API mocked, adds
nothing: delete it. Keep the component test only if it covers a branch the e2e does not (e.g. the
validation error state).

## Trivial

```typescript
// Delete: tests the framework / a constant
test("renders", () => { render(<Button />); });
test("DEFAULT_PAGE_SIZE is 20", () => expect(DEFAULT_PAGE_SIZE).toBe(20));
```

## Injecting boundaries

```typescript
// Testable: the boundary is passed in
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// Hard to test: constructs its own boundary
function processPayment(order) {
  return new StripeClient(process.env.STRIPE_KEY).charge(order.total);
}
```

Prefer specific boundary functions (`api.getUser`, `api.createOrder`) over one generic
`api.fetch(endpoint)`: each mock returns one shape and needs no conditional logic.
