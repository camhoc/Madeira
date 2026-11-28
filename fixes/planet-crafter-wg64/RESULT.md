# RESULT: planet-crafter-wg64 (rev 3)

Checked on the Linux laptop against 0.2.180-og.

## Compile
Applies with `patch -p1`. check-game-recommendations.py: exit 0 (its Swift fixture needs a Mac and did not run here). The app Swift is unchanged from rev 1, which typechecked with no new errors.

## Review: PASS WITH NOTES
- Does what README says; only matches The Planet Crafter (App ID 1284190, its folder, its exe).
- Off switch: env.MADEIRA_WG_64BIT = 0 turns off the 64-bit parser only; README now says so.
- Still conflicts in check-game-recommendations.py with cyberpunk-direct-start and subnautica2-engine-ini (counts and ID lists): whichever goes second needs its counts redone.
- Not device-tested by the laptop.
