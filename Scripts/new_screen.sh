#!/bin/bash
#
# Script to create a new screen with boilerplate code
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
    
    # Prompt for screen name
    read -p "Screen name (e.g., ParticleEffect): " SCREEN_NAME
    
    if [ -z "$SCREEN_NAME" ]; then
        echo -e "${RED}❌ Error: Screen name is required${NC}"
        exit 1
    fi
    
    # Prompt for shader
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

# Paths
SCREENS_DIR="$PROJECT_ROOT/Packages/Sources/MyToyboxScreens/Screens"
SHADERS_DIR="$PROJECT_ROOT/Packages/Sources/MyToyboxScreens/Shaders"
SCREENS_JSON="$PROJECT_ROOT/Packages/Sources/MyToyboxScreens/Resources/Screens.json"
TARGET_DIR="$SCREENS_DIR/$UPPER_CAMEL"

# Check if screen already exists
if [ -d "$TARGET_DIR" ]; then
    echo -e "${RED}❌ Error: Screen '$UPPER_CAMEL' already exists at $TARGET_DIR${NC}"
    exit 1
fi

echo -e "${BLUE}📁 Creating screen: ${UPPER_CAMEL}${NC}"

# Create directory
mkdir -p "$TARGET_DIR"

# Generate Swift file
if [ "$INCLUDE_SHADER" = true ]; then
    # With shader
    cat > "$TARGET_DIR/${UPPER_CAMEL}Screen.swift" << EOF
import SwiftUI

/// ${UPPER_CAMEL} screen demonstrating a custom visual effect.
public struct ${UPPER_CAMEL}Screen: View {
    @State private var time: Double = 0
    private let startDate = Date()
    
    public init() {}
    
    public var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startDate)
            
            Rectangle()
                .colorEffect(
                    ShaderLibrary.module.${LOWER_CAMEL}(
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

    # Generate Metal shader
    cat > "$SHADERS_DIR/${UPPER_CAMEL}Shader.metal" << EOF
#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// ${UPPER_CAMEL} shader effect.
///
/// - Parameters:
///   - position: The pixel position in the view.
///   - color: The current color at this position.
///   - time: Elapsed time in seconds.
/// - Returns: The modified color.
[[stitchable]] half4 ${LOWER_CAMEL}(
    float2 position,
    half4 color,
    float time
) {
    // TODO: Implement shader effect
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
    echo -e "  ${GREEN}✓${NC} Created ${UPPER_CAMEL}Shader.metal"
else
    # Without shader
    cat > "$TARGET_DIR/${UPPER_CAMEL}Screen.swift" << EOF
import SwiftUI

/// ${UPPER_CAMEL} screen.
public struct ${UPPER_CAMEL}Screen: View {
    public init() {}
    
    public var body: some View {
        VStack {
            Text("${UPPER_CAMEL}")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // TODO: Implement your view
        }
    }
}

#Preview {
    ${UPPER_CAMEL}Screen()
}
EOF

    echo -e "  ${GREEN}✓${NC} Created ${UPPER_CAMEL}Screen.swift"
fi

# Add to Screens.json
if [ -f "$SCREENS_JSON" ]; then
    # Create new entry
    NEW_ENTRY=$(cat << EOF
    {
        "id": "${SCREEN_ID}",
        "title": "${UPPER_CAMEL}",
        "description": "TODO: Add description",
        "tags": []
    }
EOF
)
    
    # Insert before the last ]
    # Using a temporary file for compatibility
    TEMP_FILE=$(mktemp)
    
    # Remove trailing whitespace and ] from the end, add comma and new entry
    sed '$ s/^[[:space:]]*\]$//' "$SCREENS_JSON" | \
        sed '$ s/$/,/' > "$TEMP_FILE"
    echo "$NEW_ENTRY" >> "$TEMP_FILE"
    echo "]" >> "$TEMP_FILE"
    
    mv "$TEMP_FILE" "$SCREENS_JSON"
    
    echo -e "  ${GREEN}✓${NC} Added entry to Screens.json"
fi

echo ""
echo -e "${GREEN}✅ Successfully created ${UPPER_CAMEL}Screen${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Implement your view in ${TARGET_DIR}/${UPPER_CAMEL}Screen.swift"
if [ "$INCLUDE_SHADER" = true ]; then
    echo "  2. Implement your shader in ${SHADERS_DIR}/${UPPER_CAMEL}Shader.metal"
    echo "  3. Update the description in Screens.json"
else
    echo "  2. Update the description in Screens.json"
fi
echo "  4. Build and run to see your new screen"

