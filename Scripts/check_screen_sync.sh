#!/bin/bash
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

SCREEN_SWIFT_FILE="$PROJECT_ROOT/Packages/Sources/MyToyboxScreens/Screen.swift"

# Extract case names from Screen.swift enum
# Format: case caseName (4 spaces before case)
IDS=$(grep -E '^    case [a-zA-Z_][a-zA-Z0-9_]*' "$SCREEN_SWIFT_FILE" | sed -E 's/^    case ([a-zA-Z_][a-zA-Z0-9_]*).*/\1/' | grep -v '^$')

# Validate that each id can be used as a Swift enum case name.
validate_identifier() {
    local id="$1"

    if [[ ! "$id" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "❌ Error: Invalid screen id for Swift identifier: \"$id\"" >&2
        echo "   - id must match: ^[a-zA-Z_][a-zA-Z0-9_]*$" >&2
        echo "   - example: gameOfLifeScreen, appleLogoScreen" >&2
        exit 1
    fi
}

# Check for duplicates and invalid identifiers
TMP_IDS=$(mktemp)
trap 'rm -f "$TMP_IDS"' EXIT

echo "$IDS" > "$TMP_IDS"

TOTAL_COUNT=$(wc -l < "$TMP_IDS" | tr -d ' ')
UNIQUE_COUNT=$(sort "$TMP_IDS" | uniq | wc -l | tr -d ' ')

EXIT_CODE=0

while IFS= read -r id; do
    validate_identifier "$id"
done <<< "$IDS"

if [ "$TOTAL_COUNT" -ne "$UNIQUE_COUNT" ]; then
    echo "❌ Error: Duplicate screen ids found in Screen.swift:" >&2
    sort "$TMP_IDS" | uniq -d | sed 's/^/  - /' >&2
    EXIT_CODE=1
fi

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Screen.swift case names are valid Swift identifiers and unique ($TOTAL_COUNT screens)"
fi

exit $EXIT_CODE
