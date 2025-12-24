#!/bin/bash
# Outcode Flutter Linter & Workflow Setup Script
# Copies all files from linter-workflow-package to the Flutter project root
#
# Usage:
#   1. Copy linter-workflow-package folder to your Flutter project
#   2. cd into your Flutter project
#   3. Run: ./linter-workflow-package/setup.sh
#
# Or run from inside the package folder:
#   cd linter-workflow-package
#   ./setup.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if PACKAGE_DIR is set (from npm package) or use script directory
if [ -n "${PACKAGE_DIR:-}" ]; then
  # Running from npm package
  PACKAGE_DIR="$PACKAGE_DIR"
  PROJECT_ROOT="$(pwd)"
else
  # Running from local copy
  PACKAGE_DIR="$SCRIPT_DIR"
  PROJECT_ROOT="$(cd "$PACKAGE_DIR/.." && pwd)"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Outcode Flutter Linter & Workflow Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Package directory: ${GREEN}$PACKAGE_DIR${NC}"
echo -e "Project root: ${GREEN}$PROJECT_ROOT${NC}"
echo ""

# Verify we're in a Flutter project
if [ ! -f "$PROJECT_ROOT/pubspec.yaml" ]; then
  echo -e "${RED}❌ Error: $PROJECT_ROOT is not a Flutter project (pubspec.yaml not found)${NC}"
  echo "   Please ensure linter-workflow-package is inside your Flutter project directory"
  exit 1
fi

# Verify package directory exists and has required files
if [ ! -f "$PACKAGE_DIR/package.json" ]; then
  echo -e "${RED}❌ Error: linter-workflow-package files not found${NC}"
  echo "   Expected: $PACKAGE_DIR/package.json"
  exit 1
fi

# Step counter
STEP=1
total_steps=12

print_step() {
  echo -e "${BLUE}[$STEP/$total_steps]${NC} $1"
  ((STEP++))
}

# Step 1: Copy root-level files
print_step "Copying root-level configuration files..."
for file in package.json analysis_options.yaml commitlint.config.js .fvmrc .nvmrc; do
  if [ -f "$PACKAGE_DIR/$file" ]; then
    if [ -f "$PROJECT_ROOT/$file" ]; then
      if [ "$file" = "package.json" ]; then
        # For package.json, we'll merge or overwrite (user's choice)
        echo -e "   ${YELLOW}⚠️${NC}  $file already exists"
        read -p "   Overwrite? (y/N): " OVERWRITE
        if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
          cp "$PACKAGE_DIR/$file" "$PROJECT_ROOT/$file"
          echo -e "   ${GREEN}✅${NC} Overwritten $file"
        else
          echo -e "   ${YELLOW}⏭️${NC}  Skipped $file"
        fi
      else
        cp "$PACKAGE_DIR/$file" "$PROJECT_ROOT/$file"
        echo -e "   ${GREEN}✅${NC} Copied $file"
      fi
    else
      cp "$PACKAGE_DIR/$file" "$PROJECT_ROOT/$file"
      echo -e "   ${GREEN}✅${NC} Copied $file"
    fi
  fi
done

# Step 2: Update .gitignore (merge instead of overwrite)
print_step "Updating .gitignore..."
if [ -f "$PACKAGE_DIR/.gitignore" ]; then
  if [ -f "$PROJECT_ROOT/.gitignore" ]; then
    # Merge gitignore entries
    TEMP_GITIGNORE=$(mktemp)
    cat "$PROJECT_ROOT/.gitignore" > "$TEMP_GITIGNORE"
    echo "" >> "$TEMP_GITIGNORE"
    echo "# Outcode Flutter Standards (added by setup script)" >> "$TEMP_GITIGNORE"
    # Add entries from package that don't exist in project
    while IFS= read -r line; do
      if [[ ! "$line" =~ ^#.*$ ]] && [[ -n "$line" ]]; then
        if ! grep -Fxq "$line" "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
          echo "$line" >> "$TEMP_GITIGNORE"
        fi
      fi
    done < "$PACKAGE_DIR/.gitignore"
    mv "$TEMP_GITIGNORE" "$PROJECT_ROOT/.gitignore"
    echo -e "   ${GREEN}✅${NC} Merged .gitignore"
  else
    cp "$PACKAGE_DIR/.gitignore" "$PROJECT_ROOT/.gitignore"
    echo -e "   ${GREEN}✅${NC} Created .gitignore"
  fi
fi

# Step 3: Copy .husky directory
print_step "Setting up Husky Git hooks..."
if [ -d "$PACKAGE_DIR/.husky" ]; then
  mkdir -p "$PROJECT_ROOT/.husky"
  # Copy all hook files
  for hook in commit-msg pre-commit pre-push pre-commit-branch-protection pre-push-branch-protection; do
    if [ -f "$PACKAGE_DIR/.husky/$hook" ]; then
      cp "$PACKAGE_DIR/.husky/$hook" "$PROJECT_ROOT/.husky/$hook"
      chmod +x "$PROJECT_ROOT/.husky/$hook"
      echo -e "   ${GREEN}✅${NC} Copied $hook"
    fi
  done
  echo -e "   ${GREEN}✅${NC} Husky hooks configured"
fi

# Step 4: Copy .github/workflows
print_step "Setting up GitHub Actions workflows..."
if [ -d "$PACKAGE_DIR/.github/workflows" ]; then
  mkdir -p "$PROJECT_ROOT/.github/workflows"
  for workflow in quality.yml deploy-uat.yml deploy-prod.yml merge-prod-to-main.yml README.md; do
    if [ -f "$PACKAGE_DIR/.github/workflows/$workflow" ]; then
      cp "$PACKAGE_DIR/.github/workflows/$workflow" "$PROJECT_ROOT/.github/workflows/$workflow"
      echo -e "   ${GREEN}✅${NC} Copied $workflow"
    fi
  done
  echo -e "   ${GREEN}✅${NC} GitHub Actions workflows configured"
fi

# Step 5: Copy tool scripts
print_step "Copying quality check scripts..."
if [ -d "$PACKAGE_DIR/tool" ]; then
  mkdir -p "$PROJECT_ROOT/tool"
  for script in quality.sh validate-setup.sh; do
    if [ -f "$PACKAGE_DIR/tool/$script" ]; then
      cp "$PACKAGE_DIR/tool/$script" "$PROJECT_ROOT/tool/$script"
      chmod +x "$PROJECT_ROOT/tool/$script"
      echo -e "   ${GREEN}✅${NC} Copied $script"
    fi
  done
  echo -e "   ${GREEN}✅${NC} Quality check scripts copied"
fi

# Step 6: Copy engineering documentation
print_step "Copying engineering documentation..."
if [ -d "$PACKAGE_DIR/docs/engineering" ]; then
  mkdir -p "$PROJECT_ROOT/docs/engineering"
  for doc in outcode-git-branching-strategy.md outcode-husky-hooks-standard.md; do
    if [ -f "$PACKAGE_DIR/docs/engineering/$doc" ]; then
      cp "$PACKAGE_DIR/docs/engineering/$doc" "$PROJECT_ROOT/docs/engineering/$doc"
      echo -e "   ${GREEN}✅${NC} Copied $doc"
    fi
  done
  echo -e "   ${GREEN}✅${NC} Engineering documentation copied"
fi

# Step 7: Add very_good_analysis to pubspec.yaml
print_step "Updating pubspec.yaml with very_good_analysis..."
cd "$PROJECT_ROOT"
if [ -f "$PROJECT_ROOT/pubspec.yaml" ]; then
  # Check if very_good_analysis is already in dev_dependencies
  if grep -q "very_good_analysis" "$PROJECT_ROOT/pubspec.yaml"; then
    echo -e "   ${YELLOW}ℹ️${NC}  very_good_analysis already in pubspec.yaml"
  else
    # Check if dev_dependencies section exists
    if grep -q "^dev_dependencies:" "$PROJECT_ROOT/pubspec.yaml"; then
      # dev_dependencies exists, add very_good_analysis to it
      # Find the last line in dev_dependencies section and add after it
      TEMP_PUBSPEC=$(mktemp)
      IN_DEV_DEPS=false
      ADDED=false
      
      while IFS= read -r line || [ -n "$line" ]; do
        if echo "$line" | grep -qE "^dev_dependencies:"; then
          IN_DEV_DEPS=true
          echo "$line" >> "$TEMP_PUBSPEC"
        elif [ "$IN_DEV_DEPS" = true ] && [ "$ADDED" = false ]; then
          # Check if we've left dev_dependencies (new top-level key or empty line followed by top-level key)
          if echo "$line" | grep -qE "^[a-z]"; then
            # New top-level section, add very_good_analysis before it
            echo "  very_good_analysis: ^10.0.0" >> "$TEMP_PUBSPEC"
            echo "$line" >> "$TEMP_PUBSPEC"
            ADDED=true
            IN_DEV_DEPS=false
          else
            # Still in dev_dependencies, keep the line
            echo "$line" >> "$TEMP_PUBSPEC"
          fi
        else
          echo "$line" >> "$TEMP_PUBSPEC"
        fi
      done < "$PROJECT_ROOT/pubspec.yaml"
      
      # If we were still in dev_dependencies at end of file, add it
      if [ "$IN_DEV_DEPS" = true ] && [ "$ADDED" = false ]; then
        echo "  very_good_analysis: ^10.0.0" >> "$TEMP_PUBSPEC"
        ADDED=true
      fi
      
      mv "$TEMP_PUBSPEC" "$PROJECT_ROOT/pubspec.yaml"
      
      if [ "$ADDED" = true ]; then
        echo -e "   ${GREEN}✅${NC} Added very_good_analysis to dev_dependencies"
      else
        echo -e "   ${YELLOW}⚠️${NC}  Could not automatically add very_good_analysis"
        echo -e "   ${YELLOW}   Please add 'very_good_analysis: ^10.0.0' to dev_dependencies manually${NC}"
      fi
    else
      # dev_dependencies doesn't exist, add it before flutter: section
      TEMP_PUBSPEC=$(mktemp)
      ADDED=false
      
      while IFS= read -r line || [ -n "$line" ]; do
        if echo "$line" | grep -qE "^flutter:" && [ "$ADDED" = false ]; then
          echo "" >> "$TEMP_PUBSPEC"
          echo "dev_dependencies:" >> "$TEMP_PUBSPEC"
          echo "  very_good_analysis: ^10.0.0" >> "$TEMP_PUBSPEC"
          echo "$line" >> "$TEMP_PUBSPEC"
          ADDED=true
        else
          echo "$line" >> "$TEMP_PUBSPEC"
        fi
      done < "$PROJECT_ROOT/pubspec.yaml"
      
      mv "$TEMP_PUBSPEC" "$PROJECT_ROOT/pubspec.yaml"
      
      if [ "$ADDED" = true ]; then
        echo -e "   ${GREEN}✅${NC} Added dev_dependencies section with very_good_analysis"
      else
        echo -e "   ${YELLOW}⚠️${NC}  Could not automatically add dev_dependencies"
        echo -e "   ${YELLOW}   Please add dev_dependencies section with very_good_analysis manually${NC}"
      fi
    fi
  fi
else
  echo -e "   ${RED}❌${NC} pubspec.yaml not found"
  exit 1
fi

# Step 8: Install Flutter dependencies
print_step "Installing Flutter dependencies..."
cd "$PROJECT_ROOT"
if ! command -v flutter &> /dev/null && ! command -v fvm &> /dev/null; then
  echo -e "   ${YELLOW}⚠️${NC}  Flutter not found. Skipping flutter pub get"
  echo -e "   ${YELLOW}   Please run 'flutter pub get' manually after installing Flutter${NC}"
else
  # Use FVM if available and .fvmrc exists
  if command -v fvm &> /dev/null && [ -f "$PROJECT_ROOT/.fvmrc" ]; then
    fvm flutter pub get
    echo -e "   ${GREEN}✅${NC} Flutter dependencies installed (via FVM)"
  elif command -v flutter &> /dev/null; then
    flutter pub get
    echo -e "   ${GREEN}✅${NC} Flutter dependencies installed"
  else
    echo -e "   ${YELLOW}⚠️${NC}  Flutter command not found. Skipping flutter pub get"
  fi
fi

# Step 9: Initialize Git (needed for Husky)
print_step "Initializing Git repository (required for Husky hooks)..."
cd "$PROJECT_ROOT"

# Check if git is initialized
if [ ! -d "$PROJECT_ROOT/.git" ]; then
  git init
  echo -e "   ${GREEN}✅${NC} Git repository initialized"
else
  echo -e "   ${YELLOW}ℹ️${NC}  Git repository already exists"
fi

# Step 10: Install npm dependencies
print_step "Installing npm dependencies..."
cd "$PROJECT_ROOT"
if ! command -v npm &> /dev/null; then
  echo -e "   ${RED}❌${NC} npm not found. Please install Node.js first"
  exit 1
fi
npm install
echo -e "   ${GREEN}✅${NC} npm dependencies installed"

# Step 11: Set up Husky hooks (ensure Git hooks path is configured)
print_step "Setting up Husky Git hooks..."
cd "$PROJECT_ROOT"
# Explicitly run husky install to ensure Git hooks path is configured
npx husky install || {
  echo -e "   ${YELLOW}⚠️${NC}  Husky install failed, trying alternative method..."
  # Fallback: manually set Git hooks path
  git config core.hooksPath .husky
  echo -e "   ${GREEN}✅${NC} Git hooks path configured manually"
}
# Verify hooks path is set
if git config core.hooksPath | grep -q ".husky"; then
  echo -e "   ${GREEN}✅${NC} Husky hooks configured (Git hooks path: $(git config core.hooksPath))"
else
  echo -e "   ${YELLOW}⚠️${NC}  Git hooks path not configured, setting manually..."
  git config core.hooksPath .husky
  echo -e "   ${GREEN}✅${NC} Git hooks path configured"
fi

# Step 12: Setup branches (optional)
print_step "Setting up Git branches (optional)..."

# Ask if user wants to set up GitHub remote
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📦 GitHub Repository Setup (Optional)${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Enter GitHub repository URL (or press Enter to skip): " GITHUB_URL

if [ -n "$GITHUB_URL" ]; then
  if git remote get-url origin &>/dev/null; then
    echo -e "   ${YELLOW}ℹ️${NC}  Remote 'origin' already exists: $(git remote get-url origin)"
    read -p "   Update it? (y/N): " UPDATE_REMOTE
    if [[ "$UPDATE_REMOTE" =~ ^[Yy]$ ]]; then
      git remote set-url origin "$GITHUB_URL"
      echo -e "   ${GREEN}✅${NC} Updated remote origin"
    fi
  else
    git remote add origin "$GITHUB_URL"
    echo -e "   ${GREEN}✅${NC} Added remote origin"
  fi
fi

# Ask if user wants to create initial commit and branches
echo ""
read -p "Create initial commit and standard branches? (y/N): " SETUP_BRANCHES

if [[ "$SETUP_BRANCHES" =~ ^[Yy]$ ]]; then
  # Stage all files
  git add .
  
  # Create initial commit
  git commit -m "chore: setup Outcode Flutter code quality standards

- Add Husky hooks for commit message validation and quality checks
- Add GitHub Actions workflows for CI/CD
- Add code quality scripts and configuration
- Add engineering documentation
- Configure version pinning (FVM, NVM)" || {
    echo -e "   ${YELLOW}⚠️${NC}  Commit failed (might be empty or already committed)"
  }
  echo -e "   ${GREEN}✅${NC} Initial commit created"
  
  # Ensure we're on main branch
  if git rev-parse --verify main &>/dev/null; then
    git checkout main 2>/dev/null || true
  elif git rev-parse --verify master &>/dev/null; then
    git checkout master
    git branch -m master main
  else
    git checkout -b main 2>/dev/null || git branch main
    git checkout main
  fi
  
  # Create standard branches
  for branch in develop uat prod; do
    if ! git rev-parse --verify "$branch" &>/dev/null; then
      git checkout -b "$branch" main
      echo -e "   ${GREEN}✅${NC} Created branch: $branch"
    else
      echo -e "   ${YELLOW}ℹ️${NC}  Branch '$branch' already exists"
    fi
  done
  
  # Checkout develop
  git checkout develop
  echo -e "   ${GREEN}✅${NC} Switched to develop branch"
  
  # Ask about pushing
  if git remote get-url origin &>/dev/null; then
    echo ""
    read -p "Push all branches to GitHub? (y/N): " PUSH_BRANCHES
    if [[ "$PUSH_BRANCHES" =~ ^[Yy]$ ]]; then
      for branch in main develop uat prod; do
        if git rev-parse --verify "$branch" &>/dev/null; then
          ALLOW_PROTECTED_BRANCHES=true git push -u origin "$branch" || {
            echo -e "   ${YELLOW}⚠️${NC}  Failed to push $branch"
          }
        fi
      done
      echo -e "   ${GREEN}✅${NC} Pushed all branches"
    fi
  fi
else
  echo -e "   ${YELLOW}⏭️${NC}  Skipped branch setup"
fi

# Final summary
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📋 What was set up:${NC}"
echo "   ✅ package.json with Husky, Commitlint, lint-staged"
echo "   ✅ npm dependencies installed"
echo "   ✅ pubspec.yaml updated with very_good_analysis"
echo "   ✅ Flutter dependencies installed"
echo "   ✅ .gitignore updated"
echo "   ✅ GitHub Actions workflows (quality, deploy-uat, deploy-prod, merge-prod-to-main)"
echo "   ✅ Version pinning (.fvmrc, .nvmrc)"
echo "   ✅ Code quality configuration (analysis_options.yaml)"
echo "   ✅ Commit message validation (commitlint.config.js)"
echo "   ✅ Engineering documentation"
echo "   ✅ Husky Git hooks (pre-commit, pre-push, commit-msg)"
echo "   ✅ Husky hooks path configured in Git"
echo "   ✅ Quality check scripts (tool/quality.sh, tool/validate-setup.sh)"
echo ""
echo -e "${BLUE}📝 Next Steps:${NC}"
echo ""
echo "1. ${YELLOW}Verify setup:${NC}"
echo "   npm run validate"
echo "   ${BLUE}   Note:${NC} FVM and nvm warnings are optional - setup works without them"
echo ""
echo "2. ${YELLOW}Test quality checks:${NC}"
echo "   npm run quality:check"
echo ""
echo "3. ${YELLOW}Set up GitHub branch protection rules:${NC}"
echo "   • Go to: Settings → Branches → Branch protection rules"
echo "   • Add rules for: main, develop, uat, prod"
echo "   • See: docs/engineering/outcode-git-branching-strategy.md"
echo ""
echo "4. ${YELLOW}Start developing:${NC}"
echo "   git checkout -b feature/your-feature-name"
echo ""
echo -e "${BLUE}📚 Documentation:${NC}"
echo "   • Git Strategy: docs/engineering/outcode-git-branching-strategy.md"
echo "   • Hooks Standard: docs/engineering/outcode-husky-hooks-standard.md"
echo "   • Workflows: .github/workflows/README.md"
echo ""

# Clean up the downloaded folder (mandatory)
echo -e "${BLUE}🗑️  Cleaning up...${NC}"
if [ -d "$PACKAGE_DIR" ] && [ "$PACKAGE_DIR" != "$PROJECT_ROOT" ] && [ "$PACKAGE_DIR" != "." ]; then
  rm -rf "$PACKAGE_DIR"
  echo -e "   ${GREEN}✅${NC} Removed downloaded folder: $(basename "$PACKAGE_DIR")"
else
  echo -e "   ${YELLOW}⚠️${NC}  Could not remove folder (safety check - folder might be outside project)"
fi

# Clean up install.sh from project root
if [ -f "$PROJECT_ROOT/install.sh" ]; then
  rm -f "$PROJECT_ROOT/install.sh"
  echo -e "   ${GREEN}✅${NC} Removed install.sh"
fi

echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"

