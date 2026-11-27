# REVIEW: first pass by author only. SECOND REVIEW STILL TO DO (needs a separate reviewer).
- Loop runs 20 times max, Sleep(500) only between tries; a pass breaks out; failure still returns 41 as before.
- `length` is reused (declared earlier as DWORD); `got` moved inside the loop. Check it compiles.
- fprintf(stderr) may not reach the dock report; if not, only the events remain.
- Risk: if Steam never corrects its answer, a real failure now takes 10 s longer.
- Golden: a Steam game from the external drive must still launch first try; test list: first play after app restart for Raft, RE4, Batman, Halo.

## Second pass (Nov 25, read patch + surrounding launch.c): PASS WITH NOTES. Not compiled.
- bool already used in launch.c (line 155); install_dir_fn, Sleep, fprintf(stdio.h included) all in scope; braces balance.
- Behaviour change: an unreadable query now also logs the mismatch event; result still 41. Max extra wait 9.5 s.
- Note: if the last query failed, actual_utf8 printed in the mismatch line may be stale/empty.
- Online (Rule 14, Nov 25): searched Wine/Proton/GameNative/Winlator install-dir + libraryfolders first-launch; nothing relevant found.

## Update Nov 25 22:20 (Rain World data): code 41 repeated 3 times; try 3's dock-report (relayed by iPad thread) shows session-auth-test-result=41 with NO launch-install-directory-mismatch line. So Rain World's 41 is a silent 41 of the same function: expected-install env missing, or Steam's install-dir query failing (got<=0). Unproven which. Patch now logs both (launch-expected-install-missing, launch-install-directory-query-failed) and retries the query. The retry may not fix a Rain World that repeats every time; the new events will say why. Also "pending=2" installers skipped in that run: not shown to matter.
