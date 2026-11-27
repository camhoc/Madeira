# steam-big-picture (ml2260) — NOT built, NOT device-tested, second review pending

Base: source/madeira-0.2.180. Patch: steam-big-picture.patch (Library, NewLook, FluxScreens, SettingsPages; 9 hunks).

## What it does
The launch code (ml2021 big-picture.bat, ml2210 pin, ml2230/2240 library lists, ml2250 hang-kill, recommendation list steam-big-picture v6) is already in 0.2.180 but hidden: `bigPictureShown` was only true when compiled with MADEIRA_BIG_PICTURE_UI, and no UI row ever used `bigPictureEntry`. This patch:
1. `bigPictureShown` becomes a runtime switch (UserDefaults `bigPictureShown`, default ON). Old compile flag no longer needed.
2. Adds a "Steam Big Picture" row under "Windows Desktop" on the Stores tab (NewLookStoresPage) and the console-look rail (FluxStoresRoot). Shown only when the Dock's steam.exe or Big Picture's own client exists (`steamClientInstalled`). Tapping opens the Big Picture entry's page like Desktop does.
3. Off switch: Settings > Appearance > "Steam Big Picture" toggle. Per-game lines stay in the entry's own config (steam-big-picture list); nothing added to madeira.cfg.

## Why it was left out (from code comments, not from a log I re-read this session)
Header comment: "Big Picture is unfinished". Recommendation history: v4 UI loaded; v5 V8 JIT froze the UI (254,000 emulated stores in 40 s); v6 renderer thread hung on a libcef lock in 3 of 4 starts, so a 40 s hang-kill restarts the web helper. Cause lines for those are in logs 111-119 (not in the shared folder under that name; I did not find them). Treat "works reliably" as UNPROVEN.

## Risks for second review
- Not compiled (no Xcode here). Check the three Library.swift call sites + FluxStoresRoot/NewLookStoresPage new `bigPicture:` parameter (defaulted nil).
- First run downloads Valve's client (CDN) into C:\Program Files\Steam Big Picture; storage + network use.
- Flux rail row only appears if FluxStoresRoot is used; a plain old-look Desktop button was not touched.
- Must test on iPhone and iPad: start, UI reaches home, pad/touch works, games listed (ml2230), second start after force-quit.
- Does Steam Input see Madeira's pad inside it? That is the question to test, not assumed.

## Queue
Joins the next-build queue (builds wait for everything). No GitHub write.
