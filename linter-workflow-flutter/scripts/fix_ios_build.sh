#!/bin/bash

# Script to fix iOS build issues after Flutter upgrade
# This script cleans and reinstalls iOS dependencies

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🧹 Cleaning iOS build artifacts..."

cd "$PROJECT_ROOT"

# Clean Flutter build
echo "Cleaning Flutter..."
flutter clean

# Clean iOS build artifacts
echo "Cleaning iOS build artifacts..."
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm -rf Runner.xcworkspace/xcuserdata
rm -rf Runner.xcodeproj/xcuserdata

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
cd "$PROJECT_ROOT"
flutter pub get

# Reinstall pods
echo "Reinstalling CocoaPods..."
cd ios
pod deintegrate || true
pod install --repo-update

echo "✅ iOS build cleanup complete!"
echo ""
echo "Next steps:"
echo "1. Open Runner.xcworkspace in Xcode"
echo "2. Check code signing settings"
echo "3. Try building again"

