# dock-install-dir-wait (Steam code 41). Ours. Off: env.MADEIRA_DOCK_INSTALL_DIR_WAIT = 0
Online: 3 searches (install-dir, libraryfolders first launch, Wine/Proton/GameNative/Winlator PRs); nothing relevant found.
Symptom: first play after Madeira opens fails with `launch-install-directory-mismatch=1` then `session-auth-test-result=41`; plain retry works.
Checked: the failing logs of Raft, Batman and Halo (logs/sweep-0.2.101/) are each the first play after "Madeira opened" (Raft/Batman after a crash/reopen). Raft run 1 had the vdfs rewritten at open; Halo run 1 did not, so the vdf rewrite is NOT the cause. Code 41 in launch.c compares Steam's GetAppInstallDir with MADEIRA_STEAM_HOST_EXPECTED_INSTALL (MadeiraDock.swift:499).
0.2.100 -> 0.2.101: madeira-dock.diff has no change to this check; I found no code change behind it. Cause UNPROVEN (no log line shows Steam's actual path). SSD theory: all games here are on the external drive, so it does not explain why only first plays fail.
Patch: launch.c asks again every 500 ms for up to 10 s before 41, and prints steam=<path> expected=<path> on a final mismatch so the next report proves the cause. Events: launch-install-directory-attempts, launch-install-directory-query-failed.
Base 0.2.101 launch.c; NOT compiled, not device-tested.
More data (Nov 26, iPad thread): Half-Life (original) failed 2x with launch-install-directory-mismatch=1; R.E.P.O. first start failed, second ran; Rain World 3x silent 41. Logs arrive in logs/sweep-0.2.101/ at end of sweep. Half-Life failing twice means the mismatch is not always first-try only.
