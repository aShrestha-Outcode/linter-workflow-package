# Architecture & Design Guide

This document explains the architectural decisions, patterns, and principles that guide our Flutter application development.

## Architectural Principles

### 1. Separation of Concerns

Each layer has a single, well-defined responsibility:
- **Presentation**: UI rendering and user interaction
- **Domain**: Business logic and rules
- **Data**: Data sources and persistence

### 2. Dependency Inversion

High-level modules don't depend on low-level modules. Both depend on abstractions:
- Domain layer defines interfaces (repositories)
- Data layer implements these interfaces
- Presentation layer depends on domain abstractions, not data implementations

### 3. Single Source of Truth

State flows in one direction:
```
UI ← Presentation Layer ← Domain Layer ← Data Layer ← External Sources
```

### 4. Testability

All layers are independently testable:
- Domain logic has no dependencies on Flutter
- Data sources can be mocked
- UI can be tested in isolation

### 5. Scalability

Architecture supports:
- Feature teams working independently
- Clear boundaries between modules
- Easy addition of new features

## App Architecture Overview

### Layered Architecture

```
┌─────────────────────────────────────┐
│      Presentation Layer             │
│  (UI, Widgets, State Management)    │
└──────────────┬──────────────────────┘
               │ depends on
┌──────────────▼──────────────────────┐
│         Domain Layer                 │
│  (Entities, Use Cases, Interfaces)  │
└──────────────┬──────────────────────┘
               │ implements
┌──────────────▼──────────────────────┐
│          Data Layer                  │
│  (Repositories, Data Sources, API)  │
└─────────────────────────────────────┘
```

### Layer Responsibilities

#### Presentation Layer (`lib/screens/`)

**Purpose**: Handle UI rendering and user interactions.

**Contains:**
- **Screens**: Full screens/pages (`lib/screens/[feature]/`)
- **Widgets**: Reusable UI components (`lib/core/widgets/` or feature-specific)
- **State Management**: BLoC classes (`lib/screens/[feature]/bloc/`)
- **Navigation**: AutoRoute configuration (`lib/core/router/app_router.dart`)

**Rules:**
- ✅ Can depend on Domain layer (through BLoC)
- ❌ Cannot depend on Data layer directly
- ❌ Should contain minimal business logic (logic in BLoC or Managers)
- ✅ Handles UI state (loading, error, success) via BLoC states

#### Domain Layer (`lib/core/domain/`)

**Purpose**: Business logic and rules.

**Contains:**
- **Entities**: Core business objects (pure Dart classes) (`lib/core/domain/entities/`)
- **Repositories**: Interface definitions (abstract classes) (`lib/core/domain/repositories/`)
- **Managers**: Business logic managers (`lib/core/domain/managers/`)
- **Services**: Domain services (`lib/core/services/`)

**Rules:**
- ✅ Pure Dart (no Flutter dependencies)
- ✅ Independent and testable
- ❌ No UI or data implementation details
- ✅ Defines what needs to be done, not how

#### Data Layer (`lib/core/data/`)

**Purpose**: Data sources and persistence.

**Contains:**
- **Models**: API request/response models (`lib/core/api/models/`)
- **Repositories**: Concrete implementations (`lib/core/data/repositories/`)
- **Data Sources**: Remote and local data sources (`lib/core/data/data_sources/`)
- **API Clients**: Dio HTTP client and endpoints (`lib/core/api/clients/`)

**Rules:**
- ✅ Implements domain interfaces
- ✅ Handles data transformation (models ↔ entities)
- ✅ Manages caching and offline support (Hive, SharedPreferences)
- ✅ Handles network errors and retries via Dio interceptors

## Data Flow

### Example: Loading User Profile

```
1. User taps "View Profile" button
   ↓
2. UI dispatches LoadUserProfileEvent to BLoC
   ↓
3. BLoC calls Manager.getUserProfile(userId) or Service
   ↓
4. Manager/Service calls Repository.getUserProfile(userId)
   ↓
5. Repository (Data Layer):
   - Checks local cache (Hive)
   - If miss, calls Remote Data Source (Dio API)
   - Transforms Model → Entity
   - Updates cache
   ↓
6. Returns Entity to Manager/Service
   ↓
7. Manager/Service returns Entity to BLoC
   ↓
8. BLoC emits SuccessState(entity) or ErrorState(error)
   ↓
9. UI rebuilds via BlocBuilder/BlocConsumer
```

### State Management Flow

**State Management Approach: BLoC (Business Logic Component) Pattern**

```
User Action
    ↓
BLoC Event
    ↓
BLoC (State Manager)
    ↓
Business Logic (Manager/Service)
    ↓
Repository
    ↓
BLoC State Update
    ↓
UI Rebuild (via BlocBuilder/BlocConsumer)
```

## Feature Lifecycle

### How a Feature is Structured

```
lib/screens/
└── user_profile/
    ├── user_profile_screen.dart
    ├── widgets/
    │   ├── profile_header.dart
    │   └── profile_stats.dart
    └── bloc/
        ├── user_profile_bloc.dart
        ├── user_profile_event.dart
        └── user_profile_state.dart

lib/core/
├── domain/
│   ├── entities/
│   │   └── user_profile.dart
│   ├── repositories/
│   │   └── user_profile_repository.dart
│   └── managers/
│       └── user_profile_manager.dart
├── data/
│   ├── repositories/
│   │   └── user_profile_repository_impl.dart
│   └── data_sources/
│       ├── user_profile_remote_datasource.dart
│       └── user_profile_local_datasource.dart
└── api/
    └── models/
        └── user_profile_model.dart
```

### Feature Implementation Flow

1. **Define Domain Entity** (`lib/core/domain/entities/user_profile.dart`)
   ```dart
   class UserProfile {
     final String id;
     final String name;
     final String email;
     // Pure Dart class, no dependencies
   }
   ```

2. **Define Repository Interface** (`lib/core/domain/repositories/user_profile_repository.dart`)
   ```dart
   abstract class UserProfileRepository {
     Future<Result<UserProfile>> getUserProfile(String userId);
   }
   ```

3. **Create Manager or Service** (`lib/core/domain/managers/user_profile_manager.dart` or `lib/core/services/`)
   ```dart
   class UserProfileManager {
     final UserProfileRepository repository;
     
     Future<Result<UserProfile>> getUserProfile(String userId) {
       return repository.getUserProfile(userId);
     }
   }
   ```

4. **Implement Data Layer** (`lib/core/data/`)
   - Create API Model (`lib/core/api/models/user_profile_model.dart`)
   - Implement Repository (`lib/core/data/repositories/user_profile_repository_impl.dart`)
   - Create Data Sources (`lib/core/data/data_sources/`)

5. **Create BLoC** (`lib/screens/user_profile/bloc/`)
   - Define Events and States
   - Inject Manager/Service via GetIt
   - Handle business logic calls and state emissions

6. **Build UI** (`lib/screens/user_profile/`)
   - Create Screen/Widget
   - Connect to BLoC via BlocBuilder/BlocConsumer
   - Handle loading, error, and success states

## Golden Path Example

### Feature: User Authentication

**Why this approach:**

1. **Domain-First**: We define what authentication means (login, logout) before implementation
2. **Testable**: Use cases can be tested without UI or network
3. **Flexible**: Can swap auth providers (OAuth, Firebase, custom) without changing domain
4. **Clear Boundaries**: Each layer has clear responsibilities

**Implementation:**

```dart
// Domain: Entity (lib/domain/entities/user.dart)
class User {
  final String id;
  final String email;
  final String name;
}

// Domain: Repository Interface (lib/core/domain/repositories/auth_repository.dart)
abstract class AuthRepository {
  Future<Result<OauthTokenEntity>> loginUser(LoginRequestModel model);
  Future<Result<void>> logout();
  Stream<User?> get authStateChanges;
}

// Note: Managers are singletons used elsewhere for shared business logic.
// For BLoCs, we use repositories directly for data operations.

// Data: Implementation (lib/core/data/repositories/auth_repository_impl.dart)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  
  @override
  Future<Result<User>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      final user = userModel.toEntity();
      await localDataSource.saveUser(userModel);
      return Result.success(user);
    } on NetworkException catch (e) {
      return Result.error(NetworkException('Network error occurred'));
    } on AuthException catch (e) {
      return Result.error(AuthException(e.message));
    }
  }
}

// Presentation: BLoC (lib/screens/login/bloc/login_bloc.dart)
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final LogService _logService;
  
  LoginBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required LogService logService,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        _logService = logService,
        super(LogInIdleState()) {
    on<LogInRequestEvent>(_onSubmitted);
  }
  
  Future<void> _onSubmitted(
    LogInRequestEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoggingInState());
    
    final loginRequestModel = LoginRequestModel(
      email: event.email,
      password: event.password,
    )..validate();
    
    if (loginRequestModel.hasError) {
      emit(LoginMessageState(loginRequestModel.formattedErrorMessage, SnackbarStyle.error));
      return;
    }
    
    final result = await _authRepository.loginUser(loginRequestModel);
    result.when(
      success: (final OauthTokenEntity token) {
        // Trigger profile fetch or emit logged in state
        emit(LoggedInState());
      },
      error: (final CustomException exception) {
        _logService.e(exception.toMessage(), exception, null, exception.errorCode);
        emit(LoginMessageState(exception.toMessage(), SnackbarStyle.error));
      },
    );
  }
}

// Presentation: UI (lib/screens/login/login_screen.dart)
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => Injector.instance<LoginBloc>(),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginMessageState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is LoggedInState) {
            // Navigate to home
          }
        },
        builder: (context, state) {
          if (state is LoggingInState) {
            return LoadingIndicator();
          }
          if (state is LoggedInState) {
            // Navigate to home screen
            return HomeScreen();
          }
          return LoginForm(
            onLogin: (email, password) {
              context.read<LoginBloc>().add(LogInRequestEvent(email, password));
            },
          );
        },
      ),
    );
  }
}
```

**Key Points:**
- Domain doesn't know about HTTP, JSON, or Flutter
- Data layer handles all technical details
- UI is thin and focused on rendering
- Easy to test each layer independently

## Anti-Patterns

### ❌ Business Logic in UI

**Bad:**
```dart
class LoginPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Business logic in UI - BAD!
        if (!email.contains('@')) {
          showError('Invalid email');
          return;
        }
        final response = await http.post('/login', body: {...});
        // Handle response, transform data, etc.
      },
      child: Text('Login'),
    );
  }
}
```

**Why it's bad:**
- Not testable without UI
- Logic is duplicated if used elsewhere
- Violates separation of concerns

**Good:**
```dart
// BLoC calls Repository directly
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  
  LoginBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        super(LogInIdleState()) {
    on<LogInRequestEvent>(_onSubmitted);
  }
  
  Future<void> _onSubmitted(
    LogInRequestEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoggingInState());
    final result = await _authRepository.loginUser(loginRequestModel);
    result.when(
      success: (token) => add(FetchProfileEvent()),
      error: (exception) => emit(LoginMessageState(exception.toMessage(), SnackbarStyle.error)),
    );
  }
}

// Usage in UI
context.read<LoginBloc>().add(LogInRequestEvent(email, password))
```

### ❌ Direct API Calls from UI

**Bad:**
```dart
// UI directly calling API
final response = await http.get('/api/user/$id');
final user = User.fromJson(response.body);
```

**Why it's bad:**
- UI is tightly coupled to API structure
- Hard to mock for testing
- No caching or offline support
- Violates dependency inversion

**Good:**
```dart
// BLoC calls Manager, which uses Repository
context.read<UserProfileBloc>().add(LoadUserProfile(userId));
```

### ❌ Fat Controllers/BLoCs

**Bad:**
```dart
class UserProfileBloc {
  // Contains business logic, data fetching, UI state, everything
  Future<void> loadProfile() async {
    final response = await http.get('/api/user');
    final data = json.decode(response.body);
    // Complex business logic here
    // Transform data
    // Update cache
    // Handle errors
    emit(UserProfileState(data));
  }
}
```

**Why it's bad:**
- Hard to test
- Violates single responsibility
- Not reusable

**Good:**
```dart
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserProfileRepository _userProfileRepository;
  final LogService _logService;
  
  UserProfileBloc({
    required UserProfileRepository userProfileRepository,
    required LogService logService,
  })  : _userProfileRepository = userProfileRepository,
        _logService = logService,
        super(UserProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
  }
  
  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());
    final result = await _userProfileRepository.getUserProfile(event.userId);
    result.when(
      success: (user) => emit(UserProfileSuccess(user)),
      error: (exception) {
        _logService.e(exception.toMessage(), exception, null, exception.errorCode);
        emit(UserProfileError(exception.toMessage()));
      },
    );
  }
}
```

### ❌ Shared Global State

**Bad:**
```dart
// Global variable
User? currentUser;
```

**Why it's bad:**
- Not reactive
- Hard to track changes
- Testing nightmare
- Race conditions

**Good:**
```dart
// Use BLoC for state management
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Auth state managed via BLoC
}
```

### ❌ Ignoring Errors

**Bad:**
```dart
try {
  await repository.getData();
} catch (e) {
  // Silent failure - BAD!
}
```

**Why it's bad:**
- Users don't know what went wrong
- Debugging is difficult
- Poor user experience

**Good:**
```dart
final result = await repository.getData();
result.when(
  success: (data) => showData(data),
  error: (exception) => showError(exception.message),
);
```

## Dependency Management

### Dependency Injection

We use **GetIt** for dependency injection. All dependencies are registered in modules located in `lib/core/injector/modules/`.

**Module Structure:**
- `DatabaseModule`: Database setup
- `RestClientModule`: HTTP client (Dio) configuration
- `DataSourceModule`: Remote and local data source registrations
- `RepositoryModule`: Repository implementations
- `ServiceModule`: Domain services
- `ManagerModule`: Business logic managers
- `BlocModule`: BLoC state management registration

**Example:**
```dart
// RepositoryModule (lib/core/injector/repository_module.dart)
class RepositoryModule {
  static void init() {
    final GetIt injector = Injector.instance;
    
    injector.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: injector.get<AuthRemoteDataSource>(),
        localDataSource: injector.get<AuthLocalDataSource>(),
      ),
    );
    
    injector.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(
        dataSource: injector.get<UserRemoteDataSource>(),
      ),
    );
  }
}

// ManagerModule (lib/core/injector/manager_module.dart)
// Managers are singletons used for shared business logic, not in BLoCs
class ManagerModule {
  static void init() {
    final GetIt injector = Injector.instance;
    
    // Example: Shared business logic manager (not used in BLoCs)
    injector.registerLazySingleton<SessionManager>(
      () => SessionManager(
        repository: injector.get<AuthRepository>(),
      ),
    );
  }
}

// BlocModule (lib/core/injector/bloc_module.dart)
class BlocModule {
  static void init() {
    final GetIt injector = Injector.instance;
    
    injector.registerFactory<LoginBloc>(
      () => LoginBloc(
        authRepository: injector.get<AuthRepository>(),
        userRepository: injector.get<UserRepository>(),
        logService: injector.get<LogService>(),
      ),
    );
  }
}
```

### Module Boundaries

Features are self-contained:
- Domain layer is independent
- Data layer depends on domain interfaces
- Presentation layer depends on domain layer

Cross-feature dependencies should be minimal and go through domain layer.

## Performance Considerations

### Lazy Loading

- Load data only when needed
- Use pagination for lists
- Implement virtual scrolling for large lists

### Caching Strategy

- Cache frequently accessed data
- Use memory cache for hot data
- Persist critical data locally
- Implement cache invalidation

### Build Optimization

- Use `const` constructors where possible
- Minimize rebuilds with proper state management
- Use `ListView.builder` for long lists
- Optimize images and assets

## Module-Based Architecture

### Dependency Injection with GetIt

All dependencies are registered in `Injector.init()` with proper initialization order:

1. **DeviceInformationRetrievalService** - Device info (needed early)
2. **DatabaseModule** - Hive database setup
3. **RemoteConfigService** - Remote configuration
4. **RestClientModule** - Dio HTTP client setup
5. **DataSourceModule** - Data sources
6. **RepositoryModule** - Repositories
7. **ServiceModule** - Domain services
8. **ManagerModule** - Business managers
9. **BlocModule** - BLoC registration

### Routing with AutoRoute

Navigation is handled via AutoRoute in `lib/core/router/app_router.dart`:

```dart
@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page, initial: true),
    AutoRoute(page: HomeRoute.page),
    // ... other routes
  ];
}
```

## References

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev/)
- [GetIt Documentation](https://pub.dev/packages/get_it)
- [AutoRoute Documentation](https://autoroute.vercel.app/)
- [Flutter Best Practices](https://docs.flutter.dev/development/ui/widgets-intro)

