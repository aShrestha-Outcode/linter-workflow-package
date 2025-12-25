#!/bin/bash

# Script to run the app in production mode with environment variables
# Usage: ./scripts/run_prod.sh

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."

# Check if .prod.env exists
if [ ! -f "$PROJECT_ROOT/.prod.env" ]; then
    echo "Error: .prod.env file not found in project root"
    exit 1
fi

# Convert .env to JSON format
echo "Preparing environment variables..."
dart "$SCRIPT_DIR/env_to_json.dart" "$PROJECT_ROOT/.prod.env" "$PROJECT_ROOT/.dart_defines/prod.json"

if [ ! -f "$PROJECT_ROOT/.dart_defines/prod.json" ]; then
    echo "Error: Failed to generate environment variables JSON"
    exit 1
fi

echo "Running in PRODUCTION mode..."
echo ""

# Run flutter with the dart-define-from-file flag and flavor
cd "$PROJECT_ROOT"
flutter run -t lib/main_prod.dart --flavor prod --dart-define-from-file=.dart_defines/prod.json "$@"

