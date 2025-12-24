# Troubleshooting Guide

## Common Issues

### ❌ "syntax error near unexpected token `newline'" or HTML in output

**Problem**: You're using the GitHub web URL instead of the raw file URL.

**Wrong**:
```bash
curl -fsSL https://github.com/your-org/linter-workflow-package/tree/main/install.sh | bash
```

**Correct**:
```bash
curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/main/install.sh | bash
```

**Key Difference**:
- ❌ `github.com/.../tree/main/` → Returns HTML (web page)
- ✅ `raw.githubusercontent.com/.../main/` → Returns raw file content

**How to remember**:
- Web URL: `github.com/.../tree/...` (for viewing in browser)
- Raw URL: `raw.githubusercontent.com/...` (for downloading files)

### ❌ "Language folder not found"

**Problem**: The repository doesn't have the expected folder structure.

**Solution**:
1. Check the repository exists: Visit `https://github.com/your-org/linter-workflow-package`
2. Verify the folder name: Should be `linter-workflow-flutter/` (not `flutter/`)
3. Check the branch: Default is `main`, but might be `master`

**Custom branch**:
```bash
OUTCODE_BRANCH=develop curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/develop/install.sh | bash
```

### ❌ "Git not found"

**Problem**: Git is not installed on your system.

**Solution**:
- **macOS**: `brew install git` or download from https://git-scm.com
- **Linux**: `sudo apt-get install git` (Ubuntu/Debian) or `sudo yum install git` (RHEL/CentOS)
- **Windows**: Download from https://git-scm.com/download/win

### ❌ "pubspec.yaml not found"

**Problem**: Not running from Flutter project root.

**Solution**:
```bash
# Check current directory
pwd

# Navigate to Flutter project root
cd /path/to/your-flutter-project

# Verify pubspec.yaml exists
ls pubspec.yaml

# Then run install
curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/main/install.sh | bash
```

### ❌ "npm not found"

**Problem**: Node.js/npm is not installed.

**Solution**:
- Install Node.js from https://nodejs.org (includes npm)
- Or use nvm: `nvm install 20 && nvm use 20`

### ❌ "Permission denied" when running script

**Problem**: Script doesn't have execute permissions.

**Solution**:
```bash
# Download script first
curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/main/install.sh -o install.sh

# Make executable
chmod +x install.sh

# Run
bash install.sh
```

### ❌ Sparse checkout fails

**Problem**: Git version doesn't support sparse checkout.

**Solution**: The script will automatically fall back to full clone. This is normal and works fine.

### ❌ Network/Connection issues

**Problem**: Can't download from GitHub.

**Solutions**:
1. Check internet connection
2. Try again (GitHub might be temporarily unavailable)
3. Download manually:
   ```bash
   # Clone repository
   git clone https://github.com/your-org/linter-workflow-package.git
   cd linter-workflow-package
   
   # Run install script
   bash install.sh
   ```

## Getting Help

If you encounter other issues:

1. Check the error message carefully
2. Verify you're using the correct URL format
3. Ensure you're in the Flutter project root
4. Check that all prerequisites are installed (Git, Node.js, Flutter)
5. Review the [main README](./README.md) for usage instructions

