# Testing guidelines

All testing conventions live here. `CODE_GUIDELINES.md` and `WEBAPP_GUIDELINES.md` link here instead of duplicating.

## Core principles (all stacks)

- Treat tests as **first-class**: refactor them like production code; package **by feature** next to or mirroring feature layout.
- Name tests for **behavior** so failures read as documentation (story-style or `should_...`).
- Prefer **integration** over heavy mocking unless volume forces substitutes (real DB / HTTP app where practical).
- Prefer **linear** tests: setup → single act → assertions (optional cleanup); minimal branching in the act; avoid asserting incidental intermediate state.
- For **new behavior**, prefer a test that describes the public outcome; for **bugs**, add a test at the **deepest layer** that still reproduces the bug.
- **Unit tests** target a **unit of behavior**, not every class in isolation. **E2E** stays few and CI-aware.

**DO** — Behavior-named tests; assertions next to the action they validate; explicit setup when it aids readability.

**DON'T** — DSL-heavy layers that hide intent; mocking persistence in integration tests unless the test is about isolation.

When reviewing coverage gaps, use **Code review priorities** in `CODE_GUIDELINES.md`.

---

## Python — GivenPy + PyHamcrest

Prefer **[GivenPy](https://github.com/tadas-subonis/givenpy)** and **PyHamcrest**. GivenPy is a small BDD-shaped layer over pytest or unittest; PyHamcrest keeps assertions composable.

### Dependencies

```text
pip install givenpy PyHamcrest
```

(or declare the same in your project dependency file)

### Shape of a test

Every test should use **given → when → then**:

- **`given([...]) as context`**: list preconditions explicitly; compose from named steps.
- **`when`**: exactly **one** block per test — only the code **under test** (end-user or API client entrypoint). Split if you need more than one act.
- **`then`**: outcomes; prefer PyHamcrest **`assert_that(actual, matcher)`**.

### Setup steps

- Prefer **higher-order functions** that return step closures (e.g. `there_is_external_number(5)` → `def step(context): ...`).
- Use **`lambda_with(open, close)`** (GivenPy) for setup/teardown pairs (connections, temp dirs).
- Reuse steps across files (e.g. `tests/integration/steps_*.py`).

### Naming

- Good: `test_user_should_be_able_to_login`, `test_user_should_not_be_able_to_login_with_invalid_credentials`.
- Avoid: `test_login`, `test_invalid_credentials`.

### Assertions (PyHamcrest)

- Use **`assert_that(actual, matcher)`** consistently.
- **Custom matchers** for domain meaning; extract a **named function** returning a matcher when trees get nested.

**DO** — `given`/`when`/`then`; Hamcrest matchers; reusable steps.

**DON'T** — Multiple `when` blocks per test; business logic inside matchers.

**Assertion order** — Preconditions in `given`; outcomes in `then` in the order they become observable.

---

## TypeScript / Node — HTTP integration (Jest + Supertest or equivalent)

Default to **direct integration style**, not BDD/DSL scaffolding. A test reads like a short API scenario:

1. Create required data  
2. Call the endpoint  
3. Assert HTTP response  
4. Optionally verify persistence via a repository  

**Core rules**

- Plain `describe` / `it`, plain `await`, local variables.
- Put `expect(...)` **close to the action** it validates.
- Setup **explicit in the test body**; duplication is OK when it keeps tests independent.
- **Real repositories** for persistence checks; do not mock them unless the test is about isolation.
- Helpers remove **transport boilerplate only**; if you must read the helper to understand intent, it is **too heavy**.

**Assertion ordering**

1. Status code  
2. Key response body fields  
3. Persistence / repository state  
4. Downstream side effects  

**Scope** — One meaningful scenario per test. Long **flow** tests are OK when behavior is inherently sequential; keep chronological and assert only what belongs to that flow.

**Response shape** — Assert the **live** API shape, not a legacy `{ success, data, error }` envelope the route no longer uses.

**Migration rule** — Prefer new tests in this style; rewrite touched DSL-heavy tests when practical. **Do not** introduce new heavy Given/When/Then scaffolding for Node backend tests.

Example (paths illustrative):

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

### API / HTTP coverage (any backend)

For new or changed behavior, cover at least: happy path; auth / permission failures; important validation failures; not-found and conflict where relevant.

Schema changes **MUST** include migrations (when the stack uses them) and a test or CI step that applies them.

**DO** — `describe`/`it` + `async`/`await`; assert HTTP then storage.

**DON'T** — Frameworks that hide assertions; shared fixtures that obscure the scenario.

---

## Browser E2E (e.g. Playwright)

Write behavior-level coverage **before or alongside** features when possible; lock behavior after implementation.

### Goals

- **Page objects** encapsulate selectors and actions so steps stay stable when markup changes.
- **Step definitions** (if using Cucumber) stay thin: translate Gherkin into page object calls only.

### Suggested stack

- **Playwright** (or equivalent) for automation.
- **Page object** classes per main surface (page, modal, widget).

### Example folder layout

```text
tests/
  features/
    steps/
      checkout.steps.ts
      account.steps.ts
  pages/
    CheckoutPage.ts
    AccountSettingsPage.ts
  support/
    world.ts
    hooks.ts
```

### Example: steps

```typescript
import { Given, When, Then } from "@cucumber/cucumber";
import { CheckoutPage } from "../pages/CheckoutPage";

Given("I open checkout", async function () {
  this.checkout = new CheckoutPage(this.page);
  await this.checkout.open();
});

When("I apply coupon {string}", async function (code: string) {
  await this.checkout.applyCoupon(code);
});

Then("the order summary should show discount", async function () {
  await this.checkout.expectDiscountVisible();
});
```

### Example: page object

```typescript
import { Page, expect } from "@playwright/test";

export class CheckoutPage {
  constructor(private page: Page) {}

  async open() {
    await this.page.goto("/checkout");
  }

  async applyCoupon(code: string) {
    await this.page.getByLabel("Coupon").fill(code);
    await this.page.getByRole("button", { name: "Apply" }).click();
  }

  async expectDiscountVisible() {
    await expect(this.page.getByTestId("discount-row")).toBeVisible();
  }
}
```

### Frontend testing pyramid (default order)

1. **E2E** for real user journeys (Playwright or equivalent).  
2. **UI-layer functional** when full E2E is too slow (Testing Library, RN Testing Library).  
3. **Focused component tests** only for meaningful, hard-to-cover behavior.  
4. **Reducer / store unit tests** only when logic warrants — avoid by default.  

A good frontend test answers: *Can the user complete the flow? Does the right screen state appear? Do important controls behave? Does navigation complete?*

### Page object DO / DON'T

**Good page object** — One screen or clear UI area; user-level actions (`startNewSession()`, `submitFeedback()`); hides locators; `waitForLoaded()` / small user-level assertions; stays small.

**Bad page object** — Raw component internals; business logic or huge mutable context; a getter per element; names like `setStoreStateAndContinue()` or `runScenarioA()`.

Good names: `waitForLoaded()`, `enterFeedback(text)`, `selectArea(name)`, `clickStartExercises()`, `sessionComplete()`.

### Mocking

Mock **boundaries**, not the UI. OK: network/services, storage, AI calls, platform integrations. Avoid mocking components under test, navigation, or interactions you can drive for real.

> Mock what crosses the app boundary, not what defines the user experience.

### Assertions to prefer

- Visibility; important **text**; **enabled/disabled**; **navigation** and completion; **visible errors**.  
- Avoid: internal hooks, private state shape, exact timing, mock call counts (unless the test targets that boundary).

### Test IDs

Stable `data-testid` / `testID` on meaningful controls. **Good:** `start-session-button`, `feedback-screen`, `submit-feedback-button`. **Bad:** `button-1`, `container-left`, `blue-card`.

### Selectors and naming

- Prefer **`data-testid`** (or role/label) over brittle CSS chains.  
- Align feature files with acceptance language from specs.  
- Reuse page objects for shared widgets (nav, tables, modals).  
- Test names describe user-visible behavior (e.g. `user can start a new session`), not `screen works`.

### Anti-patterns

- Reducer-only tests when a screen flow would cover the same logic.  
- Snapshot-heavy dynamic UIs.  
- Page objects that are trivial getters for every element.  
- Large fixture systems that hide the flow.  
- Ceremonial tests (`expect(true).toBeTruthy()`).  
- Proving render only, not meaningful outcome.  

Every test should prove a **user-visible** or **contract-level** outcome.

**DO** — Page objects for selectors/actions; assertions in specs; stable testids.

**DON'T** — E2E asserting global store implementation details; snapshots as default.

**Assertion order** — Arrange UI state → act → assert visibility/text/navigation in order of user perception.

---

## Choosing a style by stack

| Stack | Style |
|-------|--------|
| **Python** | GivenPy + PyHamcrest (`given` / `when` / `then`) |
| **TypeScript / Node** HTTP | Direct integration (`describe` / `it`, local `expect`) |
| **Browser** | Playwright + page objects (+ optional Cucumber steps) |

Shared goals: behavior-named tests, integration over pointless mocks, assertions near the action, no hidden DSL.

## Reference

- [GivenPy](https://github.com/tadas-subonis/givenpy) — `lambda_with`, examples  
- [PyHamcrest](https://pyhamcrest.readthedocs.io/)
