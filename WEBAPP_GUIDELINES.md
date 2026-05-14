# Web app guidelines

Principles apply to any modern web UI. TypeScript examples — adapt naming to your stack.

## Project-defining frontend rules (read first)

- **Secrets and AI** — Frontend **MUST NOT** call external AI providers (OpenAI, Anthropic, …) or any API that needs **server-only** secrets. Use a **backend** endpoint the team controls. For dev without API spend, use a **mock** or dev route behind an **env flag** — not commented-out real calls.
- **Long-running async** — Any action waiting on AI or slow backends **MUST** show **loading, progress, or pending** state; the UI must not look frozen. For polling/streams, show partial progress when available; otherwise indeterminate + explanatory label.
- **Single API client** — All app API calls **SHOULD** go through **one shared client** (base URL, auth, errors, case mapping). No ad hoc `fetch` per feature.
- **Server cache / query** (TanStack Query, SWR, …) — **Cache keys** **MUST** come from a **central factory or helpers** (no scattered stringly keys). **Mutations** **MUST** invalidate affected list/detail keys. Queries needing IDs/session **SHOULD** use **`enabled`** so they do not run half-formed. **Infinite scroll** **SHOULD** use the library’s infinite-query pattern when it fits.
- **Hooks** — **SHOULD** return **domain-friendly** fields (`items`, `isLoadingItems`, `error`) instead of leaking raw client objects everywhere when it helps readability.
- **Timestamps** — If the API sends **Unix seconds**, convert explicitly (`seconds * 1000` for `Date`); do not assume unit. Example:

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

## Stack and structure (defaults)

- **Default stack:** **Next.js (App Router) + React + TypeScript** — stable URLs / deep links, server routes for auth/licensing/SSR without a separate deploy model.
- Prefer **client components** for interactive product UI unless a screen truly benefits from SSR; marketing/SEO SSR can follow later.
- Other frameworks: keep **routing/transport** separate from **domain and UI state**.
- **Immutable** updates; organize **by feature** (colocate UI, hooks, feature utils); **HTTP API as a boundary** — map DTOs/JSON to **domain-oriented types**, not raw shapes in components.

### Next.js App Router (when this is your stack)

- **Server Components** in `app/` by default; **`"use client"`** only for hooks, browser APIs, DOM events, or client data libraries.
- **Route-owned blocking data** — pair **`loading.tsx`** with the fetch path; **`error.tsx`** when failure should replace the route.
- **Post-load** refetch/search/filters/pagination — keep loading/error **local** (skeleton, inline retry) unless product requires full-route error.
- Avoid **`useEffect`** for values derivable at render time; drive flows from **handlers** or **mutation callbacks**.
- When the client exposes detail, distinguish **auth vs permission vs network** errors in UI.

## Imports

**Application source** — Single alias (e.g. `@/` in `tsconfig` / bundler); **no** file extensions in imports.

```typescript
// Avoid
import { Nav } from '../../../components/Nav';
import { LoginModal } from '@/components/LoginModal.ts';

// Prefer
import { Nav } from '@/components/Nav';
import { LoginModal } from '@/components/LoginModal';
```

**E2E / BDD** (`tests/` steps, support) — Some runners lack the app alias; use **relative** imports and **`.ts`** extensions if ESM requires them (see `ts-node` / Playwright config).

```typescript
import { LoginPage } from '../pages/LoginPage.ts';
import type { AppWorld } from '../support/world.ts';
```

### Naming (TypeScript / React)

- Non-component files: **`kebab-case`**. Components: **`PascalCase`**. Hooks: **`use` + name**.
- Import order **SHOULD**: external packages → `@/...` → relative.

## Client state and server data

| Need | Prefer |
|------|--------|
| Server-owned data across screens | **Server-state library** or thin fetch layer with cache, invalidation, loading/error (one repo convention) |
| UI-only (modals, wizard step) | **Local state** or small colocated module |
| Shareable via URL | **Route/search params** as source of truth |
| Cross-cutting session (user id, theme) | **Small dedicated module** — do not grow into a second backend |

**Async** — Prefer plain `async`/`await` and the data layer’s patterns; heavier reactive/stream tooling only with clear orchestration/backpressure needs.

**Do not** couple components to raw fetch; keep HTTP/serialization in hooks or small services so UI stays testable.

## Domain objects at the API boundary

Convert responses into **domain types** (classes or typed records) with **methods** or pure functions for rules, not property-only bags.

### Runtime validation (Zod, Valibot, …)

- Schemas **next to the owning feature**.
- Export **schema + inferred type** together; avoid a parallel `interface` that drifts.
- Important responses **SHOULD** be parsed/validated before UI business logic runs.

## Performance and debugging

- Profile **render** (React DevTools) and **network** (waterfall, duplicate fetches).  
- **Bundle size** and code-splitting for heavy routes.  
- **Caching** and deduplication for repeated reads.  

In automated tests, assert **user-visible outcomes** and critical API contracts — not global store implementation details. E2E, API integration, and Python style: **`TESTING.md`**.

## Decision summary

| Question | Direction |
|----------|-----------|
| Where does server-fetched data live? | **Server-state/cache** layer with explicit invalidation — not copied everywhere |
| Where does ephemeral UI state live? | **Component** or minimal colocated context/store |
| How do we test user journeys? | **Browser automation** + page objects; business-language scenarios |
| How do we test APIs? | **HTTP integration** tests; real DB when useful; small server helper |
| Bugs found manually? | **Regression test** (E2E or API) when feasible |

## Maintaining conventions

Record repeatable front-end lessons here or in `docs/`. For **testing** layout, stacks, and examples, use **`TESTING.md`** only — do not duplicate E2E or HTTP test sections in this file.
