# Testing guidelines

For **Python**, prefer **[GivenPy](https://github.com/tadas-subonis/givenpy)** and **PyHamcrest**. GivenPy is a small BDD-shaped layer over any runner (pytest, unittest); PyHamcrest keeps assertions readable and composable.

## Dependencies

```text
pip install givenpy PyHamcrest
```

(or declare the same in your project dependency file)

## Shape of a test

Every test should use **given → when → then**:

- **`given([...]) as context`**: list every precondition explicitly. Keep steps small; compose larger scenarios from named steps (and “master” steps that call others).
- **`when`**: exactly **one** block per test. If you need more than one, split into more tests. Put only the code that is **under test**—usually the act from an end-user or API client perspective.
- **`then`**: outcomes and postconditions. Prefer PyHamcrest’s `assert_that` over raw `assert` for clarity.

## Setup steps

- Prefer **higher-order functions** that return a step closure so steps stay **configurable** (e.g. `there_is_external_number(5)` returning `def step(context): ...`).
- Use **`lambda_with(open, close)`** (from GivenPy) when a step must **clean up** after the context exits (connections, temp dirs, etc.).
- Reuse steps across files (e.g. `tests/integration/steps_*.py`) so `given` blocks read like a scenario outline.

## Naming

- Test names describe **behavior** and expectations at a glance, e.g. `test_user_should_be_able_to_login` or `test_user_should_not_be_able_to_login_with_invalid_credentials`.
- Avoid vague names like `test_login` or `test_invalid_credentials`.

## Assertions (PyHamcrest)

- Use **`assert_that(actual, matcher)`** consistently.
- Introduce **custom matchers** when they carry domain meaning.
- If a matcher tree gets nested or hard to read, extract a **named function** that returns the matcher (named after the behavior, not the implementation).

## Fit with the rest of `CODE_GUIDELINES.md`

- Tests remain **first-class**: refactor steps and matchers like production code; package tests **by feature** next to or mirroring the feature layout.
- Favor **integration tests** hitting a real DB or HTTP app where practical; use GivenPy’s `given` to spin up app, DB, auth, and clients the same way the README’s larger examples do.
- **Linear** tests: no unnecessary branching in `when`/`then`; keep `when` thin so failures localize to behavior.

## API / HTTP tests (Python or other backends)

For new or changed behavior, cover at least:

- Happy path
- Auth / permission failures
- Important validation failures
- Not-found and conflict responses where relevant

Schema changes MUST include migration files (when the stack uses migrations) and a test or CI step that applies them.

### TypeScript / Node HTTP suites (Jest + Supertest or equivalent)

Default to a **direct integration-test style**, not BDD/DSL scaffolding. A test should read like a short executable API scenario:

1. create the required data;
2. call the endpoint;
3. assert the HTTP response;
4. optionally verify persistence or side effects via a repository.

The test SHOULD be understandable without reading custom DSLs, composed fixtures, or multiple helper layers.

```ts
import { setupTestServer } from "./testServer";
import { UserRepository } from "@/users/UserRepository";

const { get, post } = setupTestServer();

describe("Users API", () => {
  it("creates a user and persists it", async () => {
    const created = await post("/api/users", {
      username: "anna",
      email: "anna@example.com",
    });

    expect(created.status).toBe(201);
    const userId = created.body.id as string;

    const stored = await new UserRepository().findById(userId);
    expect(stored).not.toBeNull();
  });
});
```

**Core rules**

- Prefer plain `describe` / `it`, plain `await`, and local variables.
- Put `expect(...)` **close to the action it validates**.
- Keep setup **explicit inside the test body**; duplication is acceptable when it makes each test independent and readable.
- Use **real repositories** for persistence checks; do not mock them in integration tests unless the test is specifically about isolation.
- Helpers may remove **transport boilerplate only**; if reading the helper is required to understand the test intent, the helper is **too heavy**.

**Assertion ordering**

1. status code;
2. key response body fields;
3. persistence / repository state;
4. downstream side effects.

**Scope of a single test**

One meaningful scenario per test (`creates a user`, `starts a session with feedback`, `authenticates and returns token with user`). Long **flow tests** are OK when the behavior is inherently sequential (e.g. session start → activate → exercise → submit → complete); keep the flow chronological and assert only behavior that belongs to that flow.

**Response shape**

Assert against the **current live API shape**, not a legacy `{ success, data, error }` envelope that the route no longer uses.

**Migration rule**

When touching backend tests, prefer adding new tests in this direct style; rewrite touched DSL-heavy tests when practical instead of extending the older pattern. Do not introduce new heavy Given/When/Then scaffolding for new Node backend tests.

### Choosing a style by stack

- **TypeScript / Node** backend HTTP tests: the **direct integration style** above.
- **Python** tests: **GivenPy + PyHamcrest** as in the earlier sections (the `given / when / then` block pattern is the project default there).

Both stacks share the same goals: behavior-named tests, integration over heavy mocking, assertions near the action, no DSL wrappers that hide intent.

## Browser E2E (e.g. Playwright)

- Non-trivial UI regressions SHOULD get or update E2E coverage.
- **Selectors and actions** live in **page objects** (or equivalent).
- **Network or auth mocks** live in **shared test support** modules.
- **Assertions** stay in **spec** files so failures read as product behavior.

When reviewing whether tests are enough, use the priority list in `CODE_GUIDELINES.md` (**Code review priorities**).

## Reference

- [GivenPy on GitHub](https://github.com/tadas-subonis/givenpy) — examples, `lambda_with`, and project guidelines.
- [PyHamcrest](https://pyhamcrest.readthedocs.io/) — built-in matchers and custom matcher patterns.
