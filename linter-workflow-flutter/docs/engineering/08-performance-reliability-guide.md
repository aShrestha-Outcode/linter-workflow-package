# Performance & Reliability Guide

This document outlines performance expectations, optimization strategies, and reliability practices.

## Performance Expectations

### Target Metrics

**Startup Time:**
- Cold start: < 3 seconds
- Warm start: < 1 second
- Hot restart: < 500ms

**Frame Rate:**
- Target: 60 FPS (120 FPS on supported devices)
- Frame budget: 16.67ms per frame (60 FPS)
- Minimum: 50 FPS (acceptable for complex screens)

**Memory Usage:**
- Initial memory: < 100MB
- Peak memory: < 300MB (device dependent)
- Memory leaks: Zero tolerance

**Network Performance:**
- API response time: < 2 seconds (target), < 5 seconds (acceptable)
- Image loading: Progressive loading, caching
- Data sync: Efficient, incremental updates

### Measuring Performance

**Tools:**
- Flutter DevTools (Performance tab)
- Performance overlay (`flutter run --profile`)
- Firebase Performance Monitoring
- Custom metrics

**Key Metrics to Monitor:**
- Frame rendering time
- Memory usage
- Network request duration
- App startup time
- Battery usage

## Startup Time and Frame Budget

### Startup Optimization

**Minimize Initial Work:**

```dart
// Bad: Heavy work in main()
void main() {
  final heavyData = loadLargeDataset(); // Blocks startup
  runApp(MyApp(data: heavyData));
}

// Good: Defer heavy work
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(), // Lightweight initial screen
      // Load heavy data asynchronously after app starts
    );
  }
}
```

**Optimization Strategies:**

1. **Lazy Loading**: Load data only when needed
2. **Defer Initialization**: Move non-critical initialization after app start
3. **Pre-warm Cache**: Cache critical data during splash
4. **Minimize Dependencies**: Only import what's needed initially

### Frame Budget

**16.67ms per frame (60 FPS):**

```dart
// Monitor frame rendering time
void main() {
  // Enable performance overlay
  runApp(
    MaterialApp(
      showPerformanceOverlay: true, // In debug mode
      home: MyApp(),
    ),
  );
}
```

**Common Frame Budget Violations:**

1. **Heavy Build Methods:**
   ```dart
   // Bad: Complex computation in build()
   Widget build(BuildContext context) {
     final processedData = complexProcessing(largeDataset); // Takes 50ms
     return Widget(processedData);
   }
   
   // Good: Pre-compute or use FutureBuilder
   Widget build(BuildContext context) {
     return FutureBuilder(
       future: compute(complexProcessing, largeDataset),
       builder: (context, snapshot) => Widget(snapshot.data),
     );
   }
   ```

2. **Unnecessary Rebuilds:**
   ```dart
   // Bad: Entire widget tree rebuilds
   class MyWidget extends StatelessWidget {
     Widget build(BuildContext context) {
       return Column(
         children: [
           ExpensiveWidget(),
           Text(context.select((SomeBloc bloc) => bloc.state.value)), // Rebuilds everything
         ],
       );
     }
   }
   
   // Good: Rebuild only what's needed
   class MyWidget extends StatelessWidget {
     Widget build(BuildContext context) {
       return Column(
         children: [
           ExpensiveWidget(), // Const widget doesn't rebuild
           Consumer<SomeState>(
             builder: (context, state, child) => Text(state.value),
           ),
         ],
       );
     }
   }
   ```

3. **Synchronous I/O:**
   ```dart
   // Bad: Blocks UI thread
   Widget build(BuildContext context) {
     final data = File('large.json').readAsStringSync(); // Blocks!
     return Widget(data);
   }
   
   // Good: Async I/O
   Widget build(BuildContext context) {
     return FutureBuilder(
       future: File('large.json').readAsString(),
       builder: (context, snapshot) => Widget(snapshot.data),
     );
   }
   ```

## Network Efficiency

### Request Optimization

**Minimize Requests:**
- Batch requests when possible
- Use pagination for lists
- Implement request debouncing
- Cache responses appropriately

**Request Size:**
- Send only necessary data
- Use compression (gzip)
- Optimize payload structure

```dart
// Good: Efficient API usage
class ApiClient {
  Future<List<User>> getUsers({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await http.get(
      Uri.parse('/users?page=$page&limit=$limit'),
      headers: {'Accept-Encoding': 'gzip'},
    );
    return parseUsers(response.body);
  }
}
```

### Caching Strategy

**Multi-Level Caching:**

1. **Memory Cache** (Fast, limited size)
   - Hot data
   - Frequently accessed data
   - Expires quickly

2. **Disk Cache** (Slower, larger size)
   - Less frequently accessed data
   - Persists across app restarts
   - Longer expiration

3. **Network Cache** (HTTP cache headers)
   - Respect cache headers
   - Use ETags for validation

**Example:**
```dart
class CachedRepository {
  final Map<String, CachedData> _memoryCache = {};
  final SharedPreferences _diskCache;
  
  Future<Data> getData(String key) async {
    // Check memory cache
    if (_memoryCache.containsKey(key) && !_memoryCache[key]!.isExpired) {
      return _memoryCache[key]!.data;
    }
    
    // Check disk cache
    final diskData = await _diskCache.getString(key);
    if (diskData != null) {
      final data = Data.fromJson(jsonDecode(diskData));
      _memoryCache[key] = CachedData(data, DateTime.now());
      return data;
    }
    
    // Fetch from network
    final data = await _fetchFromNetwork(key);
    
    // Update caches
    _memoryCache[key] = CachedData(data, DateTime.now());
    await _diskCache.setString(key, jsonEncode(data.toJson()));
    
    return data;
  }
}
```

### Image Optimization

**Best Practices:**

1. **Use Appropriate Image Sizes:**
   ```dart
   // Good: Resize images before loading
   Image.network(
     imageUrl,
     width: 200,
     height: 200,
     fit: BoxFit.cover,
   )
   ```

2. **Lazy Loading:**
   ```dart
   // Use ListView.builder for lazy loading
   ListView.builder(
     itemCount: images.length,
     itemBuilder: (context, index) {
       return Image.network(images[index]);
     },
   )
   ```

3. **Caching:**
   ```dart
   // Use cached_network_image
   CachedNetworkImage(
     imageUrl: imageUrl,
     placeholder: (context, url) => CircularProgressIndicator(),
     errorWidget: (context, url, error) => Icon(Icons.error),
   )
   ```

## Caching Strategy

### Cache Invalidation

**Strategies:**

1. **Time-Based**: Expire after time period
2. **Event-Based**: Invalidate on specific events
3. **Version-Based**: Invalidate when data version changes
4. **Manual**: Clear cache explicitly

**Example:**
```dart
class CacheManager {
  final Map<String, CacheEntry> _cache = {};
  
  Future<T?> get<T>(String key) async {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      return null;
    }
    return entry.data as T;
  }
  
  void invalidate(String key) {
    _cache.remove(key);
  }
  
  void invalidateAll() {
    _cache.clear();
  }
  
  void invalidateMatching(RegExp pattern) {
    _cache.removeWhere((key, value) => pattern.hasMatch(key));
  }
}
```

### Cache Warming

**Pre-load Critical Data:**

```dart
class AppInitializer {
  Future<void> initialize() async {
    // Pre-load critical data during splash
    await Future.wait([
      cacheManager.warmUp('user_profile'),
      cacheManager.warmUp('app_config'),
      cacheManager.warmUp('feature_flags'),
    ]);
  }
}
```

## Crash Monitoring and SLIs

### Crash Monitoring

**Tools:**
- Firebase Crashlytics (recommended)
- Sentry
- Custom crash reporting

**Setup:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize crash reporting
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  
  // Catch Flutter framework errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  
  // Catch async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
    return true;
  };
  
  runApp(MyApp());
}
```

### Service Level Indicators (SLIs)

**Key Metrics:**

1. **Availability**: Uptime percentage (target: 99.9%)
2. **Error Rate**: Percentage of failed requests (target: < 1%)
3. **Latency**: Response time (target: p95 < 2s)
4. **Crash Rate**: Crashes per session (target: < 0.1%)

**Monitoring:**
```dart
class MetricsCollector {
  static void recordApiCall(String endpoint, Duration duration, bool success) {
    analytics.logEvent(
      name: 'api_call',
      parameters: {
        'endpoint': endpoint,
        'duration_ms': duration.inMilliseconds,
        'success': success,
      },
    );
  }
  
  static void recordCrash(dynamic error, StackTrace stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
```

### Error Handling

**Graceful Degradation:**

```dart
class DataService {
  Future<Data> getData() async {
    try {
      // Try network first
      return await networkDataSource.getData();
    } catch (e) {
      // Fallback to cache
      logger.w('Network failed, using cache', error: e);
      final cachedData = await cacheDataSource.getData();
      if (cachedData != null) {
        return cachedData;
      }
      // Last resort: return empty/default data
      return Data.empty();
    }
  }
}
```

## Performance Best Practices

### ✅ Do This

1. **Use const constructors** where possible
2. **Minimize rebuilds** with proper state management
3. **Lazy load** data and images
4. **Cache** frequently accessed data
5. **Profile** before optimizing
6. **Use isolates** for heavy computation
7. **Optimize images** (compress, resize)
8. **Debounce/throttle** user inputs

### ❌ Don't Do This

1. ❌ **Don't do heavy work in build()**
2. ❌ **Don't rebuild entire widget tree unnecessarily**
3. ❌ **Don't load all data at once**
4. ❌ **Don't ignore performance warnings**
5. ❌ **Don't optimize prematurely**
6. ❌ **Don't block main thread**

## Performance Testing

### Benchmarking

**Measure Before Optimizing:**

```dart
void main() {
  benchmarkWidgets('MyWidget performance', (WidgetTester tester) async {
    await tester.pumpWidget(MyWidget());
    await tester.pumpAndSettle();
    
    // Measure frame rendering time
    final frames = tester.binding.transientCallbackCount;
    expect(frames, lessThan(60)); // Should be under 60 frames
  });
}
```

### Performance Profiles

**Regular Performance Audits:**
- Profile app monthly
- Identify performance regressions
- Track metrics over time
- Set performance budgets

## References

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter DevTools Performance](https://docs.flutter.dev/tools/devtools/performance)
- [Flutter Performance Overlay](https://api.flutter.dev/flutter/widgets/PerformanceOverlay-class.html)

