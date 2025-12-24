#!/bin/bash
# Outcode Flutter Setup - One-Command Installer
# Downloads the Flutter setup package from Git and runs setup
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/main/install.sh | bash
#
# Or download and run:
#   curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/main/install.sh -o install.sh
#   bash install.sh

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
REPO_URL="${OUTCODE_REPO_URL:-https://github.com/aShrestha-Outcode/linter-workflow-package.git}"
BRANCH="${OUTCODE_BRANCH:-main}"
LANGUAGE="${OUTCODE_LANGUAGE:-flutter}"
TEMP_DIR=$(mktemp -d)
PACKAGE_DIR="outcode-setup"

# Map language names to folder names in repository (bash 3.2 compatible)
case "$LANGUAGE" in
  flutter)
    LANGUAGE_FOLDER="linter-workflow-flutter"
    ;;
  reactnative)
    LANGUAGE_FOLDER="linter-workflow-reactnative"
    ;;
  nodejs)
    LANGUAGE_FOLDER="linter-workflow-nodejs"
    ;;
  *)
    # Default: use language name as folder name
    LANGUAGE_FOLDER="$LANGUAGE"
    ;;
esac

# Cleanup function
cleanup() {
  if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
  if [ -d "$PACKAGE_DIR" ] && [ "$PACKAGE_DIR" != "." ]; then
    # Don't remove if user wants to keep it
    :
  fi
}
trap cleanup EXIT

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Outcode Setup - $LANGUAGE${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Get current directory (should be project root)
PROJECT_ROOT="$(pwd)"

# Verify we're in the right project type
case "$LANGUAGE" in
  flutter)
    if [ ! -f "$PROJECT_ROOT/pubspec.yaml" ]; then
      echo -e "${RED}❌ Error: Not in a Flutter project directory${NC}"
      echo "   Please run this script from your Flutter project root (where pubspec.yaml is located)"
      exit 1
    fi
    ;;
  reactnative)
    if [ ! -f "$PROJECT_ROOT/package.json" ] || [ ! -f "$PROJECT_ROOT/app.json" ]; then
      echo -e "${RED}❌ Error: Not in a React Native project directory${NC}"
      exit 1
    fi
    ;;
  *)
    echo -e "${RED}❌ Error: Unknown language: $LANGUAGE${NC}"
    echo "   Supported languages: flutter, reactnative"
    exit 1
    ;;
esac

echo -e "Project directory: ${GREEN}$PROJECT_ROOT${NC}"
echo -e "Language: ${GREEN}$LANGUAGE${NC}"
echo ""

# Download method
echo -e "${BLUE}📦 Downloading Outcode setup package...${NC}"
echo ""

if command -v git &> /dev/null; then
  echo -e "   ${GREEN}Using Git to clone package...${NC}"
  
  # Clone only the specific language folder
  git clone --depth 1 --branch "$BRANCH" --filter=blob:none --sparse "$REPO_URL" "$TEMP_DIR/repo" 2>/dev/null || {
    echo -e "   ${YELLOW}⚠️${NC}  Sparse checkout not available, cloning full repo..."
    git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TEMP_DIR/repo"
  }
  
  cd "$TEMP_DIR/repo"
  
  # Try sparse checkout if available
  if git sparse-checkout version &>/dev/null; then
    git sparse-checkout init --cone
    git sparse-checkout set "$LANGUAGE_FOLDER"
  fi
  
  # Check if language folder exists
  if [ ! -d "$LANGUAGE_FOLDER" ]; then
    echo -e "   ${RED}❌ Error: Language folder '$LANGUAGE_FOLDER' not found in repository${NC}"
    echo "   Looking for: $LANGUAGE_FOLDER (for language: $LANGUAGE)"
    echo "   Available folders:"
    ls -d */ 2>/dev/null | sed 's|/$||' | sed 's/^/     - /' || echo "     (none found)"
    exit 1
  fi
  
  # Copy language folder to project
  cp -r "$LANGUAGE_FOLDER" "$PROJECT_ROOT/$PACKAGE_DIR"
  echo -e "   ${GREEN}✅${NC} Package downloaded successfully"
  
else
  echo -e "   ${RED}❌ Git not found. Please install Git.${NC}"
  exit 1
fi

echo ""
echo -e "${BLUE}🚀 Running setup script...${NC}"
echo ""

# Run the setup script
cd "$PROJECT_ROOT/$PACKAGE_DIR"
if [ -f "setup.sh" ]; then
  chmod +x setup.sh
  bash setup.sh
else
  echo -e "   ${RED}❌ Setup script not found${NC}"
  exit 1
fi

# Ask about cleanup
echo ""
read -p "Remove downloaded package folder? (y/N): " REMOVE_PACKAGE
if [[ "$REMOVE_PACKAGE" =~ ^[Yy]$ ]]; then
  rm -rf "$PROJECT_ROOT/$PACKAGE_DIR"
  echo -e "   ${GREEN}✅${NC} Package folder removed"
else
  echo -e "   ${YELLOW}ℹ️${NC}  Package folder kept at: $PROJECT_ROOT/$PACKAGE_DIR"
  echo -e "   ${BLUE}   You can remove it later: rm -rf $PACKAGE_DIR${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

