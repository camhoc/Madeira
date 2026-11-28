# steam-layout-import (Nov 27) — "Import Steam layout…" in the controller binds page

Online: Steam Input layouts are plain VDF text ("controller_mappings", groups + a preset's group_source_bindings). Read: SteamTracking controller_generic_wasd.vdf (Valve's own template), GoldRenard/GTAVSteamControllerNative controller.vdf (a community layout); community layouts are shared on the Workshop and SteamInputDB. GameNative downloads layouts from Steam (PR 2471).
Why not run Steam Input: Steam's controller.txt in Madeira says "CHIDDeviceListSDL(): Couldn't load SDL3.dll" (status c000007b in old logs). Separate investigation, PE check pending from the iPad thread.

What it does: Controller binds page (keyboard-and-mouse mode, per game) gets a button. Pick a .vdf; the "Default" preset's active sources are read:
- face buttons A/B/X/Y, bumpers, triggers (click or edge), D-pad, Start (button_escape), Select (button_menu), stick clicks -> key / mouse button / wheel
- stick in dpad mode bound to WASD or the arrow keys -> LS/RS key stick; right stick in joystick_mouse -> mouse
- skipped and listed under the button: gyro, touch pads, action layers, mode shifts, xinput_button / controller_action bindings, sticks with other keys, left stick as mouse
It REPLACES the game's binds table (Reset still works). Needs "Keyboard and mouse" controller mode (the page only shows then).

Off switch: env.MADEIRA_STEAM_LAYOUT_IMPORT = 0 hides the button (read once per launch).
Files: files/SteamLayoutImport.swift (new), files/Library.swift (3 hunks in ControllerBindsPage; based on source/latest = 0.2.99, the diff may need rebasing onto the newest Library.swift), steam-layout-import.diff, prototype-check.py (Python twin of the converter).
Checked: tree-sitter parse errors unchanged (Library 2 = 2, new file 0). The Python twin gives, for Valve's WASD template: LS=WASD, RS=mouse, A=Space, B=E, X=R, Y=F, LB/RB=wheel down/up, LT/RT=right/left click, Start=Esc, Select=Tab, D-pad=1/3/4/2, L3=Shift, R3=left click, nothing skipped. For the GTAV Steam Controller layout: nothing importable (trackpad layout), 3 skipped, as intended. No Swift compiler here, so NOT compiled and NOT device-tested.

Review fixes (Nov 27): "active modeshift" entries no longer count as active; the preset's switch_bindings block is the fallback for bumpers/Start/Select; xinput_button bindings are counted in one line, not listed; triggers prefer edge over click; the summary names the preset; the file picker sits on the Section. prototype-check.py predates the switch_bindings fallback and the modeshift guard (it already skipped modeshift).

Rebased onto the 0.2.180 source (Nov 28): orig/ is now the 0.2.180 file.
