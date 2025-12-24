#!/bin/bash
# Outcode Setup - Language Package Installer
# Downloads the selected language setup package from Git
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/main/install.sh | bash
#
# Or download and run:
#   curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/main/install.sh -o install.sh
#   bash install.sh
#
# After running this script:
#   1. cd into the downloaded folder (e.g., linter-workflow-flutter)
#   2. Run ./setup.sh to complete the setup

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
TEMP_DIR=$(mktemp -d)

# Available languages (bash 3.2 compatible - using simple variables)
AVAILABLE_LANGUAGES="flutter reactnative nodejs"

# Function to get folder name for a language
get_language_folder() {
  local lang="$1"
  case "$lang" in
    flutter)
      echo "linter-workflow-flutter"
      ;;
    reactnative)
      echo "linter-workflow-reactnative"
      ;;
    nodejs)
      echo "linter-workflow-nodejs"
      ;;
    *)
      echo ""
      ;;
  esac
}

# Function to prompt user for language selection
select_language() {
  echo -e "${BLUE}Available languages:${NC}"
  local i=1
  local count=0
  for lang in $AVAILABLE_LANGUAGES; do
    echo -e "   ${GREEN}$i${NC}) $lang"
    ((i++))
    ((count++))
  done
  echo ""
  
  while true; do
    read -p "Select language (1-$count): " choice
    
    # Check if input is a number
    if [[ "$choice" =~ ^[0-9]+$ ]]; then
      if [ "$choice" -ge 1 ] && [ "$choice" -le "$count" ]; then
        local idx=1
        for lang in $AVAILABLE_LANGUAGES; do
          if [ "$idx" -eq "$choice" ]; then
            SELECTED_LANGUAGE="$lang"
            LANGUAGE_FOLDER=$(get_language_folder "$SELECTED_LANGUAGE")
            return 0
          fi
          ((idx++))
        done
      else
        echo -e "   ${RED}Invalid choice. Please enter a number between 1 and $count.${NC}"
      fi
    else
      echo -e "   ${RED}Invalid input. Please enter a number.${NC}"
    fi
  done
}

# Cleanup function
cleanup() {
  if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}
trap cleanup EXIT

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Outcode Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Get current directory (should be project root)
PROJECT_ROOT="$(pwd)"

# Prompt user to select language
select_language

echo ""
echo -e "Selected language: ${GREEN}$SELECTED_LANGUAGE${NC}"
echo -e "Project directory: ${GREEN}$PROJECT_ROOT${NC}"
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
  
  # Copy language folder to project root
  echo -e "   ${BLUE}Copying $LANGUAGE_FOLDER to project directory...${NC}"
  cp -r "$LANGUAGE_FOLDER" "$PROJECT_ROOT/"
  echo -e "   ${GREEN}✅${NC} Package downloaded successfully"
  
else
  echo -e "   ${RED}❌ Git not found. Please install Git.${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Download Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo -e "   1. Navigate to the downloaded folder:"
echo -e "      ${GREEN}cd $LANGUAGE_FOLDER${NC}"
echo ""
echo -e "   2. Run the setup script:"
echo -e "      ${GREEN}./setup.sh${NC}"
echo ""
echo -e "   The setup script will guide you through:"
echo -e "     - Copying files to your project"
echo -e "     - Installing dependencies"
echo -e "     - Setting up Git hooks"
echo -e "     - Configuring GitHub remote (optional)"
echo ""

