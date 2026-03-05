# Architecture

## System Overview
`civil-commons` is a public gathering space for internet-enabled minds. It is built using **Crown**, a custom scripting language interpreted via a Node.js runner.

## Directory Structure
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
    - `scripts/:scriptId/content.cr`: The actual Crown source code for the script.
    - `script-data/:runId/:dataKey.json`: Persistent data for scripts (runId is the scriptId).
  - **Values**: 
    - `values/:valueId/metadata.json`: Metadata for a specific value.
    - `values/:valueId/content` (or similar): The content of the value.
  - **Documents**: 
    - Stored similarly to scripts and values, representing user documents.

## Communication Patterns

### Event-Driven UI Updates
The application uses standard DOM events on the `global window` for decoupled communication:
- **`recent-refresh`**: Dispatched by services after a successful `POST` (creation) to signal that "Recent" windows should reload.
- **`sessionRenamed` / `documentRenamed`**: Dispatched when metadata changes to update tab labels or window titles.

### Reference Object Pattern
Since Crown's `set` can create local bindings, the "Reference Object Pattern" (`set ref [ object [ value 123 ] ]`) is used when a value needs to be modified by a child scope (like a closure or an async fetch callback) and reflected in the parent.

## Application Design Patterns

### Application Menus
The main menu structure in `app/interface/main-menu.cr` is consolidated into a few core dropdowns: **Commons**, **File**, **New**, **Open**, **Recent**, and **Script**. 
- Entity-specific actions are centralized in these core menus rather than having their own top-level menus.
- **Preferences & External Services**: Application preferences are managed in a unified tabbed modal (`app/modules/commons/preferences.cr`).

### Recent Items Pattern
The "Recent" system in Civil Commons uses both a unified module and type-specific modules:
- **Unified Module (`app/modules/recent/items.cr`)**: This is the primary handler for the "Recent" menu items. 
  - **Real-time Synchronization**: This module listens for the `recent-refresh` global event. Services that create entities should dispatch this event to ensure open Recent windows update their lists immediately.
  - **Entity Integration**: When adding a new entity type, this module must be updated with CSS badge styling, fetching logic, and action dispatching.
- **Specific Modules (`app/modules/*/recent.cr`)**: Some entities maintain their own recent windows. Ensure consistency between these and the unified module.

### UI Consistency
- **Empty States**: All lists should use "No results" as the standard empty state message.
- **Action Parity**: Actions like "Archive" or "Restore" should be exposed in both specific entity windows and Recent Items windows.

### DOM Rendering & Performance
- **Buffered Rendering**: To prevent scroll position jumping and UI flickering during updates, use buffered rendering. Create an offscreen container, append updated children to it, and replace the active DOM content in one operation.
