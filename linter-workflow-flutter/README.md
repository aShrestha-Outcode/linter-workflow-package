# Outcode Flutter Linter & Workflow Package

This package contains all the necessary files to set up Outcode Flutter code quality standards, CI/CD workflows, and Git branching strategy for a new Flutter project.

## 🚀 Quick Setup

**One command setup** - No manual copying needed!

```bash
# From your Flutter project root
curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/main/install.sh | bash
```

That's it! The installer will:
1. Download the Flutter setup package from GitHub
2. Copy all files to the correct locations
3. Install npm dependencies
4. Set up Git hooks
5. Optionally set up GitHub remote and branches
6. Clean up downloaded files (optional)

## 📦 What's Included

- ✅ **package.json** - Node.js dependencies (Husky, Commitlint, lint-staged)
- ✅ **analysis_options.yaml** - Flutter/Dart code quality rules
- ✅ **commitlint.config.js** - Commit message validation
- ✅ **.fvmrc** - Flutter version pinning
- ✅ **.nvmrc** - Node.js version pinning
- ✅ **.gitignore** - Git ignore patterns
- ✅ **.husky/** - Git hooks (pre-commit, pre-push, commit-msg, branch protection)
- ✅ **.github/workflows/** - GitHub Actions workflows (quality, deploy-uat, deploy-prod, merge-prod-to-main)
- ✅ **tool/** - Quality check scripts (quality.sh, validate-setup.sh)
- ✅ **docs/engineering/** - Engineering documentation (Git strategy, hooks standard)

## 📋 Setup Process

The setup script automatically performs the following steps:

1. **Copy root-level files** - package.json, analysis_options.yaml, commitlint.config.js, .fvmrc, .nvmrc
2. **Update .gitignore** - Merges with existing .gitignore (won't overwrite)
3. **Set up Husky hooks** - Copies all Git hooks to .husky/
4. **Set up GitHub Actions** - Copies all workflow files to .github/workflows/
5. **Copy quality scripts** - Copies tool/quality.sh and tool/validate-setup.sh
6. **Copy documentation** - Copies engineering docs to docs/engineering/
7. **Update pubspec.yaml** - Adds very_good_analysis to dev_dependencies
8. **Install Flutter dependencies** - Runs `flutter pub get`
9. **Install npm dependencies** - Runs `npm install` to set up Husky and other tools
10. **Set up Husky hooks path** - Configures Git hooks path
11. **Optional Git setup** - Prompts for GitHub URL and branch creation

## 🔧 Prerequisites

Before running the setup script, ensure you have:

- ✅ **Flutter project** - A Flutter project with `pubspec.yaml`
- ✅ **Node.js** - Installed (for npm)
- ✅ **Git** - Installed (optional, but recommended)

## 📝 Usage Examples

### Example 1: New Flutter Project

```bash
# Create new Flutter project
flutter create my_app
cd my_app

# One command setup
curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/main/install.sh | bash
```

### Example 2: Existing Flutter Project

```bash
# Navigate to existing project
cd /path/to/existing-flutter-project

# One command setup (will merge with existing files)
curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/main/install.sh | bash
```

### Example 3: Custom Repository or Branch

```bash
# Use custom repository
OUTCODE_REPO_URL=https://github.com/your-org/custom-repo.git \
curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/main/install.sh | bash

# Use custom branch
OUTCODE_BRANCH=develop \
curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/main/install.sh | bash
```

## ⚙️ What Gets Copied

The setup script copies files from the downloaded package to your project:

```
linter-workflow-flutter/         (downloaded temporarily)
├── setup.sh                     # Setup script (runs automatically)
├── package.json                  → project root
├── analysis_options.yaml         → project root
├── commitlint.config.js          → project root
├── .fvmrc                        → project root
├── .nvmrc                        → project root
├── .gitignore                    → project root (merged)
├── .husky/                       → project root/.husky/
│   ├── commit-msg
│   ├── pre-commit
│   ├── pre-push
│   ├── pre-commit-branch-protection
│   └── pre-push-branch-protection
├── .github/workflows/            → project root/.github/workflows/
│   ├── quality.yml
│   ├── deploy-uat.yml
│   ├── deploy-prod.yml
│   ├── merge-prod-to-main.yml
│   └── README.md
├── tool/                         → project root/tool/
│   ├── quality.sh
│   └── validate-setup.sh
└── docs/engineering/            → project root/docs/engineering/
    ├── outcode-git-branching-strategy.md
    └── outcode-husky-hooks-standard.md
```

**Note**: The downloaded package folder (`outcode-setup`) is automatically removed after setup (unless you choose to keep it).

## ✅ After Setup

### 1. Verify Setup

```bash
npm run validate
```

This checks that all tools, files, and hooks are properly configured.

### 2. Test Quality Checks

```bash
npm run quality:check
```

This runs all quality checks (format, analyze, metrics, tests).

### 3. Set Up GitHub Branch Protection

**Important**: After pushing to GitHub, set up branch protection rules:

1. Go to: **Settings → Branches → Branch protection rules**
2. Add rules for: `main`, `develop`, `uat`, `prod`
3. Configure:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (1 for develop/uat, 2 for prod/main)
   - ✅ Require status checks to pass
     - Select: **"Code Quality / quality (pull_request)"**
   - ✅ Restrict who can push (no bypasses)

See `docs/engineering/outcode-git-branching-strategy.md` for detailed instructions.

### 4. Start Developing

```bash
# Create a feature branch
git checkout -b feature/your-feature-name

# Make changes and commit
git add .
git commit -m "feat: add your feature"

# Push and create PR
git push origin feature/your-feature-name
```

## 🔍 File Handling

The setup script is smart about existing files:

- **package.json** - Prompts before overwriting
- **.gitignore** - Merges entries (won't duplicate)
- **Other files** - Overwrites if they exist (backup first if needed)

## 🐛 Troubleshooting

### Script Fails: "pubspec.yaml not found"

**Problem**: Script can't find Flutter project

**Solution**: 
- Ensure you're running the command from your Flutter project root directory
- Verify `pubspec.yaml` exists in the current directory
- Run: `pwd` to check your current location

### npm install Fails

**Problem**: npm install fails

**Solution**:
- Check Node.js is installed: `node --version`
- Check npm is installed: `npm --version`
- Try: `npm install --legacy-peer-deps`

### Husky Hooks Not Working

**Problem**: Git hooks don't run

**Solution**:
```bash
# Reinstall Husky
npm install

# Verify hooks are executable
ls -la .husky/

# Test manually
.husky/pre-commit
```

### Quality Checks Fail

**Problem**: `npm run quality:check` fails

**Solution**:
- Install Flutter dependencies: `flutter pub get`
- Check Flutter is installed: `flutter --version`
- Run validation: `npm run validate`

## 📚 Documentation

After setup, see the following documentation:

- **Git Strategy**: `docs/engineering/outcode-git-branching-strategy.md`
- **Hooks Standard**: `docs/engineering/outcode-husky-hooks-standard.md`
- **Workflows**: `.github/workflows/README.md`

## 🔄 Updates

To update to the latest version, simply run the install command again:

```bash
curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/main/install.sh | bash
```

The setup script is **idempotent** - it's safe to run multiple times and will update existing files as needed.

## 📦 Repository Structure

This package is part of the `linter-workflow-package` repository:

```
linter-workflow-package/
├── install.sh                   # Universal installer (downloads language packages)
├── README.md                     # Main repository documentation
└── linter-workflow-flutter/     # This package
    ├── setup.sh
    ├── package.json
    └── ... (all setup files)
```

See the [main repository README](../README.md) for information about other languages and the overall structure.

## 📝 Notes

- The setup script is **idempotent** - safe to run multiple times
- Existing files are handled carefully (merged or prompted)
- All hooks are made executable automatically
- Works on macOS, Linux, and Windows (with Git Bash)
- No manual file copying needed - everything is automated

## 🔗 Related Documentation

- [Main Repository README](../README.md) - Overview of all language packages
- [Git Branching Strategy](./docs/engineering/outcode-git-branching-strategy.md) - Git workflow documentation
- [Husky Hooks Standard](./docs/engineering/outcode-husky-hooks-standard.md) - Git hooks documentation

---

**Version**: 1.0.0  
**Last Updated**: 2024

