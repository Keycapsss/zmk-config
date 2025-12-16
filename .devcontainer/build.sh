#!/bin/bash

# Build script for lpgalaxy_blank_slate
# Usage: ./build.sh [left|right] (optional, generic build if omitted)

set -e

BOARD="lpgalaxy_blank_slate"
SHIELD="" # shield if applicable, but lpgalaxy_blank_slate is usually a board itself or has specific shields
KEYMAP_FILE="config/felerius_blank_slate.keymap"
BUILD_DIR="build"

echo "Building for board: $BOARD"
echo "Keymap: $KEYMAP_FILE"

# Clean build directory if requested (optional)
# rm -rf "$BUILD_DIR"

# Run west build
# We use the path relative to the workspace root for the keymap
west build -s zmk/app -b "$BOARD" -d "$BUILD_DIR" -- -DZMK_KEYMAP="${PWD}/${KEYMAP_FILE}"

echo "Build complete. Firmware is located at: $BUILD_DIR/zephyr/zmk.uf2"
