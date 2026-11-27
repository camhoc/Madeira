# BG3: guard _FindAndUnlinkFrame against an empty frame list (ucrtbase, ARM64EC)

Online: this is Wine's own msvcrt/except.c; upstream records the same crash as [Wine bug 46000, "Crash in _FindAndUnlinkFrame in ucrtbase" (SuperTux)](https://list.winehq.org/hyperkitty/list/wine-bugs@list.winehq.org/thread/BO26KRHO43VLTKYR6BZUIVIJYPM7DV2T/) (not read in full, its fix is unknown to me). The function's own comment says "native crashes in this case".

## Proven (BG3 0.2.180 iPad, New Game ~75% loading, 2 of 2 runs)
- Fault: ucrtbase.dll+0x1f144, read of 0x8, insn `ldr x26,[x26,#8]`, x26 = 0.
- Disassembly of the 160 bytes at rva 0x1f0c0 (from the 0.2.180 arm64ec-windows/ucrtbase.dll, sent by the PC thread): thread-data call, `ldr x26,[x0,#264]` (= data->frame_info_head), compare with the frame argument, then the loop `cur->next`. That is _FindAndUnlinkFrame in dlls/msvcrt/except.c:915-938. Registers at the fault: x0 = 0x70d0fa2d70 (thread_data), x8 = 0, x19 = frame (0x70dd7ab3c8).
- Context: C++ exception e06d7363 (raise #33, #34) going through VCRUNTIME140_1's handler; called from the catch-end path __CxxUnregisterExceptionObject (except.c:1015).
- So: a catch block ended on a thread whose frame_info list is EMPTY (the frame was never registered on this thread's data, or the list was emptied by a nested throw).

## UNPROVEN
Why the list is empty (a different thread-data pointer, a nested rethrow unlinking early, or TLS handling in Madeira). This patch does not fix that; it only stops the NULL read. The game may then carry on, or fail later. Do not call BG3 fixed on this alone.

## Change (dlls/msvcrt/except.c only)
- _FindAndUnlinkFrame: if the list is empty, log "[cxx-unlink-guard] frame ... not registered on this thread" and return.
- __CxxUnregisterExceptionObject: do not read data->exc_record->ExceptionCode when exc_record is NULL.
- Off switch: env.MADEIRA_CXX_UNLINK_GUARD = 0 (restores the old crash).
- Needs a rebuild of ucrtbase/msvcrt for arm64ec (and aarch64/x64 if they ship the same file); build thread.

## Test
BG3 New Game > Start Game on 0.2.180+patch: look for "[cxx-unlink-guard]" lines (how often) and whether loading completes. If it then fails elsewhere, the new fault goes to this thread.
