# Job for the laptop: fork listing for the fork deep scan (read-only)

From the fork deep-scan thread (Nov 28 2026). GitHub blocks fork lists and PR lists from the cloud, so this needs your gh login.

1. `git fetch origin fix/fork-scan-data && git checkout fix/fork-scan-data` (or a worktree).
2. Read fork-scan.py first: it only does `gh api` GET requests (fork lists, forks of forks up to depth 4, PR lists). It posts nothing.
3. Run `python3 fork-scan.py` and then `python3 gitlab-scan.py` (anonymous GitLab/Codeberg GETs; cloud is blocked from those hosts). Expect 20-60 minutes total.
4. Commit everything in `out/` to this branch and push it.
No compile check or review needed. If gh hits its rate limit, push what you have and say so.
