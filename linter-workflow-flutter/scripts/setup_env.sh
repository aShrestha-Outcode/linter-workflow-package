#!/bin/bash

# Script to convert all .env files to JSON format for dart-define-from-file
# Usage: ./scripts/setup_env.sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."

echo "Converting .env files to JSON format..."
echo ""

# Create .dart_defines directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/.dart_defines"

# Convert dev environment
if [ -f "$PROJECT_ROOT/.dev.env" ]; then
    dart "$SCRIPT_DIR/env_to_json.dart" "$PROJECT_ROOT/.dev.env" "$PROJECT_ROOT/.dart_defines/dev.json"
else
    echo "Warning: .dev.env not found"
fi

# Convert uat environment
if [ -f "$PROJECT_ROOT/.uat.env" ]; then
    dart "$SCRIPT_DIR/env_to_json.dart" "$PROJECT_ROOT/.uat.env" "$PROJECT_ROOT/.dart_defines/uat.json"
else
    echo "Warning: .uat.env not found"
fi

# Convert prod environment
if [ -f "$PROJECT_ROOT/.prod.env" ]; then
    dart "$SCRIPT_DIR/env_to_json.dart" "$PROJECT_ROOT/.prod.env" "$PROJECT_ROOT/.dart_defines/prod.json"
else
    echo "Warning: .prod.env not found"
fi

echo ""
echo "Done! JSON files created in .dart_defines/"
echo ""
echo "Note: The .dart_defines/ directory is gitignored and won't be committed."

