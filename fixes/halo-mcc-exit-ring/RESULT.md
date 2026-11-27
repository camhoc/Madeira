# RESULT: halo-mcc-exit-ring

**PASS (review) / NEEDS-DEVICE**

Checked 2026-11-27 on Linux against the 0.2.180-og source zip.

## What was run
Patch is already applied in the 0.2.180-og tree (reverse-apply check succeeds). Code read only: the touched module was NOT built and nothing ran on a device.

`check-config-catalog.py` FAILS on the patched tree: "ConfigCatalog.generated.swift is out of date: run build/tools/gen-config-catalog.py". The untouched base tree also reports FAILED (it was run with all queued patches applied together, so the cause is not pinned to one patch).

## Findings
- OW2 ring expression unchanged; `MADEIRA_HALO_EXIT_RING=0` turns it off.
- README's "except a tid" note and REVIEW sections 2-3 (b)/(c) describe the old patch 2. A second dump can add up to 8192 lines.
- OW2 golden run on device still required.
