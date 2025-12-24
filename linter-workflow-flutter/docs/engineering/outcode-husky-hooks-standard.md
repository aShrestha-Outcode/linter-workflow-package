# Outcode Git Hooks Standard (Husky)

## Purpose

This document defines **Outcode's standard** for Git hooks using **Husky**, **Commitlint**, and **lint-staged**. This standard ensures consistent code quality enforcement across all mobile projects (Flutter, React Native, and future mobile frameworks).

### What Husky Is

**Husky** is a tool that makes Git hooks easy to use. It:
- ✅ Installs Git hooks automatically
- ✅ Ensures hooks are executable
- ✅ Works across macOS, Linux, and Windows
- ✅ Integrates with npm/yarn/pnpm scripts
- ✅ Version-controlled hooks (in `.husky/` directory)

### Why Outcode Uses Husky

1. **Consistency**: Same hooks across all projects and developers
2. **Version Control**: Hooks are committed to the repo (not just local)
3. **Easy Setup**: `npm install` automatically sets up hooks
4. **Cross-Platform**: Works on macOS, Linux, and Windows
5. **Integration**: Works seamlessly with npm scripts and CI/CD

### Non-Goals (What Hooks Should NOT Do)

❌ **Hooks should NOT**:
- Replace CI/CD checks (CI is the source of truth)
- Run slow operations in pre-commit (must be fast)
- Block emergency fixes (can be bypassed with `--no-verify`)
- Enforce business logic (only code quality)
- Require network access (must work offline)

---

## Standard Principles

### 1. CI is the Source of Truth

**Principle**: CI/CD checks are **mandatory and cannot be bypassed**. Local hooks are **convenience checks** that can be bypassed.

**Why**:
- ✅ Prevents bad code from reaching the repository
- ✅ Ensures all code is checked (even if hooks are bypassed)
- ✅ Provides consistent checks across all developers

**Implementation**:
- Hooks can be bypassed: `git commit --no-verify` or `git push --no-verify`
- CI **cannot** be bypassed (enforced by GitHub branch protection)
- Hooks and CI run the **same quality script** for consistency

### 2. Fast Pre-Commit; Full Checks on Pre-Push + CI

**Principle**: Pre-commit must be **fast** (<10 seconds). Full quality gates run on pre-push and CI.

**Why**:
- ✅ Developers aren't blocked by slow checks
- ✅ Catches issues early (before push)
- ✅ Full checks ensure quality before code reaches remote

**Implementation**:
- **Pre-commit**: Formatting only (via `lint-staged`)
- **Pre-push**: Full quality gate (format, analyze, metrics, tests)
- **CI**: Strict quality gate (warnings treated as errors)

### 3. Staged-Only Changes in Pre-Commit

**Principle**: Pre-commit operates on **staged files only** (not the entire repository).

**Why**:
- ✅ Faster (only checks changed files)
- ✅ Less disruptive (doesn't check unrelated files)
- ✅ Better developer experience

**Implementation**:
- Use `lint-staged` to run commands on staged files only
- Format only staged `.dart` files (or `.ts`, `.tsx` for React Native)

### 4. Formatting is Auto-Fixable; Analysis/Tests are Gating

**Principle**: Formatting is **automatically fixed** in pre-commit. Analysis and tests **block** commits/pushes if they fail.

**Why**:
- ✅ Formatting is mechanical (can be auto-fixed)
- ✅ Analysis/tests require code changes (must be fixed manually)
- ✅ Prevents committing unformatted code

**Implementation**:
- Pre-commit: `dart format` (auto-fixes)
- Pre-push: `dart format --set-exit-if-changed` (fails if not formatted)
- Pre-push: `flutter analyze` (fails on errors)

### 5. Version Pinning (Node + Flutter)

**Principle**: Pin Node.js and Flutter versions to prevent environment drift.

**Why**:
- ✅ Consistent builds across developers
- ✅ Prevents "works on my machine" issues
- ✅ Reproducible CI/CD pipelines

**Implementation**:
- `.nvmrc` for Node.js version
- `.fvmrc` for Flutter version
- Scripts detect and use pinned versions automatically

---

## What We Standardize (Scope)

### 1. Commit Message Format

**Standard**: Conventional Commits format
- Format: `type(scope): description`
- Types: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `ci`, `build`, `perf`, `revert`
- Scope: Optional, but recommended for larger changes
- Enforced by: `commitlint` in `commit-msg` hook

### 2. Pre-Commit Behavior

**Standard**:
- Runs on: `git commit`
- Speed: <10 seconds
- Operations: Formatting only (staged files)
- Can bypass: Yes (`git commit --no-verify`)

### 3. Pre-Push Behavior

**Standard**:
- Runs on: `git push`
- Speed: <2-5 minutes (depending on repo size)
- Operations: Format check, analyze, metrics, tests
- Can bypass: Yes (`git push --no-verify`)

### 4. Scripts That Hooks Call

**Standard**: Single source of truth script
- Location: `tool/quality.sh` (or `scripts/quality.sh`)
- Modes: `quick`, `check`, `ci`
- Used by: Hooks and CI/CD

### 5. CI Checks Parity

**Standard**: CI runs the same script as hooks
- Command: `npm run quality:ci`
- Script: `tool/quality.sh ci`
- Result: Same checks, same behavior

### 6. Bypass Policy and Emergency Process

**Standard**:
- Local bypass: `--no-verify` flag
- Emergency: Document reason, create ticket
- CI bypass: Not allowed (enforced by branch protection)

---

## Repo Structure (Expected Files)

### Directory Tree

```
project-root/
├── package.json                    # Node dependencies + npm scripts
├── commitlint.config.js            # Commit message validation rules
├── .nvmrc                          # Node.js version pinning
├── .fvmrc                          # Flutter version pinning (Flutter projects)
├── .husky/
│   ├── commit-msg                  # Validates commit message format
│   ├── pre-commit                   # Fast checks (formatting only)
│   ├── pre-push                     # Full quality gate
│   ├── pre-commit-branch-protection # Optional: prevents commits to protected branches
│   └── pre-push-branch-protection   # Optional: prevents pushes to protected branches
├── tool/
│   ├── quality.sh                   # Single source of truth quality script
│   └── validate-setup.sh            # Validates setup is correct
└── docs/
    └── engineering/
        └── outcode-husky-hooks-standard.md  # This document
```

### File Descriptions

#### `package.json`
- **Purpose**: Defines Node.js dependencies and npm scripts
- **Required fields**:
  - `scripts.prepare`: `"husky"` (auto-installs hooks)
  - `scripts.quality:quick`: Fast checks for pre-commit
  - `scripts.quality:check`: Full checks for pre-push
  - `scripts.quality:ci`: Strict checks for CI
- **Dependencies**: `husky`, `@commitlint/cli`, `@commitlint/config-conventional`, `lint-staged`

#### `commitlint.config.js`
- **Purpose**: Defines commit message validation rules
- **Format**: JavaScript module (CommonJS)
- **Standard**: Uses `@commitlint/config-conventional`
- **Naming**: Must be `commitlint.config.js` (not `.cjs` or `.mjs`)

#### `.husky/commit-msg`
- **Purpose**: Validates commit message format
- **Runs**: On `git commit`
- **Command**: `npx --no-install commitlint --edit "$1"`
- **Blocks**: Commit if message format is invalid

#### `.husky/pre-commit`
- **Purpose**: Fast quality checks before commit
- **Runs**: On `git commit`
- **Command**: `npx --no-install lint-staged`
- **Speed**: <10 seconds
- **Operations**: Formatting only (staged files)

#### `.husky/pre-push`
- **Purpose**: Full quality gate before push
- **Runs**: On `git push`
- **Command**: `npm run quality:check`
- **Speed**: <2-5 minutes
- **Operations**: Format check, analyze, metrics, tests

#### `tool/quality.sh`
- **Purpose**: Single source of truth for quality checks
- **Modes**:
  - `quick`: Formatting only (pre-commit)
  - `check`: Full checks (pre-push)
  - `ci`: Strict checks (CI/CD)
- **Used by**: Hooks and CI/CD workflows

#### `.nvmrc`
- **Purpose**: Pins Node.js version
- **Format**: Single line with version number (e.g., `20`)
- **Usage**: `nvm install && nvm use`

#### `.fvmrc` (Flutter projects)
- **Purpose**: Pins Flutter SDK version
- **Format**: YAML with `flutterSdkVersion: "3.38.4"`
- **Usage**: `fvm install && fvm use`

---

## Installation (Step-by-Step)

### Prerequisites

- ✅ Node.js installed (version specified in `.nvmrc`)
- ✅ Flutter installed (for Flutter projects, version specified in `.fvmrc`)
- ✅ Git repository initialized

### Step 1: Install Node Dependencies

```bash
# Install dependencies (includes Husky, Commitlint, lint-staged)
npm install
```

**What happens**:
- Installs all `devDependencies` from `package.json`
- Runs `npm run prepare` automatically (sets up Husky hooks)
- Creates `.husky/` directory with hooks

### Step 2: Verify Hooks Are Installed

```bash
# Check if hooks are executable
ls -la .husky/

# Should show:
# - commit-msg (executable)
# - pre-commit (executable)
# - pre-push (executable)
```

### Step 3: Validate Setup

```bash
# Run validation script
npm run validate
```

**Expected output**:
```
✅ Node.js: v20.x.x
✅ Flutter: 3.38.4
✅ Husky: Installed
✅ Commitlint: Configured
✅ lint-staged: Configured
✅ Quality script: Available
```

### Step 4: Test Hooks

```bash
# Test commit-msg hook
git commit -m "test: invalid format"
# Should fail with: "Invalid commit message format"

# Test pre-commit hook
git commit -m "test: valid format"
# Should run formatting on staged files

# Test pre-push hook
git push origin feature/test
# Should run full quality checks
```

---

## Troubleshooting

### Issue: Hooks Not Running

**Symptoms**: Commits/pushes succeed without running hooks

**Solutions**:
1. **Check if Husky is installed**:
   ```bash
   npm list husky
   ```

2. **Reinstall Husky**:
   ```bash
   npm install
   # This runs 'npm run prepare' which sets up hooks
   ```

3. **Check Git hooks path**:
   ```bash
   git config core.hooksPath
   # Should output: .husky
   ```

4. **Manually set hooks path**:
   ```bash
   git config core.hooksPath .husky
   ```

5. **Check hook permissions**:
   ```bash
   chmod +x .husky/commit-msg
   chmod +x .husky/pre-commit
   chmod +x .husky/pre-push
   ```

### Issue: Node Not Found / Wrong Version

**Symptoms**: `npx: command not found`  or version mismatch

**Solutions**:
1. **Install Node.js** (if not installed):
   ```bash
   # Using nvm (recommended)
   nvm install
   nvm use
   ```

2. **Check Node version**:
   ```bash
   node --version
   # Should match .nvmrc
   ```

3. **Switch to correct version**:
   ```bash
   nvm use
   ```

### Issue: Flutter Not Found / FVM Mismatch

**Symptoms**: `flutter: command not found` or version mismatch

**Solutions**:
1. **Install Flutter** (if not installed):
   ```bash
   # Using FVM (recommended)
   fvm install
   fvm use
   ```

2. **Check Flutter version**:
   ```bash
   flutter --version
   # Should match .fvmrc
   ```

3. **Switch to correct version**:
   ```bash
   fvm use
   ```

### Issue: lint-staged No Files Matched

**Symptoms**: `lint-staged` runs but says "No files matched"

**Solutions**:
1. **Check if files are staged**:
   ```bash
   git status
   # Files should be in "Changes to be committed"
   ```

2. **Check lint-staged config**:
   ```bash
   # In package.json, verify:
   "lint-staged": {
     "*.dart": ["dart format"]
   }
   ```

3. **Test manually**:
   ```bash
   npx lint-staged --debug
   ```

### Issue: Commitlint Config File Not Found

**Symptoms**: `commitlint` fails with "config file not found"

**Solutions**:
1. **Check file name**: Must be `commitlint.config.js` (not `.cjs` or `.mjs`)
2. **Check file location**: Must be in project root
3. **Verify config format**:
   ```javascript
   module.exports = {
     extends: ['@commitlint/config-conventional'],
   };
   ```

### Issue: Hooks Too Slow

**Symptoms**: Pre-commit takes >10 seconds

**Solutions**:
1. **Check what's running**: Review `.husky/pre-commit` script
2. **Ensure only formatting runs**: Should use `lint-staged` (staged files only)
3. **Check for unnecessary operations**: Remove any slow checks from pre-commit

### Windows Notes

**If engineers use Windows**:
- ✅ Husky works on Windows (Git Bash or WSL)
- ✅ Use Git Bash for best compatibility
- ✅ Ensure line endings are LF (not CRLF) in hook files
- ⚠️ Some scripts may need Windows-specific adjustments

**If macOS/Linux only**:
- ✅ No Windows-specific considerations needed
- ✅ All scripts use standard Unix commands

---

## Commit Message Standard

### Required Format

```
type(scope): description
```

### Allowed Types

| Type | When to Use | Example |
|------|-------------|---------|
| `feat` | New feature | `feat: add user authentication` |
| `fix` | Bug fix | `fix: resolve memory leak in image loader` |
| `chore` | Maintenance tasks | `chore: update dependencies` |
| `refactor` | Code refactoring | `refactor: simplify user service` |
| `docs` | Documentation | `docs: update README with setup instructions` |
| `test` | Tests | `test: add unit tests for auth service` |
| `ci` | CI/CD changes | `ci: update GitHub Actions workflow` |
| `build` | Build system | `build: update Gradle configuration` |
| `perf` | Performance | `perf: optimize image loading` |
| `revert` | Revert commit | `revert: revert "feat: add feature"` |

### Scope (Optional but Recommended)

**When to use scope**:
- ✅ Large features (multiple files changed)
- ✅ Specific module/component
- ✅ Clear area of codebase

**Recommended scopes** (examples):
- `auth` - Authentication related
- `ui` - UI components
- `api` - API integration
- `storage` - Data storage
- `navigation` - Navigation/routing
- `config` - Configuration

**Examples**:
```
feat(auth): add OAuth login
fix(ui): resolve button alignment issue
chore(deps): update Flutter to 3.38.4
```

### Good Examples

✅ **Correct**:
```
feat: add dark mode toggle
fix(auth): resolve login crash
chore: update dependencies
docs: add setup instructions
feat(ui): add user profile screen
```

### Bad Examples

❌ **Incorrect**:
```
Added new feature              # Missing type
fix bug                        # Missing colon
feat:add feature               # Missing space after colon
FEAT: Add feature              # Type should be lowercase
feat: Add feature              # Description should start lowercase
feat: add feature.             # No period at end
```

### How Commitlint Enforces It

**Configuration** (`commitlint.config.js`):
```javascript
module.exports = {
  extends: ['@commitlint/config-conventional'],
};
```

**Rules enforced**:
- ✅ Type must be one of the allowed types
- ✅ Type must be lowercase
- ✅ Description must start with lowercase
- ✅ Description must not end with period
- ✅ Format: `type(scope): description`

### How to Fix a Bad Commit Message

**If commit hasn't been pushed**:
```bash
# Amend the commit message
git commit --amend -m "feat: add user authentication"
```

**If commit has been pushed**:
```bash
# Amend and force push (only on feature branches!)
git commit --amend -m "feat: add user authentication"
git push --force-with-lease origin feature/branch-name
```

⚠️ **Warning**: Never force push to protected branches (`main`, `develop`, `uat`, `prod`)

---

## Hook Behavior Standard

### A) commit-msg Hook

**Purpose**: Validates commit message format

**What it checks**:
- ✅ Commit message follows Conventional Commits format
- ✅ Type is one of the allowed types
- ✅ Format is correct: `type(scope): description`

**What happens on failure**:
- ❌ Commit is **aborted**
- ❌ Error message shows correct format
- ❌ Examples provided

**Example failure**:
```
❌ Invalid commit message format. Commit aborted.

   Use format: type(scope): description

   Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build
   Examples:
     feat: add user authentication
     fix: resolve memory leak in image loader
     docs: update README with setup instructions
```

**Implementation** (`.husky/commit-msg`):
```bash
#!/bin/sh
npx --no-install commitlint --edit "$1" || {
  echo "❌ Invalid commit message format. Commit aborted."
  exit 1
}
```

---

### B) pre-commit Hook (Must Be Fast)

**Purpose**: Fast quality checks before commit

**Speed target**: <10 seconds

**What it runs**:
- ✅ Formatting only (staged files via `lint-staged`)
- ❌ **NO** full repository analysis
- ❌ **NO** test suites
- ❌ **NO** slow operations

**Exact commands**:
```bash
# .husky/pre-commit runs:
npx --no-install lint-staged

# lint-staged runs (from package.json):
"lint-staged": {
  "*.dart": ["dart format"]
}
```

**What happens**:
1. Formats staged `.dart` files automatically
2. Re-stages formatted files
3. Commit proceeds

**What happens on failure**:
- ❌ Commit is **aborted**
- ❌ Error message shown
- ✅ Fix issues and commit again

**Expected runtime**: <10 seconds (typically 2-5 seconds)

**Implementation** (`.husky/pre-commit`):
```bash
#!/bin/sh
set -e

echo "🚀 Running pre-commit checks..."

# Format staged Dart files using lint-staged
npx --no-install lint-staged || {
  echo "❌ Pre-commit checks failed. Please fix the issues above."
  exit 1
}

echo "✅ Pre-commit checks passed."
```

---

### C) pre-push Hook (Full Local Gate)

**Purpose**: Full quality gate before push

**Speed target**: <2-5 minutes (depending on repo size)

**What it runs**:
- ✅ Format check (`dart format --set-exit-if-changed`)
- ✅ Flutter analyze (`flutter analyze`)
- ✅ Code quality checks (metrics, complexity)
- ✅ Unit tests (`flutter test`)
- ✅ Test coverage check (warning only, not blocking)

**Exact commands**:
```bash
# .husky/pre-push runs:
npm run quality:check

# Which runs:
bash tool/quality.sh check

# Which executes:
# 1. run_format_check (dart format --set-exit-if-changed)
# 2. run_analyze (flutter analyze)
# 3. run_metrics (complexity checks)
# 4. run_tests (flutter test)
# 5. run_coverage_check (warning only)
```

**What happens on failure**:
- ❌ Push is **blocked**
- ❌ Error message shows what failed
- ✅ Fix issues and push again

**Expected runtime**: <2-5 minutes (typically 1-3 minutes)

**Implementation** (`.husky/pre-push`):
```bash
#!/bin/sh
set -e

echo "🚀 Running pre-push checks..."

# Run full quality check
npm run quality:check || {
  echo "❌ Pre-push quality checks failed. Please fix the issues above."
  exit 1
}

echo "✅ Pre-push checks passed."
```

---

## CI Parity (Mandatory)

### Principle

**CI runs the same quality script as hooks** to ensure consistency.

### Implementation

**Hooks use**:
```bash
npm run quality:check  # Pre-push
```

**CI uses**:
```bash
npm run quality:ci     # CI/CD (strict mode)
```

**Both call**: `tool/quality.sh` (single source of truth)

### Sample GitHub Actions Workflow

```yaml
name: Code Quality

on:
  pull_request:
    branches: [main, develop, uat, prod]
  workflow_dispatch:

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version-file: '.nvmrc'
          cache: 'npm'
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.4'  # Or read from .fvmrc
          channel: 'stable'
          cache: true
      
      - name: Install dependencies
        run: npm ci
      
      - name: Install Flutter dependencies
        run: flutter pub get
      
      - name: Run quality checks
        run: npm run quality:ci
```

### No Merge Without Green Checks

**Branch protection** must require:
- ✅ Quality checks to pass before merge
- ✅ Status check: `Code Quality / quality (pull_request)`

**Result**: PRs cannot be merged until quality checks pass.

---

## Policy: Bypass / Exceptions / Emergency

### Allowed Local Bypass

**Method**: `--no-verify` flag

```bash
# Bypass pre-commit hook
git commit --no-verify -m "feat: add feature"

# Bypass pre-push hook
git push --no-verify origin feature/branch
```

**Important**: 
- ✅ Hooks can be bypassed locally
- ❌ **CI cannot be bypassed** (enforced by branch protection)

### When Bypass is Permitted

✅ **Allowed**:
- Initial repository setup
- Workflow configuration
- Emergency hotfixes (with documentation)
- Testing hook behavior

❌ **Not Allowed**:
- Regular feature development
- Bug fixes
- Code changes
- Skipping quality checks for convenience

### How to Request an Exception

**Process**:
1. Create a ticket documenting:
   - Reason for bypass
   - What was bypassed
   - Duration (if temporary)
2. Get approval from tech lead
3. Document in commit message or PR description

**Example**:
```
chore: initial setup - bypass hooks for workflow configuration

Reason: Setting up Husky hooks for the first time
Approved by: @tech-lead
Ticket: #123
```

### Suppression Policy for Lint/Analyzer Rules

**General rule**: Don't suppress rules unless absolutely necessary.

**If suppression needed**:
1. **File-level**: Add comment explaining why
   ```dart
   // ignore_for_file: avoid_print
   // Reason: This is a debug utility file
   ```

2. **Line-level**: Add comment explaining why
   ```dart
   // ignore: avoid_dynamic_calls
   // Reason: JSON parsing requires dynamic type
   ```

3. **Document in PR**: Explain why suppression is needed

### Emergency Merge Policy

**Who approves**: Tech Lead or Principal Engineer

**Process**:
1. Create emergency ticket
2. Get approval
3. Bypass hooks if needed: `git push --no-verify`
4. CI will still run (cannot be bypassed)
5. Document in PR description

**Post-emergency**:
- Review what was bypassed
- Fix any issues introduced
- Update documentation if needed

---

## Troubleshooting Guide

### Common Issues

#### 1. Husky Not Running

**Symptoms**: Hooks don't execute on commit/push

**Solutions**:
```bash
# Reinstall Husky
npm install

# Check Git hooks path
git config core.hooksPath
# Should output: .husky

# Manually set if missing
git config core.hooksPath .husky

# Check hook permissions
chmod +x .husky/commit-msg
chmod +x .husky/pre-commit
chmod +x .husky/pre-push
```

#### 2. Hooks Not Executable

**Symptoms**: Permission denied errors

**Solutions**:
```bash
# Make all hooks executable
chmod +x .husky/*

# Verify
ls -la .husky/
# Should show 'x' in permissions (e.g., -rwxr-xr-x)
```

#### 3. Node Not Installed / Wrong Version

**Symptoms**: `npx: command not found` or version mismatch

**Solutions**:
```bash
# Install Node.js (using nvm)
nvm install
nvm use

# Verify version
node --version
# Should match .nvmrc
```

#### 4. Flutter Not Found / FVM Mismatch

**Symptoms**: `flutter: command not found` or version mismatch

**Solutions**:
```bash
# Install Flutter (using FVM)
fvm install
fvm use

# Verify version
flutter --version
# Should match .fvmrc
```

#### 5. lint-staged No Files Matched

**Symptoms**: `lint-staged` runs but says "No files matched"

**Solutions**:
```bash
# Check if files are staged
git status

# Stage files
git add lib/main.dart

# Test manually
npx lint-staged --debug
```

#### 6. Commitlint Config File Not Found

**Symptoms**: `commitlint` fails with "config file not found"

**Solutions**:
```bash
# Check file exists
ls -la commitlint.config.js

# Verify file name (must be commitlint.config.js)
# Not: commitlint.config.cjs or commitlint.config.mjs

# Check file format
cat commitlint.config.js
# Should show: module.exports = { extends: ['@commitlint/config-conventional'] }
```

#### 7. Windows Compatibility

**If engineers use Windows**:
- ✅ Use Git Bash (not CMD or PowerShell)
- ✅ Ensure line endings are LF (not CRLF)
- ✅ Test hooks in Git Bash before committing

**Check line endings**:
```bash
# In Git Bash
file .husky/pre-commit
# Should show: ASCII text (not "with CRLF line terminators")
```

---

## Rollout Checklist (For Applying to Other Repos)

Use this checklist when applying this standard to a new repository:

### Phase 1: Preparation

- [ ] Review this document with the team
- [ ] Identify target repository
- [ ] Create rollout ticket

### Phase 2: File Setup

- [ ] Copy `package.json` scripts section
- [ ] Copy `commitlint.config.js`
- [ ] Copy `.husky/` directory (all hooks)
- [ ] Copy `tool/quality.sh` (or adapt for framework)
- [ ] Create `.nvmrc` with Node version
- [ ] Create `.fvmrc` (Flutter) or equivalent (React Native)

### Phase 3: Dependencies

- [ ] Run `npm install` to install dependencies
- [ ] Verify Husky hooks are installed
- [ ] Run `npm run validate` to check setup

### Phase 4: Local Verification

- [ ] Test commit-msg hook: `git commit -m "invalid"`
- [ ] Test pre-commit hook: `git commit -m "test: valid"`
- [ ] Test pre-push hook: `git push origin feature/test`
- [ ] Verify hooks run correctly

### Phase 5: CI Integration

- [ ] Add GitHub Actions workflow (or equivalent)
- [ ] Use `npm run quality:ci` in CI
- [ ] Test CI workflow on a PR
- [ ] Verify CI runs same checks as hooks

### Phase 6: Branch Protection

- [ ] Set up branch protection rules
- [ ] Require quality checks to pass
- [ ] Test: PR cannot merge until checks pass
- [ ] Document branch protection setup

### Phase 7: Documentation

- [ ] Add this document to repo (`docs/engineering/`)
- [ ] Update project README with setup instructions
- [ ] Create team announcement

### Phase 8: Team Communication

- [ ] Announce in team Slack/email
- [ ] Schedule team meeting to explain
- [ ] Share this document with team
- [ ] Provide support for questions

### Phase 9: Monitoring

- [ ] Monitor hook failures (first week)
- [ ] Collect feedback from team
- [ ] Adjust if needed
- [ ] Measure adoption (commits with proper format)

---

## Appendix: Copy/Paste Templates

### package.json Scripts Template

```json
{
  "scripts": {
    "prepare": "husky",
    "format": "dart format .",
    "format:check": "dart format --set-exit-if-changed .",
    "quality:quick": "bash tool/quality.sh quick",
    "quality:check": "bash tool/quality.sh check",
    "quality:ci": "bash tool/quality.sh ci",
    "validate": "bash tool/validate-setup.sh"
  },
  "devDependencies": {
    "@commitlint/cli": "^19.0.0",
    "@commitlint/config-conventional": "^19.0.0",
    "husky": "^9.0.0",
    "lint-staged": "^15.0.0"
  },
  "lint-staged": {
    "*.dart": ["dart format"]
  }
}
```

### lint-staged Config Template

```json
{
  "lint-staged": {
    "*.dart": ["dart format"]
  }
}
```

**For React Native**:
```json
{
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"]
  }
}
```

### .husky/commit-msg Template

```bash
#!/bin/sh
# .husky/commit-msg
# Validate commit message follows conventional commit format

set -e

echo "📝 Validating commit message format..."

npx --no-install commitlint --edit "$1" || {
  echo "❌ Invalid commit message format. Commit aborted."
  echo ""
  echo "   Use format: type(scope): description"
  echo ""
  echo "   Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build"
  echo "   Examples:"
  echo "     feat: add user authentication"
  echo "     fix: resolve memory leak in image loader"
  echo "     docs: update README with setup instructions"
  exit 1
}

echo "✅ Commit message format is valid."
```

### .husky/pre-commit Template

```bash
#!/bin/sh
# .husky/pre-commit
# Fast pre-commit checks: formatting staged files only

set -e

echo "🚀 Running pre-commit checks..."

# Format staged Dart files using lint-staged
npx --no-install lint-staged || {
  echo "❌ Pre-commit checks failed. Please fix the issues above."
  exit 1
}

echo "✅ Pre-commit checks passed."
```

### .husky/pre-push Template

```bash
#!/bin/sh
# .husky/pre-push
# Full quality gate before push: format check, analyze, metrics, tests

set -e

echo "🚀 Running pre-push checks..."

# Run full quality check (format check, analyze, metrics, tests)
npm run quality:check || {
  echo "❌ Pre-push quality checks failed. Please fix the issues above."
  exit 1
}

echo "✅ Pre-push checks passed."
```

### Minimal CI YAML Template

```yaml
name: Code Quality

on:
  pull_request:
    branches: [main, develop, uat, prod]
  workflow_dispatch:

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version-file: '.nvmrc'
          cache: 'npm'
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.4'  # Or read from .fvmrc
          channel: 'stable'
          cache: true
      
      - name: Install dependencies
        run: npm ci
      
      - name: Install Flutter dependencies
        run: flutter pub get
      
      - name: Run quality checks
        run: npm run quality:ci
```

### Recommended Node Version Pinning (.nvmrc)

```
20
# Recommended: Pin Node.js version for consistent tooling
# Install nvm: https://github.com/nvm-sh/nvm
# Usage: nvm install && nvm use
```

### Recommended Flutter Version Pinning (.fvmrc)

```yaml
flutterSdkVersion: "3.38.4"
# Recommended: Pin Flutter SDK version for consistent builds
# Install FVM: https://fvm.app/docs/getting_started/installation
# Usage: fvm install && fvm use
```

---

## Repo Notes (This Repository)

### Current Implementation Status

✅ **Fully Implemented**:
- Husky hooks (commit-msg, pre-commit, pre-push)
- Commitlint configuration
- lint-staged for staged file formatting
- Quality script (`tool/quality.sh`) with three modes
- Version pinning (.nvmrc, .fvmrc)
- CI parity (GitHub Actions uses same script)
- Branch protection hooks (optional)

### Repo-Specific Details

**Quality Script Location**: `tool/quality.sh` (not `scripts/quality.sh`)

**Branch Protection**: This repo includes optional branch protection hooks:
- `.husky/pre-commit-branch-protection` - Prevents commits to protected branches
- `.husky/pre-push-branch-protection` - Prevents pushes to protected branches

**These are optional** and can be removed if not needed in other repos.

### Framework-Specific Adaptations

**For Flutter** (current repo):
- Uses `dart format` for formatting
- Uses `flutter analyze` for analysis
- Uses `flutter test` for tests

**For React Native** (future adaptation):
- Replace `dart format` with `prettier --write`
- Replace `flutter analyze` with `eslint` or `tsc --noEmit`
- Replace `flutter test` with `jest` or framework test command
- Update `lint-staged` config for `.ts`, `.tsx` files

---

## Summary

**Outcode Git Hooks Standard** ensures:
- ✅ Consistent commit message format (Conventional Commits)
- ✅ Fast pre-commit checks (formatting only)
- ✅ Full quality gate on pre-push (format, analyze, metrics, tests)
- ✅ CI parity (same checks as hooks)
- ✅ Version pinning (Node + Flutter)
- ✅ Single source of truth (quality.sh script)

**Key Principles**:
1. CI is the source of truth (hooks can be bypassed)
2. Fast pre-commit; full checks on pre-push + CI
3. Staged-only changes in pre-commit
4. Formatting is auto-fixable; analysis/tests are gating
5. Version pinning to prevent environment drift

**Result**: Consistent, high-quality code across all Outcode mobile projects.

