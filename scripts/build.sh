#!/usr/bin/env bash
set -euo pipefail

ODIN_SRC="src"
OUT_DIR="build"
OUT_BIN="$OUT_DIR/game"

mkdir -p "$OUT_DIR"

odin build "$ODIN_SRC" \
    -out:"$OUT_BIN" \
    -debug \

"./$OUT_BIN"
