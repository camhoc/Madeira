# REVIEW (Nov 21 2026, first pass by author only; second reviewer still needed per rule 0c/WORKFLOW)
- Retry+create only runs when the first open failed, so working prefixes are untouched.
- Create is limited to NOT_FOUND/PATH_NOT_FOUND; access-denied etc. still ends 42 with statuses logged.
- Risk: an empty ActiveProcess key is created; publish() then writes pid/ActiveUser into it, same as normal.
- Unchecked: real launch.c, compile, env visibility in the host.

## Second review (fresh reviewer subagent, Nov 21 2026, given the patches only): PASS with fixes
Certain:
1. Hunk headers have no line numbers, so `patch` will not apply it; the build thread applies by hand / regenerates against real launch.c. open_or_create goes before the launch function, after <windows.h>.
2. Both opens now always run (dock-code42-log too): `done:` must close `active`/`machine` only when non-NULL, and both must start NULL. Unseen; build thread must check.
3. Compiles as shown (REG_CREATED_NEW_KEY, KEY_WOW64_32KEY via REGSAM, RegCreateKeyExW, GetEnvironmentVariableW). Needs <windows.h>, <stdbool.h>.
4. No behaviour change when keys exist (first open succeeds: no sleep, create, or event). Only failure path changes: 1 s delay on any failed open, incl. ACCESS_DENIED.
5. dock-code42-log: publish_fail static never reset (type/size stale when what=3); an existing value >4 bytes gives ERROR_MORE_DATA (234), logged as what=1, not 2. Reset the struct at the start of publish().
6. Created keys are never removed (restore covers values only); empty keys persist. Harmless.
Guess:
7. 32-bit HKLM view is right (Steam is 32-bit; Wow6432Node).
8. Cause unproven: if the logged status is ACCESS_DENIED, creating keys will not help. Reviewer suggests holding until a log with dock-code42-log arrives.
Decision: ship dock-code42-log first (log is what proves it); registry-create stays behind its off switch and is safe to ride along (item 4).
