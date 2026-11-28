# REVIEW - pool-reserve
Author check (Nov 28): host-compiled the constructor/release logic with mocks and ran 5 fake image starts (see README);
patch dry-run clean on 0.2.180; Swift names checked against JITAllocator.h imports (unsigned long* -> UnsafeMutablePointer<UInt>).
Default OFF, so a build with this patch behaves like today unless `pool-reserve = 1` / `env.MADEIRA_POOL_RESERVE = 1`
(the array is freed at constructor(100)).
Known gaps: not built with the iOS toolchain; Swift untested; image-end numbers are estimates.
Second review: the laptop compile check and review after the build thread pushes it as fix/pool-reserve (Cameron, Nov 28).
