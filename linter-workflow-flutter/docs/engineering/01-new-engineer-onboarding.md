# New Engineer Onboarding Guide

> **📝 IMPORTANT: This is a template document. Please customize all sections marked with `[REPLACE]` or `📝 TODO` before sharing with new engineers in the team(project). THis document is to be filled by the team lead/mobile app engineer of the project**

Welcome to the mobile engineering team! This guide will help you get productive quickly.

## Welcome & Context

> **📝 TODO: Customize this section for your project** - Replace placeholders with project-specific information

### What We Build

> **📝 TODO**: Replace the example below with your actual project description

[**REPLACE THIS**: Describe your app's purpose and target users]

**Example (Hype project):**
**Hype** is a social network and career development platform designed specifically for athletes, coaches, and sports enthusiasts. Think of it as **"LinkedIn meets Instagram meets Spotify for the athletic world"** — connecting athletes, enabling team collaboration, providing personalized content, and supporting career growth.

**Example Key Features:**
- **Social Networking**: Connect with athletes, coaches, and teams
- **Team Collaboration**: All-in-one team management & chat
- **Content Discovery**: Personalized training videos, podcasts, articles
- **AI Goal Tracking**: Personalized action plans powered by AI
- **Personal Branding**: Professional athletic profile & MVP cards

> **📝 TODO**: Update with your app's key features (replace the example above)

### Why Mobile Matters

Mobile is the primary channel for user engagement, representing the majority of our user base. Our users expect:
- **Fast, responsive performance** - Smooth scrolling, instant interactions
- **Offline capabilities** - Core features work without internet
- **Native experience** - Platform-specific UI/UX patterns
- **Push notifications** - Real-time updates and engagement

We prioritize:
- **Performance**: Fast, responsive, and reliable
- **Quality**: Bug-free, well-tested, and maintainable
- **User Experience**: Intuitive, accessible, and delightful
- **Code Quality**: SOLID principles, clean architecture, maintainable code

### System Architecture Overview
```
┌────────────────────────────────────────────────────────────-─┐
│                    PRESENTATION LAYER                        │
│  ┌──────────────┐         ┌──────────────┐                   │
│  │   UI/Screens │────────▶│     BLoC     │                   │
│  │  (Widgets)   │  Events │ (State Mgmt) │                   │
│  └──────────────┘         └──────┬───────┘                   │
│                                   │                          │
└───────────────────────────────────┼──────────────────────────┘
                                    │
                                    │ States/Events
                                    ▼
┌──────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  ┌──────────────┐         ┌──────────────┐                   │
│  │  Managers    │         │ Repositories │                   │
│  │ (Services    │────────▶│ (Interfaces) │                   │
│  │   Logic)     │         │              │                   │
│  └──────────────┘         └──────┬───────┘                   │
│                                   │                          │
└───────────────────────────────────┼──────────────────────────┘
                                    │
                                    │ Repository Methods
                                    ▼
┌──────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌──────────────┐         ┌──────────────┐                   │
│  │ Repositories │────────▶│ Data Sources │                   │
│  │(Implementations)       │              │                   │
│  └──────────────┘         └──────┬───────┘                   │
│                                  │                           │
│                          ┌───────┴────────┐                  │
│                          │                │                  │
│                   ┌──────▼──────┐  ┌──────▼──────┐           │
│                   │   Remote    │  │    Local    │           │
│                   │ Data Source │  │ Data Source │           │
│                   │             │  │             │           │
│                   │  • REST API │  │  • Hive DB  │           │
│                   │  • Firebase │  │  • Shared   │           │
│                   │             │  │    Prefs    │           │
│                   └──────┬──────┘  └──────┬──────┘           │
│                          │                │                  │
└──────────────────────────┼────────────────┼──────────────────┘
                           │                │
                           │                │
                  ┌───────▼───────┐  ┌──────▼──────┐
                  │   API Client  │  │   Database  │
                  │   (Dio/HTTP)  │  │  (Hive)     │
                  │               │  │             │
                  │ • Backend API │  │ • Local     │
                  │ • Firebase    │  │   Storage   │
                  │               │  │             │
                  └───────────────┘  └─────────────┘
```

The mobile app communicates with backend services via **REST API** (using Dio HTTP client). We use **Firebase** for analytics, crash reporting, remote config, and storage of remote localization files. **Branch.io** handles deep linking and shareable links ( as preferred by client). **Mixpanel** provides additional analytics tracking (if preferred by client)

**Key Components:**
- **UI Layer**: Flutter widgets and screens (`lib/screens/`)
- **State Management**: BLoC (Business Logic Component) pattern
- **Dependency Injection**: GetIt for service location and DI (`lib/core/injector/`)
- **Architecture**: Module-based layered architecture
- **Networking**: Dio client with interceptors (configured in `RestClientModule`)
- **Local Storage**: Hive for local database, SharedPreferences for simple key-value storage, and Fluttersecuredstorage for important key-value pairs
- **Caching**: In-memory and persistent caching strategies
- **Routing**: AutoRoute for type-safe navigation (Go route can be used if preferred)

## Local Setup (Target: <30 minutes)

### Prerequisites

**Required:**
- macOS (for iOS development), Linux, or Windows with WSL2
- Flutter SDK (version specified in `pubspec.yaml` - currently `>=3.8.0 <4.0.0`)
- Git
- VS Code or Android Studio / IntelliJ IDEA

**Recommended:**
- FVM (Flutter Version Manager) for consistent Flutter versions
- VS Code with Flutter and Dart extensions
- Android Studio (for Android emulator and tools)
- Xcode (macOS only, for iOS development)

### One-Command Setup

```bash
# 1. Clone the repository
git clone [REPLACE: <repository-url>]
cd [REPLACE: <project-name>]

# 2. Set up environment variables (Env variables should be accessible via 1password shareable link by the project lead/mobile app developer of the project)
cp .example.env .dev.env
cp .example.env .uat.env
cp .example.env .prod.env

# 3. Fill in actual values (ask team for keys)
# Edit .dev.env, .uat.env, .prod.env with real API keys

# 4. Run setup script
chmod +x scripts/*.sh
./scripts/setup_env.sh

The above script coverts the env file to dart defines json file to be used in the project to run via vscode.

# 5. Install dependencies
flutter pub get

# 6. Run the app
./scripts/run_dev.sh
# Or press F5 in VSCode 
```

> **📝 TODO**: Replace `<repository-url>` and `<project-name>` with your actual repository URL and project name

### Step-by-Step Manual Setup

1. **Install Flutter:**
   ```bash
   # Using FVM (recommended)
   fvm install
   fvm use
   
   # Or direct installation
   # Follow: https://docs.flutter.dev/get-started/install
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get      # Installs Flutter packages
   ```

3. **Set up environment variables:**
   ```bash
   # Copy example env files
   cp .example.env .dev.env
   cp .example.env .uat.env
   cp .example.env .prod.env
   
   # Edit with actual values (ask team for keys)
   # See docs/environment-variables/01-setup.md for details
   ```

4. **Run setup script:**
   ```bash
   chmod +x scripts/*.sh
   ./scripts/setup_env.sh
   ```

5. **Verify everything works:**
   ```bash
   # Run the app in dev mode
   ./scripts/run_dev.sh
   
   # Or use VSCode: Press F5, select environment (dev/uat/prod)
   ```

### Common Setup Issues

**Issue: "Flutter command not found"**
- **Solution**: Add Flutter to your PATH or use FVM
- Verify: `flutter doctor`

**Issue: "iOS build fails (macOS only)"**
- **Solution**: Install Xcode Command Line Tools: `xcode-select --install`
- Open Xcode once to accept license agreements
- Run: `sudo xcodebuild -license accept`

**Issue: "Android build fails"**
- **Solution**: Install Android Studio, accept licenses
- Run: `flutter doctor --android-licenses`
- Set up Android SDK and emulator

**Issue: "Environment variables not loading"**
- **Solution**: Ensure `.dev.env` file exists and is properly formatted
- Run: `./scripts/setup_env.sh` to verify setup
- See: `docs/environment-variables/01-setup.md`

**Issue: "Firebase/Crashlytics errors"**
- **Solution**: Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are in place
- These files are typically in version control or provided by the team

> **📝 TODO**: Add any project-specific setup issues and solutions

## Repository Tour

> **📝 TODO**: Update this section to match your actual project structure. The structure below reflects the Hype project's module-based architecture with GetIt dependency injection.

```
lib/
├── main.dart                 # Production entry point
├── main_dev.dart             # Development entry point
├── main_uat.dart             # UAT entry point
├── main_prod.dart            # Prod entry point
├── flavor_config.dart        # Flavor configuration
├── core/                     # Core functionality
│   ├── api/                  # API clients and models
│   │   ├── clients/
│   │   │   │──rest_client          # REST API clients (Dio)
│   │   │   └──third_party_client   # any other api client 
│   │   │── exceptions/
│   │   │── resource/
│   │   └── models/              # API request/response models
│   ├── constants/               # App-wide constants
│   │   ├── remote_business_constants.dart  # Remote config constants
│   │   └── other constants files such as ui constant, timeour constants etc
│   ├── data/                    # Data layer
│   │   ├── data_sources/        # Remote and local data sources
│   │   └── repositories/        # Repository implementations
│   ├── domain/                  # Business logic layer
│   │   ├── database_abstract/   # in app database abstract class
│   │   ├── domain_models/       # Domain models
│   │   ├── entities/            # Domain entities
│   │   ├── enums/               # enums
│   │   └── repositories/        # Repository contracts abstract classes
│   ├── injector/                # Dependency Injection
│   │   ├── injector.dart        # Main GetIt injector setup
│   │   ├── bloc_module.dart     # BLoC registrations
│   │   ├── data_source_module.dart
│   │   ├── database_module.dart
│   │   ├── manager_module.dart
│   │   ├── repository_module.dart
│   │   ├── rest_client_module.dart
│   │   ├── service_module.dart
│   │   └── bloc_modules/           # Feature-specific BLoC modules
│   ├── libraries/                  # In house libraries
│   │   ├── app_switcher_protection
│   │   ├── App version checker
│   │   └── ...                     # Other libraries
│   ├── router/                     # Navigation/routing
│   │   └── app_router.dart         # AutoRoute configuration
│   ├── services/                   # Application services
│   │   ├── analytics/              # Analytics services
│   │   ├── crashlytics_service     # Crashlytics services
│   │   ├── deep_link/              # Deep linking services
│   │   ├── log_service/            # Log services
│   │   ├── location_service/       # Location service
│   │   ├── push_notification_service       # Location service
│   │   ├── device_information_retrieval/
│   │   ├── remote_config_service/
│   │   └── ...                     # Other services
│   ├── utils/                      # Utility functions
│   └── widgets/             # Reusable core widgets
├── screens/                  # UI screens/pages
│   ├── authentication/       # Auth screens
│   ├── feed/                 # Feed screens
│   ├── profile/               # Profile screens
│   └── ...                   # Other feature screens
├── theme/                    # App theme configuration
│   ├── app_theme.dart
│   ├── app_color_theme.dart
│   └── app_text_styles.dart
└── gen/                      # Generated code (AutoRoute, etc.)

scripts/                      # Build and utility scripts
├── run_dev.sh                # Run dev environment
├── run_uat.sh                # Run UAT environment
├── run_prod.sh               # Run prod environment
├── build_aab.sh              # Build Android
├── build_ios.sh               # Build iOS
├── build_release.sh           # Production builds
└── setup_env.sh               # Environment setup

docs/                         # Documentation
├── README.md                 # Main documentation index
├── environment-variables/    # Env var setup guides
├── cicd/                     # CI/CD guides
├── build-and-deploy/         # Build & deploy guides
└── product_docs/             # Product documentation

.github/
└── workflows/                # GitHub Actions CI/CD
    ├── deploy-dev.apps.yml
    ├── deploy-uat-apps.yml
    └── deploy-prod-apps.yml
```

### Architecture Overview

This project uses a **module-based architecture** with **GetIt** for dependency injection. The architecture is organized into clear layers following SOLID principles:

**Dependency Injection (DI):**
- Uses **GetIt** for service location and dependency injection
- Modules are organized in `lib/core/injector/`
- All dependencies are registered in `Injector.init()` with proper initialization order
- Critical services (like `DeviceInformationRetrievalService` and `RemoteConfigService`) are initialized early

**Module Structure:**
- **DatabaseModule**: Hive database setup and configuration
- **RestClientModule**: HTTP client (Dio) and API configuration, interceptors
- **DataSourceModule**: Remote and local data source registrations
- **RepositoryModule**: Repository implementations
- **ServiceModule**: Domain services (analytics, auth, deep linking, etc.)
- **ManagerModule**: Business logic managers
- **BlocModule**: BLoC state management registration (with feature-specific sub-modules)

**Layer Flow:**
```
UI (Screens/Widgets)
    ↓
BLoC (State Management)
    ↓
Managers/Services (Business Logic)
    ↓
Repositories (Data Access Abstraction)
    ↓
Data Sources (Remote API / Local Database)
```

**Key Design Principles:**
- **SOLID Principles**: Dependency Inversion (interfaces), Single Responsibility
- **Clean Architecture**: Clear separation of concerns across layers
- **Dependency Injection**: All dependencies injected via GetIt, no service locator anti-patterns
- **Async Initialization**: Proper handling of async service initialization order

### Where to Add New Features

**1. New Screen/Feature:**
   - Add UI in `lib/screens/[feature-name]/`
   - Add BLoC in `lib/screens/[feature-name]/bloc/`
   - Register BLoC in appropriate `lib/core/injector/bloc_modules/[feature]_bloc_module.dart`
   - Add route in `lib/core/router/app_router.dart`

**2. New API Integration:**
   - Add API endpoint client in `lib/core/api/clients/rest_client/`
   - Add data model in `lib/core/api/models/`
   - Add remote data source in `lib/core/data/data_sources/[feature]_data_sources/`
   - Register data source in `DataSourceModule`
   - Add repository interface in `lib/core/domain/repositories/` (if needed)
   - Add repository implementation in `lib/core/data/repositories/`
   - Register repository in `RepositoryModule`

**3. New Business Logic:**
   - Add manager in `lib/core/domain/managers/`
   - Or add service in `lib/core/services/`
   - Register in `ManagerModule` or `ServiceModule`

**4. New Database Entity:**
   - Add Hive adapter and entity model
   - Register in `DatabaseModule`

**5. Reusable Widget:**
   - Add to `lib/core/widgets/` (if core/widget) or `lib/screens/[feature]/widgets/` (if feature-specific)

**6. Configuration/Constants:**
   - Add to `lib/core/constants/` (app constants) or `lib/core/constants/remote_business_constants.dart` (remote config)

### Dependency Registration Pattern

When adding new dependencies, follow this pattern:

```dart
// Example: Registering a new repository
class RepositoryModule {
  static void init() {
    final GetIt injector = Injector.instance;
    
    injector.registerLazySingleton<MyRepository>(
      () => MyRepositoryImpl(
        dataSource: injector.get<MyDataSource>(),
      ),
    );
  }
}

// Then register the module in Injector.init():
await RepositoryModule.init();
```

**Module Initialization Order:**

The `Injector.init()` follows a specific initialization order to ensure dependencies are available when needed:

1. **DeviceInformationRetrievalService** - Device info (needed early by interceptors)
2. **DatabaseModule** - Database setup (foundation for data persistence)
3. **RemoteConfigService** - Remote configuration (needed before data sources that use RemoteBusinessConstants)
4. **RestClientModule** - HTTP client setup (depends on DeviceInformationRetrievalService)
5. **DataSourceModule** - Data sources (depends on RestClient and Database)
6. **RepositoryModule** - Repositories (depends on DataSources)
7. **ServiceModule** - Domain services (depends on Repositories)
8. **ManagerModule** - Business managers (depends on Services/Repositories)
9. **BlocModule** - BLoC registration (depends on Managers/Services)

> **📝 TODO**: Document any project-specific conventions or patterns (e.g., specific module initialization order requirements, singleton vs factory registration patterns, async initialization patterns, etc.)

### Code Style Guidelines

**Key Rules:**
- Use `final` for variables that are not reassigned
- Use `const` for variables known at compile time
- Prefer `const` widgets when possible for better performance
- Use arrow functions when possible
- Avoid "dot zero noise" - prefer `fontSize: 16` over `fontSize: 16.0`
- Use `Gap` instead of `SizedBox` for spacing
- Private methods to construct widgets should be prefixed with `_build`
- Separate widgets within the build function for better readability
- Use Return Early pattern
- When adding new dependency, add exact version (e.g., `intl: 0.19.0`, not `^0.19.0`)
- Avoid color blending - set color without alpha channel when possible
- Use `Theme` for changing default Flutter components visuals when possible
- Respect each platform's design style (Android ripple, iOS transparency)

See `README.md` for complete code style guidelines.

## Development Workflow

### Branching Strategy

We follow a strict Git branching strategy. See `docs/GIT_WORKFLOW.md` for complete details.

**Quick Summary:**
```
prod (production)      →  Live users, App Store releases
  ↑
uat (testing)          →  QA testing, TestFlight/Internal testing
  ↑
develop (development)  →  Integration branch, dev builds
  ↑
feature/[TICKET-ID]    →  Feature branches (Jira tickets)
```

**Feature Development:**
1. Create feature branch from `develop`: `feature/HAM-123-add-login-feature`
2. Develop and commit (hooks run automatically)
3. Create PR: `feature/HAM-123 → develop`
4. After approval, merge and continue flow: `develop → uat → prod`

**Protected Branches:**
- `develop`, `uat`, `prod` are **protected**
- **No direct pushes** - must use Pull Requests
- Enforced by GitHub branch protection

> **📝 TODO**: Update branch names if different, or document any additional protected branches (e.g., if your project uses `main` branch)

### PR Process

1. **Create Feature Branch:**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/HAM-123-your-feature-name
   ```

2. **Make Changes and Commit:**
   ```bash
   git add .
   git commit -m "feat(HAM-123): add user profile screen"
   # Pre-commit hooks run automatically (formatting, linting)
   git push origin feature/HAM-123-your-feature-name
   # Pre-push hooks run (full quality checks)
   ```

3. **Create PR on GitHub:**
   - Target: `develop` (or appropriate base branch)
   - CI runs automatically (quality checks, tests)
   - Get at least [**REPLACE: 1-2**] approval(s)
   - Ensure all status checks pass

4. **After Approval:**
   - Merge PR ([**REPLACE: squash/merge commit/rebase**] - per team preference)
   - Delete feature branch

**PR Requirements:**
- ✅ All quality checks pass (format, lint, tests)
- ✅ At least [**REPLACE: 1**] code review approval(s)
- ✅ No merge conflicts
- ✅ Descriptive commit messages (follow conventional commits)

> **📝 TODO**: Document any project-specific PR requirements (e.g., specific reviewers, additional checks, PR template, etc.)

### Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(auth): add biometric login
fix(payment): resolve crash on payment failure
docs(readme): update setup instructions
refactor(api): simplify error handling
```

Commitlint enforces this format via Git hooks - invalid messages will be rejected.

### Environment Flavors

The project supports three environments:

- **dev**: Development environment
  - Run: `./scripts/run_dev.sh` or `flutter run --flavor dev --dart-define=ENV_MODE=dev`
  - Uses `.dev.env` file

- **uat**: User Acceptance Testing environment
  - Run: `./scripts/run_uat.sh` or `flutter run --flavor uat --dart-define=ENV_MODE=uat`
  - Uses `.uat.env` file

- **prod**: Production environment
  - Run: `./scripts/run_prod.sh` or `flutter run --flavor prod --dart-define=ENV_MODE=prod`
  - Uses `.prod.env` file

Each environment has its own:
- API endpoints
- Firebase project configuration
- Feature flags
- Environment variables

See `docs/environment-variables/` for detailed setup instructions.

## First Task Playbook

### Safe First Change: Add Your Name to Contributors

> **📝 TODO**: Customize this section based on your project's first task strategy. This is just an example.

This is a safe, visible change that lets you test the entire workflow.

**Alternative First Tasks** (choose what fits your project):
- Add name to `CONTRIBUTORS.md`
- Update `README.md` with project-specific information
- Fix a simple bug from the backlog
- Add documentation for a feature
- Implement a small, low-risk feature

**Example: Adding Your Name to Contributors**

1. **Create Branch:**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/add-my-name-to-contributors
   ```

2. **Make Change:**
   - Create or update `CONTRIBUTORS.md` (or appropriate file)
   - Add your name and GitHub username

3. **Commit:**
   ```bash
   git add CONTRIBUTORS.md
   git commit -m "docs: add my name to contributors"
   # Pre-commit hook will format your commit message if needed
   ```

4. **Push:**
   ```bash
   git push origin feature/add-my-name-to-contributors
   # Pre-push hook runs quality checks (might take a minute)
   ```

5. **Create PR:**
   - Go to GitHub → Pull Requests → New PR
   - Source: `feature/add-my-name-to-contributors`
   - Target: `develop`
   - Add description: "Adding my name to contributors list as first contribution"
   - Request review from [**REPLACE: team member or tech lead**]

6. **After Approval:**
   - Merge PR
   - Verify your name appears in the file
   - Celebrate! 🎉

> **📝 TODO**: Document your project's preferred first task for new engineers

### Validating Changes Locally

Before pushing, always validate locally:

```bash
# Run the app
./scripts/run_dev.sh              # Run dev environment
flutter run --flavor dev           # Alternative way

# Run quality checks (if available)
flutter analyze                    # Run linter
flutter test                       # Run tests

# Build for testing
./scripts/build_aab.sh dev apk    # Android APK (note: script name may vary)
./scripts/build_ios.sh dev         # iOS build
```

### Understanding CI Checks

When you push, **GitHub Actions** runs:
- **Format Check**: Ensures code follows formatting rules
- **Lint Check**: Catches code quality issues
- **Tests**: Runs unit, widget, and integration tests
- **Build Check**: Verifies the app builds successfully for all flavors
- **Deployment**: Automatically deploys to TestFlight/Play Store (on merge to develop/uat/prod)

> **📝 TODO**: Document any project-specific CI checks or requirements:
> - Security scans
> - Dependency vulnerability checks
> - Performance benchmarks
> - Build size limits
> - Other custom checks

All checks must pass before PR can be merged.

## Building & Deploying

### Local Development Builds

**Android APK:**
```bash
./scripts/build_aab.sh dev apk
# Note: Script name and parameters may vary - check scripts/ directory
```

**iOS:**
```bash
./scripts/build_ios.sh dev
```

### Production Builds

**Android (with obfuscation):**
```bash
./scripts/build_release.sh android prod
```

**iOS (with obfuscation):**
```bash
./scripts/build_release.sh ios prod
```

Production builds automatically:
- ✅ Build with code obfuscation
- ✅ Save debug symbols
- ✅ Archive symbols locally
- ✅ Prompt to upload to Firebase Crashlytics

See `docs/build-and-deploy/` for detailed guides.

### Automatic Deployments

**On merge to `develop`:**
- ✅ Runs CI checks (format, lint, tests, build verification)
- ✅ Build verification for all flavors
- ❌ **No automatic deployment** - Manual deployment when needed

**On merge to `uat`:**
- ✅ Builds UAT version (with obfuscation)
- ✅ Uploads symbols to Firebase
- ✅ Deploys to TestFlight (iOS) / Play Store Internal Testing (Android)
- ✅ QA team gets notification

**On merge to `prod`:**
- ✅ Builds production version (with obfuscation)
- ✅ Uploads symbols to Firebase
- ✅ Deploys to TestFlight (iOS - External Testing) / Play Store (Production Track)
- ✅ Live to users!

See `docs/cicd/` for CI/CD setup and configuration.

## Getting Help

> **📝 TODO**: Fill in actual contact information and communication channels

- **Communication Channel**: [**REPLACE: Slack Channel/Discord/Teams/etc.**] - [**REPLACE: channel name**]
  <!-- Example: Slack Channel: #mobile-engineering -->
- **Documentation**: `docs/` folder
  - Main index: `docs/README.md`
  - Environment setup: `docs/environment-variables/`
  - CI/CD: `docs/cicd/`
  - Build & deploy: `docs/build-and-deploy/`
  - Git workflow: `docs/GIT_WORKFLOW.md`
- **Tech Lead**: [**REPLACE: Name/Email/Slack handle**]
- **Principal Engineer**: [**REPLACE: Name/Email/Slack handle**]
- **Team Lead**: [**REPLACE: Name/Email/Slack handle**]
- **Emergency Contact**: [**REPLACE: How to reach someone for urgent issues**]

## Next Steps

1. ✅ Complete setup and validation
2. ✅ Make first contribution ([**REPLACE: describe your preferred first task**])
3. ✅ Review architecture docs (`docs/product_docs/PRODUCT_SYSTEM_ARCHITECTURE_OVERVIEW.md`)
4. ✅ Read coding standards (`README.md` - Code style section)
5. ✅ Understand Git workflow (`docs/GIT_WORKFLOW.md`)
6. ✅ Ask for your first real task assignment

> **📝 TODO**: Add any project-specific next steps (e.g., specific training, shadowing sessions, access requests, etc.)

## Additional Resources

### Documentation
- **Main Docs**: `docs/README.md` - Start here for all documentation
- **Quick Start**: `QUICK_START.md` - Quick reference guide
- **Product Docs**: `docs/product_docs/` - Product architecture and features
- **Engineering Docs**: `docs/` - All engineering documentation

### External Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [BLoC Pattern](https://bloclibrary.dev/)
- [GetIt Documentation](https://pub.dev/packages/get_it)
- [AutoRoute Documentation](https://autoroute.vercel.app/)
- [Conventional Commits](https://www.conventionalcommits.org/)

Welcome to the team! 🚀
