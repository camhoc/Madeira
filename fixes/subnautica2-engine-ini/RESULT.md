# RESULT: subnautica2-engine-ini

**PASS / NEEDS-DEVICE**

Checked on the Linux laptop against 0.2.180-og.

## Run
- Applies with `patch -p6` from the tree root. `-p1` does NOT work (headers hold absolute /mnt/project-files paths). Result matches the files in new/.
- check-game-recommendations.py exit 0; check-ini-editor.py exit 0.
- Swift typecheck of the whole app: no new errors (only the existing Squeeze one).

## Review: PASS WITH NOTES
- Does what README says. IniDocument.add replaces an existing key, so repeated starts do not pile up lines. A new or empty file is handled. Project names cannot contain slashes or be "..".
- Off switch env.MADEIRA_UE_INI_SEED = 0 (or no line): nothing is written. Lines already written stay in Engine.ini until the game deletes it.
- Other games: only a config with the key is affected; only the Subnautica 2 list sets it.
- The 788-character config line: no per-line limit found in the config readers.
- If an existing Engine.ini has a key twice, only the first is updated.
- Not checked: whether existing users' old -dpcvars argument gets cleared without Reset. ConfigCatalog needs regenerating.

## Conflicts in check-game-recommendations.py
- with cyberpunk-direct-start: YES (hunk at line 497, the version assert).
- with planet-crafter-wg64: no.
- cyberpunk-direct-start and planet-crafter-wg64 DO conflict with each other.
