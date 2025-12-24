# Outcode Linter & Workflow Package

Code quality standards, CI/CD workflows, and Git branching strategy for all languages.

## 🚀 Quick Start

### Step-by-Step Setup

1. **Create your project** (Flutter, React Native, etc.)

2. **Navigate to your project folder:**
   ```bash
   cd your-project-folder
   ```

3. **Download the install script:**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/aShrestha-Outcode/linter-workflow-package/main/install.sh -o install.sh
   ```

4. **Make the script executable:**
   ```bash
   chmod +x install.sh
   # Or: chmod 777 install.sh
   ```

5. **Run the installer:**
   ```bash
   ./install.sh
   ```

6. **Select your language** when prompted:
   - `1` for Flutter
   - `2` for React Native (coming soon)
   - `3` for Node.js (coming soon)

7. **That's it!** The script will automatically:
   - Download the language-specific setup package
   - Run the setup script
   - Install all dependencies
   - Configure Git hooks
   - Set up CI/CD workflows
   - Guide you through GitHub remote configuration (optional)

### Alternative: Non-Interactive Mode

If you want to skip the language selection prompt:

```bash
OUTCODE_LANGUAGE=flutter ./install.sh
```

**⚠️ Important**: Use `raw.githubusercontent.com` (not `github.com/tree/...`) to get the raw script file.

## 📁 Repository Structure

```
linter-workflow-package/
├── README.md                    # This file
├── install.sh                   # Universal installer script
├── linter-workflow-flutter/     # Flutter setup package
│   ├── setup.sh
│   ├── package.json
│   ├── analysis_options.yaml
│   └── ... (all Flutter setup files)
└── linter-workflow-reactnative/ # React Native setup (future)
    └── ...
```

## 📦 Available Languages

- ✅ **Flutter** - Complete setup with Husky, GitHub Actions, quality checks
- 🚧 **React Native** - Coming soon
- 🚧 **Node.js** - Coming soon

## 🎯 What Gets Set Up

Each language package includes:
- ✅ Git hooks (Husky, Commitlint)
- ✅ CI/CD workflows (GitHub Actions)
- ✅ Code quality configuration
- ✅ Engineering documentation
- ✅ Version pinning
- ✅ Quality check scripts

## 📚 Language-Specific Documentation

- [Flutter Setup Guide](./linter-workflow-flutter/README.md)

## 🔧 Customization

### Custom Repository URL

```bash
OUTCODE_REPO_URL=https://github.com/your-org/custom-repo.git ./install.sh
```

### Custom Branch

```bash
OUTCODE_BRANCH=develop ./install.sh
```

### Non-Interactive Language Selection

```bash
OUTCODE_LANGUAGE=flutter ./install.sh
```

## 🤝 Contributing

To add a new language:

1. Create `linter-workflow-<language>/` folder
2. Add setup files following the Flutter example
3. Update `install.sh` to map the language name to folder name
4. Submit a PR

## 📝 License

MIT

---

**Made with ❤️ by Outcode Software**

