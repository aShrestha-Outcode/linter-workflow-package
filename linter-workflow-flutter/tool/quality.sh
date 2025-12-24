#!/bin/bash
# Outcode Flutter Code Quality Standard
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
if ! command_exists dart && ! command_exists flutter; then
  echo -e "${RED}❌ Error: Neither 'dart' nor 'flutter' command found.${NC}"
  echo "   Please install Flutter: https://docs.flutter.dev/get-started/install"
  exit 1
fi

# Detect Flutter command (FVM or direct)
if command -v fvm &> /dev/null; then
  if [ -f ".fvmrc" ] || [ -f "fvm_config.json" ]; then
    FLUTTER_CMD="fvm flutter"
    echo -e "${YELLOW}ℹ️  Using FVM for Flutter commands${NC}"
    # Verify FVM is working
    if ! fvm flutter --version &> /dev/null; then
      echo -e "${YELLOW}⚠️  FVM detected but Flutter command failed, falling back to system Flutter${NC}"
      FLUTTER_CMD="flutter"
    fi
  else
    FLUTTER_CMD="flutter"
  fi
else
  FLUTTER_CMD="flutter"
fi

# Verify Flutter is accessible
FLUTTER_BIN=$(echo "$FLUTTER_CMD" | cut -d' ' -f1)
if ! command_exists "$FLUTTER_BIN"; then
  echo -e "${RED}❌ Error: Flutter command '$FLUTTER_BIN' not found in PATH${NC}"
  exit 1
fi

# Function to run format check
run_format_check() {
  echo -e "\n${GREEN}📐 Checking code formatting...${NC}"
  if ! dart format --set-exit-if-changed .; then
    echo -e "${RED}❌ Code formatting check failed. Run 'dart format .' to fix.${NC}"
    return 1
  fi
  echo -e "${GREEN}✅ Formatting check passed${NC}"
}

# Function to run format (auto-fix)
run_format() {
  echo -e "\n${GREEN}📐 Formatting code...${NC}"
  dart format . || {
    echo -e "${RED}❌ Formatting failed${NC}"
    return 1
  }
  echo -e "${GREEN}✅ Formatting complete${NC}"
}

# Function to run Flutter analyze
run_analyze() {
  local strict_mode="${1:-false}"
  echo -e "\n${GREEN}🔍 Running Flutter analyze...${NC}"
  
  if [ "$strict_mode" = "true" ]; then
    # CI mode: treat warnings as errors
    if ! $FLUTTER_CMD analyze --fatal-warnings --fatal-infos; then
      echo -e "${RED}❌ Analysis failed (strict mode: warnings treated as errors)${NC}"
      return 1
    fi
  else
    # Normal mode: only fail on errors (not warnings/info)
    OUTPUT=$($FLUTTER_CMD analyze --no-fatal-infos --no-fatal-warnings 2>&1)
    EXIT_CODE=$?
    
    # Check if there are actual errors (not just warnings/info)
    # Match "error •" pattern (with bullet point)
    ERROR_COUNT=$(echo "$OUTPUT" | grep -c "  error •" 2>/dev/null || echo "0")
    
    # Also check exit code - analyze returns non-zero if there are errors
    if [ "$ERROR_COUNT" -gt 0 ]; then
      echo -e "${RED}❌ Analysis found $ERROR_COUNT error(s)${NC}"
      echo "$OUTPUT" | grep "  error •" | head -10
      return 1
    fi
    
    if [ "$EXIT_CODE" -ne 0 ] && [ "$ERROR_COUNT" -eq 0 ]; then
      # Exit code non-zero but no errors found - might be warnings only
      echo -e "${YELLOW}⚠️  Analysis found issues (check output above)${NC}"
      # Don't fail on warnings in normal mode
    fi
  fi
  
  echo -e "${GREEN}✅ Analysis passed${NC}"
}

# Function to run code quality checks (using built-in analyzer)
# Note: dart_code_metrics removed, using very_good_analysis + built-in analyzer
run_metrics() {
  echo -e "\n${GREEN}📊 Running code quality checks...${NC}"
  
  if ! command_exists dart; then
    echo -e "${YELLOW}⚠️  Dart not found, skipping quality checks${NC}"
    return 0
  fi
  
  # Check for functions with too many parameters (>5)
  # This is a basic complexity check since analyzer doesn't enforce parameter limits
  echo -e "${GREEN}🔍 Checking function complexity...${NC}"
  
  # Find functions with more than 5 parameters
  # Handle multi-line function signatures by looking for patterns with 6+ commas in parameter lists
  # Exclude widget constructors (MaterialApp, Scaffold, etc.) as they commonly have many named parameters
  COMPLEX_FUNCTIONS=$(find lib -name "*.dart" -type f ! -path "*/gen/*" ! -name "*.g.dart" ! -name "*.freezed.dart" ! -name "*.mocks.dart" -exec awk '
    BEGIN { in_params = 0; param_count = 0; function_name = ""; line_num = 0; is_widget = 0 }
    # Skip widget constructors (common Flutter widgets that legitimately have many named parameters)
    /^(MaterialApp|Scaffold|Column|Row|Container|Padding|Text|ThemeData|ColorScheme|AppBar|FloatingActionButton|StatelessWidget|StatefulWidget)\s*\(/ ||
    /^\s+(MaterialApp|Scaffold|Column|Row|Container|Padding|Text|ThemeData|ColorScheme|AppBar|FloatingActionButton|StatelessWidget|StatefulWidget)\s*\(/ {
      # Skip widget constructors - they commonly have many named parameters
      next
    }
    /^[a-zA-Z_][a-zA-Z0-9_]*\s*\(/ || /^\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\(/ || /^void\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\(/ || /^\s+void\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\(/ {
      # Start of function signature (matches: func(, void func(, etc.)
      function_name = $0
      line_num = NR
      in_params = 1
      param_count = 0
      is_widget = 0
      # Count commas in first line
      gsub(/[^,]/, "", $0)
      param_count = length($0)
    }
    in_params && /,/ {
      # Count additional commas in parameter list
      gsub(/[^,]/, "", $0)
      param_count += length($0)
    }
    in_params && /\)/ {
      # End of parameter list
      if (param_count >= 5 && !is_widget) {  # 5 commas = 6 parameters, but skip widgets
        print FILENAME ":" line_num ":" function_name " (" (param_count + 1) " parameters)"
      }
      in_params = 0
      param_count = 0
      is_widget = 0
    }
  ' {} \; 2>/dev/null)
  
  if [ -n "$COMPLEX_FUNCTIONS" ]; then
    echo -e "${RED}❌ Found functions with more than 5 parameters (complexity violation)${NC}"
    echo -e "${YELLOW}   Consider refactoring to use classes/objects instead of many parameters${NC}"
    echo "$COMPLEX_FUNCTIONS" | head -5
    return 1
  fi
  
  # Check for deep nesting (basic check - looks for multiple consecutive closing braces)
  # This is a simplified check - full nesting analysis would require AST parsing
  DEEP_NESTING=$(find lib -name "*.dart" -type f ! -path "*/gen/*" ! -name "*.g.dart" ! -name "*.freezed.dart" ! -name "*.mocks.dart" -exec awk '
    BEGIN { max_depth = 0; current_depth = 0 }
    /{/ { current_depth++; if (current_depth > max_depth) max_depth = current_depth }
    /}/ { current_depth-- }
    END { if (max_depth > 6) print max_depth }
  ' {} \; 2>/dev/null | sort -rn | head -1)
  
  if [ -n "$DEEP_NESTING" ] && [ "$DEEP_NESTING" -gt 6 ]; then
    echo -e "${YELLOW}⚠️  Found deep nesting (max depth: $DEEP_NESTING levels)${NC}"
    echo -e "${YELLOW}   Consider refactoring with early returns to reduce nesting${NC}"
    # Don't fail on this, just warn (nesting detection is imprecise)
  fi
  
  # The analyzer already runs comprehensive checks including:
  # - Complexity (through lint rules)
  # - Code style (through lint rules)
  # - Best practices (through lint rules)
  # - very_good_analysis provides additional rules
  
  echo -e "${GREEN}✅ Code quality checks passed (enforced by analyzer + very_good_analysis)${NC}"
  echo -e "${YELLOW}ℹ️  Code quality is enforced through:${NC}"
  echo "   • Flutter analyzer (complexity, style, best practices)"
  echo "   • very_good_analysis (additional quality rules)"
  echo "   • Custom lint rules in analysis_options.yaml"
  echo "   • Parameter count checks (max 5 parameters)"
  
  return 0
}

# Function to run tests
run_tests() {
  echo -e "\n${GREEN}🧪 Running Flutter tests...${NC}"
  if ! $FLUTTER_CMD test --no-pub; then
    echo -e "${RED}❌ Tests failed${NC}"
    return 1
  fi
  echo -e "${GREEN}✅ All tests passed${NC}"
}

# Function to check test coverage
# MIN_COVERAGE: Minimum coverage percentage (default: 80)
# STRICT_MODE: If true, fails if coverage is below threshold (default: false for pre-push, true for CI)
run_coverage_check() {
  local strict_mode="${1:-false}"
  local min_coverage="${MIN_COVERAGE:-80}"
  
  echo -e "\n${GREEN}📊 Checking test coverage...${NC}"
  
  # Run tests with coverage
  if ! $FLUTTER_CMD test --coverage --no-pub >/dev/null 2>&1; then
    echo -e "${RED}❌ Failed to generate coverage report${NC}"
    if [ "$strict_mode" = "true" ]; then
      return 1
    fi
    return 0
  fi
  
  # Check if coverage directory exists
  if [ ! -d "coverage" ]; then
    echo -e "${YELLOW}⚠️  Coverage directory not found${NC}"
    if [ "$strict_mode" = "true" ]; then
      return 1
    fi
    return 0
  fi
  
  # Parse lcov.info to get coverage percentage
  # lcov format: lines found: X, lines hit: Y
  if [ -f "coverage/lcov.info" ]; then
    # Extract total lines and hit lines from lcov.info
    TOTAL_LINES=$(grep "^LF:" coverage/lcov.info | awk -F: '{sum+=$2} END {print sum}' || echo "0")
    HIT_LINES=$(grep "^LH:" coverage/lcov.info | awk -F: '{sum+=$2} END {print sum}' || echo "0")
    
    if [ "$TOTAL_LINES" -eq 0 ]; then
      echo -e "${YELLOW}⚠️  No coverage data found (no testable lines)${NC}"
      if [ "$strict_mode" = "true" ]; then
        return 1
      fi
      return 0
    fi
    
    # Calculate coverage percentage
    COVERAGE_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($HIT_LINES / $TOTAL_LINES) * 100}")
    COVERAGE_INT=$(awk "BEGIN {printf \"%.0f\", ($HIT_LINES / $TOTAL_LINES) * 100}")
    
    echo -e "${GREEN}   Coverage: ${COVERAGE_PERCENT}% (${HIT_LINES}/${TOTAL_LINES} lines)${NC}"
    echo -e "${GREEN}   Minimum required: ${min_coverage}%${NC}"
    
    # Check if coverage meets threshold
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
    echo -e "${YELLOW}⚠️  Coverage file (coverage/lcov.info) not found${NC}"
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
    run_analyze false || exit 1
    run_metrics || exit 1
    run_tests || exit 1
    run_coverage_check false || true  # Warning only, doesn't fail
    echo -e "\n${GREEN}✅ All quality checks passed!${NC}"
    ;;
  ci)
    echo -e "${GREEN}🚀 Running CI quality checks (strict mode)...${NC}"
    run_format_check || exit 1
    run_analyze true || exit 1
    run_metrics || exit 1
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

