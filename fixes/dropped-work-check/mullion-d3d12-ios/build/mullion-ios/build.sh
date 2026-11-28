#!/bin/bash
# Madeira: build Mullion's unix side (winemetal unix + cache + airconv + DXBCParser) for iOS-arm64
# as ONE relocatable object, libmullion_unix.o, whose only global symbols are the two call tables
# (mullion_winemetal_unix_call_funcs / _wow64_funcs). Everything else is made private with
# ld -r -exported_symbols_list, so Mullion's copies of airconv/DXBCParser/winemetal (forks of the
# same DXMT code as ours) can link into the one Madeira image beside DXMT without duplicate symbols.
# LLVM stays undefined here and resolves against the LLVM 15 archives already in libdxmt_combined.a
# (Mullion needs LLVM 15 too: its README). The object goes into libdxmt_combined.a.
#
# Source: Mullion (github.com/dttdrv/mullion, LGPL-2.1+, DXMT parts MIT) at MULLION_REV, with
# build/mullion-ios/patches/*.patch applied. Off switch: the app only binds these tables when a
# game's config says d3d12 = mullion (build/ntdll-unix/virtual_ios.c, "mlnmetal" branch).
set -eu

BUILD_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$BUILD_DIR/../.." && pwd)"
MULLION_REV="${MULLION_REV:-11e77a8}"
MULLION_ROOT="${MULLION_ROOT:-$REPO_ROOT/toolchains/mullion}"
SRC="$MULLION_ROOT/src"
LLVM_SRC="$REPO_ROOT/toolchains/llvm-project/llvm"
LLVM_BUILD="$REPO_ROOT/toolchains/llvm-ios-build"
SDK=$(xcrun --sdk iphoneos --show-sdk-path)
OBJ_DIR="$BUILD_DIR/obj"
OUT_OBJ="$BUILD_DIR/libmullion_unix.o"

if [ ! -d "$MULLION_ROOT/.git" ]; then
    git clone https://github.com/dttdrv/mullion "$MULLION_ROOT"
fi
git -C "$MULLION_ROOT" fetch -q origin || true
git -C "$MULLION_ROOT" checkout -q -f "$MULLION_REV"
git -C "$MULLION_ROOT" clean -fdq   # a previous run's patched-in new files (mullion_ios.h) would stop git apply
git -C "$MULLION_ROOT" submodule update --init --recursive
for p in "$BUILD_DIR"/patches/*.patch; do
    git -C "$MULLION_ROOT" apply --whitespace=nowarn "$p"
done

rm -rf "$OBJ_DIR"; mkdir -p "$OBJ_DIR" "$BUILD_DIR/shader-headers"

COMMON_FLAGS="-arch arm64 -isysroot $SDK -miphoneos-version-min=18.0 -fblocks -O2"
INCLUDES="-I$MULLION_ROOT/include -I$MULLION_ROOT/libs -I$SRC/winemetal -I$SRC/airconv -I$SRC/airconv/transforms -I$SRC"
INCLUDES_DIRECTX="-I$MULLION_ROOT/include/native/directx -I$MULLION_ROOT/include/native/windows"
LLVM_INCLUDES="-I$LLVM_BUILD/include -I$LLVM_SRC/include"
AIRCONV_DEFS="-D_FILE_OFFSET_BITS=64 -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS"
CXX_FLAGS="-std=c++20 -fno-exceptions -funwind-tables -fno-rtti -Wno-extern-c-compat"
FAILED=""

run() { # name, command...
    local name=$1; shift
    printf "  %-40s " "$name"
    if "$@" 2>"$OBJ_DIR/$name.err"; then echo OK; else echo FAILED; FAILED="$FAILED $name"; fi
}

echo "=== Mullion winemetal unix (Objective-C, manual retain/release) ==="
for f in winemetal_unix cache; do
    run "$f" xcrun -sdk iphoneos clang $COMMON_FLAGS -x objective-c -fno-objc-arc $INCLUDES \
        -c "$SRC/winemetal/unix/$f.c" -o "$OBJ_DIR/mln_$f.o"
done

echo "=== airconv shader headers (Metal 3.1, as Madeira's DXMT) ==="
for name in air_denorm air_msad air_samplepos air_tessellation; do
    xcrun -sdk macosx metal -std=metal3.1 --target=air64-apple-macos14.0 \
        -o "$BUILD_DIR/shader-headers/$name.air" -c "$SRC/airconv/shaders/$name.metal"
    (cd "$BUILD_DIR/shader-headers" && xxd -n "$name" -i "$name.air" "$name.h")
done

echo "=== airconv (C++20, LLVM 15 headers) ==="
AIRCONV_SRC=$(cd "$SRC/airconv" && ls *.cpp nt/*.cpp transforms/*.cpp | grep -v '^airconv_cli.cpp$')
for cpp in $AIRCONV_SRC; do
    name=mln_air_$(echo "$cpp" | tr '/' '_' | sed 's/\.cpp$//')
    run "$name" xcrun -sdk iphoneos clang++ $COMMON_FLAGS $CXX_FLAGS $INCLUDES $INCLUDES_DIRECTX \
        -I"$BUILD_DIR/shader-headers" $LLVM_INCLUDES $AIRCONV_DEFS -c "$SRC/airconv/$cpp" -o "$OBJ_DIR/$name.o"
done

echo "=== DXBCParser (throws: exceptions on) ==="
for cpp in BlobContainer.cpp DXBCUtils.cpp ShaderBinary.cpp; do
    name=mln_dxbc_$(basename "$cpp" .cpp)
    run "$name" xcrun -sdk iphoneos clang++ $COMMON_FLAGS -std=c++20 -fno-rtti -Wno-extern-c-compat \
        -Wno-unknown-pragmas $INCLUDES $INCLUDES_DIRECTX $AIRCONV_DEFS \
        -c "$MULLION_ROOT/libs/DXBCParser/$cpp" -o "$OBJ_DIR/$name.o"
done

if [ -n "$FAILED" ]; then
    for n in $FAILED; do echo "=== $n ===" >&2; cat "$OBJ_DIR/$n.err" >&2; done
    echo "FAILED:$FAILED" >&2; exit 1
fi

echo "=== prelink: hide everything but the two call tables ==="
printf '_mullion_winemetal_unix_call_funcs\n_mullion_winemetal_unix_call_wow64_funcs\n' > "$BUILD_DIR/exports.txt"
xcrun -sdk iphoneos ld -r -arch arm64 -exported_symbols_list "$BUILD_DIR/exports.txt" \
    -o "$OUT_OBJ" "$OBJ_DIR"/*.o
# a check that the hiding worked: no global definition but the tables
LEAK=$(xcrun nm -gU "$OUT_OBJ" | awk '{print $3}' | grep -v -x -f "$BUILD_DIR/exports.txt" || true)
if [ -n "$LEAK" ]; then echo "ERROR: still global after prelink:" >&2; echo "$LEAK" | head >&2; exit 1; fi
# The app links libdxmt_combined.a (no Xcode project change): add the object there. Run this AFTER
# tools/build/build-dxmt-ios.sh, which recreates that archive. The member is only pulled in when
# ntdll-unix is built with MADEIRA_MULLION=1 (virtual_ios.c then names the tables).
COMBINED="$REPO_ROOT/app/Madeira/libdxmt_combined.a"
[ -f "$COMBINED" ] || { echo "ERROR: $COMBINED missing: run tools/build/build-dxmt-ios.sh first" >&2; exit 1; }
cp "$OUT_OBJ" "$BUILD_DIR/mullion_unix.o"
xcrun -sdk iphoneos ar r "$COMBINED" "$BUILD_DIR/mullion_unix.o"
xcrun -sdk iphoneos ranlib "$COMBINED"
# also the DXMT build's own copy: build/dxmt-ios/build.sh's refresh path copies that one over the app's,
# which would otherwise drop this member and break a MADEIRA_MULLION=1 link
DXMT_COPY="$REPO_ROOT/build/dxmt-ios/libdxmt_combined.a"
if [ -f "$DXMT_COPY" ]; then
    xcrun -sdk iphoneos ar r "$DXMT_COPY" "$BUILD_DIR/mullion_unix.o"
    xcrun -sdk iphoneos ranlib "$DXMT_COPY"
fi
echo "Added mullion_unix.o ($(wc -c < "$OUT_OBJ" | tr -d ' ') bytes) to $COMBINED"
