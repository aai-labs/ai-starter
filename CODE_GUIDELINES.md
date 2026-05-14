# Code guidelines

Summarized from internal conventions, from [dev.tasubo.com](https://dev.tasubo.com/) (Tadas Šubonis), the [next-fastapi-boilerplate](https://bitbucket.org/tdisolutions/next-fastapi-boilerplate) agent playbook, and the [owlang-study](https://github.com/tadas-subonis/owlang-study/blob/master/AGENTS.md) software-design ruleset. See **Sources** at the end.

## Rule language (strictness)

- **MUST**: mandatory unless the user explicitly overrides.
- **SHOULD**: strong default; diverge only with a clear reason.
- **MAY**: optional and situational.

## Complexity and cognitive load

Complexity is the enemy. Our main limit is **understanding**, so every decision should reduce cognitive load and make future changes safer.

Watch for these symptoms:

| Symptom | What it looks like |
|---------|--------------------|
| **Change amplification** | A small change touches many files or classes. |
| **High cognitive load** | You must understand too many concepts before editing safely. |
| **Unknown unknowns** | It is unclear *where* to change or *what* might break. |

Two main causes: **dependencies** (modules entangled, nothing readable in isolation) and **obscurity** (important info implicit, scattered, or hidden). Complexity grows incrementally; adopt **zero tolerance** for unnecessary complexity and duplication. Invest roughly **10–20%** of effort into design, refactoring, and cleanup—not only "tests green."

For coding agents: prefer changes that simplify structure and remove duplication. Do not patch locally if a small refactor would clearly improve the design—propose it instead.

## API and platform boundaries

Keep routers thin and move business logic into services.
Use dependency injection, avoid manual wiring in business code.
Preserve async boundaries for IO heavy work.
Keep logging contextual (org_id, resource identifiers).
Never bypass organization scoping.
Use explicit HTTP errors at API boundaries.

## Backend layering (HTTP services)

- **Routes** MUST stay thin: parse input, resolve dependencies, delegate to a service, return mapped responses.
- **Services** MUST own business rules and permission-sensitive orchestration; they SHOULD translate domain failures to HTTP where that is the project convention.
- **Repositories** (or the project’s persistence layer) MUST own queries and persistence mechanics; services MUST NOT embed ad hoc SQL or ORM composition when a repository is the established boundary.
- Reuse the project’s **dependency injection** and shared infrastructure patterns instead of constructing clients ad hoc in handlers.
- **Repository composition over inheritance**: feature repositories MUST NOT extend a shared `BaseRepository`; they SHOULD hold a `BaseRepository` (or equivalent persistence delegate) and forward to it. Shared persistence primitives live in one place (e.g. `shared/persistence`), while each feature owns its repositories within its own folder.

**New domain vertical** (adjust folder names to your repo): define models → repository → service → routes → register router → migration if schema changed → tests (`TESTING.md`).

Example:
```
api/domains/<domain>/
  models.py
  repository.py
  service.py
  routes.py
```  

## Domain and architecture

Use **ubiquitous language**: one name per concept, shared with non-developers where possible.
Prefer **package by feature**, not a single global layer layout; layers only inside features when needed.
Separate **domain** (aggregates, domain services, repositories, domain events) from **infrastructure** (DB, HTTP, UI). Treat “swap MySQL for files / REST for CLI” as a mental check, not a mandate to abstract everything.
**Entities** have identity (typically an ID). Prefer client-generated **UUID/ULID** when they fit your storage and security model.
**Value objects** describe a concept without identity; even with a storage `_id`, the domain meaning can still be a value.
**Aggregates**: enforce invariants inside the aggregate root; load/save through the root; **no object references between different aggregate roots**—link by ID (or an explicit snapshot documented as historical).
**Repositories**: narrow, explicit names (`find_one_by_id`, `save`, …); persist at aggregate root; integration tests prove behavior.
**Application/domain services**: orchestrate processes that do not belong on a single entity. Do not let them become **transactional scripts** that hold all rules while entities are getters/setters (anemic model).
**Factories** only when construction is non-trivial; avoid hiding factories inside repositories.

## HTTP and REST

Resources at stable URIs; nesting reflects ownership (`/users/{id}/orders/{id}`).
Use **GET/POST/PUT-PATCH/DELETE** for their intended semantics; GET must not mutate server state aside from logs.
Prefer **JSON**, **HTTPS**, and simple auth (e.g. Basic with `user_id:api_key`) for internal APIs unless you have a stronger standard.
**Version** under `/api/v1/...` (or a deliberate alternative); prefix `/api` to leave room for non-API routes.
Default to **returning the full resource**; add `fields=` or similar only when measured need; enable compression.
Avoid **breaking** changes: OK to add fields/endpoints/optional query params; avoid removing/renaming fields, URLs, or required params.
Do not put **verbs** in URLs (`/create`, `/delete` as path segments).
**REST is not the domain layer**: decode input, reload authoritative state from the repository, call domain methods that enforce transitions, map errors to HTTP (e.g. 409 for stale/out-of-date).
Use real **HTTP status codes**, not `200` for every outcome. Typical mapping:

| Code | Use |
|------|-----|
| `200` | Successful read or update **with** a response body. |
| `201` | Resource created. |
| `204` | Success **without** a body (e.g. delete); avoid redundant `{"status":"ok"}` when `204` fits. |
| `400` | Business precondition failed (or use `422` if the stack reserves it for schema validation). |
| `401` / `403` | Unauthenticated / unauthorized. |
| `404` | Missing or not visible to the caller. |
| `409` | State conflict or uniqueness violation. |
| `422` | Validation failures when the framework maps request shape errors to it (e.g. FastAPI/Pydantic). |

Richardson maturity **level 2** is enough for most internal APIs; HATEOAS is optional and often not worth the cost.

## API models and persistence

- Keep **persistence models** and **API DTOs** separate; internal fields MUST NOT leak on public responses.
- Name request/response shapes consistently where it helps, e.g. `*Create`, `*Update`, `*Read`, `*Filter`.
- Partial updates SHOULD follow patch semantics (`exclude_unset` or equivalent).
- Mutable collection defaults MUST use factories, not shared mutable instances.

## Tests

Treat tests as **first-class**: refactor them, apply SOLID, remove duplication like production code.
Structure each test: **setup → execution → assertion** (optional cleanup). Prefer **linear** tests: no branches, minimal assertions (often one), no loops; avoid asserting incidental intermediate state.
Prefer **integration tests** with real DB and important libraries over heavy mocking, unless volume forces an in-memory substitute.
**Unit tests** target a **unit of behavior**, not every class in isolation.
**E2E** few and slow-aware; too many make CI brittle.
For **new behavior**, write a test that describes the public outcome first; for **bugs**, add a test at the **deepest layer** that still reproduces the bug.
Name tests for **behavior** (e.g. story-style or `should_...`) so failures read as documentation.
UI: invest in testability early for non-trivial UIs; otherwise cost hits later.

**Python:** Prefer **[GivenPy](https://github.com/tadas-subonis/givenpy)** with **PyHamcrest** for structure and assertions (`pip install givenpy PyHamcrest`); works with pytest or unittest. Use `given([...]) as context` for explicit setup steps (compose and reuse steps; prefer small higher-order step factories for parameters); a single `when` block that only exercises the code under test (user-facing entrypoint); `then` for expectations readable without comments. Use `lambda_with` (or equivalent) for setup/teardown pairs. See `TESTING.md`.

## Immutability and functional style

Prefer **immutable** data and “transform and return” over mutating inputs; reduces surprises under concurrency and unclear collaborators.
Combine **OOP for domain vocabulary** with **functional transitions**: methods return new state (e.g. immutable records + `replace` / `with*` wrapped in domain-named methods).
In data/ETL-style code, prefer **linear pipelines** (`map`/`filter`/`reduce`) over deep nested calls; keep steps **loosely coupled** so steps can be added or dropped without editing hidden call chains.
When arity grows, use small **types** (dataclasses/value objects) instead of long tuples and `starmap` soup.

## Object-oriented design

Use **encapsulation** and **scope**: private fields; methods that use instance state belong on that type; `static` “services” that only take arguments are a smell—consider **move method**.
Let types **communicate intent** (e.g. `order.getTotalPrice()` on `Order`, not `OrderManager.getTotalPrice(order)`).
Watch for **Manager/Util/Helper** dumping grounds; move behavior to the domain type unless wrapping third-party APIs.
Prefer **composition over inheritance**; deep inheritance trees are a maintenance risk—exceptions like Null Object or small polymorphic families, often behind factories.
Avoid deep `extends` chains and "god" base classes; aim for small composable objects with single responsibilities.
Separate **domain** from **presentation** and **infrastructure** modules where feasible (onion-style boundaries and DI help).
If there are is excessive amount of if checks then it probably you should be using Strategy Pattern (OOP or Functional version using functions)

### Deep modules

Prefer **deep** modules: a small public interface backed by rich internal behavior. Avoid shallow wrapper classes that mirror DB tables or only forward calls. Each module owns its data and invariants; do not leak internal formats or external API specifics across module boundaries.

### Method extraction

Avoid **private "helper" methods** as the default tool for splitting up logic. Instead:

- Extract a small **public class or service** when the helper carries real responsibility (it can then be tested and reused on its own).
- Use **locally scoped functions** inside a method when the helper is purely a readability aid and would be invisible outside that method.

Either keeps behavior explicit and testable; a forest of private helpers usually hides design that should become its own object.

### Coupling and the Law of Demeter

A method should typically call only:

- itself,
- its parameters,
- objects it creates,
- its direct collaborators (its own fields).

Avoid message chains like `a.getB().getC().getD().doSomething()`. Prefer a single intention-revealing method on the receiver (`order.shippingCity()` over `order.getUser().getProfile().getAddress().getCity()`).

Coupling smells to fix:

- **Feature envy**: a method uses more of another class's data than its own → **move function**.
- **Message chains** → **hide delegate**.
- **Middle man**: a class mostly forwards calls → remove it or give it real behavior.
- **Shotgun surgery**: one logical change requires edits across many classes → consolidate the responsibility.

Orthogonality goal: changing one concept should require touching **one** module.

## Functions and parameters

A function SHOULD do **one thing** at one level of abstraction. If you need comments to separate sections, **extract a function** (or class).

Parameter count guidance:

| Count | Quality |
|-------|---------|
| 0 | Best |
| 1–2 | Good |
| 3 | Acceptable |
| 4+ | Avoid |

Fixes when arity grows:

- **Introduce a parameter object** for related fields.
- **Preserve whole object**: pass the entity/value object instead of its pieces.
- **Replace parameter with query**: derive the value inside from existing data.

Anti-patterns:

- **Flag arguments** (`doThing(isFast)`): split into `doThingFast` / `doThingSafe`.
- **Output arguments**: prefer return values or methods on the receiver.
- **Pass-through methods**: if a class mostly forwards, simplify or remove it.
- **Dead functions**: delete them.

## Naming

Use **ubiquitous language**; the name should let a reader guess purpose without reading the implementation. Reflect side effects (`getOrCreateUser`, `refreshCache`), not only outcomes. Longer scope → more descriptive names. Avoid vague names: `data`, `result`, `temp`, `Manager`, `Helper`.

If naming is hard, the design is probably fuzzy—fix the design first.

### Comments and documentation

Prefer **clear code** over comments. Use comments to explain **why** and non-obvious invariants, trade-offs, or contracts; do not restate **what** the code is doing. Delete commented-out legacy code and outdated doc blocks.

## Control flow

Prefer **flat, explicit pipelines** over nested `if`/`else` chains:

```typescript
function processOrder(orderId: string) {
  const order    = loadOrder(orderId);
  const ready    = ensureReadyForProcessing(order);
  const paid     = chargeOrder(ready);
  const notified = notifyCustomer(paid);
  saveOrder(notified);
}
```

Each step has one responsibility; the stack stays shallow; steps are easy to test or reorder.

Other clarity techniques:

- Repeated `if`/`switch` on the same concept → use **types/polymorphism** (one factory, then call methods).
- **Decompose conditionals** into named predicates (`order.isShippable()` over inline boolean salad).
- **Guard clauses** (early `return` / `throw`) keep nesting shallow.
- Avoid double negatives.

## Parameters, validation, and nulls

**Fail fast** at boundaries (controllers, facades), but avoid repeating validation at every call: introduce **value objects** / validated DTOs constructed via factories so downstream code receives only valid types.
Be cautious with framework-bound “beans” that can exist in an invalid state; prefer explicit construction/validation paths.
Avoid **null** in your own APIs: use **Optional**, empty collections, or **Null Object** where appropriate.

### Parse, don't validate

Do not sprinkle ad hoc `validate*` functions across the call chain. Instead, **parse** raw input **into a domain type** at the boundary; failing the parse *is* the validation step. Once a `BookingId`, `Email`, or `OrderDraft` exists, downstream code can rely on it being **valid by construction**. This removes duplicated checks and prevents "valid in some layers, not others" bugs.

## Error handling

- Where possible, **define errors out of existence** by changing semantics (e.g. `unset(key)` is a no-op when the key is missing; prefer idempotent operations).
- Handle low-level issues near the source (retries, backoff, fallback) rather than at every call site.
- Use **assertions** for true invariants ("should never happen"); use **exceptions** for genuinely exceptional conditions, not normal control flow.
- Keep **reads vs writes** separate where practical (query vs modifier).

## Time and environment dependencies

If `now()` or similar is hard to test, you are missing a concept: inject a **Clock** (or language equivalent) instead of calling `new Date()` / `Instant.now()` directly in domain code.

## Events and integration

Use an **event bus** when subsystems should stay **loosely coupled**, the publisher should not block on slow handlers, outcomes are “fire and forget” from the publisher’s perspective, or **multiple** reactions are needed.
Mind **listener lifecycle** (memory leaks from strong references); unsubscribe or use weak subscriptions deliberately.
Put **shared event types** in a focused module or package when they cross features.

## Distributed and collaborative state (advanced)

When hiding sync/replication behind familiar collections, plan for **deltas**, **resync**, **concurrency**, and possibly **vector clocks** / eventual consistency patterns—do not pretend local invariants hold globally without a model.

## Working with AI on code and design

Do not ship **vague** one-shot prompts or paste assignments blindly; define what “good” and “bad” look like, what is unique to your system, and the **one thing** that must be correct.
Prefer **one task per prompt**, then chain 2–4 focused steps rather than one mega-prompt.
Iterate: critique first drafts for specificity, numbers, format, and skeptic objections; **stress-test** the result.
Give **rails**: templates, checklists, examples, constraints; ban “AI voice” filler if the artifact is human-facing.
Save **what worked**: exact prompts, model choice, context that helped, and failures—build a small playbook.

## Problem decomposition (e.g. interviews, hard bugs)

Understand the task fully before coding; identify pattern (divide & conquer, DP, data structure mapping, brute force then refine); watch **edge cases** and numeric overflow; use the platform’s library types; test with at least two contrasting cases.

## Refactoring discipline

When to refactor: duplication, non-orthogonal design (one change ripples everywhere), the domain understanding has changed, or the code is hard to explain. How:

1. Do **not mix** a big refactor with a new feature in the same change.
2. Make sure tests (or at minimum a manual smoke check) cover the behavior you are about to move.
3. Take **small, reversible steps**; run tests after each step.
4. Stop and re-align if the plan changes mid-flight.

"Design it twice": seriously consider at least two designs before committing to one for non-trivial work.

## Code review priorities

When reviewing a change, weigh roughly in this order:

1. Correctness and regressions.
2. Data contracts and schema safety (API and clients).
3. Cache keys and invalidation for server-fetched data (when applicable).
4. Auth and permission behavior.
5. Loading and async UX (when applicable).
6. Test coverage gaps.

Do not lead with style-only feedback unless it affects correctness or maintainability.

## Definition of done

- Behavior covers happy path and important edge cases.
- Validation and authorization are correct for touched surfaces.
- Tests for changed behavior are added or updated and passing.
- Lint and type checks pass for touched areas.
- Migrations are included when the database schema changes.
- No unrelated refactors or formatting churn.

## Red flags checklist

If several boxes apply to a change, consider a small focused refactor before merging:

- [ ] The module or class is hard to describe in one sentence.
- [ ] A "shallow" module: the interface is almost as complex as the implementation.
- [ ] A deep inheritance chain (`A → B → C → D`) with no strong justification.
- [ ] Complex nested workflows where a flat pipeline would do.
- [ ] The same domain rule lives in several places.
- [ ] A domain term has different meanings in different modules.
- [ ] Aggregate roots hold direct references to other aggregate roots.
- [ ] Entities are just fields + getters/setters (anemic model).
- [ ] Business rules implemented in HTTP controllers instead of the domain.
- [ ] REST URLs contain verbs (`/create`, `/delete`).
- [ ] API changes break clients without a new version.
- [ ] Large classes or long functions mixing abstraction levels.
- [ ] Frequent flag arguments or long parameter lists.
- [ ] Message chains (`a.b().c().d()`) or "middle man" classes.
- [ ] Shared mutable state scattered across files.
- [ ] Comments explaining **what** instead of **why**.
- [ ] Logic that is hard to test without going through HTTP or the DB.
