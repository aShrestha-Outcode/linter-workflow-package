# Development & Tooling Guide

This guide covers the tools, scripts, and workflows used in daily development.

## Toolchain Overview

### Flutter/Dart Versions

**Flutter Version**: See `.fvmrc` file
**Dart Version**: Bundled with Flutter

**Version Management:**
We use FVM (Flutter Version Manager) for consistent Flutter versions across the team.

```bash
# Install FVM
dart pub global activate fvm

# Install Flutter version from .fvmrc
fvm install
fvm use

# Use Flutter via FVM
fvm flutter run
fvm flutter pub get
```

**Why FVM?**
- Ensures all developers use the same Flutter version
- Prevents "works on my machine" issues
- Easy version switching

### Node.js Version

**Node.js Version**: See `.nvmrc` file

**Version Management:**
We use nvm (Node Version Manager) for consistent Node.js versions.

```bash
# Install nvm (macOS/Linux)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Use Node version from .nvmrc
nvm install
nvm use

# Verify
node --version
```

**Why nvm?**
- Ensures consistent Node.js versions for tooling (Husky, Commitlint)
- Prevents version-related issues

### IDE Recommendations

**Primary: VS Code**

**Required Extensions:**
- Flutter
- Dart
- Error Lens
- GitLens
- YAML

**Settings:**
```json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  }
}
```

**Alternative: Android Studio / IntelliJ IDEA**

**Required Plugins:**
- Flutter
- Dart
- Git Integration

## Scripts & Automation

### Setup Scripts

**Initial Setup:**
```bash
# One-command setup (if setup script exists)
./setup.sh

# Or manual setup
npm install          # Installs Husky, Commitlint, etc.
flutter pub get      # Installs Flutter packages

# Set up environment variables
cp .example.env .dev.env
cp .example.env .uat.env
cp .example.env .prod.env
# Edit .dev.env, .uat.env, .prod.env with actual values

# Run environment setup script
chmod +x scripts/*.sh
./scripts/setup_env.sh
```

**Validation:**
```bash
# Verify setup is correct
npm run validate

# Checks:
# - Node.js, npm, Flutter installed
# - Dependencies installed
# - Git hooks configured
# - Required files present
```

### Quality Check Scripts

**Quick Check (Pre-commit):**
```bash
npm run quality:quick
# Or
bash tool/quality.sh quick

# Runs:
# - Code formatting (auto-fix)
```

**Full Check (Pre-push):**
```bash
npm run quality:check
# Or
bash tool/quality.sh check

# Runs:
# - Format check
# - Analyze (lint)
# - Code quality checks
# - Tests
# - Coverage check (warning only)
```

**CI Check (Strict):**
```bash
npm run quality:ci
# Or
bash tool/quality.sh ci

# Runs:
# - Format check (fails on errors)
# - Analyze (strict mode, warnings = errors)
# - Code quality checks
# - Tests
# - Coverage check (fails if below threshold)
```

### Build Scripts

**Run App (Environment Flavors):**
```bash
# Development environment
./scripts/run_dev.sh
# Or: flutter run --flavor dev --dart-define=ENV_MODE=dev

# UAT environment
./scripts/run_uat.sh
# Or: flutter run --flavor uat --dart-define=ENV_MODE=uat

# Production environment
./scripts/run_prod.sh
# Or: flutter run --flavor prod --dart-define=ENV_MODE=prod

# Run on specific device
flutter devices                    # List devices
flutter run --flavor dev -d <device-id>

# Run in release mode
flutter run --flavor dev --release

# Run in profile mode (for performance testing)
flutter run --flavor dev --profile
```

**Build for Platforms:**
```bash
# Android - Development
./scripts/build_aab.sh dev apk    # APK for dev
./scripts/build_aab.sh uat apk    # APK for UAT
./scripts/build_aab.sh prod apk   # APK for prod

# Android - Production (with obfuscation)
./scripts/build_release.sh android prod

# iOS - Development
./scripts/build_ios.sh dev

# iOS - Production (with obfuscation)
./scripts/build_release.sh ios prod

# Alternative: Direct Flutter commands
flutter build apk --flavor dev    # APK
flutter build appbundle --flavor prod  # AAB (for Play Store)
flutter build ios --flavor prod   # iOS app
flutter build ipa --flavor prod   # IPA (for App Store)
```

### Test Scripts

**Run All Tests:**
```bash
flutter test
```

**Run Specific Tests:**
```bash
# Run tests in specific file
flutter test test/unit/user_test.dart

# Run tests matching pattern
flutter test --name "UserRepository"

# Run with coverage
flutter test --coverage
```

**Generate Coverage Report:**
```bash
flutter test --coverage
# Coverage report in: coverage/lcov.info

# View HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Formatting and Linting

**Format Code:**
```bash
# Format all Dart files
dart format .

# Format specific directory
dart format lib/

# Check formatting (don't change files)
dart format --set-exit-if-changed .
```

**Analyze Code:**
```bash
# Run analyzer
flutter analyze

# Analyze with info level
flutter analyze --no-fatal-infos

# Analyze specific file
flutter analyze lib/main.dart
```

**Lint-Staged (Automatic):**
Pre-commit hook automatically formats staged files:
```bash
# This runs automatically on commit
npx lint-staged

# Manual run
npx lint-staged
```

## Debugging & Profiling

### Debugging Workflows

**VS Code Debugging:**
1. Set breakpoints in code
2. Press F5 or "Run > Start Debugging"
3. Select environment (dev/uat/prod) when prompted
4. App runs in debug mode, stops at breakpoints
5. Inspect variables, step through code

**Note**: VS Code launch configurations are in `.vscode/launch.json` with predefined configurations for each environment flavor.

**Flutter DevTools:**
```bash
# Run app with DevTools
flutter run

# DevTools opens automatically at:
# http://localhost:9100

# Or open manually
flutter pub global activate devtools
flutter pub global run devtools
```

**Debugging Features:**
- **Breakpoints**: Set in VS Code/Android Studio
- **Hot Reload**: Press `r` in terminal (preserves state)
- **Hot Restart**: Press `R` in terminal (resets state)
- **Widget Inspector**: Click inspector icon in DevTools
- **Performance Overlay**: Press `P` in terminal

**Common Debugging Scenarios:**

**1. UI Not Updating:**
- Check if state is being updated
- Verify widget is listening to state changes
- Use Flutter DevTools widget inspector

**2. Network Issues:**
- Check network logs in debug console
- Use browser DevTools (for web) or network interceptors
- Verify API endpoints and authentication

**3. State Issues:**
- Add logging in state management code
- Use DevTools state inspector
- Check state snapshots

**4. Performance Issues:**
- Enable performance overlay: `flutter run --profile`
- Use DevTools performance tab
- Profile with `flutter run --profile`

### Performance Profiling

**Performance Overlay:**
```bash
# Enable performance overlay
flutter run --profile
# Press 'P' in terminal to toggle overlay
```

**Performance Metrics:**
- **FPS**: Should be 60 FPS (or 120 on supported devices)
- **Frame Budget**: 16.67ms per frame (60 FPS)
- **Rebuilds**: Minimize unnecessary rebuilds

**Profiling with DevTools:**
1. Run app: `flutter run --profile`
2. Open DevTools
3. Go to "Performance" tab
4. Record performance
5. Analyze frame timeline

**Memory Profiling:**
1. Open DevTools
2. Go to "Memory" tab
3. Take heap snapshot
4. Analyze memory usage
5. Check for leaks

**Common Performance Issues:**

**1. Too Many Rebuilds:**
```dart
// Bad: Widget rebuilds on every state change
Widget build(BuildContext context) {
  return BlocBuilder<UserBloc, UserState>(
    builder: (context, state) => Text(state.value), // Rebuilds on any state change
  );
}

// Good: Use BlocSelector to rebuild only when specific state changes
Widget build(BuildContext context) {
  return BlocSelector<UserBloc, UserState, String>(
    selector: (state) => state.value,
    builder: (context, value) => Text(value), // Only rebuilds when value changes
  );
}
```

**2. Heavy Work on Main Thread:**
```dart
// Bad: Blocking main thread
void loadData() {
  final data = complexComputation(); // Blocks UI
}

// Good: Use isolates or async
Future<void> loadData() async {
  final data = await compute(complexComputation, input);
}
```

**3. Large Lists Without Virtual Scrolling:**
```dart
// Bad: Renders all items
ListView(children: items.map(...).toList())

// Good: Only renders visible items
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

## Git Workflow Tools

### Git Hooks (Husky)

Husky manages Git hooks automatically. Hooks run:

**Pre-commit:**
- Format staged files
- Run lint-staged

**Pre-push:**
- Run full quality checks
- Prevent push if checks fail

**Commit-msg:**
- Validate commit message format (Conventional Commits)

**Manual Hook Execution:**
```bash
# Test pre-commit hook
.husky/pre-commit

# Test pre-push hook
.husky/pre-push

# Test commit-msg hook
.husky/commit-msg "$(git log -1 --pretty=%B)"
```

### Commitlint

Validates commit messages:

```bash
# Test commit message
echo "feat: add new feature" | npx commitlint

# Invalid message example
echo "added feature" | npx commitlint  # Will fail
```

## Environment Management

### Environment Variables

The project uses three environment flavors: **dev**, **uat**, and **prod**. Each has its own environment file:

**Environment Files:**
- `.dev.env` - Development environment
- `.uat.env` - User Acceptance Testing environment
- `.prod.env` - Production environment
- `.example.env` - Template (committed to git)

**Setup:**
```bash
# Copy template and create environment files
cp .example.env .dev.env
cp .example.env .uat.env
cp .example.env .prod.env

# Edit files with actual values (ask team for keys)
# Then run setup script
./scripts/setup_env.sh
```

**Usage:**
Environment variables are loaded at runtime based on the selected flavor. The app uses `load_env.dart` script to load variables into `.dart_defines/` directory.

**Each environment has:**
- API endpoints
- Firebase project configuration
- Feature flags
- Environment-specific variables

**Note**: `.dev.env`, `.uat.env`, and `.prod.env` are in `.gitignore`. Never commit actual API keys or secrets. Use `.example.env` as template.

## Useful Commands Reference

### Flutter Commands

```bash
# Clean build artifacts
flutter clean
flutter pub get

# Update Flutter
flutter upgrade

# Check Flutter installation
flutter doctor
flutter doctor -v  # Verbose

# Get dependencies
flutter pub get
flutter pub upgrade

# Analyze dependencies
flutter pub deps
```

### Git Commands

```bash
# Create feature branch
git checkout -b feature/my-feature

# Commit with proper message
git commit -m "feat: add user profile"

# Push branch
git push origin feature/my-feature

# Update branch from develop
git checkout feature/my-feature
git rebase develop
# Or
git merge develop
```

### NPM Commands

```bash
# Install dependencies
npm install

# Run scripts
npm run validate
npm run quality:check
npm run format
```

## Troubleshooting

**Issue: "Flutter command not found"**
- Use FVM: `fvm flutter` instead of `flutter`
- Or add Flutter to PATH

**Issue: "Hooks not running"**
- Run: `npx husky install`
- Check: `git config core.hooksPath` should be `.husky`

**Issue: "Format check fails in CI but works locally"**
- Ensure using same Flutter version (use FVM)
- Run: `dart format .` to ensure consistent formatting

**Issue: "Tests pass locally but fail in CI"**
- Check Flutter version matches
- Ensure all dependencies are in `pubspec.yaml`
- Check for platform-specific code

## References

- [Flutter CLI Documentation](https://docs.flutter.dev/reference/flutter-cli)
- [FVM Documentation](https://fvm.app/)
- [Husky Documentation](https://typicode.github.io/husky/)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools/overview)

