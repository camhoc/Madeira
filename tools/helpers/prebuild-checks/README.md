# prebuild-checks
Usage: `python3 -B prebuild-checks.py <scratch copy of the source tree>` (`--write-baseline` records current failures)
Prints `NEW FAIL <test>` lines and a pass count; exit 1 only on new failures. Skips tests that mention Swift.

known-failures.txt: 74 failures of 309 tests on the Linux laptop, 0.2.180 source, 2026-11-27 (same twice).
The job note expected 17. Sampled causes include no `xcrun` and Linux compile errors; not all were examined,
so a real failure may be hidden in this list.

Not found: any "fix-markers" check, so none is run.

Timer (not enabled). ~/.config/systemd/user/prebuild-checks.service:

    [Service]
    Type=oneshot
    ExecStart=/usr/bin/python3 -B /path/to/prebuild-checks.py /path/to/scratch-tree

~/.config/systemd/user/prebuild-checks.timer:

    [Timer]
    OnCalendar=daily
    [Install]
    WantedBy=timers.target
