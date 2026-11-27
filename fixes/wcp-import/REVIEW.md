# REVIEW wcp-import
Status: first draft by the WCP thread (Nov 27 2026). NOT compiled, NOT second-reviewed, NOT device-tested. Do not put in a build until: (1) a real .wcp sample is checked against the schema, (2) the tar+zstd/xz unpack is written and typechecks, (3) an independent second review.
Known gaps: install step and ModKind.component not written yet; FEX target folder unknown; zstd streaming support unchecked.
Off switch: env.MADEIRA_WCP_IMPORT = 0.
Update Nov 27: format now checked on one real DXVK .wcp (xz tar, ${system32}/${syswow64} targets); WCPProfile.parse updated for those placeholders. Still missing: xz-tar reader, link-aware install/uninstall, FEX sample (download URL was dead).
Update Nov 27 (2): design changed to per-game package folder + link-source override (WineProcessBridge.m diff, WCPStore.swift). Diff generated against source/madeira-0.2.101 (checked it applies as text, NOT compiled). Review points: helper runs once per route per session; name validated (no "/" or ".."); unset/off/incomplete falls back to bundle; log line "[wcp]" on use.
Update Nov 27 (3): C unpack + PE-kind check host-tested (see README STATUS). Second review should look at: wcp_untar.c tar parsing (padding handling after long-name/pax entries, caps), WCPStore.importPackage temp-folder cleanup, WCPSection state refresh, and that wrong-arch refusal is wanted for plain x64 DXVK.
