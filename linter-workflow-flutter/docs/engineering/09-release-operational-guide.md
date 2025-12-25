# Release & Operational Guide

This document covers environment management, build and release processes, versioning, and operational procedures.

## Environment Management

### Environments

**Development:**
- Purpose: Local development
- API: Development/staging API
- Configuration: `.env.dev`
- Build: Debug mode

**UAT (User Acceptance Testing):**
- Purpose: Testing before production
- API: UAT API server
- Configuration: `.env.uat`
- Build: Release mode (unsigned for testing)

**Production:**
- Purpose: Live app in stores
- API: Production API
- Configuration: `.env.prod`
- Build: Release mode (signed for stores)

### Environment Configuration

**Environment Files:**

```dart
// lib/core/config/env_config.dart
class EnvConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.dev.example.com',
  );
  
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );
  
  static bool get isProduction => apiBaseUrl.contains('api.prod');
}
```

**Build with Environment:**

```bash
# Development
flutter run --dart-define=ENV=dev

# UAT
flutter build apk --dart-define=ENV=uat --dart-define=API_BASE_URL=https://api.uat.example.com

# Production
flutter build appbundle --dart-define=ENV=prod --dart-define=API_BASE_URL=https://api.example.com
```

### Environment Variables

**Store in `.env` files (gitignored):**

```
# .env.dev
API_BASE_URL=https://api.dev.example.com
API_KEY=dev-key-123
ENABLE_LOGGING=true

# .env.uat
API_BASE_URL=https://api.uat.example.com
API_KEY=uat-key-456
ENABLE_LOGGING=true

# .env.prod
API_BASE_URL=https://api.example.com
API_KEY=prod-key-789
ENABLE_LOGGING=false
```

**Load Environment:**

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env.dev'); // or .env.uat, .env.prod
  runApp(MyApp());
}
```

## Build & Release Process

### Build Types

**Debug:**
- Purpose: Development
- Features: Hot reload, debugging, logging
- Performance: Not optimized
- Command: `flutter run`

**Profile:**
- Purpose: Performance testing
- Features: Performance profiling, some optimizations
- Command: `flutter run --profile`

**Release:**
- Purpose: Production deployment
- Features: Optimized, obfuscated, minimal logging
- Command: `flutter build --release`

### Android Build Process

**APK (for direct distribution):**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**App Bundle (for Play Store):**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**Signing:**
```bash
# Create keystore (one-time)
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Configure signing (android/key.properties)
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=upload
storeFile=../upload-keystore.jks
```

### iOS Build Process

**Build for Device:**
```bash
flutter build ios --release
```

**Create IPA:**
```bash
flutter build ipa --release
# Output: build/ios/ipa/app.ipa
```

**Requirements:**
- Xcode installed
- Apple Developer account
- Provisioning profiles
- Code signing certificates

### Build with Obfuscation

**For Release Builds:**
```bash
flutter build apk --obfuscate --split-debug-info=./debug-info
flutter build appbundle --obfuscate --split-debug-info=./debug-info
flutter build ios --obfuscate --split-debug-info=./debug-info
```

**Benefits:**
- Smaller app size
- Harder to reverse engineer
- Protects intellectual property

## Versioning Strategy

### Semantic Versioning

**Format:** `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes (API changes, major features)
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

**Examples:**
- `1.0.0` - Initial release
- `1.0.1` - Bug fix
- `1.1.0` - New feature
- `2.0.0` - Breaking change

### Version Configuration

**Update in `pubspec.yaml`:**
```yaml
version: 1.2.3+45
# Format: version+buildNumber
# version: User-facing version
# buildNumber: Build number (incremented for each build)
```

**Access Version in Code:**
```dart
import 'package:package_info_plus/package_info_plus.dart';

final packageInfo = await PackageInfo.fromPlatform();
print(packageInfo.version); // 1.2.3
print(packageInfo.buildNumber); // 45
```

### Version Management

**Release Process:**

1. **Update Version:**
   ```yaml
   # pubspec.yaml
   version: 1.2.3+46  # Increment version and build number
   ```

2. **Update CHANGELOG.md:**
   ```markdown
   ## [1.2.3] - 2024-01-15
   
   ### Added
   - New feature X
   
   ### Fixed
   - Bug Y
   
   ### Changed
   - Improvement Z
   ```

3. **Tag Release:**
   ```bash
   git tag -a v1.2.3 -m "Release version 1.2.3"
   git push origin v1.2.3
   ```

## Release Workflow

### Release Process Overview

See `docs/engineering/outcode-git-branching-strategy.md` for detailed Git workflow.

**Summary:**
```
develop → uat → prod → main
```

### UAT Release

**Process:**

1. **Merge to UAT:**
   - Create PR: `develop → uat`
   - CI runs quality checks
   - Get approval
   - Merge PR

2. **Deploy to UAT:**
   - GitHub Actions workflow builds and deploys
   - Deploy to TestFlight (iOS) and Firebase App Distribution / Play Store Internal (Android)

3. **Testing:**
   - QA team tests
   - Stakeholder review
   - Fix any issues found

### Production Release

**Process:**

1. **Merge to Prod:**
   - Create PR: `uat → prod`
   - CI runs quality checks
   - Get approval (may require 2 approvals)
   - Merge PR

2. **Deploy to Stores:**
   - GitHub Actions workflow builds and deploys
   - Upload to App Store Connect (iOS)
   - Upload to Play Console (Android)

3. **Store Review:**
   - Wait for Apple/Google review
   - Address any review feedback

4. **Merge to Main:**
   - After store approval, run "Merge Prod to Main" workflow
   - This ensures `main` branch reflects live store code

### Hotfix Process

**For Critical Production Issues:**

1. **Create Hotfix Branch:**
   ```bash
   git checkout prod
   git pull origin prod
   git checkout -b hotfix/critical-bug-fix
   ```

2. **Fix and Test:**
   - Fix the issue
   - Test thoroughly
   - Commit: `git commit -m "fix: resolve critical production bug"`

3. **Deploy:**
   - Create PR: `hotfix/critical-bug-fix → prod`
   - Fast-track approval
   - Merge and deploy

4. **Merge Back:**
   - Merge hotfix back to `develop` via PR

## Rollback Strategy

### Play Store Rollback

**Process:**

1. **Identify Previous Version:**
   - Go to Play Console → Release → Production
   - Identify last good version

2. **Rollback:**
   - Deactivate current release
   - Activate previous version
   - Users will receive previous version on next update

**Limitations:**
- Can't force immediate rollback (users need to update)
- Previous version must be available in Play Console

### App Store Rollback

**Process:**

1. **Identify Previous Version:**
   - Go to App Store Connect → App → Versions
   - Identify last good version

2. **Submit Previous Version:**
   - Create new submission with previous version
   - Fast-track review request (if critical)
   - Wait for approval

**Limitations:**
- Requires new submission and review
- Takes time (can request expedited review for critical issues)

### Code Rollback

**Git Rollback:**

```bash
# Revert commit
git revert <commit-hash>
git push origin branch-name

# Or reset to previous commit (if not pushed)
git reset --hard <commit-hash>
```

**Best Practice:**
- Use `git revert` for commits already in shared branches
- Use `git reset` only for local commits

## Incident Handling Basics

### Incident Severity

**Critical (P0):**
- App crash affecting all users
- Data loss or security breach
- Complete service outage
- Response: Immediate

**High (P1):**
- Major feature broken
- Significant performance degradation
- Partial service outage
- Response: Within 1 hour

**Medium (P2):**
- Minor feature broken
- Workaround available
- Response: Within 4 hours

**Low (P3):**
- Cosmetic issues
- Non-critical bugs
- Response: Next release

### Incident Response Process

1. **Identify**: Confirm issue exists and assess severity
2. **Communicate**: Notify team and stakeholders
3. **Contain**: Prevent further impact (feature flags, rollback)
4. **Fix**: Develop and deploy fix
5. **Verify**: Confirm fix resolves issue
6. **Post-Mortem**: Document incident, root cause, prevention

### On-Call Process

**Responsibilities:**
- Monitor alerts and notifications
- Respond to incidents
- Escalate if needed
- Document incidents

**Tools:**
- Crash reporting (Firebase Crashlytics)
- Error monitoring (Sentry)
- Analytics (Firebase Analytics)
- Alerting (PagerDuty, Slack)

## Monitoring & Alerts

### Key Metrics to Monitor

**App Health:**
- Crash rate
- ANR (Application Not Responding) rate
- Error rate
- Session duration

**Performance:**
- App startup time
- API response times
- Frame rendering performance
- Memory usage

**Business:**
- Active users
- Feature usage
- Conversion rates
- User retention

### Setting Up Alerts

**Critical Alerts:**
- Crash rate > 1%
- Error rate > 5%
- API failure rate > 10%

**Performance Alerts:**
- Startup time > 5 seconds
- API response time p95 > 5 seconds
- Memory usage > threshold

## Deployment Checklist

### Pre-Deployment

- [ ] All tests pass (unit, widget, integration)
- [ ] Code review approved
- [ ] Version number updated
- [ ] CHANGELOG.md updated
- [ ] Environment variables configured
- [ ] Build tested on real devices
- [ ] Release notes prepared

### Post-Deployment

- [ ] Monitor crash reports
- [ ] Monitor error logs
- [ ] Verify metrics are normal
- [ ] Check user feedback
- [ ] Update documentation if needed

## References

- [Flutter Build Documentation](https://docs.flutter.dev/deployment)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [Google Play Console](https://play.google.com/console/)

