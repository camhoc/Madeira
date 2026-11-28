#!/bin/bash
# cd <Madeira source root with wine zips merged>; POOL=0 skips 0002/0004/0012 (default: applied, opt-in switches, Memory pool thread KEEP); PAD=0 skips 0005 (default: applied, Controllers thread agreed).
# NOT compiled. Laptop compile + review via build thread.
H=$(dirname "$(readlink -f "$0")"); D=$H/../upstream-615-ubisoft-split
for p in "$D"/00*.patch; do n=$(basename $p | cut -c1-4)
  case $n in
    0017|0018) echo "skip $n (already covered in 0.2.180, see REVIEW.md)"; continue;;
    0002|0004|0012) [ "$POOL" = 0 ] && { echo "skip $n (POOL=0)"; continue; };;
    0005) [ "$PAD" = 0 ] && { echo "skip $n (PAD=0)"; continue; };;
  esac
  X=(--exclude='app/Madeira/ConfigCatalog.generated.swift'); [ $n = 0010 ] && X+=(--exclude=wine)   # no wine pin bump
  git apply "${X[@]}" --reject --whitespace=nowarn "$p" 2>&1 | grep -E "Rejected" | sed "s/^/$n: /"
done
for w in "$H"/wine/*.patch; do (cd wine && git apply -p1 "$w") || echo "wine patch $(basename $w) FAILED"; done
python3 "$H/hand-merge.py"
git mv -f build/fex-patches/0002-ios-split-lock-atomics-inline.patch build/fex-patches/0028-ios-split-lock-atomics-inline.patch 2>/dev/null || mv build/fex-patches/0002-ios-split-lock-atomics-inline.patch build/fex-patches/0028-ios-split-lock-atomics-inline.patch
sed -i 's/`0002-ios-split-lock-atomics-inline.patch`/`0028-ios-split-lock-atomics-inline.patch`/' build/fex-patches/README.md
echo "Then: regenerate ConfigCatalog.generated.swift; hand-merge GameRecommendations fixtures; review leftover *.rej (build.sh/docs hunks may be dropped)."
