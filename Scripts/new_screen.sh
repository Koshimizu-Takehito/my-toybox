#!/bin/bash
#
# Script to create a new screen as an individual SPM module
#
# Usage:
#   ./Scripts/new_screen.sh                    # Interactive mode
#   ./Scripts/new_screen.sh ParticleEffect     # With name argument
#   ./Scripts/new_screen.sh ParticleEffect -s  # With Metal shader
#
# Options:
#   -s, --shader  Include a Metal shader template
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
SCREEN_NAME=""
INCLUDE_SHADER=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--shader)
            INCLUDE_SHADER=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [ScreenName] [-s|--shader]"
            echo ""
            echo "Options:"
            echo "  -s, --shader  Include a Metal shader template"
            echo "  -h, --help    Show this help message"
            exit 0
            ;;
        *)
            if [ -z "$SCREEN_NAME" ]; then
                SCREEN_NAME="$1"
            fi
            shift
            ;;
    esac
done

# Interactive mode if no name provided
if [ -z "$SCREEN_NAME" ]; then
    echo -e "${BLUE}🆕 Create New Screen${NC}"
    echo ""

    read -p "Screen name (e.g., ParticleEffect): " SCREEN_NAME

    if [ -z "$SCREEN_NAME" ]; then
        echo -e "${RED}❌ Error: Screen name is required${NC}"
        exit 1
    fi

    read -p "Include Metal shader? (y/N): " SHADER_ANSWER
    if [[ "$SHADER_ANSWER" =~ ^[Yy]$ ]]; then
        INCLUDE_SHADER=true
    fi

    echo ""
fi

# Validate screen name (must be UpperCamelCase)
if [[ ! "$SCREEN_NAME" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
    echo -e "${RED}❌ Error: Screen name must be UpperCamelCase (e.g., ParticleEffect)${NC}"
    exit 1
fi

# Convert to various cases
UPPER_CAMEL="$SCREEN_NAME"
LOWER_CAMEL="$(echo "${SCREEN_NAME:0:1}" | tr '[:upper:]' '[:lower:]')${SCREEN_NAME:1}"
SCREEN_ID="${LOWER_CAMEL}Screen"
TARGET_NAME="Screen_${UPPER_CAMEL}"

# Paths
PACKAGE_DIR="$PROJECT_ROOT/Packages"
MODULE_DIR="$PACKAGE_DIR/Sources/Screens/$UPPER_CAMEL"
PACKAGE_SWIFT="$PACKAGE_DIR/Package.swift"
SCREEN_SWIFT="$PACKAGE_DIR/Sources/MyToyboxCatalog/Screen.swift"

# Check if screen already exists
if [ -d "$MODULE_DIR" ]; then
    echo -e "${RED}❌ Error: Screen '$UPPER_CAMEL' already exists at $MODULE_DIR${NC}"
    exit 1
fi

echo -e "${BLUE}📁 Creating screen module: ${TARGET_NAME}${NC}"

# Create directories
mkdir -p "$MODULE_DIR/Resources"

# --- Generate Localizable.xcstrings ---
cat > "$MODULE_DIR/Resources/Localizable.xcstrings" << EOF
{
  "sourceLanguage": "en",
  "strings": {
    "screen.${LOWER_CAMEL}.description": {
      "extractionState": "manual",
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "TODO: Add description"
          }
        },
        "ja": {
          "stringUnit": {
            "state": "translated",
            "value": "TODO: 説明を追加"
          }
        }
      }
    },
    "screen.${LOWER_CAMEL}.title": {
      "extractionState": "manual",
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "${UPPER_CAMEL}"
          }
        },
        "ja": {
          "stringUnit": {
            "state": "translated",
            "value": "${UPPER_CAMEL}"
          }
        }
      }
    }
  },
  "version": "1.0"
}
EOF
echo -e "  ${GREEN}✓${NC} Created Resources/Localizable.xcstrings"

# --- Generate Swift files ---
if [ "$INCLUDE_SHADER" = true ]; then
    mkdir -p "$MODULE_DIR/Shaders"

    # Screen file (shader variant)
    cat > "$MODULE_DIR/${UPPER_CAMEL}Screen.swift" << EOF
import SwiftUI
import MyToyboxCore

@Metadata(title: "${UPPER_CAMEL}", description: "TODO: Add description", tags: [])
public struct ${UPPER_CAMEL}Screen: View {
    @State private var time: Double = 0
    private let startDate = Date()

    public init() {}

    public var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startDate)

            Rectangle()
                .colorEffect(
                    ShaderLibrary.screenModule.${LOWER_CAMEL}(
                        .float(elapsed)
                    )
                )
        }
    }
}

#Preview {
    ${UPPER_CAMEL}Screen()
}
EOF

    # Thumbnail file (shader variant)
    cat > "$MODULE_DIR/${UPPER_CAMEL}Screen+Thumbnail.swift" << EOF
import SwiftUI

extension ${UPPER_CAMEL}Screen {
    @ViewBuilder
    public static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        Rectangle()
            .colorEffect(
                ShaderLibrary.screenModule.${LOWER_CAMEL}(
                    .float(time)
                )
            )
    }
}

#Preview {
    ${UPPER_CAMEL}Screen.thumbnail
        .colorScheme(.dark)
}
EOF

    # ShaderLibrary+ScreenModule.swift
    cat > "$MODULE_DIR/ShaderLibrary+ScreenModule.swift" << EOF
import SwiftUI

extension ShaderLibrary {
    static var screenModule: ShaderLibrary {
        if let url = Bundle.module.url(forResource: "default", withExtension: "metallib") {
            return ShaderLibrary(url: url)
        }
        return .default
    }
}
EOF

    # Metal shader file
    cat > "$MODULE_DIR/Shaders/${UPPER_CAMEL}Shader.metal" << EOF
#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[stitchable]] half4 ${LOWER_CAMEL}(
    float2 position,
    half4 color,
    float time
) {
    float2 uv = position / 400.0;

    half3 result = half3(
        sin(uv.x * 10.0 + time) * 0.5 + 0.5,
        sin(uv.y * 10.0 + time * 1.5) * 0.5 + 0.5,
        sin((uv.x + uv.y) * 5.0 + time * 2.0) * 0.5 + 0.5
    );

    return half4(result, 1.0);
}
EOF

    echo -e "  ${GREEN}✓${NC} Created ${UPPER_CAMEL}Screen.swift (with shader)"
    echo -e "  ${GREEN}✓${NC} Created ${UPPER_CAMEL}Screen+Thumbnail.swift"
    echo -e "  ${GREEN}✓${NC} Created ShaderLibrary+ScreenModule.swift"
    echo -e "  ${GREEN}✓${NC} Created Shaders/${UPPER_CAMEL}Shader.metal"
else
    # Screen file (no shader)
    cat > "$MODULE_DIR/${UPPER_CAMEL}Screen.swift" << EOF
import SwiftUI
import MyToyboxCore

@Metadata(title: "${UPPER_CAMEL}", description: "TODO: Add description", tags: [])
public struct ${UPPER_CAMEL}Screen: View {
    public init() {}

    public var body: some View {
        VStack {
            Text("${UPPER_CAMEL}")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    ${UPPER_CAMEL}Screen()
}
EOF

    # Thumbnail file (no shader)
    cat > "$MODULE_DIR/${UPPER_CAMEL}Screen+Thumbnail.swift" << EOF
import SwiftUI

extension ${UPPER_CAMEL}Screen {
    @ViewBuilder
    public static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        Text("${UPPER_CAMEL}")
            .font(.caption2)
            .fontWeight(.bold)
    }
}

#Preview {
    ${UPPER_CAMEL}Screen.thumbnail
        .colorScheme(.dark)
}
EOF

    echo -e "  ${GREEN}✓${NC} Created ${UPPER_CAMEL}Screen.swift"
    echo -e "  ${GREEN}✓${NC} Created ${UPPER_CAMEL}Screen+Thumbnail.swift"
fi

# --- Update Package.swift (add target + add dependency to MyToyboxCatalog) ---
awk -v name="$TARGET_NAME" -v upper="$UPPER_CAMEL" -v shader="$INCLUDE_SHADER" '
    /MARK: - MyToyboxClipCatalog/ && !target_inserted {
        print "        .target("
        print "            name: \"" name "\","
        print "            dependencies: [\"MyToyboxCore\"],"
        print "            path: \"Sources/Screens/" upper "\","
        if (shader == "true") {
            print "            exclude: [\"Shaders\"],"
        }
        print "            resources: [.process(\"Resources\")]" (shader == "true" ? "," : "")
        if (shader == "true") {
            print "            plugins: [.plugin(name: \"BuildMetalShaders\")]"
        }
        print "        ),"
        print ""
        target_inserted = 1
    }
    /MARK: - MyToyboxCatalog/ { in_screens = 1 }
    in_screens && !dep_inserted && /\.product\(name: "MetadatasMacros"/ {
        print "                \"" name "\","
        dep_inserted = 1
    }
    { print }
' "$PACKAGE_SWIFT" > "$WORK_DIR/Package.swift"
mv "$WORK_DIR/Package.swift" "$PACKAGE_SWIFT"

if ! grep -q "name: \"${TARGET_NAME}\"" "$PACKAGE_SWIFT"; then
    echo -e "  ${RED}❌ Error: Failed to add target to Package.swift${NC}"
    exit 1
fi
echo -e "  ${GREEN}✓${NC} Added target to Package.swift"

if ! grep -q "^                \"${TARGET_NAME}\"," "$PACKAGE_SWIFT"; then
    echo -e "  ${RED}❌ Error: Failed to add dependency to MyToyboxCatalog${NC}"
    exit 1
fi
echo -e "  ${GREEN}✓${NC} Added dependency to MyToyboxCatalog"

# --- Add case to Screen.swift ---
if [ -f "$SCREEN_SWIFT" ]; then
    if grep -q "^    case ${SCREEN_ID}" "$SCREEN_SWIFT"; then
        echo -e "  ${YELLOW}⚠${NC} Case '${SCREEN_ID}' already exists in Screen.swift"
    else
        awk -v new_case="    case ${SCREEN_ID}" '
            /^}/ {
                print new_case
                print
                next
            }
            { print }
        ' "$SCREEN_SWIFT" > "$WORK_DIR/Screen.swift"
        mv "$WORK_DIR/Screen.swift" "$SCREEN_SWIFT"
        if ! grep -q "^    case ${SCREEN_ID}$" "$SCREEN_SWIFT"; then
            echo -e "  ${RED}❌ Error: Failed to add case to Screen.swift${NC}"
            exit 1
        fi
        echo -e "  ${GREEN}✓${NC} Added case to Screen.swift"
    fi
fi

echo ""
echo -e "${GREEN}✅ Successfully created ${TARGET_NAME} module${NC}"
echo ""

echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Implement your view in ${MODULE_DIR}/${UPPER_CAMEL}Screen.swift"
if [ "$INCLUDE_SHADER" = true ]; then
    echo "  2. Implement your shader in ${MODULE_DIR}/Shaders/${UPPER_CAMEL}Shader.metal"
    echo "  3. Refine the thumbnail in ${MODULE_DIR}/${UPPER_CAMEL}Screen+Thumbnail.swift"
    echo "  4. Update @Metadata with title, description, and tags"
    echo "  5. Build and run to see your new screen"
else
    echo "  2. Refine the thumbnail in ${MODULE_DIR}/${UPPER_CAMEL}Screen+Thumbnail.swift"
    echo "  3. Update @Metadata with title, description, and tags"
    echo "  4. Build and run to see your new screen"
fi
