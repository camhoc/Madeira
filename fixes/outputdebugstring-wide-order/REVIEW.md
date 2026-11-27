# REVIEW: outputdebugstring-wide-order-1 (second-pass, fresh reviewer, WORKFLOW step 3)

Base checked: unzipped 0.2.101 tree (dll2 for ntdll, dll1 for kernelbase). Patch not edited.

## Dry run
`patch -p1 --dry-run` from the wine folder: "checking file dlls/ntdll/signal_arm64ec.c", clean, no offset or fuzz. Hunk counts (-6512,10 +6512,13) match the body.

## (1) Parameter order
kernelbase/debug.c OutputDebugStringW (dll1, ~line 278-300) builds the record as:
```
args[0] = wcslen(str) + 1;
args[1] = (ULONG_PTR)str;
args[2] = strlen(strA.Buffer) + 1;
args[3] = (ULONG_PTR)strA.Buffer;
RaiseException( DBG_PRINTEXCEPTION_WIDE_C, 0, 4, args );
```
So (wide len, wide ptr, ANSI len, ANSI ptr). The patch now calls
```
ios_exc_dump_str( "OutputDebugStringW", rec->ExceptionInformation[1], rec->ExceptionInformation[0], 1 );
ios_exc_dump_str( "OutputDebugStringA", rec->ExceptionInformation[3], rec->ExceptionInformation[2], 0 );
```
which is correct (ptr=[1] len=[0] wide=1; ptr=[3] len=[2] wide=0). This is also the documented native Windows layout (matches Wine). The old code was the reverse, which explains "D" / "......." in the Halo log.
ANSI variant untouched: the `0x40010006 && NumberParameters >= 2` block (ptr=[1], len=[0], wide=0, and the only `ios_fatal_probe( orig_context )` caller) is outside the hunk. Verified by reading lines ~6507-6512 and the patch context. The `0x4001000a && NumberParameters >= 4` guard is unchanged.
Side note (not a bug): the `/* ml812 ... the wide form appends (len, ptr) */` comment at ~6504 is slightly misleading (wide form puts wide first). Optional comment fix only.

## (2) Length units / bounds (ios_exc_dump_str, ~5956-5999)
- Wide: `WCHAR wbuf[110]` (220 bytes); `n = len` (WCHARs incl. NUL), clamped `if (n > 110) n = 110;`, read `n * sizeof(WCHAR)` <= 220 bytes into wbuf: no overflow. Then `n = got / sizeof(WCHAR)` (<= 110), loop `i < n && i < sizeof(out)-1` writes out[0..109] then `out[i]=0`; out is 224 bytes: no overflow. Embedded NUL ends the loop. wbuf is not NUL-terminated if the read is full, but the loop is bounded by n, so no over-read of wbuf.
- ANSI: `if (n > sizeof(out) - 1) n = sizeof(out) - 1;` (223), read n bytes into out (224, memset 0), loop bounded by `got` and 223. No overflow. Read length = ANSI len incl. NUL, i.e. exactly the buffer kernelbase allocated (RtlUnicodeStringToAnsiString), so no out-of-bounds read of the target; with the old swapped order the wide read of an ANSI buffer could read up to 2x its size (a possible partial/UNREADABLE), so the patch is strictly safer.
- Reads go through NtReadVirtualMemory (status, no fault). `!addr || !len` returns 0 silently.
- Truncation: strings over 110 WCHARs / 223 bytes are cut, unchanged behaviour.
- Odd case unchecked: a non-kernelbase raiser (a game calling RaiseException(0x4001000A) itself with its own, maybe reversed, layout). Worst case is garbage text in the log, never a memory error.

## (3) Return values
- Both ios_exc_dump_str calls in the 0x4001000a block already discard the return value (`ios_exc_dump_str( ... );` as a bare statement), before and after the patch. Neither feeds `ios_fatal_probe`.
- The only user of the return value (the `LowLevelFatalError` match, `return strstr( out, "LowLevelFatalError" ) != NULL;`) is the 0x40010006 branch, which is untouched. The 0x00004000/0x00008000 branch calls ios_exc_dump_str with the return discarded too.
- Consequence: behaviour beyond logging does not change. Note for the future: a UE fatal that arrives only via the wide code (0x4001000a) will now print readable text but still will not trigger ios_fatal_probe, same as before. Not a regression; optional follow-up only if wanted.
- No state change in the dump function other than ERR output (no statics).

## (4) Golden games / logs and timing
The whole block sits inside ml811's per-code limiter: `if (slot >= 0 && ++seen_hits[slot] <= 4)`, 16 slots, so at most 4 hits per exception code per process run, i.e. at most 4 x 2 = 8 dump lines for 0x4001000a. The README's "more log lines per game" is therefore overstated: the number of lines is the same as before (each call already logged one line, "D"/"......" or UNREADABLE); only the content changes. Possible differences: a line that was "UNREADABLE" or empty/short now shows text. Timing cost is negligible (two small NtReadVirtualMemory calls, <=4 times per run, already paid before).
Golden games that use wide OutputDebugString (OutputDebugStringW or UE-style wide prints) could show different log text only:
- Unreal: Satisfactory (#3) is the likely one, plus any UE title.
- Unity: Silksong (#1), 7 Days to Die (#2), RimWorld (#8): Unity/Mono may use OutputDebugStringW sometimes.
- Others (Stardew .NET, Undertale, Touhou, Denshattack, Just Cause 2, FNV): possible but unchecked; no run logs were read for this review ("unchecked").
No golden game's pass/fail depends on the text. Unchecked: actual log lines from any golden game; none were run.

## (5) Compile (by reading)
- Only argument order and a comment changed; same function, same types (ULONG_PTR addr, SIZE_T len, int wide; ExceptionInformation[] is ULONG_PTR). No new identifiers, includes or declarations.
- The inserted comment has no nested `*/` and no `/*` inside it (the quoted text uses plain quotes). The `"D"` and `"......"` quotes are inside the comment only.
- Braces balance in the hunk. Not compiled: "unchecked" for an actual build; the ARM64EC target build was not run by this reviewer.

## Verdict
OK to queue. No changes needed. Optional (non-blocking): reword the line ~6504 comment ("the wide form appends (len, ptr)") and correct the README line "more log lines per game" (line count is capped by the ml811 limiter at 4 hits per code). Needs a real compile in the next build and a look at the Halo MCC log (expect readable "Shutdown handler: ..." text on both W and A lines) as the proof.

## Re-review: limiter hunk
Scope: only the second hunk (@@ -6488,7 +6488,10 @@) of outputdebugstring-wide-order-1.patch. Full patch dry run (`patch -p1 --dry-run`, base 0.2.101): applies cleanly, both hunks.

### Ternary
```
if (slot >= 0 && ++seen_hits[slot] <= ((rec->ExceptionCode == 0x40010006 || rec->ExceptionCode == 0x4001000a) ? 600 : 4))
```
Correct. The ternary is fully parenthesised, so `<=` compares against 600 or 4 as intended; `&&` short-circuit is unchanged (the increment only runs when slot >= 0). ExceptionCode is DWORD, the literals are unsigned-fitting (0x4001000a < 2^31), no sign problem; seen_hits is LONG, constants are int: no warning expected. The comment contains no nested comment markers. Style nit only: the line is about 130 columns.

### Other users of seen_hits[] / per-slot arrays
Grep of the whole ntdll file: `seen_code`, `seen_hits`, `seen_n`, `in_probe` appear only at lines ~6477-6497 and 6603 (the `seen_n`/`seen` at ~5900-5921 belong to a different, function-local static in another function). Only uses: slot lookup (`seen_code[i] == (LONG)rec->ExceptionCode`), slot allocation (limit 16), the limiter, the `hit=%d` print (`(int)seen_hits[slot]`, now shows up to 600), and the `in_probe` reset. Nothing else counts against these arrays, so nothing breaks. 16 slots unchanged; both OutputDebugString codes take one slot each. Pre-existing and unchanged: `++seen_hits[slot]` keeps incrementing after the cap (LONG wraps only after 2^31 hits, unrealistic), and the increment is non-atomic but is serialised by the `in_probe` compare-exchange (other threads that find it taken skip decoding, they do not wait).

### Cost / recursion inside exception dispatch
- Per hit: 1 ERR ml811 line + (0x4001000a) 2 dump lines, 2 NtReadVirtualMemory (<=220 bytes each); (0x40010006) 1 dump line, 1 read. kernelbase OutputDebugStringW's handler returns EXECUTE_HANDLER for the wide code, so normally every W call also falls through to OutputDebugStringA and raises 0x40010006 too: per wide print about 3 + 2 = 5 log lines. Worst case at the cap: 600 x 3 + 600 x 2 = about 3000 lines per process run, plus the 4 x other codes. Not previously possible (was about 20).
- Recursion/lock safety unchanged: no allocation, no locks, reads via NtReadVirtualMemory, and the in_probe guard still prevents re-entry (an exception raised during decoding is not decoded again). ERR itself is the same call already made 4 times before; whether ERR takes a lock or does a synchronous file write on iOS is "unchecked" (not read). If ERR blocks, the cost is up to about 3000 writes spread over the run, in the thread that printed, with the in_probe flag held meanwhile (other threads' exceptions simply skip logging during that window, so some lines can be lost under contention but nothing deadlocks).
- ios_fatal_probe keeps its own `fired > 2` budget, so a flood of "LowLevelFatalError" strings cannot multiply the heavy probe (only the 40010006 branch calls it).
- Timing: a chatty game pays a few microseconds to some tens of microseconds per print for the first 600, then falls back to a single increment and compare. Negligible except in the ERR-blocking case above.

### Golden games: who could flood or slow
All "unchecked": no run logs were read for this review and I did not measure per-game OutputDebugString rates. Only the first 600 prints per code per run are decoded, so the log growth is bounded at about 3000 lines (about 300 KB at 100 chars/line) per run, and the cost stops after that.
- Most likely to be chatty: Unreal (Satisfactory #3; UE writes to OutputDebugString only when it believes a debugger is attached or in some builds, unverified here) and any title that logs through OutputDebugStringW. Fallout: New Vegas (#10), Just Cause 2 (#9) and other older native engines sometimes print debug text through OutputDebugStringA: ANSI prints now also get 600 instead of 4 (the 0x40010006 limit rose too).
- Unity (Silksong #1, 7 Days to Die #2, RimWorld #8): Mono/Unity player normally does not call OutputDebugString in release builds; unchecked.
- Stardew (.NET, #4): Debug.WriteLine/Trace may reach OutputDebugString in debug listeners; unchecked. Undertale, Touhou, Denshattack: unchecked.
- Step-6 check (suggested): in each golden run count `[exc] ml811 code=40010006` / `4001000a` lines; expect at most 600 each. A per-run log size jump of a few hundred KB would be the worst outcome, and the "2 launches, 60 s+" pass/fail is not expected to depend on it.

### Verdict
OK to queue. The ternary is correct, nothing else depends on the per-slot counters, no new recursion or lock risk, and the log growth is bounded (about 3000 lines/run). Unchecked and worth confirming in the test build: ERR cost on iOS and the actual line counts in Halo MCC and one chatty golden game. Optional: wrap the long condition onto two lines.
