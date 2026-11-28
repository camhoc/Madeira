# CHECK: test-hooks
Targets the 0.2.180 source tree, not main. Read README.md and REVIEW.md. Apply, Swift typecheck, check it is inert unless bundle id is the iPad ID and env.MADEIRA_IPAD_TEST_HOOKS = 1 (default off), and that it adds no new bundle ID text beyond what the iPad-ID removal plan allows (flag it). Check pbxproj if new files. RESULT.md "Compile:" and "Review:" PASS or FAIL.
