# REVIEW: direct-relative-touch
Self-check done; second review pending.

## Second review (fresh reviewer, source read, not compiled): PASS WITH FIXES -> both applied
1. Stuck button if Relative toggled mid-touch: fixed. The mode is decided at touch-down (`directRelTouch` set only when relative); Moved/Ended/Cancelled follow that touch, not the live setting.
2. Second finger could overwrite the delta origin: fixed. One tracked touch; others ignored while it is down.
Not re-reviewed after the fixes (small); build thread compile is the check.
