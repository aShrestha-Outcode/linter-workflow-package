#!/bin/bash
# Setup validation script
# Verifies that all required tools and dependencies are installed

set -uo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

check_command() {
  local cmd=$1
  local name=${2:-$cmd}
  
  if command -v "$cmd" &> /dev/null; then
    local version=$($cmd --version 2>&1 | head -n1 || echo "unknown")
    echo -e "${GREEN}✅${NC} $name: $version"
    return 0
  else
    echo -e "${RED}❌${NC} $name: Not found"
    ((ERRORS++))
    return 1
  fi
}

check_optional_command() {
  local cmd=$1
  local name=${2:-$cmd}
  
  if command -v "$cmd" &> /dev/null; then
    local version=$($cmd --version 2>&1 | head -n1 || echo "unknown")
    echo -e "${GREEN}✅${NC} $name: $version"
    return 0
  else
    echo -e "${YELLOW}⚠️${NC}  $name: Not found (optional)"
    ((WARNINGS++))
    return 1
  fi
}

check_file() {
  local file=$1
  local name=${2:-$file}
  
  if [ -f "$file" ]; then
    echo -e "${GREEN}✅${NC} $name: Found"
    return 0
  else
    echo -e "${RED}❌${NC} $name: Not found"
    ((ERRORS++))
    return 1
  fi
}

check_directory() {
  local dir=$1
  local name=${2:-$dir}
  
  if [ -d "$dir" ]; then
    echo -e "${GREEN}✅${NC} $name: Found"
    return 0
  else
    echo -e "${RED}❌${NC} $name: Not found"
    ((ERRORS++))
    return 1
  fi
}

echo "🔍 Validating Outcode Flutter Code Quality setup..."
echo ""

echo "📦 Required Tools:"
check_command "node" "Node.js"
check_command "npm" "npm"
check_command "dart" "Dart SDK" || check_command "flutter" "Flutter"
check_command "git" "Git"

echo ""
# Only show optional tools section if config files exist (meaning they're recommended)
if [ -f ".fvmrc" ] || [ -f "fvm_config.json" ] || [ -f ".nvmrc" ]; then
  echo "🔧 Optional Tools (recommended by config files):"
  echo -e "   ${BLUE}ℹ️${NC}  These are optional - setup works without them, but they help ensure version consistency"
  echo ""
  
  if [ -f ".fvmrc" ] || [ -f "fvm_config.json" ]; then
    if command -v fvm &> /dev/null; then
      check_optional_command "fvm" "FVM (Flutter Version Manager)"
    else
      echo -e "   ${YELLOW}ℹ️${NC}  FVM: Not installed (optional)"
      echo -e "      ${BLUE}   →${NC} You can use system Flutter or install FVM: https://fvm.app/docs/getting_started/installation"
      echo -e "      ${BLUE}   →${NC} FVM helps ensure all developers use the same Flutter version"
      # Don't count as warning - it's truly optional
    fi
  fi
  
  if [ -f ".nvmrc" ]; then
    # nvm is a shell function, not a command, so check differently
    if type nvm &> /dev/null 2>&1 || [ -s "$HOME/.nvm/nvm.sh" ] || [ -s "/usr/local/opt/nvm/nvm.sh" ]; then
      echo -e "${GREEN}✅${NC} nvm: Available (Node Version Manager)"
    else
      echo -e "   ${YELLOW}ℹ️${NC}  nvm: Not installed (optional)"
      echo -e "      ${BLUE}   →${NC} You can use system Node.js or install nvm: https://github.com/nvm-sh/nvm"
      echo -e "      ${BLUE}   →${NC} nvm helps ensure all developers use the same Node.js version"
      # Don't count as warning - it's truly optional
    fi
  fi
  echo ""
fi

echo ""
echo "📁 Required Files:"
check_file "package.json"
check_file "pubspec.yaml"
check_file "analysis_options.yaml"
check_file "commitlint.config.js"
check_file "tool/quality.sh"

echo ""
echo "📁 Required Directories:"
check_directory ".husky" "Husky hooks"

echo ""
echo "📦 Dependencies:"
if [ -d "node_modules" ]; then
  echo -e "${GREEN}✅${NC} Node modules: Installed"
  if [ -d "node_modules/husky" ] || [ -f "node_modules/husky/lib/index.js" ] || [ -f "node_modules/.bin/husky" ]; then
    echo -e "${GREEN}✅${NC} Husky: Installed"
  else
    echo -e "${YELLOW}⚠️${NC}  Husky: May not be installed (run: npm install)"
    ((WARNINGS++))
  fi
else
  echo -e "${RED}❌${NC} Node modules: Not installed (run: npm install)"
  ((ERRORS++))
fi

if [ -d ".dart_tool" ]; then
  echo -e "${GREEN}✅${NC} Flutter dependencies: Available"
else
  echo -e "${YELLOW}⚠️${NC}  Flutter dependencies: Run 'flutter pub get'"
  ((WARNINGS++))
fi

if grep -q "very_good_analysis" pubspec.yaml 2>/dev/null; then
  echo -e "${GREEN}✅${NC} very_good_analysis: Configured in pubspec.yaml"
else
  echo -e "${YELLOW}⚠️${NC}  very_good_analysis: Not in pubspec.yaml (recommended)"
  ((WARNINGS++))
fi

echo ""
echo "🔗 Git Hooks:"
if git config core.hooksPath | grep -q ".husky" 2>/dev/null; then
  echo -e "${GREEN}✅${NC} Git hooks path: Configured"
else
  echo -e "${YELLOW}⚠️${NC}  Git hooks path: Not configured (run: npm install)"
  ((WARNINGS++))
fi

if [ -x ".husky/pre-commit" ]; then
  echo -e "${GREEN}✅${NC} pre-commit hook: Executable"
else
  echo -e "${RED}❌${NC} pre-commit hook: Not executable"
  ((ERRORS++))
fi

if [ -x ".husky/pre-push" ]; then
  echo -e "${GREEN}✅${NC} pre-push hook: Executable"
else
  echo -e "${RED}❌${NC} pre-push hook: Not executable"
  ((ERRORS++))
fi

if [ -x ".husky/commit-msg" ]; then
  echo -e "${GREEN}✅${NC} commit-msg hook: Executable"
else
  echo -e "${RED}❌${NC} commit-msg hook: Not executable"
  ((ERRORS++))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}✅ Setup validation passed!${NC}"
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo -e "${YELLOW}⚠️  Setup validation passed with $WARNINGS warning(s)${NC}"
  exit 0
else
  echo -e "${RED}❌ Setup validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
  echo ""
  echo "Quick fix:"
  echo "  1. Run: npm install"
  echo "  2. Run: flutter pub get"
  echo "  3. Run: npm run validate"
  exit 1
fi

