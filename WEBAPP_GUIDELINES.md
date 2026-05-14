# Web app guidelines

Principles below apply to any modern web UI stack. Where examples use **TypeScript**, adapt naming to your language.



---

## Principles

- Prefer **immutable** updates (derive new state instead of mutating shared objects in place).
- Organize code **by feature** (colocate UI, hooks, and feature-specific utilities), not only by technical layer.
- Treat the **HTTP API as a boundary**: map wire formats (DTOs/JSON) into **domain-oriented types** with behavior, not raw shapes scattered through components.

---

## Default stack (team)

- **Next.js (App Router) + React + TypeScript** as the current default.

Rationale in short:

- App Router supports stable URLs and deep links while keeping SPA-style navigation where needed.
- Server routes remain available for auth, licensing, or future SSR/SEO without a separate deployment model.

Notes:

- Prefer **client components** for interactive product UI unless a screen truly benefits from server rendering.
- SSR for marketing or SEO can be added later within the same framework.

If you use another framework, keep the same separation: **routing and transport** vs **domain and UI state**.

### Next.js App Router (when this is your stack)

- Prefer **Server Components** in `app/` by default. Add **`"use client"`** only when the module needs hooks, browser APIs, DOM events, or client-side data libraries.
- **Route-owned blocking work** (first paint cannot proceed without the data): pair **segment `loading.tsx`** with the fetch path, and use **segment `error.tsx`** when failure should replace the page for that route.
- **Post-load** refetch, search, filters, and pagination SHOULD keep loading and error UI **local to the component** (skeleton, inline error + retry), not replace the whole route unless the product demands it.
- Avoid **`useEffect`** for values derivable during render; run user-triggered flows from **event handlers** or **mutation callbacks**.
- When the API client exposes enough detail, surface **auth vs permission vs generic network** errors differently in UI.

---

## Components

Build **reusable** UI pieces (buttons, dialogs, tables, form fields) and compose features from them. Avoid one-off copies of the same markup across features.

---

## Imports

### Application source

- Use **absolute imports** via a single project alias (e.g. `@/` mapped in `tsconfig.json` / bundler config), not long `../../` chains.

```typescript
// Avoid
import { Nav } from '../../../components/Nav';

// Prefer
import { Nav } from '@/components/Nav';
```

- **Do not** include file extensions in application source imports.

```typescript
// Avoid
import { LoginModal } from '@/components/LoginModal.ts';

// Prefer
import { LoginModal } from '@/components/LoginModal';
```

### E2E / BDD support code (e.g. Playwright + Cucumber)

Some runners resolve modules without your app’s path alias. In **step** and **support** files under `tests/`, use **relative imports** and include **`.ts`** extensions if your runner requires explicit ESM paths (see your `ts-node` / Playwright config).

```typescript
// Example: tests/steps/auth.steps.ts
import { LoginPage } from '../pages/LoginPage.ts';
import type { AppWorld } from '../support/world.ts';
```

### Naming (TypeScript / React)

- Feature and non-component files: **`kebab-case`** (e.g. `use-orders-query.ts`, `orders-grid.tsx`—match team convention if different).
- React components: **`PascalCase`**. Hooks: **`use` + name** (`useOrders`, `useOrganizationActions`).
- Import order SHOULD be: **external packages** → **path alias** (`@/...`) → **relative** imports.

---

## Client state and server data

Keep responsibilities explicit:

| Need | Prefer |
|------|--------|
| Data owned by the **server**, shared across screens | A **server-state library** or thin fetch layer with caching, invalidation, and loading/error metadata (pick one convention for the repo). |
| **UI-only** state (modals, toggles, wizard step) | **Local component state** or a small colocated module. |
| State that must be **shareable via URL** | **Route/search params** as the source of truth where possible. |
| **Cross-cutting** client session (e.g. current user id, theme) | A **small dedicated module** (context, store, or equivalent)—avoid growing it into a second backend. |

**Async coordination:** prefer straightforward `async`/`await` and your chosen data layer’s built-in patterns. Introduce heavier stream/reactive tooling only when a feature has clear orchestration or backpressure requirements.

**Do not** couple components to low-level fetch details; keep HTTP and serialization behind hooks or small services so UI stays testable.

### AI providers and other privileged backends

- Frontend code MUST NOT call external AI providers (OpenAI, Anthropic, etc.) or any other API that needs server-only secrets directly. Always go through a **backend endpoint** that the team controls.
- For local development without spending API budget, use a **frontend-local mock** (or a dev backend route) explicitly gated by env flag—do not hard-code "real" provider calls and toggle them with comments.

### Long-running async UX

- Any user action that waits on AI-backed or otherwise slow backend work MUST show a visible **loading, progress, or pending state**. The UI must never appear frozen while a request is in flight.
- For background polling or streamed results, surface partial progress (token streaming, step counters, percent) when available; otherwise show an indeterminate state with a label that hints at what is happening.

### Single API client

- All application API calls SHOULD go through **one shared client module** (base URL, auth headers, errors, case mapping). Do **not** add ad hoc `fetch` helpers or duplicate HTTP clients per feature.

### Server cache / query conventions (TanStack Query, SWR, or equivalent)

- **Cache keys** MUST be built through a **central factory or shared helpers**; do not scatter stringly-typed ad hoc keys.
- **Mutations** MUST invalidate the list/detail keys they affect.
- Queries that need IDs or session context SHOULD use **`enabled`** (or equivalent) so they do not run half-formed.
- **“Load more” / infinite scroll** SHOULD use the library’s infinite-query pattern instead of one-off manual paging when it fits the UX.

### Hooks as the UI-facing API

- Hooks SHOULD return **domain-friendly fields** (`items`, `isLoadingItems`, `error`) instead of leaking raw client objects everywhere, when that improves readability.

---

## Domain objects at the API boundary

Convert API responses into **domain types** (classes or typed records) with **methods** or pure functions that express rules, not only property bags.

### Runtime validation (e.g. Zod, Valibot)

- Keep **schemas next to the feature** that owns the contract.
- Export **schema + inferred type** from the same module; avoid duplicating a parallel `interface` that can drift.
- **Important** API responses SHOULD be parsed/validated through the schema (or shared client) before use in UI logic.

### Example: timestamps from the backend

If the API sends **Unix seconds** (possibly fractional), convert explicitly; do not pass raw numbers straight into `Date` without knowing the unit.

```typescript
// Wrong if `expires` is seconds — yields Invalid Date
const date = new Date(dto.expires);

// Correct: seconds → milliseconds
const seconds = parseFloat(String(dto.expires));
const date = new Date(seconds * 1000);
```

Guardrails for edge values:

```typescript
const MAX_JS_DATE_MS = 8640000000000000;

function parseBackendDate(timestamp: string | number): Date | null {
  const seconds = parseFloat(String(timestamp));
  if (Number.isNaN(seconds)) return null;
  if (seconds * 1000 > MAX_JS_DATE_MS) {
    return new Date(MAX_JS_DATE_MS);
  }
  return new Date(seconds * 1000);
}
```

---

## End-to-end tests (BDD + page objects)

Write behavior-level coverage **before or alongside** features when possible; run them after implementation to lock behavior.

### Goals

- **Page objects** encapsulate selectors and actions so steps and scenarios stay stable when markup changes.
- **Step definitions** stay thin: translate Gherkin (or similar) into page object calls only.

### Suggested stack

- **Playwright** (or equivalent) for browser automation.
- **Page object** classes per main surface (page, modal flow, embedded widget).

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

1. **E2E functional tests** for real user journeys (Playwright or equivalent).
2. **UI-layer functional tests** for screen flows when full E2E is too slow or expensive (e.g. React Native Testing Library, Testing Library).
3. **Focused component tests** only when a component has meaningful, hard-to-cover behavior.
4. **Reducer / store unit tests** only when there is real logic worth isolating—avoid by default.

A frontend test should answer: *can the user complete the flow? does the right screen state appear? do the important controls behave? does navigation move on?* That beats checking props, setter calls, or private component internals.

### Page object DO / DON'T

A good page object:

- represents **one screen** or a clear UI area;
- exposes meaningful user actions (`startNewSession()`, `submitFeedback()`);
- hides locator details and offers `waitForLoaded()` / small user-level assertions;
- stays small.

A bad page object:

- exposes raw component internals;
- holds business logic or large mutable context objects;
- has a method for every getter so the scenario becomes unreadable;
- methods named like `setStoreStateAndContinue()` or `runScenarioA()` (mechanical, not user-level).

Good action names: `waitForLoaded()`, `enterFeedback(text)`, `selectArea(name)`, `clickStartExercises()`, `sessionComplete()`.

### Mocking guidance

Mock **boundaries**, not the UI. Acceptable mocks: network/service calls, storage, AI/OpenAI calls, platform-only integrations. Avoid mocking screen components under test, navigation, or user interactions you can drive directly.

> Rule: mock what crosses the app boundary, not what defines the user experience.

### Assertions to prefer

- Screen / element **visibility**.
- Important **text and content**.
- **Enabled / disabled** affordances.
- **Navigation outcomes** and completion states.
- **Visible error** messages.

Avoid asserting on internal hook calls, private state shape, exact timing, or mock call counts (unless the test is specifically about an integration boundary).

### Test IDs

Use stable `testID` / `data-testid` on **meaningful user-facing controls**. Names should be semantic and stable:

- Good: `start-session-button`, `feedback-screen`, `submit-feedback-button`, `area-option-grammar`, `session-results`.
- Bad: `button-1`, `container-left`, `blue-card`.

### Anti-patterns to avoid

- Reducer-isolated tests when a screen flow would cover the same logic.
- Snapshot-heavy tests for dynamic screens.
- Page objects with trivial getters for every element.
- Large shared fixture systems that hide the flow.
- "Ceremonial" tests: render screen → click button → `expect(true).toBeTruthy()`.
- Tests that only prove a component rendered, without checking meaningful behavior.

Every test should prove a meaningful **user-visible** outcome.

### Stable selectors and naming

- Prefer **`data-testid`** (or role/label) in page objects over brittle CSS chains.
- Map product scenarios from your spec doc to **feature files** and keep naming aligned with acceptance language.
- Reuse page objects for shared widgets (nav, tables, modals).
- Test names describe user-visible behavior, e.g. `user can start a new session`, not `screen works` or `renders correctly`.

Backend and Python integration style live in **`TESTING.md`** and your API test layout; keep browser E2E focused on user-visible behavior.

---

## HTTP / API integration tests (backend / BFF)

Prefer a **small helper** that starts the app or test server and exposes typed `get` / `post` (or your HTTP client), then **plain `describe` / `it`** with linear flow: call → assert status/body → optionally assert persistence via a repository.

Pattern:

- One short **setup** helper per suite file (not a heavy framework).
- **Assertions next to the action** they validate.
- Prefer **real persistence** (or test DB) for integration tests when practical.

Example shape (paths and helpers are illustrative):

```typescript
import { setupTestServer } from "./testServer";
import { OrderRepository } from "@/repositories/OrderRepository";

const { get, post } = setupTestServer();

describe("Orders API", () => {
  it("creates an order and persists it", async () => {
    const created = await post("/api/orders", { sku: "ABC", qty: 1 });
    expect(created.status).toBe(201);
    const id = created.body.id as string;

    const fetched = await get(`/api/orders/${id}`);
    expect(fetched.status).toBe(200);

    const stored = await new OrderRepository().findById(id);
    expect(stored).not.toBeNull();
  });
});
```

Core rules:

- Prefer **plain** `describe` / `it` and **`async`/`await`** with local variables.
- Assert **HTTP result first**, then **storage** or side effects if needed.
- Helpers should remove **transport boilerplate only**, not hide assertions.

---

## Performance and debugging

When the app feels slow:

- Profile **render cost** (React DevTools, profiler) and **network** (waterfall, duplicate fetches).
- Review **bundle size** and code-splitting for large routes.
- Check **caching and request deduplication** for repeated server reads.

Avoid testing **implementation details** of a global store in E2E; assert **user-visible outcomes** and critical API contracts instead.

---

## Decision summary

| Question | Direction |
|----------|-----------|
| Where does server-fetched data live? | In your chosen **server-state/cache** layer with explicit invalidation rules—not copied into many unrelated components. |
| Where does ephemeral UI state live? | **Component state** or a minimal context/store slice colocated with the feature. |
| How do we test user journeys? | **Browser automation** + **page objects**; scenarios in business language. |
| How do we test APIs? | **Integration tests** with real HTTP and, when useful, real DB; small server helper. |
| Bugs reported manually? | Add a **regression test** (E2E or API) when feasible. |

---

## Maintaining this document

Record **repeatable** conventions and lessons (stack choices, testing layout, pitfalls) here so future work stays consistent.

When you fix a production bug, add a **test** when it is practical—functional or BDD—that would have caught it.
