#!/bin/bash

# Script to upload debug symbols to Firebase Crashlytics
# Usage: ./scripts/upload_symbols.sh <android|ios> <dev|uat|prod>

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."

# Check if running in CI
CI_MODE=${CI:-false}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./scripts/upload_symbols.sh <android|ios> <dev|uat|prod>"
    echo ""
    echo "Examples:"
    echo "  ./scripts/upload_symbols.sh android prod"
    echo "  ./scripts/upload_symbols.sh ios prod"
    echo ""
    echo "This uploads debug symbols from obfuscated builds to Firebase Crashlytics"
    echo "so that crash reports can be deobfuscated and made readable."
    exit 1
fi

PLATFORM=$1
ENV_TYPE=$2

cd "$PROJECT_ROOT"

echo -e "${BLUE}======================================================"
echo "📤 Uploading Debug Symbols to Firebase Crashlytics"
echo -e "======================================================${NC}"
echo ""
echo "Platform: $PLATFORM"
echo "Environment: $ENV_TYPE"
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Firebase CLI not found!${NC}"
    echo ""
    echo "Please install Firebase CLI:"
    echo "  npm install -g firebase-tools"
    echo ""
    echo "Then login:"
    echo "  firebase login"
    exit 1
fi

# Determine Firebase app ID based on environment
case $ENV_TYPE in
    dev)
        # Read from environment variables (set in CI or locally)
        ANDROID_APP_ID="${FIREBASE_ANDROID_DEV_APP_ID:-}"
        IOS_APP_ID="${FIREBASE_IOS_DEV_APP_ID:-}"
        ;;
    uat)
        ANDROID_APP_ID="${FIREBASE_ANDROID_UAT_APP_ID:-}"
        IOS_APP_ID="${FIREBASE_IOS_UAT_APP_ID:-}"
        ;;
    prod)
        ANDROID_APP_ID="${FIREBASE_ANDROID_PROD_APP_ID:-}"
        IOS_APP_ID="${FIREBASE_IOS_PROD_APP_ID:-}"
        ;;
    *)
        echo -e "${RED}❌ Invalid environment. Must be dev, uat, or prod${NC}"
        exit 1
        ;;
esac

# Check if app ID is set
if [ "$PLATFORM" == "android" ] && [ -z "$ANDROID_APP_ID" ]; then
    ENV_TYPE_UPPER=$(echo "$ENV_TYPE" | tr '[:lower:]' '[:upper:]')
    echo -e "${RED}❌ Firebase Android App ID not set for $ENV_TYPE environment${NC}"
    echo ""
    echo "Please set the environment variable:"
    echo "  export FIREBASE_ANDROID_${ENV_TYPE_UPPER}_APP_ID='your-app-id'"
    echo ""
    echo "Or in CI, add it as a secret: FIREBASE_ANDROID_${ENV_TYPE_UPPER}_APP_ID"
    exit 1
fi

if [ "$PLATFORM" == "ios" ] && [ -z "$IOS_APP_ID" ]; then
    ENV_TYPE_UPPER=$(echo "$ENV_TYPE" | tr '[:lower:]' '[:upper:]')
    echo -e "${RED}❌ Firebase iOS App ID not set for $ENV_TYPE environment${NC}"
    echo ""
    echo "Please set the environment variable:"
    echo "  export FIREBASE_IOS_${ENV_TYPE_UPPER}_APP_ID='your-app-id'"
    echo ""
    echo "Or in CI, add it as a secret: FIREBASE_IOS_${ENV_TYPE_UPPER}_APP_ID"
    exit 1
fi

if [ "$PLATFORM" == "android" ]; then
    # Android symbol upload
    SYMBOLS_DIR="build/app/outputs/symbols/android/$ENV_TYPE"
    
    if [ ! -d "$SYMBOLS_DIR" ]; then
        echo -e "${RED}❌ Symbols directory not found: $SYMBOLS_DIR${NC}"
        echo ""
        echo "Did you build with --obfuscate and --split-debug-info?"
        echo "Example:"
        echo "  ./scripts/build_aab.sh $ENV_TYPE --obfuscate --split-debug-info=build/app/outputs/symbols/android/$ENV_TYPE"
        exit 1
    fi
    
    echo -e "${YELLOW}📦 Found Android symbols at: $SYMBOLS_DIR${NC}"
    echo ""
    echo "Files:"
    ls -lh "$SYMBOLS_DIR"
    echo ""
    
    echo -e "${BLUE}📤 Uploading to Firebase Crashlytics...${NC}"
    
    # Upload symbols
    if firebase crashlytics:symbols:upload \
        --app="$ANDROID_APP_ID" \
        "$SYMBOLS_DIR"; then
        echo ""
        echo -e "${GREEN}✅ Android symbols uploaded successfully!${NC}"
    else
        echo ""
        echo -e "${RED}❌ Failed to upload Android symbols${NC}"
        exit 1
    fi
    
elif [ "$PLATFORM" == "ios" ]; then
    # iOS symbol upload (dSYM files)
    
    # First, check for symbols directory
    SYMBOLS_DIR="build/ios/outputs/symbols/$ENV_TYPE"
    
    if [ -d "$SYMBOLS_DIR" ]; then
        echo -e "${YELLOW}📦 Found iOS symbols at: $SYMBOLS_DIR${NC}"
        echo ""
        
        echo -e "${BLUE}📤 Uploading to Firebase Crashlytics...${NC}"
        
        if firebase crashlytics:symbols:upload \
            --app="$IOS_APP_ID" \
            "$SYMBOLS_DIR"; then
            echo ""
            echo -e "${GREEN}✅ iOS symbols uploaded successfully!${NC}"
        else
            echo ""
            echo -e "${RED}❌ Failed to upload iOS symbols${NC}"
            exit 1
        fi
    fi
    
    # Also check for xcarchive (dSYM files)
    ARCHIVE_DIR="build/ios/archive/Runner.xcarchive"
    DSYM_DIR="$ARCHIVE_DIR/dSYMs"
    
    if [ -d "$DSYM_DIR" ]; then
        echo -e "${YELLOW}📦 Found dSYM files at: $DSYM_DIR${NC}"
        echo ""
        echo "Files:"
        ls -lh "$DSYM_DIR"
        echo ""
        
        echo -e "${BLUE}📤 Uploading dSYM files to Firebase Crashlytics...${NC}"
        
        for DSYM in "$DSYM_DIR"/*.dSYM; do
            if [ -d "$DSYM" ]; then
                echo "Uploading: $(basename "$DSYM")"
                if firebase crashlytics:symbols:upload \
                    --app="$IOS_APP_ID" \
                    "$DSYM"; then
                    echo -e "${GREEN}  ✓ Uploaded$(basename "$DSYM")${NC}"
                else
                    echo -e "${RED}  ✗ Failed to upload $(basename "$DSYM")${NC}"
                fi
            fi
        done
        
        echo ""
        echo -e "${GREEN}✅ iOS dSYM files uploaded!${NC}"
    fi
    
    if [ ! -d "$SYMBOLS_DIR" ] && [ ! -d "$DSYM_DIR" ]; then
        echo -e "${RED}❌ No iOS symbols found!${NC}"
        echo ""
        echo "Expected locations:"
        echo "  - $SYMBOLS_DIR"
        echo "  - $DSYM_DIR"
        echo ""
        echo "Did you build with --obfuscate and --split-debug-info?"
        echo "Example:"
        echo "  ./scripts/build_ios.sh $ENV_TYPE --obfuscate --split-debug-info=build/ios/outputs/symbols/$ENV_TYPE"
        exit 1
    fi
    
else
    echo -e "${RED}❌ Invalid platform. Must be 'android' or 'ios'${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}======================================================"
echo "✅ Symbol Upload Complete"
echo -e "======================================================${NC}"
echo ""
echo "Your crash reports will now be automatically deobfuscated!"
echo ""
echo "Note: It may take a few minutes for symbols to be processed."
echo ""

