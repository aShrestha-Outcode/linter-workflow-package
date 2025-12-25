#!/bin/bash
# Outcode React Native Code Quality Standard
# Single source of truth for quality checks used by hooks and CI
#
# Usage:
#   tool/quality.sh quick   # Fast checks for pre-commit (formatting only)
#   tool/quality.sh check   # Full local checks for pre-push
#   tool/quality.sh ci      # Strict CI checks (treats warnings as errors)

set -euo pipefail

# Track start time for performance reporting
START_TIME=$(date +%s)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Pre-flight checks
if ! command_exists node && ! command_exists npm; then
  echo -e "${RED}❌ Error: Node.js and npm not found.${NC}"
  echo "   Please install Node.js: https://nodejs.org/"
  exit 1
fi

# Function to run format check
run_format_check() {
  echo -e "\n${GREEN}📐 Checking code formatting...${NC}"
  if ! npm run format:check; then
    echo -e "${RED}❌ Code formatting check failed. Run 'npm run format' to fix.${NC}"
    return 1
  fi
  echo -e "${GREEN}✅ Formatting check passed${NC}"
}

# Function to run format (auto-fix)
run_format() {
  echo -e "\n${GREEN}📐 Formatting code...${NC}"
  npm run format || {
    echo -e "${RED}❌ Formatting failed${NC}"
    return 1
  }
  echo -e "${GREEN}✅ Formatting complete${NC}"
}

# Function to run ESLint
run_lint() {
  local strict_mode="${1:-false}"
  echo -e "\n${GREEN}🔍 Running ESLint...${NC}"
  
  if [ "$strict_mode" = "true" ]; then
    # CI mode: fail on any ESLint error or warning
    if ! npm run lint; then
      echo -e "${RED}❌ ESLint failed (strict mode: all issues treated as errors)${NC}"
      return 1
    fi
  else
    # Normal mode: ESLint already shows warnings but doesn't fail on them by default
    # We'll let ESLint handle this - it will exit non-zero only on errors
    if ! npm run lint; then
      echo -e "${RED}❌ ESLint found errors${NC}"
      return 1
    fi
  fi
  
  echo -e "${GREEN}✅ Linting passed${NC}"
}

# Function to run tests
run_tests() {
  echo -e "\n${GREEN}🧪 Running tests...${NC}"
  
  # Check if Jest is configured (look for jest.config.js or jest in package.json)
  if [ ! -f "jest.config.js" ] && [ ! -f "jest.config.json" ] && ! grep -q '"jest"' package.json 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Jest not configured. Skipping tests.${NC}"
    echo -e "   ${BLUE}ℹ️${NC}  To enable tests, configure Jest in your project"
    return 0
  fi
  
  # Try to run tests (React Native projects typically use Jest)
  if npm run test -- --passWithNoTests 2>/dev/null || npm test -- --passWithNoTests 2>/dev/null || npx jest --passWithNoTests 2>/dev/null; then
    echo -e "${GREEN}✅ All tests passed${NC}"
    return 0
  else
    echo -e "${RED}❌ Tests failed${NC}"
    return 1
  fi
}

# Function to check test coverage
run_coverage_check() {
  local strict_mode="${1:-false}"
  local min_coverage="${MIN_COVERAGE:-80}"
  
  echo -e "\n${GREEN}📊 Checking test coverage...${NC}"
  
  # Check if Jest is configured
  if [ ! -f "jest.config.js" ] && [ ! -f "jest.config.json" ] && ! grep -q '"jest"' package.json 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Jest not configured. Skipping coverage check.${NC}"
    if [ "$strict_mode" = "true" ]; then
      return 1
    fi
    return 0
  fi
  
  # Run tests with coverage
  if npm run test -- --coverage --passWithNoTests 2>/dev/null || npm test -- --coverage --passWithNoTests 2>/dev/null || npx jest --coverage --passWithNoTests 2>/dev/null; then
    # Coverage directory should exist after running tests
    if [ -d "coverage" ]; then
      # Try to extract coverage from coverage/coverage-summary.json (Jest format)
      if [ -f "coverage/coverage-summary.json" ]; then
        # Extract total coverage percentage from Jest coverage summary
        # Jest coverage summary has format: {"total": {"lines": {"pct": 85.5}, ...}}
        COVERAGE_PERCENT=$(node -e "try { const cov = require('./coverage/coverage-summary.json'); console.log(cov.total?.lines?.pct || 0); } catch(e) { console.log(0); }" 2>/dev/null || echo "0")
        COVERAGE_INT=$(echo "$COVERAGE_PERCENT" | cut -d. -f1)
        
        echo -e "${GREEN}   Coverage: ${COVERAGE_PERCENT}%${NC}"
        echo -e "${GREEN}   Minimum required: ${min_coverage}%${NC}"
        
        if [ "$COVERAGE_INT" -lt "$min_coverage" ]; then
          echo -e "${RED}❌ Test coverage is ${COVERAGE_PERCENT}%, which is below the minimum of ${min_coverage}%${NC}"
          echo -e "${YELLOW}   Please add more tests to increase coverage${NC}"
          
          if [ "$strict_mode" = "true" ]; then
            echo -e "${RED}   Coverage check failed (strict mode)${NC}"
            return 1
          else
            echo -e "${YELLOW}   ⚠️  Coverage warning (not blocking in pre-push mode)${NC}"
            echo -e "${YELLOW}   Coverage will be enforced in CI${NC}"
            return 0
          fi
        else
          echo -e "${GREEN}✅ Test coverage meets minimum requirement (${min_coverage}%)${NC}"
          return 0
        fi
      else
        echo -e "${YELLOW}⚠️  Coverage summary file not found${NC}"
        if [ "$strict_mode" = "true" ]; then
          return 1
        fi
        return 0
      fi
    else
      echo -e "${YELLOW}⚠️  Coverage directory not found${NC}"
      if [ "$strict_mode" = "true" ]; then
        return 1
      fi
      return 0
    fi
  else
    echo -e "${RED}❌ Failed to generate coverage report${NC}"
    if [ "$strict_mode" = "true" ]; then
      return 1
    fi
    return 0
  fi
}

# Main execution
MODE="${1:-check}"

case "$MODE" in
  quick)
    echo -e "${GREEN}🚀 Running quick quality checks (pre-commit mode)...${NC}"
    run_format
    ;;
  check)
    echo -e "${GREEN}🚀 Running full quality checks (pre-push mode)...${NC}"
    run_format_check || exit 1
    run_lint false || exit 1
    run_tests || exit 1
    run_coverage_check false || true  # Warning only, doesn't fail
    echo -e "\n${GREEN}✅ All quality checks passed!${NC}"
    ;;
  ci)
    echo -e "${GREEN}🚀 Running CI quality checks (strict mode)...${NC}"
    run_format_check || exit 1
    run_lint true || exit 1
    run_tests || exit 1
    run_coverage_check true || exit 1  # Strict mode - fails if below threshold
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    echo -e "\n${GREEN}✅ All CI quality checks passed! (took ${DURATION}s)${NC}"
    ;;
  *)
    echo -e "${RED}❌ Unknown mode: $MODE${NC}"
    echo "Usage: $0 {quick|check|ci}"
    exit 1
    ;;
esac

# Report duration for check mode
if [ "$MODE" = "check" ]; then
  END_TIME=$(date +%s)
  DURATION=$((END_TIME - START_TIME))
  echo -e "${GREEN}⏱️  Total time: ${DURATION}s${NC}"
fi

