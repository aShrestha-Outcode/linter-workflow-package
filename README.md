# Outcode Linter & Workflow Package

Code quality standards, CI/CD workflows, and Git branching strategy for all languages.

## 🚀 Quick Start

### Flutter Projects

```bash
# One command setup
curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/main/install.sh | bash
```

**⚠️ Important**: Use `raw.githubusercontent.com` (not `github.com/tree/...`) to get the raw script file.

### React Native Projects (coming soon)

```bash
OUTCODE_LANGUAGE=reactnative curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/main/install.sh | bash
```

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
OUTCODE_REPO_URL=https://github.com/your-org/custom-repo.git \
curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/main/install.sh | bash
```

### Custom Branch

```bash
OUTCODE_BRANCH=develop \
curl -fsSL https://raw.githubusercontent.com/your-org/linter-workflow-package/main/install.sh | bash
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

