# REVIEW: kk-position-float4 (author's notes; second review still needed)

## Problem (proven by the log text the build thread gave)
Elden Ring and Deep Rock Galactic (DX12 via vkd3d on KosmicKrisp):
`program_source:5:22: error: type 'uint4' (vector of 4 'unsigned int' values) is not valid for attribute 'position'`,
then `invalid return type 'VertexOut' for vertex function`, vr -1000012000.
vkd3d's vertex shader stores gl_Position with an integer type. KosmicKrisp writes each VertexOut member with the
type of its NIR store (msl_iomap.c vs_output_block: alu_type_to_string(info.type)), so position became uint4,
which Metal refuses: [[position]] must be float4.

## Change (3 files, 36 lines)
- msl_iomap.c: new msl_vs_position_float(ctx, location): true for VARYING_SLOT_POS in a vertex shader unless
  MADEIRA_KK_POS_FLOAT is exactly "0" (read once). vs_output_block then declares the member as float4.
- nir_to_msl.c, store_output: when that is true and the stored value is a 32-bit int/uint, the right-hand side is
  wrapped in as_type<floatN>(...) (N = written components), so the bits are kept, as Vulkan treats the output as
  float. Float stores are unchanged. 8/16/64-bit integer stores are not cast (not seen; Metal would still refuse).
- msl_private.h: the declaration. msl_iomap.c gains #include <stdlib.h> for getenv.

## Not checked / limits
- Not compiled (no meson/mako on the laptop). Read twice; util_bitcount and nir_alu_type_get_* are already used
  in nir_to_msl.c.
- A vertex shader that READS its own position output (load_output) still declares the loaded value with the
  store's type; the member is now float4, so such a read of an int-typed position would not compile. Not seen.
- The disk shader cache key does not include the switch: clear the cache when toggling it.
- No collision: kk-playport-pack rev 2 changes nir_to_msl.c only in 0008 (fcanonicalize, a different function);
  this patch applies after the whole pack and after kk-archive-cap.
