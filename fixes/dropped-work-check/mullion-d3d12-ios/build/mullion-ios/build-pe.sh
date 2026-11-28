#!/bin/bash
# Madeira: Mullion's Windows side (ARM64EC) for the d3d12 = mullion lane.
# Output: app/Madeira/vulkan/mullion/{d3d12,d3d12core,dxgi,d3d11,d3d10core,mlnmetal}.dll
# winemetal is built as mlnmetal.dll (patch 0002), so the session's links to it never
# collide with DXMT's winemetal.dll, and its unix side binds Mullion's own tables
# (build/ntdll-unix/virtual_ios.c "mlnmetal" branch).
# Needs: llvm-mingw (same as DXMT), wine/build-arm64ec (import libs + winebuild), meson, ninja.
set -euo pipefail
BUILD_DIR="$(cd "$(dirname "$0")" && pwd)"
R="$(cd "$BUILD_DIR/../.." && pwd)"
MULLION_ROOT="${MULLION_ROOT:-$R/toolchains/mullion}"
TC="${LLVM_MINGW:-$R/toolchains/llvm-mingw-20260421-ucrt-macos-universal}/bin"
W="$R/wine/build-arm64ec"
B="$R/toolchains/mullion-build-arm64ec"
DEST="$R/app/Madeira/vulkan/mullion"   # inside the existing "vulkan" folder reference: no Xcode project change
export PATH="$TC:$PATH"
[ -x "$TC/arm64ec-w64-mingw32-clang" ] || { echo "llvm-mingw not found: $TC" >&2; exit 1; }
[ -d "$MULLION_ROOT/src" ] || { echo "run build/mullion-ios/build.sh first (it checks out + patches Mullion)" >&2; exit 1; }

CROSS="$B.cross.txt"
cat > "$CROSS" <<CROSSFILE
[binaries]
c = '$TC/arm64ec-w64-mingw32-clang'
cpp = '$TC/arm64ec-w64-mingw32-clang++'
ar = '$TC/arm64ec-w64-mingw32-ar'
strip = '$TC/arm64ec-w64-mingw32-strip'
windres = '$TC/arm64ec-w64-mingw32-windres'

[properties]
needs_exe_wrapper = true

[host_machine]
system = 'windows'
cpu_family = 'aarch64'
cpu = 'aarch64'
endian = 'little'
CROSSFILE

# always reconfigure, so a changed option or patch reaches an existing build dir
SETUP_MODE=""; [ -f "$B/build.ninja" ] && SETUP_MODE="--reconfigure"
SDKROOT="$(xcrun --sdk macosx --show-sdk-path)" meson setup $SETUP_MODE "$B" "$MULLION_ROOT" \
        --cross-file "$CROSS" --buildtype release \
        -Dwine_build_path="$W" -Dwine_builtin_dll=true -Dbuild_unix_side=false \
        -Dwinemetal_name=mlnmetal -Denable_d3d12=true
SDKROOT="$(xcrun --sdk macosx --show-sdk-path)" meson compile -C "$B"

mkdir -p "$DEST"
for m in d3d12/d3d12.dll d3d12/d3d12core.dll dxgi/dxgi.dll d3d11/d3d11.dll d3d10/d3d10core.dll winemetal/mlnmetal.dll; do
    "$TC/arm64ec-w64-mingw32-strip" --strip-debug -o "$DEST/$(basename "$m")" "$B/src/$m"
    echo "  $(basename "$m"): $(wc -c < "$DEST/$(basename "$m")") bytes"
done
# the import a DLL makes must be mlnmetal.dll, never winemetal.dll (else it would bind DXMT's tables)
for d in "$DEST"/*.dll; do
    if "$TC/llvm-objdump" -p "$d" | grep -qi 'DLL Name: winemetal.dll'; then
        echo "ERROR: $(basename "$d") imports winemetal.dll" >&2; exit 1
    fi
done
