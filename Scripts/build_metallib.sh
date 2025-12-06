#!/bin/bash
#
# Metalシェーダーをプリコンパイルして default.metallib を生成するスクリプト
#
# 使用方法:
#   ./Scripts/build_metallib.sh                           # デフォルト設定で実行
#   ./Scripts/build_metallib.sh -o OUTPUT_FILE -s SRC_DIR # カスタム設定で実行
#
# オプション:
#   -o OUTPUT_FILE  出力ファイルパス（default.metallib）
#   -s SRC_DIR      Metalソースディレクトリ（複数指定可）
#   -i INCLUDE_DIR  ヘッダーのインクルードディレクトリ
#
# このスクリプトは以下の場合に実行してください:
#   - Metalシェーダー(.metal)を変更した場合
#   - 新しいMetalシェーダーを追加した場合
#

set -euo pipefail

# デフォルト値
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE=""
SRC_DIRS=()
INCLUDE_DIR=""

# 引数解析
while getopts "o:s:i:" opt; do
    case $opt in
        o) OUTPUT_FILE="$OPTARG" ;;
        s) SRC_DIRS+=("$OPTARG") ;;
        i) INCLUDE_DIR="$OPTARG" ;;
        *) echo "Usage: $0 [-o OUTPUT_FILE] [-s SRC_DIR]... [-i INCLUDE_DIR]" && exit 1 ;;
    esac
done

# デフォルト値を設定（引数がない場合）
if [ ${#SRC_DIRS[@]} -eq 0 ]; then
    SRC_DIRS=(
        "$PROJECT_ROOT/Packages/Sources/MyToyboxCore/Utils/Shaders"
        "$PROJECT_ROOT/Packages/Sources/MyToyboxScreens/Shaders"
    )
fi

if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE="$PROJECT_ROOT/Packages/Sources/MyToyboxScreens/Resources/default.metallib"
fi

if [ -z "$INCLUDE_DIR" ]; then
    INCLUDE_DIR="$PROJECT_ROOT/Packages/Sources/MyToyboxCore/Utils/Shaders"
fi

# 一時ディレクトリ
BUILD_DIR=$(mktemp -d)
trap "rm -rf $BUILD_DIR" EXIT

echo "🔨 Building Metal shaders..."

# すべての.metalファイルを収集
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

# 各.metalファイルを.airにコンパイル
INCLUDE_ARGS=""
if [ -n "$INCLUDE_DIR" ] && [ -d "$INCLUDE_DIR" ]; then
    INCLUDE_ARGS="-I$INCLUDE_DIR"
fi

for metal_file in "${METAL_FILES[@]}"; do
    filename=$(basename "$metal_file" .metal)
    echo "  Compiling: $(basename "$metal_file")"
    xcrun -sdk iphonesimulator metal -c "$metal_file" \
        -o "$BUILD_DIR/$filename.air" \
        $INCLUDE_ARGS \
        2>&1 || {
            echo "❌ Failed to compile: $metal_file"
            exit 1
        }
done

# 出力ディレクトリを作成
mkdir -p "$(dirname "$OUTPUT_FILE")"

# .airファイルを.metallibにリンク
echo "🔗 Linking to metallib..."
xcrun -sdk iphonesimulator metallib "$BUILD_DIR"/*.air -o "$OUTPUT_FILE"

echo "✅ Successfully created: $OUTPUT_FILE"
echo "   Size: $(du -h "$OUTPUT_FILE" | cut -f1)"

