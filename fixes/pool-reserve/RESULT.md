# RESULT: pool-reserve

Checked on the Linux laptop against 0.2.180-og. Reviewed without the PC notes (not arrived).

## Compile
- Applies with `patch -p1`.
- JITAllocator.c: iOS SDK clang syntax check, no errors or new warnings.
- Swift typecheck of the whole app: no new errors (only the existing Squeeze one).
- Host tests naming JITAllocator/StikJITHelper: same results before and after.

## Review: PASS WITH NOTES (OK for the A/B test; "off = today" is not true)
- Footprint: no rise expected. The array is zero-fill and untouched pages are not counted in the memory footprint. The app has the extended-virtual-addressing entitlement, so 1.4 GB more address space is fine.
- Main note: the switch does NOT give today's layout. The 1440 MB array is part of the app image in every build, so it is mapped at exec for everyone, and everything dyld and the system map before constructor(100) (linked frameworks, early malloc regions, __LINKEDIT, which follows __DATA) now land above it, around 0x16b... instead of in today's places. With the switch off it is freed at constructor(100), but those earlier mappings have already moved. So the "off" side of an A/B is not 0.2.180, and every user gets the new early layout. Check on device with pool-reserve off: image range, StikJIT.framework address, main stack address.
- Stack: the image now ends near 0x16a...; README's 0x16af64000 is a stack seen with today's smaller image; the kernel may place the stack elsewhere. Unverified.
- Off switch: `pool-reserve = 0` / env.MADEIRA_POOL_RESERVE = 0. An empty env value (MADEIRA_POOL_RESERVE=) turns it ON.
- Release happens once, before the census; nothing frees it if the census path is never reached (held until exit, harmless).
