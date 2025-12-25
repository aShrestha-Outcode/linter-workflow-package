#!/bin/bash

# Script to build Android App Bundle (AAB) or APK with environment variables
# Usage: ./scripts/build_aab.sh <dev|uat|prod> [apk|appbundle] [additional flutter build args]

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."

if [ -z "$1" ]; then
    echo "Usage: ./scripts/build_aab.sh <dev|uat|prod> [apk|appbundle] [additional flutter build args]"
    echo "Example: ./scripts/build_aab.sh prod              # Builds AAB (default)"
    echo "Example: ./scripts/build_aab.sh prod appbundle    # Explicitly build AAB"
    echo "Example: ./scripts/build_aab.sh dev apk           # Build APK instead"
    echo "Example: ./scripts/build_aab.sh dev apk --split-per-abi"
    echo ""
    echo "Default build type: appbundle (AAB)"
    exit 1
fi

ENV_TYPE=$1
shift  # Remove first argument

# Determine build type (default to appbundle)
BUILD_TYPE="appbundle"
if [ "$1" == "apk" ] || [ "$1" == "appbundle" ]; then
    BUILD_TYPE=$1
    shift  # Remove build type argument
fi

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

# Set build type display name
if [ "$BUILD_TYPE" == "appbundle" ]; then
    BUILD_NAME="AAB (App Bundle)"
else
    BUILD_NAME="APK"
fi

echo "Building Android $BUILD_NAME in $ENV_TYPE mode..."
echo ""

# Build with the dart-define-from-file flag and flavor
cd "$PROJECT_ROOT"
flutter build $BUILD_TYPE -t $MAIN_FILE --flavor $ENV_TYPE --dart-define-from-file=$JSON_FILE "$@"

