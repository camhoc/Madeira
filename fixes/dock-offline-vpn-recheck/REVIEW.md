# dock-offline-vpn-recheck (v2)
Problem: on cellular, after the JIT VPN starts, Steam goes offline. Log (sentry/cameron-logs-nov17/d80c9907-BlackOps..., 0.2.29): line 57 "[jit-loopback] ... connected via utun3 10.7.1.1", line 95 "[dock-offline] enabled=1 network=down request=1", line 142 own upload "-1009 ... unsatisfied (No network route)": the network really was down then.
Cause (from code, UNPROVEN on cellular for 0.2.180): shortcut "start cellular" turns Cellular Data OFF; "done" turns it back on only after the debugger leaves. DockOffline.configure (MadeiraDock.swift) reads the path before that. Wi-Fi log logs/0.2.180-iphone-2026-11-26/fallout-nv.txt shows the order: dock-offline line 100 (17:54:56), "run input=done" line 183 (17:54:59). No 0.2.180 cellular log exists.
Fix: networkDown is false while JITNetworkShortcut still owes a "done cellular" (cellularOffOnPurpose). Truly offline phones unaffected.
Off switch: env.MADEIRA_DOCK_OFFLINE_CELLULAR_WAIT = 0.
Risk: Steam starts "online" for ~1-3 s before cellular returns; Dock connect timeout is 10 s, so should recover. Unproven. VPN removal after JIT is by design (docs/JIT.md), not device-tested.
Online: VPN false-down reports (pexip/glib PR 11, tailscale issue 21383), nothing Madeira-specific.
Overlap: none found by folder name; MadeiraDock.swift and JITNetwork.swift also touched by other fixes? full grep not done: laptop to check.
Not compiled (MainActor.assumeIsolated use needs compile check). Needs iPhone on cellular.
