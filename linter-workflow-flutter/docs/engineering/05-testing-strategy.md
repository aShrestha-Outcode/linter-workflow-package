# Testing Strategy

This document outlines our testing philosophy, pyramid, and guidelines for writing effective tests.

## Testing Philosophy

### Core Principles

1. **Tests as Documentation**: Tests describe how code should behave
2. **Test Behavior, Not Implementation**: Focus on what code does, not how
3. **Fast Feedback**: Tests should run quickly
4. **Reliable**: Tests should be deterministic and not flaky
5. **Maintainable**: Tests should be easy to read and update

### Testing Goals

- **Confidence**: Deploy with confidence that changes don't break existing functionality
- **Regression Prevention**: Catch bugs before they reach production
- **Documentation**: Tests serve as living documentation
- **Design Feedback**: Writing tests helps identify design issues

## Testing Pyramid

```
        /\
       /  \      E2E Tests (Few)
      /----\
     /      \    Integration Tests (Some)
    /--------\
   /          \  Unit Tests (Many)
  /------------\
```

### Unit Tests (Foundation)

**Purpose**: Test individual functions, classes, or methods in isolation.

**Characteristics:**
- Fast (< 1ms per test typically)
- Isolated (no dependencies on external systems)
- Deterministic (same input = same output)
- Many tests

**When to Write:**
- ✅ Business logic
- ✅ Utility functions
- ✅ Data transformations
- ✅ State management logic (BLoC)
- ✅ Managers and Services

**Example:**
```dart
void main() {
  group('UserRepository', () {
    test('should return user when ID is valid', () async {
      // Arrange
      final repository = UserRepository(mockDataSource);
      when(mockDataSource.getUser('123')).thenAnswer((_) async => mockUser);
      
      // Act
      final result = await repository.getUser('123');
      
      // Assert
      expect(result, equals(mockUser));
      verify(mockDataSource.getUser('123')).called(1);
    });
    
    test('should throw exception when user not found', () async {
      // Arrange
      final repository = UserRepository(mockDataSource);
      when(mockDataSource.getUser('999')).thenThrow(UserNotFoundException());
      
      // Act & Assert
      expect(
        () => repository.getUser('999'),
        throwsA(isA<UserNotFoundException>()),
      );
    });
  });
}
```

### Widget Tests (UI Layer)

**Purpose**: Test UI components in isolation.

**Characteristics:**
- Medium speed (10-100ms per test)
- Test widget rendering and interactions
- Can mock dependencies
- Some tests

**When to Write:**
- ✅ Custom widgets
- ✅ UI interactions
- ✅ Widget state changes
- ✅ Form validation UI

**Example:**
```dart
void main() {
  testWidgets('LoginPage should show error when login fails', (tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(),
      ),
    );
    
    // Act
    await tester.enterText(find.byKey(loginEmailKey), 'invalid@email.com');
    await tester.enterText(find.byKey(loginPasswordKey), 'wrongpassword');
    await tester.tap(find.byKey(loginButtonKey));
    await tester.pumpAndSettle();
    
    // Assert
    expect(find.text('Invalid email or password'), findsOneWidget);
  });
}
```

### Integration Tests (E2E)

**Purpose**: Test complete user flows across multiple screens.

**Characteristics:**
- Slow (seconds per test)
- Tests real app behavior
- May require test backend
- Few tests

**When to Write:**
- ✅ Critical user flows
- ✅ Payment flows
- ✅ Authentication flows
- ✅ Navigation flows

**Example:**
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete login flow', (tester) async {
    // Arrange
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();
    
    // Act: Navigate to login
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    
    // Act: Enter credentials
    await tester.enterText(find.byKey(emailFieldKey), 'user@example.com');
    await tester.enterText(find.byKey(passwordFieldKey), 'password123');
    await tester.tap(find.byKey(loginButtonKey));
    await tester.pumpAndSettle();
    
    // Assert: Should navigate to home
    expect(find.text('Welcome'), findsOneWidget);
  });
}
```

## Unit Testing Rules

### Structure: AAA Pattern

**Arrange, Act, Assert:**

```dart
test('description', () {
  // Arrange: Set up test data and mocks
  final repository = UserRepository(mockDataSource);
  when(mockDataSource.getUser('123')).thenAnswer((_) async => mockUser);
  
  // Act: Execute the code being tested
  final result = await repository.getUser('123');
  
  // Assert: Verify the results
  expect(result, equals(mockUser));
});
```

### Test Naming

Use descriptive test names that explain what is being tested:

```dart
// Good
test('should return user when ID exists in database', () {});
test('should throw UserNotFoundException when ID does not exist', () {});
test('should cache user data after first fetch', () {});

// Bad
test('getUser', () {});
test('test1', () {});
test('works', () {});
```

### Test Organization

Use `group()` to organize related tests:

```dart
group('UserRepository', () {
  group('getUser', () {
    test('should return user when ID is valid', () {});
    test('should throw exception when ID is invalid', () {});
    test('should return cached user when available', () {});
  });
  
  group('updateUser', () {
    test('should update user in database', () {});
    test('should invalidate cache after update', () {});
  });
});
```

### Mocking

Use mocks for dependencies:

```dart
// Using mockito
class MockUserDataSource extends Mock implements UserDataSource {}

void main() {
  late MockUserDataSource mockDataSource;
  late UserRepository repository;
  
  setUp(() {
    mockDataSource = MockUserDataSource();
    repository = UserRepository(mockDataSource);
  });
  
  test('should call data source', () async {
    when(mockDataSource.getUser('123')).thenAnswer((_) async => mockUser);
    
    await repository.getUser('123');
    
    verify(mockDataSource.getUser('123')).called(1);
  });
}
```

### Testing Edge Cases

Always test:
- ✅ Happy path (normal case)
- ✅ Error cases
- ✅ Edge cases (empty, null, boundary values)
- ✅ Invalid input

**Example:**
```dart
group('EmailValidator', () {
  test('should return true for valid email', () {
    expect(EmailValidator.isValid('user@example.com'), isTrue);
  });
  
  test('should return false for invalid email', () {
    expect(EmailValidator.isValid('invalid'), isFalse);
  });
  
  test('should return false for empty string', () {
    expect(EmailValidator.isValid(''), isFalse);
  });
  
  test('should return false for null', () {
    expect(EmailValidator.isValid(null), isFalse);
  });
});
```

## Widget/UI Testing Guidelines

### Testing Widgets

**Focus on:**
- Widget renders correctly
- User interactions work
- State updates reflect in UI
- Error states display correctly

**Example:**
```dart
testWidgets('CounterWidget increments count on button tap', (tester) async {
  // Arrange
  await tester.pumpWidget(
    MaterialApp(
      home: CounterWidget(),
    ),
  );
  
  // Assert: Initial state
  expect(find.text('0'), findsOneWidget);
  
  // Act: Tap increment button
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump(); // Trigger rebuild
  
  // Assert: Count incremented
  expect(find.text('1'), findsOneWidget);
  expect(find.text('0'), findsNothing);
});
```

### Finding Widgets

Use keys for finding widgets:

```dart
// Define keys
const loginButtonKey = Key('login_button');
const emailFieldKey = Key('email_field');

// In widget
ElevatedButton(
  key: loginButtonKey,
  onPressed: () {},
  child: Text('Login'),
)

// In test
await tester.tap(find.byKey(loginButtonKey));
```

### Async Testing

Use `pumpAndSettle()` for animations and async operations:

```dart
testWidgets('shows loading indicator during data fetch', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Initial build
  await tester.pump();
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  
  // Wait for async operation to complete
  await tester.pumpAndSettle();
  expect(find.byType(CircularProgressIndicator), findsNothing);
});
```

## Integration Testing Scope

### What to Test

**Critical Flows:**
- User registration and login
- Payment processing
- Data synchronization
- Navigation between major screens

**Example Integration Test:**
```dart
testWidgets('user can complete purchase flow', (tester) async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();
  
  // Navigate to products
  await tester.tap(find.text('Products'));
  await tester.pumpAndSettle();
  
  // Select product
  await tester.tap(find.byKey(productCardKey));
  await tester.pumpAndSettle();
  
  // Add to cart
  await tester.tap(find.byKey(addToCartButtonKey));
  await tester.pumpAndSettle();
  
  // Go to checkout
  await tester.tap(find.byKey(cartButtonKey));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(checkoutButtonKey));
  await tester.pumpAndSettle();
  
  // Complete purchase
  await tester.enterText(find.byKey(cardNumberKey), '4111111111111111');
  await tester.tap(find.byKey(payButtonKey));
  await tester.pumpAndSettle();
  
  // Verify success
  expect(find.text('Purchase Complete'), findsOneWidget);
});
```

## Test Naming and Structure

### File Structure

```
test/
├── unit/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   ├── data/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── datasources/
│   └── core/
│       └── utils/
├── widget/
│   └── presentation/
│       ├── pages/
│       └── widgets/
└── integration/
    └── flows/
```

### File Naming

Test files should mirror source files:

```
Source: lib/core/domain/managers/user_profile_manager.dart
Test:   test/unit/core/domain/managers/user_profile_manager_test.dart
```

## When Tests Are Required vs Optional

### Required Tests

**Always write tests for:**
- ✅ Business logic (managers, services, domain logic)
- ✅ Data transformations (models, entities)
- ✅ Complex utility functions
- ✅ State management logic
- ✅ Critical user flows (payment, auth)
- ✅ Bug fixes (regression tests)

### Optional Tests

**Tests are optional but recommended for:**
- ⚠️ Simple getters/setters
- ⚠️ Pure UI components without logic
- ⚠️ Trivial utility functions

**Use judgment:** If it's easy to test and provides value, write the test.

## Test Coverage

### Coverage Goals

- **Target**: 80% code coverage minimum
- **Critical paths**: 100% coverage (payment, auth, data operations)
- **UI layer**: 70%+ coverage (focus on interactive widgets)

### Coverage Reports

```bash
# Generate coverage
flutter test --coverage

# View coverage
# Coverage report in: coverage/lcov.info

# HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Coverage in CI

CI enforces coverage threshold:
- Build fails if coverage < 80%
- Coverage report generated on every PR
- Track coverage trends over time

## Best Practices

### ✅ Do This

1. **Write tests first (TDD)** when possible
2. **Test one thing per test**
3. **Use descriptive test names**
4. **Keep tests fast and isolated**
5. **Use mocks for external dependencies**
6. **Test edge cases and error paths**
7. **Keep tests maintainable**

### ❌ Don't Do This

1. ❌ Test implementation details
2. ❌ Write flaky tests (random, timing-dependent)
3. ❌ Test third-party code
4. ❌ Write slow tests unnecessarily
5. ❌ Ignore test failures
6. ❌ Write tests that are hard to understand

## Testing Tools

### Mocking

**mockito** - Recommended mocking library:

```yaml
dev_dependencies:
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

**Usage:**
```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([UserDataSource])
void main() {
  late MockUserDataSource mockDataSource;
  // ...
}
```

### Test Utilities

**test** - Core testing framework (built into Flutter)
**flutter_test** - Widget testing utilities
**integration_test** - Integration testing

## Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/user_test.dart

# Run tests matching pattern
flutter test --name "UserRepository"

# Run in watch mode (auto-rerun on changes)
flutter test --watch
```

## References

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Testing Best Practices](https://docs.flutter.dev/testing/best-practices)
- [Mockito Documentation](https://pub.dev/packages/mockito)

