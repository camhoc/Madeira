#!/bin/bash
# Build triangle12.exe (x86_64 Windows, runs under FEX like a game) for the d3d12 = mullion proof.
# Same shader route as build/d3d11-triangle: SM 5.0 DXBC made with d3dcompiler through the build Mac's Wine.
set -eu
DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$DIR/../.." && pwd)"
MINGW="$REPO_ROOT/toolchains/llvm-mingw-20260421-ucrt-macos-universal/bin"
CC="$MINGW/x86_64-w64-mingw32-clang"
WINE=${WINE:-/opt/homebrew/bin/wine}
[ -x "$DIR/hlsl_compile.exe" ] || "$CC" -o "$DIR/hlsl_compile.exe" "$DIR/hlsl_compile.c" -ld3dcompiler -O2
for stage in vs ps; do
    "$WINE" "$DIR/hlsl_compile.exe" "${stage}_main" "${stage}_5_0" < "$DIR/shaders.hlsl" > "$DIR/$stage.dxbc"
    head -c 4 "$DIR/$stage.dxbc" | grep -q DXBC || { echo "ERROR: $stage.dxbc is not DXBC" >&2; exit 1; }
    xxd -i -n "${stage}_dxbc" "$DIR/$stage.dxbc" > "$DIR/${stage}_dxbc.h"
done
"$CC" -O2 -o "$DIR/triangle12.exe" -I "$DIR" "$DIR/triangle12.c" -ld3d12 -ldxgi -luuid
file "$DIR/triangle12.exe"
