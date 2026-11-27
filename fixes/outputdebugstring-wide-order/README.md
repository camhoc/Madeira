# outputdebugstring-wide-order (ntdll, LOG ONLY), rev=outputdebugstring-wide-order-1

Written Nov 25 2026 by thread "Get Halo MCC past Easy Anti-Cheat" (cmsg_01RYsSHVyBApabNeqTgzQudYEvDSiLfB9WWMHuwv8Jzog3). Base 0.2.101. Status: WRITTEN, not compiled, no REVIEW.md yet (so not queued). Patch path relative to the wine folder (dlls/ntdll/signal_arm64ec.c).

## Why
In Halo MCC's 0.2.101 run 3 log most OutputDebugString lines print as `OutputDebugStringA: "D"` followed by `OutputDebugStringW: "......."`. Only the single-byte variant (code 0x40010006) prints right ("Shutdown handler: initialize.."). The ml812 dump for 0x4001000a reads the parameters as (ansi len, ansi ptr, wide len, wide ptr); for DBG_PRINTEXCEPTION_WIDE_C the order is (wide len, wide ptr, ansi len, ansi ptr) [checked: our own kernelbase/debug.c OutputDebugStringW sets args[0]=wcslen+1, args[1]=wide ptr, args[2]=strlen+1, args[3]=ANSI ptr; and it matches the log: the "A" dump of a UTF-16 string stops after one char, the "W" dump of ANSI bytes gives dots]. The game's own log lines up to its exit(1) therefore never reached our log. This swaps the two dump calls.

## Effect and risk
Log only. Second hunk: the ml811 limiter allowed only 4 hits per exception code, so Halo's run 3 log holds just 8 OutputDebugString lines (checked: 8) and the game's last lines before exit(1) were never printed even with the right order. OutputDebugString codes (0x40010006, 0x4001000a) now get 600 hits per run; all other codes keep 4.  Every game that uses OutputDebugStringW-style prints will now show readable text (up to about 600 lines per code in a chatty game; the existing per-line cap of 110 wide chars / 223 bytes is unchanged). No new switch: a pure log fix (workflow exception). Back-out = revert the hunk.

## Unchecked
Not compiled. Needs a fresh reviewer's REVIEW.md before it is queued.
