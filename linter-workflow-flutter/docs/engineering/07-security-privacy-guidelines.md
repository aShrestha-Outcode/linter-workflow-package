# Security & Privacy Guidelines

This document outlines security best practices and privacy considerations for mobile app development.

## Secure Storage Rules

### Sensitive Data Storage

**Never store in plain text:**
- Passwords
- API keys
- Authentication tokens
- Credit card numbers
- Personal identification numbers (SSN, etc.)

### Storage Solutions

**Use secure storage packages:**

```dart
// Recommended: flutter_secure_storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
  iOptions: IOSOptions(
    accessibility: IOSAccessibility.first_unlock_this_device,
  ),
);

// Store sensitive data
await storage.write(key: 'auth_token', value: token);

// Retrieve
final token = await storage.read(key: 'auth_token');
```

**Platform-specific:**
- **iOS**: Uses Keychain
- **Android**: Uses EncryptedSharedPreferences or Keystore

### What Can Be Stored in Regular Storage

**Safe for SharedPreferences:**
- User preferences (theme, language)
- Non-sensitive settings
- Cached non-sensitive data

**Never in SharedPreferences:**
- Passwords
- Tokens
- API keys
- PII (unless encrypted)

## Authentication & Token Handling

### Token Storage

**Best Practices:**
- Store tokens securely (use flutter_secure_storage)
- Implement token refresh mechanism
- Clear tokens on logout
- Handle token expiration gracefully

**Example:**
```dart
class AuthService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
```

### Token Refresh

**Implement automatic token refresh:**

```dart
class ApiClient {
  Future<Response> request(String endpoint) async {
    final token = await authService.getToken();
    
    var response = await http.get(
      Uri.parse(endpoint),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    // Handle token expiration
    if (response.statusCode == 401) {
      final newToken = await authService.refreshToken();
      if (newToken != null) {
        // Retry with new token
        response = await http.get(
          Uri.parse(endpoint),
          headers: {'Authorization': 'Bearer $newToken'},
        );
      } else {
        // Redirect to login
        authService.logout();
      }
    }
    
    return response;
  }
}
```

### Authentication State

**Handle authentication state securely:**
- Verify tokens server-side
- Don't trust client-side authentication state alone
- Implement proper session management
- Handle biometric authentication securely

## Network Security

### HTTPS Only

**Always use HTTPS for network requests:**

```dart
// Good: HTTPS
final response = await http.get(Uri.parse('https://api.example.com/data'));

// Bad: HTTP (never use in production)
// final response = await http.get(Uri.parse('http://api.example.com/data'));
```

### Certificate Pinning

**For high-security apps, implement certificate pinning:**

```dart
import 'package:dio/dio.dart';
import 'package:dio_certificate_pinning/dio_certificate_pinning.dart';

final dio = Dio()
  ..interceptors.add(
    CertificatePinningInterceptor(
      allowedSHAFingerprints: [
        'SHA256:ABC123...', // Your server's certificate fingerprint
      ],
    ),
  );
```

**When to use:**
- High-security applications
- Financial applications
- Healthcare applications
- Government applications

### API Key Management

**Never hardcode API keys:**

```dart
// Bad: Hardcoded
final apiKey = 'sk_live_abc123...';

// Good: Environment variable
final apiKey = dotenv.env['API_KEY'] ?? '';
```

**Use environment files:**
- `.env.dev` - Development keys
- `.env.prod` - Production keys
- Add `.env*` to `.gitignore`
- Use `.env.example` as template

### Request/Response Validation

**Validate all inputs:**
- Sanitize user inputs
- Validate API responses
- Handle errors securely (don't expose sensitive info)

```dart
// Validate API response
try {
  final response = await apiClient.get('/user');
  if (response.statusCode == 200) {
    final user = User.fromJson(response.data);
    return user;
  } else {
    throw ApiException('Failed to fetch user');
  }
} catch (e) {
  // Log error securely (don't log sensitive data)
  logger.e('Failed to fetch user', error: e);
  throw UserNotFoundException();
}
```

## PII Handling

### Personal Identifiable Information (PII)

**PII includes:**
- Names
- Email addresses
- Phone numbers
- Physical addresses
- Dates of birth
- Government IDs
- Financial information

### PII Handling Rules

1. **Minimize Collection**: Only collect PII that's necessary
2. **Encrypt in Transit**: Always use HTTPS
3. **Encrypt at Rest**: Store PII securely
4. **Access Control**: Limit who can access PII
5. **Data Retention**: Delete PII when no longer needed
6. **User Consent**: Get explicit consent for PII collection

### Logging PII

**Never log PII:**

```dart
// Bad: Logging PII
logger.i('User logged in: ${user.email}');
logger.d('Processing payment for card: ${card.last4}');

// Good: Logging without PII
logger.i('User logged in: ${user.id}');
logger.d('Processing payment for user: ${user.id}');
```

### Data Masking

**Mask PII in logs and UI when appropriate:**

```dart
String maskEmail(String email) {
  final parts = email.split('@');
  if (parts.length != 2) return email;
  final username = parts[0];
  final domain = parts[1];
  if (username.length <= 2) return email;
  final masked = username[0] + '*' * (username.length - 2) + username[username.length - 1];
  return '$masked@$domain';
}

// Example: j***n@example.com
```

## Analytics Privacy Rules

### Data Collection

**What to Track:**
- ✅ User actions (button clicks, screen views)
- ✅ Feature usage
- ✅ Performance metrics
- ✅ Error events (without sensitive data)

**What NOT to Track:**
- ❌ Passwords or authentication tokens
- ❌ Credit card numbers
- ❌ Full names or addresses
- ❌ Exact locations (use approximate if needed)
- ❌ Health information

### User Consent

**GDPR/CCPA Compliance:**
- Get explicit consent before tracking
- Allow users to opt-out
- Provide privacy policy
- Document what data is collected

**Example:**
```dart
class AnalyticsService {
  final bool _userConsented;
  
  Future<void> trackEvent(String event, Map<String, dynamic> params) async {
    if (!_userConsented) return;
    
    // Remove any PII from params
    final sanitizedParams = _sanitizeParams(params);
    
    await analytics.logEvent(
      name: event,
      parameters: sanitizedParams,
    );
  }
  
  Map<String, dynamic> _sanitizeParams(Map<String, dynamic> params) {
    // Remove PII
    final sanitized = Map<String, dynamic>.from(params);
    sanitized.removeWhere((key, value) => _isPII(key));
    return sanitized;
  }
}
```

### Analytics Tools

**Common Tools:**
- Firebase Analytics
- Mixpanel
- Amplitude
- Custom analytics

**Rules:**
- Configure to respect user privacy settings
- Use anonymization features
- Don't track across apps without consent
- Provide opt-out mechanism

## App Store Compliance Considerations

### Privacy Policy

**Required for App Store/Play Store:**
- Clearly state what data is collected
- Explain how data is used
- Describe data sharing practices
- Provide contact information

### Privacy Labels (iOS)

**App Privacy labels must be accurate:**
- Data collection practices
- Data usage purposes
- Third-party sharing

### Play Store Data Safety (Android)

**Data Safety section must be accurate:**
- Data collection and sharing
- Security practices
- Data deletion options

### Permissions

**Request permissions appropriately:**
- Request only when needed
- Explain why permission is needed
- Handle denial gracefully
- Don't block app functionality for optional permissions

```dart
// Request permission with explanation
Future<bool> requestLocationPermission() async {
  final status = await Permission.location.request();
  
  if (status.isDenied) {
    // Show explanation
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission'),
        content: Text('We need location to show nearby services.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Permission.location.request();
            },
            child: Text('Allow'),
          ),
        ],
      ),
    );
  }
  
  return status.isGranted;
}
```

## Security Best Practices

### Code Security

1. **No Hardcoded Secrets**: Use environment variables
2. **Input Validation**: Validate all user inputs
3. **Output Encoding**: Encode data before displaying
4. **Error Handling**: Don't expose sensitive info in errors
5. **Code Obfuscation**: Use Flutter's code obfuscation for release builds

```bash
# Build with obfuscation
flutter build apk --obfuscate --split-debug-info=./debug-info
```

### Dependency Security

1. **Regular Updates**: Keep dependencies updated
2. **Security Audits**: Run `flutter pub audit` regularly
3. **Vulnerability Monitoring**: Monitor for security issues
4. **Minimal Dependencies**: Only use trusted packages

### Device Security

1. **Root/Jailbreak Detection**: Consider detecting rooted/jailbroken devices for sensitive apps
2. **Certificate Validation**: Validate SSL certificates
3. **Anti-Tampering**: Consider anti-tampering measures for high-security apps

## Incident Response

### Security Incident Process

**If security issue is discovered:**

1. **Assess Severity**: Determine impact
2. **Contain**: Prevent further damage
3. **Notify**: Inform security team and users if needed
4. **Fix**: Deploy fix quickly
5. **Monitor**: Monitor for related issues
6. **Document**: Document incident and response

### Data Breach Response

**If PII is compromised:**

1. **Immediate Containment**: Stop breach
2. **Assessment**: Determine scope
3. **Notification**: Notify affected users and authorities (if required)
4. **Remediation**: Fix vulnerability
5. **Post-Incident Review**: Learn and improve

## Compliance

### Regulations

**Be aware of:**
- **GDPR** (EU): General Data Protection Regulation
- **CCPA** (California): California Consumer Privacy Act
- **HIPAA** (US Healthcare): Health Insurance Portability and Accountability Act
- **PCI DSS** (Payment): Payment Card Industry Data Security Standard

**Consult legal team** for compliance requirements specific to your app and jurisdiction.

## Security Checklist

Before releasing:

- [ ] No hardcoded secrets or API keys
- [ ] All network traffic uses HTTPS
- [ ] Sensitive data stored securely (flutter_secure_storage)
- [ ] PII is not logged
- [ ] User consent obtained for data collection
- [ ] Privacy policy is accurate and accessible
- [ ] Permissions requested appropriately
- [ ] Dependencies are up to date
- [ ] Code is obfuscated (release builds)
- [ ] Error messages don't expose sensitive info

## References

- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Flutter Security Best Practices](https://docs.flutter.dev/development/data-and-backend/state-mgmt/options#security)
- [GDPR Compliance Guide](https://gdpr.eu/)

