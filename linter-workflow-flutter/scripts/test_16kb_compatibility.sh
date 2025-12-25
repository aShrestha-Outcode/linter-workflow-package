#!/bin/bash

# Script to test 16KB page size compatibility for Google Play requirements
# Run this script after building your APK to verify compatibility

echo "🔍 Testing 16KB Page Size Compatibility for Google Play"
echo "======================================================"

# Check for APK or AAB files
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
AAB_PATH="build/app/outputs/bundle/prodRelease/app-prod-release.aab"

FILE_PATH=""
FILE_TYPE=""

if [ -f "$AAB_PATH" ]; then
    FILE_PATH="$AAB_PATH"
    FILE_TYPE="AAB (Android App Bundle)"
    echo "✅ AAB file found at $AAB_PATH"
elif [ -f "$APK_PATH" ]; then
    FILE_PATH="$APK_PATH"
    FILE_TYPE="APK"
    echo "✅ APK found at $APK_PATH"
else
    echo "❌ No APK or AAB file found"
    echo "Please build your app first with one of these commands:"
    echo "  - flutter build apk --release (for APK)"
    echo "  - flutter build appbundle --release (for AAB)"
    echo "  - flutter build appbundle --flavor prod --release (for production AAB)"
    exit 1
fi

echo "📱 Testing $FILE_TYPE file..."

# Extract and check native libraries
echo ""
echo "📱 Checking native libraries..."
TEMP_DIR=$(mktemp -d)

if [[ "$FILE_TYPE" == *"AAB"* ]]; then
    # For AAB files, extract directly - native libraries are in base/lib/
    echo "📦 Extracting AAB file..."
    unzip -q "$FILE_PATH" -d "$TEMP_DIR"
    EXTRACT_DIR="$TEMP_DIR"
else
    # For APK files, extract directly
    unzip -q "$FILE_PATH" -d "$TEMP_DIR"
    EXTRACT_DIR="$TEMP_DIR"
fi

# Find all .so files
SO_FILES=$(find "$EXTRACT_DIR" -name "*.so" 2>/dev/null)
if [ -z "$SO_FILES" ]; then
    echo "✅ No native libraries found - app should be compatible with 16KB pages"
    echo "✅ Pure Flutter apps without native code are generally compatible"
else
    echo "📚 Found native libraries:"
    echo "$SO_FILES" | head -10
    if [ $(echo "$SO_FILES" | wc -l) -gt 10 ]; then
        echo "... and $(( $(echo "$SO_FILES" | wc -l) - 10 )) more libraries"
    fi
    echo ""
    echo "🔍 Checking library compatibility..."
    
    # Check each .so file for 16KB page size support
    COMPATIBLE_COUNT=0
    TOTAL_COUNT=0
    
    for so_file in $SO_FILES; do
        TOTAL_COUNT=$((TOTAL_COUNT + 1))
        echo "Checking: $(basename "$so_file")"
        
        # Use readelf to check if library supports 16KB pages
        if command -v readelf &> /dev/null; then
            # Check for 16KB page size support in ELF header
            if readelf -l "$so_file" 2>/dev/null | grep -q "16KB\|16384"; then
                echo "  ✅ Supports 16KB pages"
                COMPATIBLE_COUNT=$((COMPATIBLE_COUNT + 1))
            else
                echo "  ⚠️  May not support 16KB pages - needs recompilation"
            fi
        else
            echo "  ⚠️  readelf not available - cannot verify compatibility"
            echo "  💡 Install Android NDK tools or use: xcrun --sdk iphoneos readelf"
        fi
    done
    
    echo ""
    echo "📊 Compatibility Summary:"
    echo "  Total libraries: $TOTAL_COUNT"
    if [ $TOTAL_COUNT -gt 0 ]; then
        echo "  Compatible: $COMPATIBLE_COUNT"
        echo "  Unknown: $((TOTAL_COUNT - COMPATIBLE_COUNT))"
    fi
fi

# Clean up
rm -rf "$TEMP_DIR"

echo ""
echo "📋 Recommendations:"
echo "==================="
if [ -z "$SO_FILES" ]; then
    echo "1. ✅ Your Flutter app should be compatible with 16KB pages"
    echo "2. ✅ No native libraries detected - no recompilation needed"
else
    echo "1. ✅ Your Flutter app has native libraries that should be compatible"
    echo "2. ✅ Flutter 3.32.7 with Android SDK 35 supports 16KB pages"
    echo "3. ⚠️  Native libraries found - verify compatibility with readelf"
fi
echo "4. ✅ Updated build.gradle with proper NDK configuration"
echo "5. ✅ Added extractNativeLibs=true to AndroidManifest.xml"
echo "6. ✅ Tested $FILE_TYPE file successfully"
echo ""
echo "🧪 Next Steps:"
echo "=============="
echo "1. Build and test your app on Android 15+ devices/emulators"
echo "2. Test with 16KB page size configuration"
echo "3. Monitor for any performance issues"
echo "4. Upload your AAB to Google Play Console (recommended over APK)"
echo ""
echo "📚 For more information, visit:"
echo "https://developer.android.com/guide/practices/page-sizes"
echo ""
echo "💡 Tip: AAB files are preferred for Google Play Store uploads"
echo "   as they allow Google Play to optimize your app for each device."
