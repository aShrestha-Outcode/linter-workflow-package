# Dependency & Tech Stack Governance

This document defines our approach to managing dependencies, evaluating new libraries, and maintaining our technology stack.

## Approved Tech Stack

### Core Framework

- **Flutter**: Primary framework (version in `.fvmrc`)
- **Dart**: Programming language (bundled with Flutter)

### State Management

**BLoC (Business Logic Component) Pattern**

**Rationale**: BLoC provides predictable state management, separates business logic from UI, and works well with our module-based architecture. It enforces unidirectional data flow and makes testing easier.

**Key Packages:**
- `flutter_bloc`: BLoC pattern implementation
- `bloc_test`: Testing utilities for BLoC

### Dependency Injection

**GetIt**

**Rationale**: GetIt is a simple service locator that works well with our module-based architecture. It provides lazy initialization, singleton support, and clear dependency registration patterns.

**Key Packages:**
- `get_it`: Service locator and DI container

### Networking

**Dio**

**Rationale**: Dio provides interceptors, request/response transformation, and better error handling than the standard http package. It integrates well with our architecture for API client configuration.

**Key Packages:**
- `dio`: HTTP client with interceptors

### Local Storage

**Hive + SharedPreferences**

**Rationale**: 
- **Hive**: Fast, lightweight NoSQL database for complex local data storage
- **SharedPreferences**: Simple key-value storage for app preferences and settings

**Key Packages:**
- `hive`: Fast NoSQL database
- `hive_flutter`: Flutter bindings for Hive
- `shared_preferences`: Simple key-value storage

### Testing

- **test**: Core testing framework
- **mockito**: Mocking library
- **flutter_test**: Widget testing

### Tooling

- **very_good_analysis**: Linting rules
- **Husky**: Git hooks
- **Commitlint**: Commit message validation
- **lint-staged**: Format staged files

## Dependency Rules

### General Rules

1. **Prefer Official Packages**: Use packages from `pub.dev` official repository
2. **Check Maintenance**: Ensure package is actively maintained (recent updates, issues addressed)
3. **Review Dependencies**: Check package dependencies for security issues
4. **Version Pinning**: Pin major versions, allow patch updates
5. **Document Decisions**: Document why a dependency was added

### Adding New Dependencies

**Process:**

1. **Evaluate Need**: Do we really need this dependency?
   - Can we build it ourselves?
   - Is it worth the maintenance burden?

2. **Research Package**:
   - Check pub.dev score and popularity
   - Review GitHub issues and maintenance status
   - Check license compatibility
   - Review dependencies (transitive dependencies)

3. **Get Approval**: For major dependencies, get team/tech lead approval

4. **Add Dependency**: Add to `pubspec.yaml` with version constraint

5. **Document**: Add to this document if it's a significant addition

**Version Constraints:**

```yaml
dependencies:
  # Major version pinning (allows minor and patch updates)
  flutter_bloc: ^8.0.0
  get_it: ^7.0.0
  dio: ^5.0.0
  
  # Exact version (for critical dependencies - prefer this approach per code style)
  intl: 0.19.0  # Not ^0.19.0 - exact version
  
  # Example of major version pinning
  # hive: ^2.0.0
```

### Removing Dependencies

**When to Remove:**
- Package is deprecated
- No longer needed
- Replaced by better alternative
- Security vulnerabilities

**Process:**
1. Remove from `pubspec.yaml`
2. Run `flutter pub get`
3. Remove unused imports
4. Update tests if needed
5. Document removal if significant

## Library Evaluation Checklist

Before adding a new package, evaluate using this checklist:

### Essential Criteria

- [ ] **Active Maintenance**: Updated within last 6 months
- [ ] **Popularity**: Used by significant number of projects (check pub.dev popularity)
- [ ] **Documentation**: Has good documentation and examples
- [ ] **License**: License is compatible with our project
- [ ] **Size**: Package size is reasonable (check impact on app size)
- [ ] **Dependencies**: Doesn't pull in excessive transitive dependencies

### Quality Indicators

- [ ] **GitHub Activity**: Recent commits, issues are addressed
- [ ] **Test Coverage**: Package has good test coverage
- [ ] **Null Safety**: Supports null safety (Dart 2.12+)
- [ ] **Platform Support**: Supports required platforms (iOS, Android, Web)
- [ ] **Community**: Active community, Stack Overflow answers

### Security & Stability

- [ ] **Security**: No known security vulnerabilities
- [ ] **Stability**: Package is stable (not in beta/pre-release)
- [ ] **Breaking Changes**: Version history shows reasonable upgrade path

### Alternative Evaluation

- [ ] **Alternatives**: Evaluated alternative packages
- [ ] **Trade-offs**: Understand trade-offs of chosen package
- [ ] **Migration Path**: Consider migration if better alternative emerges

## Upgrade Strategy

### Regular Updates

**Minor/Patch Updates:**
- Update regularly (monthly or quarterly)
- Test thoroughly before deploying
- Update `pubspec.yaml` version constraints

**Major Updates:**
- Evaluate breaking changes
- Plan migration path
- Test extensively
- Get team approval

### Upgrade Process

1. **Check for Updates:**
   ```bash
   flutter pub outdated
   ```

2. **Review Changes:**
   - Check CHANGELOG
   - Review breaking changes
   - Check GitHub releases

3. **Update Dependencies:**
   ```bash
   flutter pub upgrade
   # Or update specific package
   flutter pub upgrade package_name
   ```

4. **Test Thoroughly:**
   ```bash
   flutter test
   flutter run
   # Test on all platforms
   ```

5. **Commit Changes:**
   ```bash
   git add pubspec.yaml pubspec.lock
   git commit -m "chore: upgrade dependencies"
   ```

### Flutter SDK Upgrades

**Process:**

1. **Check Compatibility**: Verify all dependencies support new Flutter version
2. **Update Flutter**: `flutter upgrade`
3. **Update .fvmrc**: Update version in `.fvmrc`
4. **Test**: Run full test suite
5. **Fix Issues**: Address any breaking changes
6. **Team Communication**: Notify team of upgrade

## Deprecation Policy

### Deprecating Dependencies

**When to Deprecate:**
- Package is no longer maintained
- Better alternative exists
- Security issues cannot be resolved
- Conflicts with other dependencies

**Process:**

1. **Identify Replacement**: Find alternative or plan to build internally
2. **Plan Migration**: Create migration plan and timeline
3. **Implement Replacement**: Build or integrate replacement
4. **Update Code**: Replace usage throughout codebase
5. **Remove Dependency**: Remove from `pubspec.yaml`
6. **Document**: Update this document

### Handling Deprecated Dependencies

**If Dependency is Deprecated:**

1. **Assess Impact**: How critical is this dependency?
2. **Check Alternatives**: Are there maintained alternatives?
3. **Plan Migration**: Create timeline for migration
4. **Monitor**: Watch for security issues in deprecated package

## Dependency Categories

### Core Dependencies

**Required for app functionality:**
- State management
- Networking
- Local storage
- Authentication

**Rules:**
- Very careful evaluation before adding
- Long-term commitment
- Document rationale

### Utility Dependencies

**Helper packages:**
- Date formatting
- String utilities
- JSON serialization

**Rules:**
- Easier to replace
- Can be swapped if better alternative emerges

### Development Dependencies

**Build-time only:**
- Code generators
- Linters
- Build tools

**Rules:**
- More flexible
- Don't affect app size
- Can experiment more freely

## Security Considerations

### Security Audit

**Regular Audits:**
- Run `flutter pub audit` regularly
- Review dependencies for known vulnerabilities
- Update vulnerable packages immediately

```bash
# Check for vulnerabilities
flutter pub audit
```

### Security Policies

1. **No Hardcoded Secrets**: Never commit API keys, passwords, tokens
2. **Environment Variables**: Use `.env` files for sensitive config
3. **Dependency Updates**: Keep dependencies updated for security patches
4. **Code Review**: Review dependency additions in PRs

## Size Considerations

### App Size Impact

**Monitor App Size:**
- Check impact of new dependencies on app size
- Consider alternatives for large packages
- Use tree-shaking where possible

```bash
# Analyze app size
flutter build apk --analyze-size
```

### Large Dependencies

**If dependency is large:**
- Evaluate if it's necessary
- Consider alternatives
- Check if features can be used conditionally
- Document size impact

## Dependency Review Process

### Regular Reviews

**Quarterly Review:**
- Review all dependencies
- Check for outdated packages
- Identify unused dependencies
- Plan upgrades

### PR Review

**When reviewing PRs that add dependencies:**
- Verify evaluation checklist was followed
- Check if dependency is necessary
- Review version constraints
- Ensure documentation is updated

## Documentation

### Dependency Documentation

**For major dependencies, document:**
- Why it was chosen
- Alternatives considered
- Known issues or limitations
- Migration notes (if replacing another package)

**Example:**
```markdown
## State Management: BLoC

**Version**: ^8.0.0

**Rationale**: 
- Predictable unidirectional data flow
- Clear separation of business logic from UI
- Excellent testability
- Works well with our module-based architecture

**Alternatives Considered**: Provider, Riverpod, GetX
**Known Limitations**: None significant
**Migration Notes**: Migrated from setState in v1.0
```

## Emergency Updates

### Critical Security Updates

**Process for critical security updates:**

1. **Immediate Assessment**: Evaluate severity
2. **Quick Fix**: Update to patched version
3. **Test**: Run critical tests
4. **Deploy**: Fast-track deployment if necessary
5. **Follow-up**: Full testing and review after deployment

## References

- [pub.dev](https://pub.dev/) - Package repository
- [Flutter Pub Documentation](https://docs.flutter.dev/development/packages-and-plugins)
- [Dart Package Guide](https://dart.dev/guides/libraries/create-library-packages)

