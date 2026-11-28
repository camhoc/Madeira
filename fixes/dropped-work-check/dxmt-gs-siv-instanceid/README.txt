dxmt-gs-siv-instanceid (made Nov 15): 3 lines in src/airconv/dxbc_signature.cpp (handle_signature_gs), on the dxmt pin 1aab69fd (willfaust/dxmt ios-port).
Adds CLIP_DISTANCE/CULL_DISTANCE siv inputs (GTA V Enhanced, "unhandled geometry shader siv") and SV_GSInstanceID input (Frostpunk, "unhandled geometry shader input").
Same as upstream 3Shain/dxmt 767d462 + 7854fdf (each tiny). Apply in the dxmt submodule. Unbuilt, untested. NOT upstream.
Test: GTA V Enhanced, Frostpunk. Risk: GS body may still hit another unhandled case (assert) after the signature passes; the pinned fork already has GS instance-id and gs_instance_count code.
