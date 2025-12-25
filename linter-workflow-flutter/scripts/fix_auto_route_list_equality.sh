#!/bin/bash

# Script to fix auto_route_generator's const ListEquality issue
# This script should be run after build_runner generates the router file
# Known issue: auto_route_generator generates invalid const ListEquality expressions in Dart 3.8+

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ROUTER_FILE="$PROJECT_ROOT/lib/core/router/app_router.gr.dart"

if [ ! -f "$ROUTER_FILE" ]; then
    echo "⚠️  Router file not found: $ROUTER_FILE"
    exit 1
fi

echo "🔧 Fixing ListEquality const expressions in app_router.gr.dart..."

# Replace const ListEquality with non-const versions for all occurrences
sed -i '' 's/const ListEquality<SportDomain>()/ListEquality<SportDomain>()/g' "$ROUTER_FILE"

# Count how many replacements were made
COUNT=$(grep -o "ListEquality<SportDomain>()" "$ROUTER_FILE" | wc -l | tr -d ' ')
echo "✅ Fixed $COUNT ListEquality const expressions."

