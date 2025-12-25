# Coding Standards & Conventions

This document defines our coding standards, naming conventions, and best practices for Flutter development.

## General Coding Principles

1. **Clarity over Cleverness**: Write code that's easy to understand
2. **DRY (Don't Repeat Yourself)**: Extract common logic into reusable functions/classes
3. **YAGNI (You Aren't Gonna Need It)**: Don't over-engineer; build what's needed now
4. **Single Responsibility**: Each class/function should do one thing well
5. **Fail Fast**: Validate inputs early and fail with clear error messages

## Naming Conventions

### Files and Folders

- **Files**: `snake_case.dart`
- **Folders**: `snake_case`
- **Private files**: `_private_file.dart` (leading underscore)

**Examples:**
```
user_profile_page.dart
user_profile_repository.dart
_user_profile_helper.dart  # private utility
```

### Classes and Types

- **Classes**: `PascalCase`
- **Abstract classes**: `PascalCase` (often end with interface name like `Repository`, `Manager`)
- **Mixins**: `PascalCase` with `Mixin` suffix: `ValidatableMixin`
- **Extensions**: `PascalCase` with `Extension` suffix: `StringExtension`

**Examples:**
```dart
class UserProfile {}
class AuthRepository {}
abstract class BaseRepository {}
mixin ValidatableMixin {}
extension StringExtension on String {}
```

### Variables and Functions

- **Variables**: `camelCase`
- **Private members**: `_camelCase` (leading underscore)
- **Constants**: `lowerCamelCase` for final variables, `SCREAMING_SNAKE_CASE` for compile-time constants
- **Functions/Methods**: `camelCase`
- **Private functions**: `_camelCase`

**Examples:**
```dart
String userName = 'Ashwin';
final String apiKey = 'secret';
const String APP_NAME = 'MyApp';
void getUserProfile() {}
void _validateInput() {}  // private
```

### Boolean Names

- Use positive boolean names: `isEnabled`, `hasData`, `canEdit`
- Avoid negatives: `isNotEnabled` ❌ → `isDisabled` ✅

### Collections

- **Lists**: Use descriptive plural names: `users`, `items`, `messages`
- **Maps**: Use descriptive names: `userMap`, `settingsMap`

### Parameters

- Use descriptive parameter names
- Consider named parameters for functions with 3+ parameters
- Use required for critical parameters

**Examples:**
```dart
// Good
void updateUser({
  required String id,
  required String name,
  String? email,
});

// Bad
void updateUser(String id, String name, String email);
```

## File and Folder Structure Rules

### File Organization

Each file should contain:
1. **Imports** (sorted: Dart → Flutter → Package → Relative)
2. **Class/Widget definition**
3. **Private helpers** (if any)

**Import Order:**
```dart
// Dart SDK
import 'dart:async';
import 'dart:math';

// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Packages
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// Relative imports
import '../models/user.dart';
import '../utils/helpers.dart';
```

**Example File Structure:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user.dart';
import '../bloc/user_bloc.dart';

class UserProfilePage extends StatelessWidget {
  // Widget implementation
}

// Private helpers at the bottom
String _formatUserName(User user) {
  return '${user.firstName} ${user.lastName}';
}
```

### Folder Structure

Follow module-based organization:

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
│   │   │   ├── rest_client          # REST API clients (Dio)
│   │   │   └── third_party_client   # Any other API client
│   │   ├── exceptions/
│   │   ├── resource/
│   │   └── models/              # API request/response models
│   ├── constants/               # App-wide constants
│   │   ├── remote_business_constants.dart  # Remote config constants
│   │   └── other constants files (ui constants, timeout constants, etc.)
│   ├── data/                    # Data layer
│   │   ├── data_sources/        # Remote and local data sources
│   │   └── repositories/        # Repository implementations
│   ├── domain/                  # Business logic layer
│   │   ├── database_abstract/   # In-app database abstract class
│   │   ├── domain_models/       # Domain models
│   │   ├── entities/            # Domain entities
│   │   ├── enums/               # Enums
│   │   └── repositories/        # Repository contracts (abstract classes)
│   ├── injector/                # Dependency Injection
│   │   ├── injector.dart        # Main GetIt injector setup
│   │   ├── bloc_module.dart     # BLoC registrations
│   │   ├── data_source_module.dart
│   │   ├── database_module.dart
│   │   ├── manager_module.dart
│   │   ├── repository_module.dart
│   │   ├── rest_client_module.dart
│   │   ├── service_module.dart
│   │   └── bloc_modules/        # Feature-specific BLoC modules
│   ├── libraries/               # In-house libraries
│   │   ├── app_switcher_protection
│   │   ├── app_version_checker
│   │   └── ...                  # Other libraries
│   ├── router/                  # Navigation/routing
│   │   └── app_router.dart      # AutoRoute configuration
│   ├── services/                # Application services
│   │   ├── analytics/           # Analytics services
│   │   ├── crashlytics_service  # Crashlytics service
│   │   ├── deep_link/           # Deep linking services
│   │   ├── log_service/         # Log services
│   │   ├── location_service/    # Location service
│   │   ├── push_notification_service  # Push notification service
│   │   ├── device_information_retrieval/
│   │   ├── remote_config_service/
│   │   └── ...                  # Other services
│   ├── utils/                   # Utility functions
│   └── widgets/                 # Reusable core widgets
├── screens/                     # UI screens/pages
│   ├── authentication/          # Auth screens
│   ├── feed/                    # Feed screens
│   ├── profile/                 # Profile screens
│   └── ...                      # Other feature screens
├── theme/                       # App theme configuration
│   ├── app_theme.dart
│   ├── app_color_theme.dart
│   └── app_text_styles.dart
└── gen/                         # Generated code (AutoRoute, etc.)
```

**Rule**: If code is used by multiple features, it belongs in `core/`. Feature-specific UI and BLoC stay in `screens/[feature]/`.

## State Management Guidelines

**Our Approach: BLoC (Business Logic Component) Pattern**

### BLoC Structure

- Keep BLoCs focused on single responsibility
- Use sealed classes or freezed for states
- Separate events from states
- Business logic stays in Managers/Services, not BLoC

**Example:**
```dart
// Events (lib/screens/login/bloc/login_event.dart)
part of 'login_bloc.dart';

sealed class LoginEvent {}

class LogInRequestEvent extends LoginEvent {
  final String email;
  final String password;
  LogInRequestEvent(this.email, this.password);
}

class FormFieldValueChangedEvent extends LoginEvent {
  final String email;
  final String password;
  FormFieldValueChangedEvent(this.email, this.password);
}

class FetchProfileEvent extends LoginEvent {}

// States (lib/screens/login/bloc/login_state.dart)
part of 'login_bloc.dart';

sealed class LoginState {}

class LogInIdleState extends LoginState {}

class LoggingInState extends LoginState {}

class LoggedInState extends LoginState {
  final UserDomain user;
  LoggedInState(this.user);
}

class LoginMessageState extends LoginState {
  final String message;
  final SnackbarStyle style;
  LoginMessageState(this.message, this.style);
}

// BLoC (lib/screens/login/bloc/login_bloc.dart)
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required final AuthRepository authRepository,
    required final UserRepository userRepository,
    required final AnalyticsRepository analyticsRepository,
    required final LogService logService,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        _analyticsRepository = analyticsRepository,
        _logService = logService,
        super(LogInIdleState()) {
    on<LogInRequestEvent>(_onSubmitted);
    on<FormFieldValueChangedEvent>(_onFormValueChanged);
    on<FetchProfileEvent>(_onFetchProfile);
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final AnalyticsRepository _analyticsRepository;
  final LogService _logService;

  Future<void> _onSubmitted(
    final LogInRequestEvent event,
    final Emitter<LoginState> emit,
  ) async {
    // Create and validate the login request model
    final LoginRequestModel loginRequestModel = LoginRequestModel(
      email: event.email,
      password: event.password,
    )..validate();

    if (loginRequestModel.hasError) {
      emit(
        LoginMessageState(
          loginRequestModel.formattedErrorMessage,
          SnackbarStyle.error,
        ),
      );
      return;
    }

    emit(LoggingInState());

    // Perform login and handle response
    final Result<OauthTokenEntity> response = await _authRepository.loginUser(loginRequestModel);
    
    response.when(
      success: (final OauthTokenEntity loginResponse) {
        _analyticsRepository.trackEvent(
          event: AnalyticsEvents.userLoginEvent,
          properties: <String, dynamic>{},
        );
        add(FetchProfileEvent());
      },
      error: (final CustomException error) {
        _logService.e(
          error.toMessage(),
          error,
          null,
          error.errorCode,
        );
        _analyticsRepository.trackEvent(
          event: AnalyticsEvents.userLoginEvent,
          properties: <String, dynamic>{'error': error.toJson},
        );
        emit(LoginMessageState(error.toMessage(), SnackbarStyle.error));
      },
    );
  }

  Future<void> _onFormValueChanged(
    final FormFieldValueChangedEvent event,
    final Emitter<LoginState> emit,
  ) async {
    final LoginRequestModel loginRequestModel = LoginRequestModel(
      email: event.email,
      password: event.password,
    )..validate();

    if (loginRequestModel.hasError) {
      emit(
        LoginMessageState(
          loginRequestModel.formattedErrorMessage,
          SnackbarStyle.validationError,
        ),
      );
      return;
    }
    emit(LogInIdleState());
  }

  Future<void> _onFetchProfile(
    final FetchProfileEvent event,
    final Emitter<LoginState> emit,
  ) async {
    final Result<UserEntity> response = await _userRepository.fetchCurrentUserDetails();
    response.when(
      success: (final UserEntity user) {
        _analyticsRepository.trackEvent(
          event: AnalyticsEvents.profileFetchEvent,
          properties: <String, dynamic>{},
        );
        emit(LoggedInState(UserDomain(user)));
      },
      error: (final CustomException exception) {
        _logService.e(
          exception.toString(),
          exception,
          null,
          exception.errorCode,
        );
        _analyticsRepository.trackEvent(
          event: AnalyticsEvents.profileFetchEvent,
          properties: <String, dynamic>{'error': exception.toJson},
        );
        emit(LoginMessageState(exception.toMessage(), SnackbarStyle.error));
      },
    );
  }
}
```

### State Updates

- Use sealed classes or freezed for state variants
- Use `part` files for events and states (e.g., `part 'login_event.dart'; part 'login_state.dart';`)
- BLoC handles state transitions and coordinates repositories/services
- Repositories handle data operations; Managers (when used) are singletons for shared business logic
- Update state immutably via BLoC events

## Error Handling Standards

### Error Types

Define specific error types extending `CustomException`:

```dart
// Custom exceptions extend CustomException
class NetworkException extends CustomException {
  NetworkException(String message) : super(message);
}

class AuthException extends CustomException {
  AuthException(String message) : super(message);
}

class ValidationException extends CustomException {
  ValidationException(String message) : super(message);
}
```

### Error Handling Pattern

Use `Result<T>` pattern:

```dart
// Result class definition (using freezed)
@freezed
abstract class Result<T> with _$Result<T> {
  const factory Result.success(final T body) = Success<T>;
  const factory Result.error(final CustomException error) = Error<T>;
}

// Repository methods return Result
Future<Result<User>> getUser(String id) async {
  try {
    final user = await dataSource.getUser(id);
    return Result.success(user);
  } on NetworkException catch (e) {
    return Result.error(NetworkException('Network error occurred'));
  } catch (e) {
    return Result.error(UnknownException(e.toString()));
  }
}

// Manager/BLoC handles Result using pattern matching
final result = await repository.getUser(userId);
result.when(
  success: (user) => emit(SuccessState(user)),
  error: (exception) => emit(ErrorState(exception.message)),
);
```

### Never Swallow Errors

**Bad:**
```dart
try {
  await dangerousOperation();
} catch (e) {
  // Silent failure - BAD!
}
```

**Good:**
```dart
try {
  await dangerousOperation();
} catch (e) {
  logError(e);
  showErrorToUser('Operation failed. Please try again.');
}
```

## Logging and Analytics Rules

### Logging

Use structured logging:

```dart
import 'package:logger/logger.dart';

final logger = Logger();

// Use appropriate log levels
logger.d('Debug message');      // Development only
logger.i('Info message');       // General information
logger.w('Warning message');    // Warnings
logger.e('Error message', error: e, stackTrace: stackTrace);  // Errors
```

**Rules:**
- ✅ Log errors with stack traces
- ✅ Log important user actions
- ❌ Don't log sensitive data (passwords, tokens, PII)
- ❌ Don't log in production (use analytics instead)
- ✅ Use appropriate log levels

### Analytics

Track user actions and app events:

```dart
analytics.logEvent(
  name: 'user_profile_viewed',
  parameters: {
    'user_id': userId,
    'source': 'home_screen',
  },
);
```

**Rules:**
- ✅ Track key user actions
- ✅ Track feature usage
- ❌ Don't track PII without consent
- ✅ Use consistent event naming
- ✅ Document tracked events

## Linting and Formatting Expectations

### Code Formatting

We use `dart format` (built into Flutter):

```bash
# Format code
dart format .

# Check formatting
dart format --set-exit-if-changed .
```

**Rules:**
- ✅ Run `dart format` before committing
- ✅ Follow Flutter style guide
- ✅ Maximum line length: 100 characters (configurable)

### Linting

We use `analysis_options.yaml` with `very_good_analysis`:

```bash
# Run analyzer
flutter analyze

# Check for issues
flutter analyze --fatal-warnings
```

**Key Rules Enforced:**
- ✅ `avoid_print`: Use logger instead of print
- ✅ `prefer_const_constructors`: Use const where possible
- ✅ `always_declare_return_types`: Explicit return types
- ✅ `prefer_final_locals`: Use final for variables that don't change
- ✅ `use_key_in_widget_constructors`: Keys for widgets in lists

### Pre-commit Hooks

Husky hooks automatically run:
1. **Format check**: `dart format --set-exit-if-changed .`
2. **Lint-staged**: Format staged files

### Pre-push Hooks

Before pushing, hooks run:
1. **Format check**: Ensures all code is formatted
2. **Analyze**: Runs `flutter analyze`
3. **Tests**: Runs all tests
4. **Coverage check**: Ensures test coverage meets threshold

**If hooks fail, fix issues before pushing.**

## Documentation Standards

### Code Comments

**When to comment:**
- ✅ Complex business logic
- ✅ Non-obvious algorithms
- ✅ Workarounds for bugs
- ✅ Public APIs

**When NOT to comment:**
- ❌ Self-explanatory code
- ❌ Comments that repeat what code says

**Example:**
```dart
// Good: Explains WHY, not WHAT
// Using cached data to avoid rate limiting on external API
final user = await cache.getUser(userId) ?? await api.getUser(userId);

// Bad: Repeats what code says
// Get user from cache or API
final user = await cache.getUser(userId) ?? await api.getUser(userId);
```

### Documentation Comments

Use dartdoc for public APIs:

```dart
/// Retrieves user profile by ID.
///
/// Returns [User] if found, throws [UserNotFoundException] if not found.
///
/// Example:
/// ```dart
/// final user = await repository.getUser('123');
/// ```
Future<User> getUser(String id);
```

## Testing Standards

See `05-testing-strategy.md` for detailed testing guidelines.

**Quick Rules:**
- ✅ Write unit tests for business logic
- ✅ Write widget tests for UI components
- ✅ Aim for 80%+ code coverage
- ✅ Use descriptive test names: `test('should return user when ID is valid')`

## Code Review Checklist

When reviewing code, check:

- [ ] Follows naming conventions
- [ ] No business logic in UI layer
- [ ] Proper error handling
- [ ] Tests written and passing
- [ ] No hardcoded values (use constants/config)
- [ ] No commented-out code
- [ ] Proper logging (no print statements)
- [ ] Follows formatting standards
- [ ] No security issues (sensitive data, etc.)
- [ ] Performance considerations (no unnecessary rebuilds, etc.)

## Standards Enforcement

### Automated Enforcement

1. **Pre-commit hooks**: Format and lint staged files
2. **Pre-push hooks**: Full quality checks (format, analyze, tests)
3. **CI/CD**: Runs on every PR, blocks merge if fails
4. **Analysis options**: Enforces linting rules

### Manual Enforcement

- Code reviews check adherence to standards
- Team discussions for ambiguous cases
- Regular refactoring to improve code quality

## References

- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Style Guide](https://docs.flutter.dev/development/ui/widgets-intro)
- [very_good_analysis Rules](https://github.com/VeryGoodOpenSource/very_good_analysis)

