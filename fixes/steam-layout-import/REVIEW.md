# REVIEW steam-layout-import
- Self-check: parse-only (tree-sitter: Library 2 = 2, new file 0). No compile, no device test. Python twin matches the Swift on Valve's WASD template.
- Fresh subagent review (Nov 27): one must-fix, applied: "active modeshift" was treated as active. Nice-to-haves applied: switch_bindings fallback, one-line xinput count, preset name in the summary, correct error text, edge before click, fileImporter on the Section. Not applied: none.
- Reviewer found no compile problems and no infinite loops on malformed input (unterminated string, stray braces, empty file). Known quirk: input nested deeper than 40 levels mis-parses without crashing.
- Behaviour to know: replaces the whole binds table; inputs the layout leaves out fall back to the template defaults.
