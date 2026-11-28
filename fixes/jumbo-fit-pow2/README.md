# jumbo-fit-pow2 (opt-in, default OFF) - The Witcher 3 64 GB / 32 GB reserves

Evidence: Discord post (Saz, iPhone19,4, 0.2.180, Nov 27): `[jumbo#2] size=0x1000000000 -> st=0xc0000017`, then a NULL
read at witcher3.exe+0x2806754; the 32 GB ask (0x800000000) is refused too. Both sizes are powers of two.
Our existing `ios_jumbo_fit` (virtual_ios.c ~35106, `env.MADEIRA_JUMBO_FIT_GB`, written for BO3's 18 GiB pool)
returns early for powers of two ("Chromium/V8 cages check their size"), so no config reaches these asks today.

Change: one extra switch. With `env.MADEIRA_JUMBO_FIT_POW2 = 1` (and `env.MADEIRA_JUMBO_FIT_GB = 16`, held 4..16)
a power-of-two reserve-only PAGE_NOACCESS ask of 16 GiB or more (no hint/limit/alignment, never the Steam client or
CEF helpers: the existing skips) is given 16 GB; the caller still believes it has the full size. Unset: no change.
Per game config lines (suggested for Witcher 3, UNTESTED):
```
env.MADEIRA_JUMBO_FIT_GB = 16
env.MADEIRA_JUMBO_FIT_POW2 = 1
```
Playport's decision 0180 says The Witcher 3 4.x runs with a ~6 GB short grant of its 16/64/32 GiB pools
(their short-reserve-mb=6144), so a 16 GB grant should be roomier. A game that commits past the grant is logged by the
existing `ios_jfit` bookkeeping. UNPROVEN that this fixes Saz's launch; the later exit code 1 after ~5 s is a separate open item.

Not done here: Playport's elastic reservations (0289-0292): 0289 applies, 0290 13/14 hunks (fuzz 2-3, offsets ~13k lines),
0291 3/4, 0292 3/7 against our virtual_ios.c; too risky to apply mechanically, a manual port is a bigger job.
Marker for the log: `[jumbo-fit] ... given 16 GB` (existing line). Host check: patch dry-run clean on 0.2.180; not compiled.
