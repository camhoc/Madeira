# REVIEW: kk-archive-cap
- License: ours, MIT, public Apple API only. No GPL copied.
- Off switch: env.MADEIRA_KK_METAL_ARCHIVE unset = unchanged (env parsing runs only when on).
- Not compiled. Second review done (Nov 28, read-only). Found and FIXED:
  1. Non-numeric MAX_MB (e.g. "2GB") parsed as 0 = no cap -> strict strtol with endptr check, same for FLUSH_S.
  2. Over-cap files didn't count toward the 256-file limit, so the folder could grow forever -> limit is now opened+bad+capped; oldest past 256 are deleted.
  Left as is: an over-cap file doesn't stop the scan, smaller older files after it can still open (fine).
