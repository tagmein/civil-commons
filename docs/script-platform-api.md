# Script Platform API

When you run a script (Script Output window), the Crown scope includes a **`platform`** object you can use to list and load documents, sessions, values, scripts, and dictionaries, and to update their content or metadata. This lets you build script "apps" that edit documents or other session data.

## Scope when running a script

- **`window`** – The Script Output window (use `get window content appendChild, call [ element ]` to add UI).
- **`runId`** – Stable id for this script in this session (persists across page reloads); use with script-data APIs.
- **`sessionId`** – Current session id. **Pass this as the first argument to all `platform` methods** that act on session-scoped data.
- **`platform`** – API described below.

## Best practice: use `sessionId` from scope

Always pass the current session when calling platform methods that need it:

```crown
get platform listDocuments, call [ get sessionId ]
get platform getDocument, call [ get sessionId ] [ get doc-id ]
```

## Sessions

| Method | Arguments | Returns |
|--------|-----------|--------|
| `platform listSessions` | none | Array of `{ id, name, archived, createdAt }` |

Example:

```crown
set sessions [ get platform listSessions, call ]
get sessions, each [ function s [ log [ get s name ] ] ]
```

## Documents

| Method | Arguments | Returns |
|--------|-----------|--------|
| `platform listDocuments` | `session-id` | Array of `{ id, name, archived, createdAt }` |
| `platform getDocument` | `session-id`, `doc-id` | `{ id, name, archived, createdAt, content }` |
| `platform updateDocument` | `session-id`, `doc-id`, `body` | Updated document object. `body` may include `name`, `archived`, `content` |

Example: list documents, load one, change content, save:

```crown
set docs [ get platform listDocuments, call [ get sessionId ] ]
get docs, each [
 function doc [
  set full [ get platform getDocument, call [ get sessionId ] [ get doc id ] ]
  set new-content [ template '%0\n\nAppended by script.' [ get full content ] ]
  get platform updateDocument, call [ get sessionId ] [ get doc id ] [ object [ content [ get new-content ] ] ]
 ]
]
```

## Scripts

| Method | Arguments | Returns |
|--------|-----------|--------|
| `platform listScripts` | `session-id` | Array of `{ id, name, archived, createdAt }` |
| `platform getScript` | `session-id`, `script-id` | `{ id, name, createdAt, content }` |
| `platform updateScript` | `session-id`, `script-id`, `body` | Updated script. `body` may include `name`, `archived`, `content` |

## Values

| Method | Arguments | Returns |
|--------|-----------|--------|
| `platform listValues` | `session-id` | Array of `{ id, name, type, value, archived, createdAt }` |
| `platform getValue` | `session-id`, `value-id` | `{ id, name, type, value, archived, createdAt }` |
| `platform updateValue` | `session-id`, `value-id`, `body` | Updated value. `body` may include `name`, `type`, `value`, `archived` |

## Dictionaries

| Method | Arguments | Returns |
|--------|-----------|--------|
| `platform listDictionaries` | `session-id` | Array of `{ id, name, archived, createdAt }` |
| `platform getDictionary` | `session-id`, `dict-id` | `{ id, name, archived, createdAt, entries }` |
| `platform updateDictionary` | `session-id`, `dict-id`, `body` | Updated dictionary. `body` may include `name`, `archived`, `entries` |

## Building a script app that edits a document

1. Use **`platform listDocuments`** with **`get sessionId`** to get the list of documents.
2. Use **`platform getDocument`** with **`sessionId`** and the chosen document **`id`** to load metadata and **`content`**.
3. Build your UI in the Script Output window (e.g. a textarea bound to the content).
4. On save, call **`platform updateDocument`** with **`sessionId`**, document **`id`**, and a body object containing **`content`** (and optionally **`name`**, **`archived`**).

All methods return promises; Crown awaits them, so you can assign the result and use it in the next line.
