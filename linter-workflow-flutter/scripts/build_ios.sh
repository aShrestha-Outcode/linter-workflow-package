#!/bin/bash

# Script to build iOS with environment variables
# Usage: ./scripts/build_ios.sh <dev|uat|prod> [additional flutter build args]

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."

if [ -z "$1" ]; then
    echo "Usage: ./scripts/build_ios.sh <dev|uat|prod> [additional flutter build args]"
    echo "Example: ./scripts/build_ios.sh prod --release"
    exit 1
fi

ENV_TYPE=$1
shift  # Remove first argument, leaving any additional args

# Determine which env file and main file to use
case $ENV_TYPE in
    dev)
        ENV_FILE=".dev.env"
        MAIN_FILE="lib/main_dev.dart"
        JSON_FILE=".dart_defines/dev.json"
        ;;
    uat)
        ENV_FILE=".uat.env"
        MAIN_FILE="lib/main_uat.dart"
        JSON_FILE=".dart_defines/uat.json"
        ;;
    prod)
        ENV_FILE=".prod.env"
        MAIN_FILE="lib/main_prod.dart"
        JSON_FILE=".dart_defines/prod.json"
        ;;
    *)
        echo "Error: Invalid environment type. Must be dev, uat, or prod"
        exit 1
        ;;
esac

# Check if env file exists
if [ ! -f "$PROJECT_ROOT/$ENV_FILE" ]; then
    echo "Error: $ENV_FILE file not found in project root"
    exit 1
fi

# Convert .env to JSON format
echo "Preparing environment variables..."
dart "$SCRIPT_DIR/env_to_json.dart" "$PROJECT_ROOT/$ENV_FILE" "$PROJECT_ROOT/$JSON_FILE"

if [ ! -f "$PROJECT_ROOT/$JSON_FILE" ]; then
    echo "Error: Failed to generate environment variables JSON"
    exit 1
fi


echo "Building iOS in $ENV_TYPE mode..."
echo ""

# Build iOS with the dart-define-from-file flag and flavor
cd "$PROJECT_ROOT"

# Check if --export-options-plist is in arguments, if so use 'flutter build ipa'
if [[ "$*" == *"--export-options-plist"* ]]; then
    # Build IPA (for CI/CD deployment)
    flutter build ipa -t $MAIN_FILE --flavor $ENV_TYPE --dart-define-from-file=$JSON_FILE "$@"
else
    # Build iOS archive (for local development)
    flutter build ios -t $MAIN_FILE --flavor $ENV_TYPE --dart-define-from-file=$JSON_FILE "$@"
fi

