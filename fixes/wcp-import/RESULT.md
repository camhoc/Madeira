# RESULT: wcp-import

**PASS for the four bugs below (host tested) / NEEDS-MAC**

## Fixed (2026-11-27)
- wcp_untar.c: size cap can no longer be bypassed by overflow; oversized base-256 sizes saturate.
- wcp_untar.c: PE header bounds check done in 64 bits.
- wcp_untar.c: empty entry name no longer reads name[-1].
- WCPStore.swift: duplicate DLL entries in profile.json no longer crash; the first one wins.

## What was run
gcc 13.3 with ASan/UBSan on crafted inputs: normal archive 0 (OK); "../", symlink and empty name 3 (refused);
overflow archive 4 (too big, 1 byte on disk with a 1 MB cap); bad e_lfanew DLL 0 (not a PE). No sanitizer reports.
WCPStore.swift passes `swiftc -parse` only (syntax, not typechecked). The real-package tests in the README were not rerun.

## Still open
- The five new files are not registered in project.pbxproj, so they will not build yet.
- Swift not typechecked or compiled; nothing run on a device.
- WCPSection.swift substring match: `dxvk-2.0` also matches `dxvk-2.0.1`.
- pax long path records are skipped, so such names unpack truncated.
