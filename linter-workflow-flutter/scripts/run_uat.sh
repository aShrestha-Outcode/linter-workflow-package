#!/bin/bash

# Script to run the app in UAT mode with environment variables
# Usage: ./scripts/run_uat.sh

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."

# Check if .uat.env exists
if [ ! -f "$PROJECT_ROOT/.uat.env" ]; then
    echo "Error: .uat.env file not found in project root"
    exit 1
fi

# Convert .env to JSON format
echo "Preparing environment variables..."
dart "$SCRIPT_DIR/env_to_json.dart" "$PROJECT_ROOT/.uat.env" "$PROJECT_ROOT/.dart_defines/uat.json"

if [ ! -f "$PROJECT_ROOT/.dart_defines/uat.json" ]; then
    echo "Error: Failed to generate environment variables JSON"
    exit 1
fi

echo "Running in UAT mode..."
echo ""

# Run flutter with the dart-define-from-file flag and flavor
cd "$PROJECT_ROOT"
flutter run -t lib/main_uat.dart --flavor uat --dart-define-from-file=.dart_defines/uat.json "$@"

