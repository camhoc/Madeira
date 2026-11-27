# regression-compare
Usage: `python3 -B regression-compare.py <good-run-dir> <new-run-dir>`
Prints changed config lines, app version/build, and new or gone error/exit/dock lines. Uses ../log-triage/patterns.tsv.
Test: `python3 -B regression-compare.py sample/good sample/new`.
