#!/bin/bash

# Script to run the app in development mode with environment variables
# Usage: ./scripts/run_dev.sh

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."

# Check if .dev.env exists
if [ ! -f "$PROJECT_ROOT/.dev.env" ]; then
    echo "Error: .dev.env file not found in project root"
    exit 1
fi

# Convert .env to JSON format
echo "Preparing environment variables..."
dart "$SCRIPT_DIR/env_to_json.dart" "$PROJECT_ROOT/.dev.env" "$PROJECT_ROOT/.dart_defines/dev.json"

if [ ! -f "$PROJECT_ROOT/.dart_defines/dev.json" ]; then
    echo "Error: Failed to generate environment variables JSON"
    exit 1
fi

echo "Running in DEV mode..."
echo ""

# Run flutter with the dart-define-from-file flag and flavor
cd "$PROJECT_ROOT"
flutter run -t lib/main_dev.dart --flavor dev --dart-define-from-file=.dart_defines/dev.json "$@"

