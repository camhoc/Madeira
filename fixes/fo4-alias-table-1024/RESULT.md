# RESULT: fo4-alias-table-1024

**PASS (review) / NEEDS-DEVICE**

Checked 2026-11-27 on Linux against the 0.2.180-og source zip.

## What was run
Patch is already applied in the 0.2.180-og tree (reverse-apply check succeeds). Code read only: the touched module was NOT built and nothing ran on a device.

## Findings
- Table size, mask, static_assert and cap check agree; `MADEIRA_ALIAS_TABLE_MAX=256` restores the old refusal point.
- Still unchecked: registrations before ProcessInit use the default cap of 1024.
- Golden games (Fallout 4, DRG, GTA V Enhanced) not run.
