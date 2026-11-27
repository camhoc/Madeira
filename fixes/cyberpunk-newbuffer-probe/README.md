# cyberpunk-newbuffer-probe: log what the failing newBuffer asked for (log only)

Thread "Fix Cyberpunk crash at start", Nov 27 2026. Base: source/madeira-0.2.180, madeira-d3d12/src/pe/madeira_d3d12.c line 15293. NOT compiled, NOT device-tested (no compiler here).

## Why
Cyberpunk now reaches the renderer (iPad16,8, run 3/4, direct start with pool-split + NOCOPY). Then `[madeira-d3d12] newBuffer failed while the device is still responding` (2 lines) and, the next lines, `[task-exc] BREAKPOINT` / `[int3-guest] guest_rip=0x14190b621` (REDengine abort). Before it: 655 [placed] lines, 364 "Metal size 0 (NOT in the heap: standalone)". Metal currentAllocatedSize was 527 MB (run 3) / 293 MB (run 4) at the last reading, against a 3670 MB budget. The log never says WHAT SIZE the failing newBuffer asked for. Unproven guesses: a very large buffer over Metal's max buffer length, or a Metal count limit.

## Change (log only, no behaviour change)
At the existing failure line, log desc->Width, heap type, flags, whether it was a placed resource, and Metal currentAllocatedSize. No setting needed (it only adds one log line on a path that already fails). 

## Off switch
None needed: log line on an error path only. To remove, revert the one line.

## Not checked
Compile. That MTLDevice_currentAllocatedSize and mad_creation_failure are in scope at that line (both are used earlier in the same file: lines 1498 and 10520).
