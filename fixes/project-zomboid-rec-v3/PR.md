# Project Zomboid recommended list v2 -> v3 (menu-crash fix)

Patches (against the 0.2.180 source, `app/Madeira/GameRecommendations.swift` and `tests/host/check-game-recommendations.py`): `project-zomboid-rec-v3.patch`, `check-game-recommendations.patch`. Data-only change. Host check applied: `check-game-recommendations.py` PASSES with both patches (Swift step skipped, no compiler here).

## Why (PROVEN)
The shipped v2 list (`-XX:-UseZGC -XX:+UseG1GC -XX:TieredStopAtLevel=1`) crashes: 0.2.101 run, "projectzomboid64.exe status=0x1 lived=194.16s", hs_err EXCEPTION_ACCESS_VIOLATION at pc 0x154ed1934. That pc is ucrtbase.dll+0x61934 (memcpy) doing `stp q0,q1,[x8,#-16]` (0xAD3F8500) into the JVM code cache, and the Madeira log says `[sigbus-diag] #10 q-pair store NOT emulated ... alias_write=refused honor_guest_prot=1` (signal_arm64_ios.c, ios_alias_write: the page's recorded protection is not writable). Same pc in tests 7 and 8 (hs_err_252, 3 min).
With `env.MADEIRA_X64_RWX_PLAIN = 1` (existing switch, also in the Slay the Spire 2 list) plus SerialGC, one compiler thread and no background compiling: menu in about 5 min at 60 fps, no hs_err, 0 "q-pair store NOT emulated" lines (test 10 runs 1-2, test 11; iPad, 0.2.180). Log: "[x64-rwx] MADEIRA_X64_RWX_PLAIN=1 -> 64-bit guest RWX memory is plain read/write".

## Change
- `_JAVA_OPTIONS = -XX:-UseZGC -XX:+UseSerialGC -XX:TieredStopAtLevel=1 -XX:CICompilerCount=1 -XX:-BackgroundCompilation`
- `env.MADEIRA_X64_RWX_PLAIN = 1`
- version 2 -> 3; the checker's version pin gets project-zomboid at 3.

## Not in this change (on purpose)
- `env.FEX_VECTORTSOENABLED = 1` and `env.FEX_MEMCPYSETTSOENABLED = 1`: the checker bans them from every list. Tests 7, 10 and 11 had them ON, so whether they matter together with RWX_PLAIN is untested (needs a run with only the list above).

## Not proven / open
- A new world still does not load: test 11 ended at 612 s ("WorldStreamer.isBusy() loop start", `[reclaim-census] at=fatal-segv fault=0x4`, bink64.dll in the call chain). This list gets the player to the menu only.
- Small text on New Game is garbled in some runs, clean in others (cause unproven).
- Because of that, ship as the new recommended list only if the build thread/Cameron accept "menu works, world load open".

## Off switch
Per-game config: set `env.MADEIRA_X64_RWX_PLAIN = 0` or put the old `_JAVA_OPTIONS` line back; Reset to Recommended restores v3. Data-only list change, no code path.
