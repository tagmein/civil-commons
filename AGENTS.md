# AGENTS.md

## Overview
`civil-commons` is a public gathering space for internet-enabled minds. It is built using **Crown**, a custom scripting language interpreted via a Node.js runner (`.cr` files).

## The Crown Language
The project's application code is written entirely in `crown`. Crown scripts are interpreted by the `crown` runner at the root of the project. It evaluates syntax that resembles a command-based functional language, utilizing constructs like `set`, `get`, `function`, `list`, `object`, and `call`.
- **`.cr` files**: Source code files in Crown.
- The `crown` script itself is a Node.js file that implements the parsing and execution environment.

## Architecture
- **`app/`**: Contains the frontend application logic, components, interface modules, and libraries.
  - `app/main.cr`: The main entry point for the frontend, responsible for loading various services and UI components.
- **`api/`**: Contains the backend API endpoints (e.g., handling contacts, dictionaries, documents, scripts, sessions, values, and mail). It also handles Google OAuth (`api/auth-google.cr`).
- **`core/`**: Core application logic and orchestration, like `conductor.cr`.
- **`tests/`**: Test harnesses and integration tests (`*.spec.cr`).

## Data Structure
State and data are stored locally in the `data/` directory using standard file formats (mostly JSON and plain text).

- `data/sessions.json`: Lists the active sessions.
- `data/sessions/:sessionId/`: Directory containing data scoped to a specific session.
  - **Dictionaries**: 
    - `dictionaries.json`: Lists dictionary IDs for the session.
    - `dictionaries/:dictId/metadata.json`: Metadata for a specific dictionary.
    - `dictionaries/:dictId/entries.json`: The actual entries within the dictionary.
  - **Scripts**: 
    - `scripts.json`: Lists script IDs.
    - `scripts/:scriptId/metadata.json`: Script metadata (name, description, etc.).
    - `scripts/:scriptId/source.cr`: The actual Crown source code for the script.
    - `script-data/:runId/:dataKey.json`: Persistent data for scripts (runId is the scriptId).
  - **Values**: 
    - `values/:valueId/metadata.json`: Metadata for a specific value.
    - `values/:valueId/content` (or similar): The content of the value.
  - **Documents**: 
    - Stored similarly to scripts and values, representing user documents.

## Working on this Project
When making modifications or adding features to `civil-commons`:
1. **Understand Crown**: Code modifications to `.cr` files must rigorously use the Crown language syntax.
2. **Respect the Data Structure**: When creating or modifying data-related endpoints, ensure they conform to the existing JSON and directory hierarchy inside `data/`.
3. **Write Tests**: When adding new functionality or fixing bugs, find or create the corresponding `.spec.cr` files to add test coverage. Run tests via the existing test scripts.

### Application Menus
The main menu structure in `app/interface/main-menu.cr` is consolidated into a few core dropdowns: **Commons**, **File**, **New**, **Open**, **Recent**, and **Script**. 
- Entity-specific actions (like opening a document or creating a script) are centralized in these core menus rather than having their own top-level menus.
- **Preferences & External Services**: Application preferences, including API keys for external services like Google Gemini AI, are managed in a unified tabbed modal (`app/modules/commons/preferences.cr`). When adding new service configurations, place them in the "Services" tab of the Preferences window rather than creating standalone menu items.

### Recent Items Pattern
The "Recent" system in Civil Commons uses both a unified module and type-specific modules:
- **Unified Module (`app/modules/recent/items.cr`)**: This is the primary handler for the "Recent" menu items (`recent:all`, `recent:documents`, `recent:dictionaries`, etc.). When adding a new entity type, this module must be updated with:
  - CSS badge styling.
  - Fetching logic in `open-recent-window`.
  - Dispatch logic for `open`, `archive`, and `restore` actions.
  - Conductor registration for the new `recent:type` action.
- **Specific Modules (`app/modules/*/recent.cr`)**: Some entities maintain their own recent windows (e.g., `document:recent`). Ensure consistency between these and the unified module.

### UI Consistency
- **Empty States**: All lists (Recent, Search, etc.) should use "No results" as the standard empty state message instead of type-specific or technical labels.
- **Action Parity**: If an entity can be "Archived" or "Restored" via a service, those actions should be exposed in both the specific entity window and the Recent Items windows.

### DOM Rendering & Performance
- **Buffered Rendering**: To prevent scroll position jumping and UI flickering during frequent or large DOM updates (like logs or long lists), use buffered rendering. Create an offscreen container (e.g., `global document createElement, call div`), append all updated children to it, and insert it into the active DOM *before* removing the old container. This maintains the parent container's scroll height during the replacement and provides a stable visual experience.