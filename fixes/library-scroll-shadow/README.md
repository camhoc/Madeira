# library-scroll-shadow (base 0.2.180, NewLook.swift only)
Symptom (Cameron, Nov 26): fast scrolling in the Library is choppy, drops frames.
Cause: UNPROVEN. No log line or profile of a scroll yet. Code evidence only: each cover (NewLookCover) draws a radius-9 blurred
shadow on the clipped picture, a live offscreen blur per cell per frame; 20+ cells visible while scrolling.
Fix: shadow from a plain rounded rectangle behind the cover (cacheable), same look. Off: env.MADEIRA_LIBRARY_SCROLL_SHADOW = 0 (read once).
Not done: PadItem's onGeometryChange (global frame, every cell, every scroll frame, main thread) is a second suspect; left alone because pad highlight needs the frames.
Status: NOT compiled, NOT device-tested, NOT second-reviewed. Needs PC typecheck.
Online: Apple forums/dev.to LazyVGrid lag threads list shadows, blurs and per-cell onGeometryChange as common causes (searched, not read in depth); no Madeira-specific hit.
