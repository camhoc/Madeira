# CHECK: editor-plain-labels
- Swift: needs the Mac runner (Xcode) to typecheck/compile. On the laptop: review the diff and run only the Python host checks the README names.
- NOT in any build yet; queued for the next build after review.
- Base: the patch is written against the Madeira 0.2.180 source tree (release 0.2.180-og, source zip), NOT against this repository's main (older upstream layout). Paths inside the patch are relative to that tree. Do not expect it to apply to main.
- What to verify: see README.md and REVIEW.md in this folder (symptom, change, off switch). 
- Report: post the result to the Madeira project (pass/fail, compiler output if any). Do not merge or push to main.
