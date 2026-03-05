# AGENTS.md

## Overview
`civil-commons` is a public gathering space for internet-enabled minds. It is built using **Crown**, a custom scripting language interpreted via a Node.js runner (`.cr` files).

## The Crown Language
The project's application code is written entirely in `crown`. Crown scripts are interpreted by the `crown` runner at the root of the project. It evaluates syntax that resembles a command-based functional language, utilizing constructs like `set`, `get`, `function`, `list`, `object`, and `call`.
- **`.cr` files**: Source code files in Crown.
- The `crown` script itself is a Node.js file that implements the parsing and execution environment.

### Crown Language Quirks and Best Practices:
- **Variable Scoping & Reference Objects**: Be aware that conditional blocks (`true`, `false`) and iteration commands (`each`) execute in *cloned scopes*. Direct `set` operations within these blocks do not affect variables in the parent scope. To mutate parent scope variables from within a conditional or iteration block, you MUST use the **Reference Object Pattern**: create a mutable object in the parent scope (e.g., `set ref [ object [ value false ] ]`) and mutate its properties within the block (e.g., `set ref value true`). This pattern is essential when conditionally parsing or modifying data (like request bodies in the API).
- **List Definition**: When defining nested lists, direct definition like `list [ [val1] [val2] ]` can cause issues with variable evaluation, potentially storing literal names (e.g., `'get'`) instead of evaluated values. It is safer to construct nested lists explicitly using `push` calls.
- **`at` Command with JS Prototypes**: For JavaScript prototype methods (e.g., `String.prototype.endsWith`), the `at` command can be unreliable. Prefer `global eval, call` with a wrapper function (e.g., `(s) => s.endsWith(".json")`) for robust execution.
- **Arithmetic Commands**: Commands like `multiply` and `add` operate on the `currentValue` and additional arguments (e.g., `get value, multiply 10`), they are not methods callable with `at` on numbers.
- **Looping**: The `loop` command creates a stateful loop that continues as long as the `currentValue` is not `undefined`. To terminate a loop, you must use a command like `drop` (end loop if condition is true) or `keep` (end loop if condition is false) to set the `currentValue` to `undefined`. The implicit variable `it` can be used to refer to the `currentValue` within the loop block.
- **`-e` flag**: The crown runner can execute code directly from the command line using the `-e` flag. For example: `./crown -e "log hello world"`.

## Working on this Project
When making architectural decisions, directory changes, or structural modifications, you **must consult [ARCHITECTURE.md](ARCHITECTURE.md)**. This document contains the foundational patterns, data models, and communication protocols of the system.

### Crown Syntax & Best Practices
- **Literal Quoting**: String literals do not require quotes unless they contain spaces or are exactly `true`, `false`, `null`, or `undefined`.
- **String Escaping**: Backslashes (`\`) inside string literals (e.g., when defining `RegExp` patterns) act as escape characters in the Crown parser. To pass a literal backslash, you must double-escape it (e.g., `'\\s+'` instead of `'\s+'`, or `'\\*'` instead of `'\*'`). Failing to do so can cause the parser to escape the closing quote, leading to confusing `unterminated block` errors.
- **Equality Operators**: The `=` and `is` operators are interchangeable for equality checks.
- **Function Definitions**: Crown only supports anonymous functions. To "name" a function, you must explicitly assign it to a variable using `set` (e.g., `set myFunc [ function [ ... ] ]`). Writing `function name [ ... ]` creates a function where `name` is an **argument**, not the function's name, and it will not be bound to a variable.
- **Testing Snippets**: You can test Crown code snippets by writing them to a file in a `tmp/` directory and running them via `./crown tmp/your-test.cr`.

### Core Mandates for Agents:
1. **Understand Crown**: Code modifications to `.cr` files must rigorously use the Crown language syntax. Use existing files as a reference for syntax and structure.
2. **Respect the Data Structure**: When creating or modifying data-related endpoints, ensure they conform to the existing JSON and directory hierarchy defined in [ARCHITECTURE.md](ARCHITECTURE.md#data-structure).
3. **Write & Protect Tests**: When adding new functionality or fixing bugs, find or create the corresponding `.spec.cr` files to add test coverage. **DO NOT remove `tests.cr` or any files in the `tests/` directory**, as these are the foundational test infrastructure and integration suites. All `*.spec.cr` files throughout the repository are essential project components.
4. **Maintain UI Consistency**: Adhere to the design patterns (menus, empty states, buffered rendering) detailed in [ARCHITECTURE.md](ARCHITECTURE.md#application-design-patterns).
5. **Real-time Synchronization**: Ensure any new entity creation or modification dispatches the appropriate global events (e.g., `recent-refresh`) as described in the [Communication Patterns](ARCHITECTURE.md#communication-patterns).
6. **Preserve Root Metadata**: Essential project files like `LOVE.md`, `GEMINI.md`, and `AGENTS.md` itself must never be removed.

### Architectural Patterns
- **Shared Libraries (`app/lib/`)**: Generic utilities (like `markdown.cr` or `svg-icon.cr`) should be placed in `app/lib/` and registered in `app/main.cr`. This makes them globally available via the `lib` object (e.g., `get lib markdown`).
- **UI View State Persistence**: Document-specific UI preferences (like `mode` or `markdownViewMode`) are stored in the document's metadata on the server. This ensures that the editor's state is preserved across session reloads.
- **Metadata-Driven API**: When adding new document properties, update the `documents-create`, `documents-update`, `documents-get`, and `documents-list` API routes to ensure the properties are correctly initialized, persisted, and returned.
- **Optimistic UI Updates**: To ensure high responsiveness, the `session-service` uses a local cache (`log-optimistic-updates`) for transient states like `skippedOnReplay` and `minimized`. This allows the UI to reflect changes immediately while persistence requests happen in the background.
- **Log Event Lifecycle**: Modals that are triggered by a logged action (e.g., `rename`) should override their `close` method to mark the triggering log entry as `skippedOnReplay`. This prevents modals from re-opening unexpectedly during session playback on reload.
- **Log Enrichment**: The event log renderer should use available services (e.g., `document-service`, `value-service`) to resolve entity names from IDs so that the log remains readable and reflects current data.

### Script Execution & Persistence
- **Run ID Stability**: The `runId` passed to Crown scripts is the script's own ID. This ensures that data saved via the `script-data` API (e.g., `/api/sessions/:id/script-data/:runId/...`) is persistent across page reloads and replayed events for that specific script.
- **Script Platform API**: Scripts have access to a `platform` object for interacting with session data (documents, values, etc.). Always use the `sessionId` from the script's scope when calling platform methods.

### Service Event Patterns
- **Listeners Object**: Services that emit events (like `session-service`, `document-service`, etc.) maintain a `listeners` object. Every event name used in the application MUST be initialized in this object (e.g., `myEvent [ list ]`).
- **Debugging 'undefined' each/push**: If you see a Crown error stating `each command requires current value to be an Array, got undefined` or a failure to `push` to undefined, check if the event name is missing or commented out in the service's `listeners` definition.
- **Consistent API**: Always provide `on` and `emit` functions in services to allow standard event subscription patterns across the application.

### Technical Constraints
- Avoid introducing external Node.js dependencies or standard web framework patterns; the project strictly relies on its custom Crown runtime and standard built-in mechanisms.
- If you need to understand how a specific core function is implemented or evaluated, refer to the `crown` interpreter script at the root of the project.
