# Outcode Flutter Linter & Workflow Package

This package contains all the necessary files to set up Outcode Flutter code quality standards, CI/CD workflows, and Git branching strategy for a new Flutter project.

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

## 🚀 Quick Setup

### Step 1: Copy the Package

Copy the entire `linter-workflow-package` folder to your Flutter project root:

```bash
# Example: If your Flutter project is at /path/to/my-flutter-app
cp -r linter-workflow-package /path/to/my-flutter-app/
```

### Step 2: Run the Setup Script

Navigate to your Flutter project and run the setup script:

```bash
cd /path/to/my-flutter-app
./linter-workflow-package/setup.sh
```

That's it! The script will:
1. Copy all files to the correct locations
2. Install npm dependencies
3. Set up Git hooks
4. Optionally set up GitHub remote and branches

## 📋 Setup Process

The setup script performs the following steps:

1. **Copy root-level files** - package.json, analysis_options.yaml, commitlint.config.js, .fvmrc, .nvmrc
2. **Update .gitignore** - Merges with existing .gitignore (won't overwrite)
3. **Set up Husky hooks** - Copies all Git hooks to .husky/
4. **Set up GitHub Actions** - Copies all workflow files to .github/workflows/
5. **Copy quality scripts** - Copies tool/quality.sh and tool/validate-setup.sh
6. **Copy documentation** - Copies engineering docs to docs/engineering/
7. **Install npm dependencies** - Runs `npm install` to set up Husky and other tools
8. **Optional Git setup** - Prompts for GitHub URL and branch creation

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

# Copy package folder
cp -r /path/to/linter-workflow-package .

# Run setup
./linter-workflow-package/setup.sh
```

### Example 2: Existing Flutter Project

```bash
# Navigate to existing project
cd /path/to/existing-flutter-project

# Copy package folder
cp -r /path/to/linter-workflow-package .

# Run setup (will merge with existing files)
./linter-workflow-package/setup.sh
```

## ⚙️ What Gets Copied

```
linter-workflow-package/
├── setup.sh                    # Setup script (run this)
├── package.json                 → project root
├── analysis_options.yaml        → project root
├── commitlint.config.js         → project root
├── .fvmrc                       → project root
├── .nvmrc                       → project root
├── .gitignore                   → project root (merged)
├── .husky/                      → project root/.husky/
│   ├── commit-msg
│   ├── pre-commit
│   ├── pre-push
│   ├── pre-commit-branch-protection
│   └── pre-push-branch-protection
├── .github/workflows/           → project root/.github/workflows/
│   ├── quality.yml
│   ├── deploy-uat.yml
│   ├── deploy-prod.yml
│   ├── merge-prod-to-main.yml
│   └── README.md
├── tool/                        → project root/tool/
│   ├── quality.sh
│   └── validate-setup.sh
└── docs/engineering/           → project root/docs/engineering/
    ├── outcode-git-branching-strategy.md
    └── outcode-husky-hooks-standard.md
```

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
- Ensure `linter-workflow-package` folder is inside your Flutter project directory
- Verify `pubspec.yaml` exists in the parent directory

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

## 🗑️ Cleanup (Optional)

After setup is complete, you can optionally remove the `linter-workflow-package` folder:

```bash
rm -rf linter-workflow-package
```

All files have been copied to the project root, so the package folder is no longer needed.

## 📦 Distribution

To share this package with your team:

1. **Zip the folder**:
   ```bash
   zip -r linter-workflow-package.zip linter-workflow-package/
   ```

2. **Or use Git**:
   ```bash
   git clone <repo-url>
   cd <repo>
   cp -r linter-workflow-package /path/to/new-project/
   ```

3. **Or host it**:
   - Upload to internal file server
   - Share via company wiki
   - Include in onboarding documentation

## 🔄 Updates

When the package is updated:

1. Copy the new `linter-workflow-package` folder
2. Run `setup.sh` again (it will update existing files)
3. Or manually copy specific files you need to update

## 📝 Notes

- The script is **idempotent** - safe to run multiple times
- Existing files are handled carefully (merged or prompted)
- All hooks are made executable automatically
- The script works on macOS, Linux, and Windows (with Git Bash)

---

**Version**: 1.0.0  
**Last Updated**: 2024

