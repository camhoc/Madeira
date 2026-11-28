# kk-archive-cap (0010, on top of kk-metal-archive 0009, Mesa 26.3.1)
Why: the iediot/Madeira notes saw memory grow without limit from opened Metal archives. Our 0009 opened up to 256 files with no byte limit and flushed every 30 s (flush cost ~8% in 0.2.101).
What:
- env.MADEIRA_KK_ARCHIVE_MAX_MB (default 2048, 0 = no cap): newest-first, files that would push the opened total past the cap are NOT opened and stay on disk.
- env.MADEIRA_KK_ARCHIVE_FLUSH_S (default 120, valid 5..3600): seconds between flushes (was fixed 30).
- [kk-archive] start line now shows opened MB, skipped(cap), cap and flush.
Off switch: still env.MADEIRA_KK_METAL_ARCHIVE (0009). With it unset nothing changes.
Unproven: not compiled; real archive size for Detroit unknown (check opened MB on the next run); a longer flush means up to 120 s of new pipelines lost if iOS kills the app.
Code is ours (MIT); the idea comes from the iediot notes, nothing copied.
