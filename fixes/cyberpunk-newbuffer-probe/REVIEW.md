# REVIEW cyberpunk-newbuffer-probe
Status: author's own check only (Sonnet thread, Nov 27). NEEDS an independent second review before it goes in a build (rule: second review for every fix).
- One added log line on an existing error path; no behaviour change, no new setting.
- Variables used (info, heap_type, desc, ph, d, r) are all in scope in the quoted block (checked in the source text, not compiled).
- Not compiled, not device-tested.

## Second review (build thread, Nov 27 19:10Z)
Original .diff is malformed (hunk counts wrong). Use cyberpunk-newbuffer-probe-fixed.diff in this folder: same change, applies cleanly to the 0.2.180 tree. Content OK. Not compiled.
