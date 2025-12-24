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
  
  # Clone the repository (don't use sparse checkout initially - it might hide folders)
  echo -e "   ${BLUE}Cloning repository from $REPO_URL (branch: $BRANCH)...${NC}"
  if ! git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TEMP_DIR/repo" 2>&1; then
    echo -e "   ${RED}❌ Failed to clone repository${NC}"
    echo "   Please check:"
    echo "     - Repository URL is correct: $REPO_URL"
    echo "     - Branch exists: $BRANCH"
    echo "     - You have access to the repository"
    exit 1
  fi
  
  # Change to repository directory
  cd "$TEMP_DIR/repo" || {
    echo -e "   ${RED}❌ Failed to change to repository directory${NC}"
    exit 1
  }
  
  # Debug: Show what's actually in the repo
  echo -e "   ${BLUE}ℹ️${NC}  Checking repository contents..."
  echo -e "   ${BLUE}   Current directory: $(pwd)${NC}"
  echo -e "   ${BLUE}   Folders found:${NC}"
  ls -d */ 2>/dev/null | sed 's|/$||' | sed 's/^/     - /' || echo "     (checking...)"
  echo ""
  
  # Check if language folder exists (simple, direct check)
  if [ ! -d "$LANGUAGE_FOLDER" ]; then
    echo -e "   ${RED}❌ Error: Language folder '$LANGUAGE_FOLDER' not found in repository${NC}"
    echo "   Looking for: $LANGUAGE_FOLDER (for language: $LANGUAGE)"
    echo ""
    echo -e "   ${YELLOW}Available folders in repository:${NC}"
    if ls -d */ >/dev/null 2>&1; then
      ls -d */ | sed 's|/$||' | while read folder; do
        echo "     - $folder"
      done
    else
      echo "     (no folders found)"
    fi
    echo ""
    echo -e "   ${YELLOW}All files and directories:${NC}"
    ls -la
    echo ""
    echo -e "   ${BLUE}Debugging info:${NC}"
    echo "     Repository URL: $REPO_URL"
    echo "     Branch: $BRANCH"
    echo "     Current directory: $(pwd)"
    echo "     Looking for folder: $LANGUAGE_FOLDER"
    echo "     Git branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')"
    echo "     Git commit: $(git rev-parse HEAD 2>/dev/null | cut -c1-7 || echo 'unknown')"
    echo ""
    echo -e "   ${YELLOW}Possible solutions:${NC}"
    echo "     1. Verify the folder '$LANGUAGE_FOLDER' exists in the GitHub repository"
    echo "     2. Check the branch name (current: $BRANCH)"
    echo "     3. Visit: https://github.com/aShrestha-Outcode/linter-workflow-package/tree/$BRANCH"
    echo "     4. Ensure the folder is committed and pushed to GitHub"
    echo "     5. Check if the folder name matches exactly (case-sensitive)"
    exit 1
  fi
  
  echo -e "   ${GREEN}✅ Found folder: $LANGUAGE_FOLDER${NC}"
  
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

