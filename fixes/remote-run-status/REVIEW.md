# REVIEW (remote-run-status), first pass by the writer, NOT an independent review
- Mirrors RemoteRecs.swift refresh/keep/verify line for line; differences: body is a whole RunStatusFile, freshness by `generated` date, no merge (the whole file replaces the bundled one).
- Trust: a validly signed file replaces ALL ratings; the key is the same one that guards recs and shared settings. Compromise of that key already allows recs changes; ratings are display-only (no config or code is written from them besides labels and "fix lines" counts).
- Replay: older `generated` refused; same-day files accepted (a re-publish on the same day works).
- Risk: ratings shown from a hand-stale kept file vs a newer bundled one is handled (bundled wins when newer).
- Risk: Date parsing uses DateFormatter on a background thread; fine, formatter is created per call.
- Not covered: kept file's `newestBuild` vs running build for the Retest text (uses data as given).
- Needs: compile, a second review, a host test (decode + older/newer/replay cases), device test after the server endpoint exists.
