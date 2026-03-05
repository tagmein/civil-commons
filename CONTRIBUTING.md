# Contributing to Civil Commons

First off, thank you for considering contributing to Civil Commons! It's people like you that make this a great public gathering space for internet-enabled minds.

## Development Setup

1. **Clone the repository:**
   `git clone <repository_url>`
2. **Review the core documents:**
   Before you start, please read the following to understand the project's unique architecture and constraints:
   - `ARCHITECTURE.md`: Foundational patterns, data models, and communication protocols.
   - `AGENTS.md`: Detailed information on the Crown language and core mandates for AI agents working on this codebase.
   - `ETHICS.md`: The ethical guidelines for AI contributions.
3. **Running the application:**
   You can start the development server using the provided `serve.cr` or `watch` scripts.
   `./crown serve.cr` or `./watch`

## The Crown Language

This project is built using a custom scripting language called **Crown**.
- All application logic is in `.cr` files.
- The `crown` file at the root is the Node.js interpreter.
- Please review `AGENTS.md` and `ARCHITECTURE.md` carefully to understand the syntax, scoping rules, and best practices.
- You can test snippets via `./crown tmp/test.cr`.

## Contribution Guidelines

1. **Strictly adhere to Crown syntax:** Do not introduce external Node.js dependencies or standard web framework patterns.
2. **Preserve Data Structures:** Ensure any modifications conform to the existing JSON and directory hierarchy defined in `ARCHITECTURE.md`.
3. **Write Tests:** New functionality or bug fixes must include corresponding `.spec.cr` files. Never remove existing tests.
4. **Follow UI Patterns:** Adhere to the design patterns (menus, empty states, buffered rendering) detailed in `ARCHITECTURE.md`.
5. **No External Libraries:** Rely strictly on the custom Crown runtime and built-in mechanisms unless explicitly stated otherwise.

## Code of Conduct

By participating in this project, you agree to abide by our code of conduct. We are committed to providing a welcoming and inspiring community for all. Please approach collaborations with kindness and respect, as outlined in `LOVE.md`.
