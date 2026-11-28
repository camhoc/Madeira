# RESULT: dock-eac-entry (rev 2)

**PASS / NEEDS-DEVICE**

Checked on the Linux laptop against 0.2.180-og.

- dock-eac-entry-2.patch applies with `patch -p1`.
- check-dock-start-program.py: exit 0.
- Swift typecheck of the whole app: no new errors (only the existing ContentView.swift Squeeze iOS 17.5 one).
- Review: only app 976730 is affected; off switch gates the entry choice.
- Not run on a device. ConfigCatalog still needs regenerating for the new switch (per README).
