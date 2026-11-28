# RESULT: msvcr-mixed-builtin

**Review: PASS WITH NOTES** (loader.c NOT compiled: Wine is not configured on the laptop)

Checked against 0.2.180-og. Reviewed without the PC notes (RULES.md / WORKFLOW.md had not arrived).

## Run
- Applies with `patch -p1` from the tree root.
- The new function, extracted and built on Linux with stubs, over 8 cases plus the off switch: behaves as the code reads (results below). This is not the Wine build.
- No host test names the neighbouring force-builtin code, so none was run.

## Could other games change? YES
Any 64-bit (ARM64EC) process that loads msvcr71/80/90/100/110/120 by a relative name, with no msvcp<NN> of the same number in a folder searched before system32, now takes the system32 copy. That includes:
- a game shipping only msvcr<NN> that works today on its own copy (now gets system32's);
- a game with msvcr120 and only msvcp100 (checked per number);
- a DLL loaded with its own folder as search path (plugin), where msvcp sits in the game root: also switched, unless that msvcr is already loaded.
Not changed: games shipping both beside each other; 32-bit games; msvcr80/90 redirected by a side-by-side manifest (that lookup runs first, so the fix does not cover them either); msvcr140/ucrt.

## Notes
- Off switch env.MADEIRA_NATIVE_MSVCR = 1 works in the extracted function.
- "system32 copy = builtin" is assumed; a redist installer may have put Microsoft's DLL there.
- The [msvcr-builtin] log line also fires when the game ships no msvcr at all, though it says "the game's x64 copy would feed..."; do not count those as affected games.
- A name without ".dll" is not matched.
- Test on device the two control games in README before shipping.
