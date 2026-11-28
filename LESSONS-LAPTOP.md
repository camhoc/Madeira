# Lessons from laptop checks (2026-11-27/28)

- metal-gate: run the host test of every file touched; check-background-run.py asserts the exact commit line and has Swift stubs that need new symbols. No dladdr on a per-commit path.
- fex-playport: generate patches without *.orig files. Check FEX_IOS_HOST is set before reviewing iOS-only code.
- kk-playport-pack (Mesa): "applies with fuzz" is not "correct". Read every fuzzed hunk; 0010/0012 landed outside their blocks, 0013 needs symbols that are missing.
- subnautica2: use a/ b/ relative paths in patch headers; absolute ones need -p6.
- game lists: check-game-recommendations.py has counts in both its Python and Swift parts; update both. Patches to it often conflict.
- dual-network: always fetch the branch tip before committing; a laptop commit once overwrote a newer revision.
- msvcr-mixed-builtin (Wine loader): for 'force builtin' rules, list which games change, not only the target; side-by-side manifest lookup runs before the hook, and 'system32' may hold a native redist DLL.
- pool-reserve: a big static array changes the exec-time address layout for every build, even when its switch frees it later; an A/B 'off' side is then not the old build.
- steam-layout-import: new Swift files need a project.pbxproj entry; typechecking all files on disk does not catch that.
- kk-playport-pack rev 2: after porting patches from another project, grep every new identifier in the target tree; a struct from a dropped patch (kk_memory_stats) is easy to miss.
- bo3-stp-sd-emul: a 'logged once' switch line inside a fault path only appears after the first fault; do not use it as proof the build has the fix.
- test-hooks: check README/notes files too, not only the patch, for text that must not be public (the iPad bundle id was in README on a public repo).
- grounded-direct-start / vcrt-x64-key: before reviewing a queued patch, test reverse-apply and grep its added lines in the base; both were already in 0.2.180.
- apply-all: a patch that is already in can still apply forward with fuzz and duplicate code (ntdll-sigbus-diag). Check reverse-apply before applying, not only forward.
- subnautica2: run every tests/host script that compiles a touched file standalone (check-dock-installers compiles DockInstallers.swift with its own stubs).
