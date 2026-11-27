# remote-run-status: "Will it run?" ratings online (RemoteRecs way)

Cameron: "yes" (Nov 26/27 2026, relayed by coordinator). Base: 0.2.180 (source/madeira-0.2.180).
STATUS: written, NOT compiled, NOT device-tested, NOT reviewed. Queue AFTER the run-status.json regeneration (INDEX.md).

## What it does
- Today run-status.json is bundled only. This adds a signed download from the Get Help server (GET shared/run-status),
  kept on the device, read at the NEXT start. The bundled file is the fallback.
- Same channel as RemoteRecs.swift: Ed25519 key (SharedConfigs.publicKey/verify), x-madeira-key header, signature in
  x-madeira-signature, body = the run-status.json exactly as make-run-status.py writes it. Kept file = signature line + body (atomic write), re-verified when read.
- Used only if it decodes as RunStatusFile (version 1, not empty, <=2 MB), `generated` (YYYY-MM-DD) is not older than the bundled one
  nor than the kept one (no replay of old ratings), and the kept file is <=120 days old.
- Off: env.MADEIRA_REMOTE_RUN_STATUS = 0. No MadeiraSharedConfigsKey in Info.plist: off. Logs: [remote-run-status].

## Files
- RemoteRunStatus.swift (NEW: add to the Xcode project; no other new files)
- remote-run-status-wiring.diff (RunStatus.swift: RunStatusStore.file now = RemoteRunStatus.newerThan(bundled) ?? bundled; MadeiraApp.swift: RemoteRunStatus.refresh() next to RemoteRecs.refresh())
Apply with `patch -p1` from app/Madeira's parent (paths a/app/Madeira/...). Then run gen-config-catalog.py (new switch MADEIRA_REMOTE_RUN_STATUS, category "App & front end", default 1, source RemoteRunStatus.swift), typecheck, host checks (tests/host/check-run-status.py).

## Server side (Get Help thread cmsg_01RYsSHVyBApabNeqTgzQudYLUpzMhEEuFy6R35pdvhe7h)
New endpoint shared/run-status, same pattern as shared/recs: returns the file body with x-madeira-signature (Ed25519 over the body, same key as recs). A wrangler var RUNSTATUS="off" could send nothing. The deploy needs Cameron's typed OK in that thread. Until it is deployed the app gets a non-200 and uses the bundled ratings (logged once per hour at most).
Publishing flow: make-run-status.py writes the file on the PC, it is signed and uploaded to the server like the recs file.
