#!/bin/bash
#
# Script to pre-compile Metal shaders into default.metallib
#
# Usage:
#   ./Scripts/build_metallib.sh                                  # Run with defaults (iphonesimulator)
#   ./Scripts/build_metallib.sh -p iphoneos                      # Build for iOS device
#   ./Scripts/build_metallib.sh -p macosx                        # Build for macOS
#   ./Scripts/build_metallib.sh -o OUTPUT_FILE -s SRC_DIR        # Custom output / sources
#
# Options:
#   -p PLATFORM     Target platform: iphonesimulator | iphoneos | macosx
#                   Defaults to $PLATFORM_NAME (set by Xcode) or "iphonesimulator".
#   -o OUTPUT_FILE  Output file path
#   -s SRC_DIR      Metal source directory (can be specified multiple times)
#   -i INCLUDE_DIR  Header include directory
#
# MSL version and deployment target:
#   - Language: MSL 3.2 (matches Package.swift: .iOS(.v18) / .macOS(.v15))
#     Xcode 26 defaults to MSL 4.0 which requires iOS 26+ / macOS 26+ at runtime.
#   - Deployment target triple is set per platform so the generated metallib can be
#     loaded on iOS 18.0+ / macOS 15.0+ at runtime.
#     Without an explicit -target the Metal compiler embeds the host SDK's default
#     (currently iOS 26 / macOS 26) which causes MTLLibraryErrorDomain Code=1
#     "deployment target not supported" on older OS versions.
#
# Run this script when:
#   - You modify Metal shader files (.metal)
#   - You add new Metal shaders
#

set -euo pipefail

# Default values
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE=""
SRC_DIRS=()
INCLUDE_DIR=""
PLATFORM=""

# Parse arguments
while getopts "p:o:s:i:" opt; do
    case $opt in
        p) PLATFORM="$OPTARG" ;;
        o) OUTPUT_FILE="$OPTARG" ;;
        s) SRC_DIRS+=("$OPTARG") ;;
        i) INCLUDE_DIR="$OPTARG" ;;
        *) echo "Usage: $0 [-p PLATFORM] [-o OUTPUT_FILE] [-s SRC_DIR]... [-i INCLUDE_DIR]" && exit 1 ;;
    esac
done

# Resolve platform: -p flag > $PLATFORM_NAME (Xcode) > default
if [ -z "$PLATFORM" ]; then
    PLATFORM="${PLATFORM_NAME:-iphonesimulator}"
fi

# Map platform to SDK and deployment target triple
# Versions match Package.swift: .iOS(.v18) and .macOS(.v15)
case "$PLATFORM" in
    iphoneos)
        SDK="iphoneos"
        TRIPLE="air64-apple-ios18.0"
        ;;
    macosx)
        SDK="macosx"
        TRIPLE="air64-apple-macos15.0"
        ;;
    iphonesimulator|*)
        SDK="iphonesimulator"
        TRIPLE="air64-apple-ios18.0-simulator"
        ;;
esac

# Set default paths if not provided (matches Plugins/BuildMetalShaders)
if [ ${#SRC_DIRS[@]} -eq 0 ]; then
    SRC_DIRS=(
        "$PROJECT_ROOT/Packages/Sources/MyToyboxScreens/Utils/Shaders"
        "$PROJECT_ROOT/Packages/Sources/MyToyboxScreens/Shaders"
    )
fi

if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE="$PROJECT_ROOT/Packages/Sources/MyToyboxScreens/Resources/default.metallib"
fi

if [ -z "$INCLUDE_DIR" ]; then
    INCLUDE_DIR="$PROJECT_ROOT/Packages/Sources/MyToyboxScreens/Utils/Shaders"
fi

# Temporary directory
BUILD_DIR=$(mktemp -d)
trap "rm -rf $BUILD_DIR" EXIT

echo "🔨 Building Metal shaders (platform=$PLATFORM, sdk=$SDK, target=$TRIPLE)..."

# Collect all .metal files
METAL_FILES=()

for src_dir in "${SRC_DIRS[@]}"; do
    if [ -d "$src_dir" ]; then
        while IFS= read -r -d '' file; do
            METAL_FILES+=("$file")
        done < <(find "$src_dir" -name "*.metal" -print0)
    fi
done

if [ ${#METAL_FILES[@]} -eq 0 ]; then
    echo "⚠️ No Metal files found"
    exit 0
fi

echo "📁 Found ${#METAL_FILES[@]} Metal files"

INCLUDE_ARGS=""
if [ -n "$INCLUDE_DIR" ] && [ -d "$INCLUDE_DIR" ]; then
    INCLUDE_ARGS="-I$INCLUDE_DIR"
fi

# Compile each .metal file to .air
for metal_file in "${METAL_FILES[@]}"; do
    filename=$(basename "$metal_file" .metal)
    echo "  Compiling: $(basename "$metal_file")"
    xcrun -sdk "$SDK" metal -c "$metal_file" \
        -std=metal3.2 \
        -target "$TRIPLE" \
        -fmetal-math-mode=fast \
        -o "$BUILD_DIR/$filename.air" \
        $INCLUDE_ARGS \
        2>&1 || {
            echo "❌ Failed to compile: $metal_file"
            exit 1
        }
done

# Create output directory
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Link .air files to .metallib
echo "🔗 Linking to metallib..."
xcrun -sdk "$SDK" metallib "$BUILD_DIR"/*.air -o "$OUTPUT_FILE"

echo "✅ Successfully created: $OUTPUT_FILE"
echo "   Size: $(du -h "$OUTPUT_FILE" | cut -f1)"
