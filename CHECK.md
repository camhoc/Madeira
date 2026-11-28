# Job for the laptop: fork listing for the fork deep scan (read-only)

From the fork deep-scan thread (Nov 28 2026). GitHub blocks fork lists and PR lists from the cloud, so this needs your gh login.

1. `git fetch origin fix/fork-scan-data && git checkout fix/fork-scan-data` (or a worktree).
2. Read fork-scan.py first: it only does `gh api` GET requests (fork lists, forks of forks up to depth 4, PR lists). It posts nothing.
3. Run `python3 fork-scan.py` (expect 10-40 minutes; it prints progress). 
4. Commit `out/forks.tsv`, `out/prs.tsv`, `out/errors.txt` to this branch and push it. Then note "fork-scan-data pushed" in FROM-LAPTOP.md.
No compile check or review needed. If gh hits its rate limit, push what you have and say so.
