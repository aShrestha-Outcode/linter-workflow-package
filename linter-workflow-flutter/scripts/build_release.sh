#!/bin/bash

# Script to build production release with obfuscation and symbol management
# Usage: ./scripts/build_release.sh <android|ios> <env>

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."

# Check if running in CI (non-interactive mode)
CI_MODE=${CI:-false}

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./scripts/build_release.sh <android|ios> <env>"
    echo ""
    echo "Examples:"
    echo "  ./scripts/build_release.sh android prod"
    echo "  ./scripts/build_release.sh ios prod"
    echo ""
    echo "This script:"
    echo "  1. Builds the app (obfuscation enabled for prod, disabled for uat)"
    echo "  2. Saves debug symbols separately"
    echo "  3. Archives symbols for future reference"
    echo "  4. Optionally uploads symbols to Firebase Crashlytics"
    exit 1
fi

PLATFORM=$1
ENV=$2

# Determine if obfuscation should be enabled (only for prod)
OBFUSCATE=false
if [ "$ENV" == "prod" ]; then
    OBFUSCATE=true
fi

echo -e "${BLUE}======================================================"
echo "🚀 Building Production Release"
echo -e "======================================================${NC}"
echo ""
echo "Platform: $PLATFORM"
echo "Environment: $ENV"
if [ "$OBFUSCATE" == "true" ]; then
    echo -e "Obfuscation: ${GREEN}Enabled${NC} (Production build)"
else
    echo -e "Obfuscation: ${YELLOW}Disabled${NC} (UAT build - for better crash reports)"
fi
echo ""

cd "$PROJECT_ROOT"

# Get version from pubspec.yaml
VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')
echo "Version: $VERSION"
echo ""

# Create timestamp for archiving
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_DIR="symbols_archive/${VERSION}_${TIMESTAMP}"

if [ "$PLATFORM" == "android" ]; then
    SYMBOLS_PATH="build/app/outputs/symbols/android/$ENV"
    
    if [ "$OBFUSCATE" == "true" ]; then
        echo -e "${YELLOW}🔨 Building Android AAB with obfuscation...${NC}"
        echo ""
        
        # Build with obfuscation
        if ! ./scripts/build_aab.sh "$ENV" \
            --release \
            --obfuscate \
            --split-debug-info="$SYMBOLS_PATH"; then
            echo -e "${RED}❌ Build failed!${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}🔨 Building Android AAB (no obfuscation)...${NC}"
        echo ""
        
        # Build without obfuscation
        if ! ./scripts/build_aab.sh "$ENV" \
            --release \
            --split-debug-info="$SYMBOLS_PATH"; then
            echo -e "${RED}❌ Build failed!${NC}"
            exit 1
        fi
    fi
    
    echo ""
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
    echo ""
    
    # Archive symbols (skip in CI to save disk space)
    if [ "$CI_MODE" != "true" ]; then
        echo -e "${YELLOW}📦 Archiving debug symbols...${NC}"
        mkdir -p "$ARCHIVE_DIR"
        cp -r "$SYMBOLS_PATH" "$ARCHIVE_DIR/android_$ENV"
        
        # Create metadata file
        cat > "$ARCHIVE_DIR/metadata.txt" << EOF
Build Information
=================
Platform: Android
Environment: $ENV
Version: $VERSION
Build Date: $(date)
Build Type: Release$(if [ "$OBFUSCATE" == "true" ]; then echo " (Obfuscated)"; else echo " (Not Obfuscated)"; fi)
Symbols Path: $SYMBOLS_PATH
EOF
        
        echo -e "${GREEN}✅ Symbols archived to: $ARCHIVE_DIR${NC}"
        echo ""
    else
        echo -e "${BLUE}🤖 CI Mode: Skipping symbol archiving (saves disk space)${NC}"
        echo "Symbols generated at: $SYMBOLS_PATH"
        echo ""
    fi
    
    # Show build output location
    echo -e "${BLUE}📱 Build Output:${NC}"
    AAB_PATH="build/app/outputs/bundle/${ENV}Release/app-${ENV}-release.aab"
    if [ -f "$AAB_PATH" ]; then
        echo "  AAB: $AAB_PATH"
        ls -lh "$AAB_PATH"
    fi
    echo ""
    
elif [ "$PLATFORM" == "ios" ]; then
    SYMBOLS_PATH="build/ios/outputs/symbols/$ENV"
    
    if [ "$OBFUSCATE" == "true" ]; then
        echo -e "${YELLOW}🔨 Building iOS with obfuscation...${NC}"
        echo ""
        
        # Build with obfuscation
        # Check if running in CI - use ipa build, otherwise ios build
        if [ "$CI_MODE" == "true" ]; then
            # CI: Build IPA with export options
            if ! ./scripts/build_ios.sh "$ENV" \
                --release \
                --obfuscate \
                --split-debug-info="$SYMBOLS_PATH" \
                --export-options-plist=ios/Runner/ExportOptions.plist; then
                echo -e "${RED}❌ Build failed!${NC}"
                exit 1
            fi
        else
            # Local: Build iOS archive
            if ! ./scripts/build_ios.sh "$ENV" \
                --release \
                --obfuscate \
                --split-debug-info="$SYMBOLS_PATH"; then
                echo -e "${RED}❌ Build failed!${NC}"
                exit 1
            fi
        fi
    else
        echo -e "${YELLOW}🔨 Building iOS (no obfuscation)...${NC}"
        echo ""
        
        # Build without obfuscation
        # Check if running in CI - use ipa build, otherwise ios build
        if [ "$CI_MODE" == "true" ]; then
            # CI: Build IPA with export options
            if ! ./scripts/build_ios.sh "$ENV" \
                --release \
                --split-debug-info="$SYMBOLS_PATH" \
                --export-options-plist=ios/Runner/ExportOptions.plist; then
                echo -e "${RED}❌ Build failed!${NC}"
                exit 1
            fi
        else
            # Local: Build iOS archive
            if ! ./scripts/build_ios.sh "$ENV" \
                --release \
                --split-debug-info="$SYMBOLS_PATH"; then
                echo -e "${RED}❌ Build failed!${NC}"
                exit 1
            fi
        fi
    fi
    
    echo ""
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
    echo ""
    
    # Archive symbols (skip in CI to save disk space)
    if [ "$CI_MODE" != "true" ]; then
        echo -e "${YELLOW}📦 Archiving debug symbols...${NC}"
        mkdir -p "$ARCHIVE_DIR"
        
        # Copy symbol files if they exist
        if [ -d "$SYMBOLS_PATH" ]; then
            cp -r "$SYMBOLS_PATH" "$ARCHIVE_DIR/ios_$ENV"
        fi
        
        # Copy dSYM files
        DSYM_DIR="build/ios/archive/Runner.xcarchive/dSYMs"
        if [ -d "$DSYM_DIR" ]; then
            cp -r "$DSYM_DIR" "$ARCHIVE_DIR/dSYMs"
        fi
        
        # Create metadata file
        cat > "$ARCHIVE_DIR/metadata.txt" << EOF
Build Information
=================
Platform: iOS
Environment: $ENV
Version: $VERSION
Build Date: $(date)
Build Type: Release$(if [ "$OBFUSCATE" == "true" ]; then echo " (Obfuscated)"; else echo " (Not Obfuscated)"; fi)
Symbols Path: $SYMBOLS_PATH
dSYM Path: $DSYM_DIR
EOF
        
        echo -e "${GREEN}✅ Symbols archived to: $ARCHIVE_DIR${NC}"
        echo ""
    else
        echo -e "${BLUE}🤖 CI Mode: Skipping symbol archiving (saves disk space)${NC}"
        echo "Symbols generated at: $SYMBOLS_PATH"
        echo ""
    fi
    
    # Show build output location
    echo -e "${BLUE}📱 Build Output:${NC}"
    ARCHIVE_PATH="build/ios/archive/Runner.xcarchive"
    if [ -d "$ARCHIVE_PATH" ]; then
        echo "  Archive: $ARCHIVE_PATH"
    fi
    echo ""
    
else
    echo -e "${RED}❌ Invalid platform. Must be 'android' or 'ios'${NC}"
    exit 1
fi

# Ask about symbol upload (skip in CI mode)
if [ "$CI_MODE" == "true" ]; then
    echo ""
    echo -e "${BLUE}======================================================"
    echo "🤖 CI Mode Detected"
    echo -e "======================================================${NC}"
    echo ""
    echo "Skipping interactive symbol upload prompt."
    echo "Symbols should be uploaded in a separate CI step."
    echo ""
else
    echo ""
    echo -e "${YELLOW}======================================================"
    echo "📤 Upload Symbols to Firebase Crashlytics?"
    echo -e "======================================================${NC}"
    echo ""
    echo "Would you like to upload the debug symbols now?"
    echo "This is required for crash reports to be readable."
    echo ""
    read -p "Upload symbols? (y/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        ./scripts/upload_symbols.sh "$PLATFORM" "$ENV"
    else
        echo ""
        echo -e "${YELLOW}⚠️  Symbols NOT uploaded.${NC}"
        echo ""
        echo "To upload later, run:"
        echo "  ./scripts/upload_symbols.sh $PLATFORM $ENV"
        echo ""
    fi
fi

echo ""
echo -e "${BLUE}======================================================"
echo "✅ Release Build Complete!"
echo -e "======================================================${NC}"
echo ""
echo "Summary:"
echo "  Platform: $PLATFORM"
echo "  Environment: $ENV"
echo "  Version: $VERSION"
echo "  Symbols archived: $ARCHIVE_DIR"
echo ""
echo "Next steps:"
if [ "$PLATFORM" == "android" ]; then
    echo "  1. Test the AAB thoroughly"
    echo "  2. Upload to Google Play Console"
    echo "  3. Verify symbols uploaded to Crashlytics"
else
    echo "  1. Archive and validate in Xcode"
    echo "  2. Upload to App Store Connect"
    echo "  3. Verify symbols uploaded to Crashlytics"
fi
echo ""

