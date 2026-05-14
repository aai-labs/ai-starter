# Changelog

## [Unreleased]

### Changed

- Restructured guidelines for agent-first use: **AGENTS.md** now leads with a work loop, a **what goes where** table, and explicit **Always / Ask first / Never** guardrails.
- **CODE_GUIDELINES.md**: added **Project-defining rules** at the top; compressed generic design content into **Design heuristics**; removed duplicate testing prose, meta “working with AI” / interview sections, and advanced distributed-state notes; tests fully delegated to **TESTING.md**.
- **WEBAPP_GUIDELINES.md**: added **Project-defining frontend rules** at the top; merged principles and stack notes; removed duplicate E2E and HTTP integration sections (now only in **TESTING.md**).
- **TESTING.md**: single source for core principles, Python (GivenPy), Node/TS HTTP integration, and browser E2E (page objects, pyramid, selectors) with per-stack **DO / DON'T** checklists.
- **README.md**: updated file descriptions and import guidance to match the split.
