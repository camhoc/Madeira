# direct-relative-touch (finger camera too sensitive, iPhone 16 Pro Max report, also iPad)
Online: searched Winlator/GameNative/Wine touch-camera threads (e.g. GameNative discussion 161); none describes this bug or a related open PR. The cause below is from Madeira source, not from the player's log (none supplied yet).
Cause (source, 0.2.98 ContentView.swift): in a direct (non-Dock) session `touchesBegan/Moved/Ended/Cancelled` take `guard desktopMode else {...}` and post ABSOLUTE positions (`winios_post_touch_*`). `InputSettings.relative` and `sensRel` are read only in the Dock/trackpad branch. A game that locks the cursor (ClipCursor) turns absolute positions into large position-dependent deltas (see the ml641 comment), so sensRel has no effect. This matches the player's guess about direct touch with `env.MADEIRA_TOUCH_MOUSE = 1`. Not confirmed on a device.
Change: when Pointer mode = Relative in a direct session, finger motion is sent as deltas scaled by `sensRel * MouseTuning.speed` (same math as the Dock branch, with sub-pixel carry). No click on tap in this mode (same as Dock relative). Absolute behaviour is unchanged when Relative is off. Applies on iPhone and iPad.
Off: `env.MADEIRA_DIRECT_RELATIVE_TOUCH = 0` (per game or global). Marker: `[direct-relative-touch] deltas scaled by sensRel`.
Note: the player's sensRel 0.01 is below the slider minimum (0.10); with this fix 0.01 would make the camera nearly still. Suggest 0.5-2.0.
Limit: still needs Relative on. A player with Relative off keeps the absolute path.
Apply after the tap fixes (ContentView.swift only).
