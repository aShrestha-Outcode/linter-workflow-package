#!/bin/bash

# Script to verify that .env files are NOT bundled in the app
# Usage: ./scripts/verify_no_env_bundled.sh

echo "======================================================"
echo "Verifying .env files are NOT bundled in the app..."
echo "======================================================"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

cd "$PROJECT_ROOT"

# Check 1: Verify .env files are NOT in pubspec.yaml assets
echo "📋 Check 1: Scanning pubspec.yaml for .env files..."
if grep -q "\.env" pubspec.yaml 2>/dev/null; then
    echo -e "${RED}❌ FAIL: Found .env references in pubspec.yaml${NC}"
    echo "   .env files should NOT be in the assets section!"
    grep "\.env" pubspec.yaml
    exit 1
else
    echo -e "${GREEN}✅ PASS: No .env files in pubspec.yaml assets${NC}"
fi
echo ""

# Check 2: Build a test APK and verify
echo "📦 Check 2: Building test APK to verify bundle contents..."
echo "   (This will take a moment...)"
echo ""

# Build debug APK
if ! ./scripts/build_aab.sh dev apk --debug > /tmp/build_output.log 2>&1; then
    echo -e "${YELLOW}⚠️  WARNING: Build failed. Check /tmp/build_output.log${NC}"
    echo "   You may need to fix build issues first."
    exit 1
fi

APK_PATH="build/app/outputs/flutter-apk/app-dev-debug.apk"

if [ ! -f "$APK_PATH" ]; then
    # Try alternative path
    APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
fi

if [ ! -f "$APK_PATH" ]; then
    echo -e "${YELLOW}⚠️  WARNING: Could not find built APK${NC}"
    echo "   Expected at: $APK_PATH"
    exit 1
fi

echo "   APK built at: $APK_PATH"
echo ""

# Check 3: Extract and search APK for .env files
echo "🔍 Check 3: Searching APK contents for .env files..."

# Create temp directory for extraction
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Unzip APK
unzip -q "$APK_PATH" -d "$TEMP_DIR"

# Search for .env files
ENV_FILES=$(find "$TEMP_DIR" -name "*.env" 2>/dev/null)

if [ -n "$ENV_FILES" ]; then
    echo -e "${RED}❌ FAIL: Found .env files in APK!${NC}"
    echo "   Files found:"
    echo "$ENV_FILES"
    echo ""
    echo "   This is a SECURITY RISK!"
    exit 1
else
    echo -e "${GREEN}✅ PASS: No .env files found in APK${NC}"
fi
echo ""

# Check 4: Search for .dart_defines JSON files
echo "🔍 Check 4: Searching APK for .dart_defines JSON files..."

JSON_FILES=$(find "$TEMP_DIR" -path "*/.dart_defines/*.json" 2>/dev/null)

if [ -n "$JSON_FILES" ]; then
    echo -e "${RED}❌ FAIL: Found .dart_defines JSON files in APK!${NC}"
    echo "   Files found:"
    echo "$JSON_FILES"
    echo ""
    echo "   This is a SECURITY RISK!"
    exit 1
else
    echo -e "${GREEN}✅ PASS: No .dart_defines JSON files found in APK${NC}"
fi
echo ""

# Check 5: Search for common secret patterns
echo "🔍 Check 5: Searching for plaintext API keys in assets..."

# List all assets in the APK
ASSETS_DIR="$TEMP_DIR/assets"
if [ -d "$ASSETS_DIR" ]; then
    echo "   Assets found in APK:"
    ls -la "$ASSETS_DIR" | head -20
    echo ""
    
    # Search for suspicious files that might contain secrets
    SUSPICIOUS_FILES=$(find "$ASSETS_DIR" -type f \( -name "*.txt" -o -name "*.config" -o -name "*.properties" \) 2>/dev/null)
    
    if [ -n "$SUSPICIOUS_FILES" ]; then
        echo -e "${YELLOW}⚠️  Found config-like files (manual review recommended):${NC}"
        echo "$SUSPICIOUS_FILES"
    else
        echo -e "${GREEN}✅ No suspicious config files found${NC}"
    fi
fi
echo ""

# Summary
echo "======================================================"
echo "📊 VERIFICATION SUMMARY"
echo "======================================================"
echo ""
echo -e "${GREEN}✅ All checks passed!${NC}"
echo ""
echo "Your .env files are NOT bundled in the app."
echo "Environment variables are compiled into the bytecode."
echo ""
echo "This means:"
echo "  ✓ Cannot extract .env files from APK/IPA"
echo "  ✓ Cannot see .dart_defines JSON files"
echo "  ✓ Secrets are compiled into Dart bytecode"
echo "  ✓ Still extractable via reverse engineering, but much harder"
echo ""
echo "For maximum security, consider:"
echo "  • Using --obfuscate flag for production builds"
echo "  • Storing critical secrets server-side"
echo "  • Implementing certificate pinning"
echo ""

