# GEMINI.md

Please refer to the [AGENTS.md](AGENTS.md) file for comprehensive information regarding the architecture, data structure, and the **Crown** programming language used in `civil-commons`.

## Gemini Specific Instructions
- When making changes to the application logic, ensure you write correctly formatted Crown (`.cr`) code. Use existing files as a reference for syntax and structure.
- If you need to understand how a specific core function is implemented or evaluated, refer to the `crown` interpreter script at the root of the project.
- Always maintain the file-based data structure exactly as defined when manipulating state in the `data/` directory.
- Avoid introducing external Node.js dependencies or standard web framework patterns; the project strictly relies on its custom Crown runtime and standard built-in mechanisms.