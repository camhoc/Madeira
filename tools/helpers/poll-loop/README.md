# poll-loop
Usage: `python3 -B poll-loop.py --repo <clone> --state <file> [--watch <download>]...`
Prints one `changed: ...` line when a fix/* head or watched file size changed (the chat files live on
fix/laptop-chat); otherwise nothing. Network: `git ls-remote` only.
Tested 2026-11-27: first run listed the branches, an immediate second run printed nothing.
