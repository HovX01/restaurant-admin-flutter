# CLAUDE.md - AI Development Specification

This document provides comprehensive guidance for AI assistants working on the Restaurant Admin Flutter project.

## Project Overview

**Name**: Restaurant Admin Flutter App
**Type**: Flutter mobile application for restaurant management
**Version**: 1.0.0+1
**Architecture**: Clean Architecture with MCP (Model Context Protocol) pattern
**State Management**: Provider pattern
**Min Flutter SDK**: 3.2.0
**Min Dart SDK**: 3.0.0

### Purpose
Mobile interface for restaurant staff to manage orders, products, deliveries, and receive real-time updates via WebSocket. Supports role-based access control for ADMIN, MANAGER, KITCHEN_STAFF, and DELIVERY_STAFF.

## Project Structure

```
restaurant-admin-flutter/
├── lib/
│   ├── core/                    # Foundation layer - shared utilities
│   │   ├── config/              # API endpoints, WebSocket URLs
│   │   ├── constants/           # Enums (UserRole, OrderStatus), app constants
│   │   ├── network/             # Dio HTTP client with interceptors
│   │   ├── storage/             # Secure JWT token storage
│   │   └── utils/               # Application logger
│   │
│   ├── data/                    # Data layer - external interface
│   │   ├── models/              # JSON-serializable immutable models
│   │   │   ├── user_model.dart
│   │   │   ├── order_model.dart
│   │   │   ├── product_model.dart
│   │   │   ├── delivery_model.dart
│   │   │   └── api_response.dart
│   │   └── services/            # API service repositories
│   │       ├── auth_service.dart
│   │       ├── order_service.dart
│   │       ├── product_service.dart
│   │       └── websocket_service.dart
│   │
│   └── presentation/            # Presentation layer - UI
│       ├── providers/           # State management (ChangeNotifier)
│       │   ├── auth_provider.dart
│       │   ├── order_provider.dart
│       │   └── product_provider.dart
│       ├── screens/             # Screen widgets
│       │   ├── login_screen.dart
│       │   ├── home_screen.dart
│       │   ├── orders_screen.dart
│       │   └── products_screen.dart
│       └── theme/               # Material Design 3 theme
│           └── app_theme.dart
│
├── assets/                      # Static resources
│   ├── images/                  # App logos, icons
│   └── fonts/                   # Custom fonts (JetBrains Mono)
│
├── docs/                        # Comprehensive documentation
│   ├── api/                     # API integration guides
│   └── CI-CD-GUIDE.md          # Build and deployment guide
│
├── test/                        # Unit, widget, integration tests
├── android/                     # Android-specific configuration
├── scripts/                     # Build and release automation
├── .github/workflows/           # CI/CD pipelines
└── pubspec.yaml                # Dependencies and project metadata
```

## Architecture Principles

### Clean Architecture Layers

1. **Core Layer** (`lib/core/`)
   - Framework-agnostic foundation
   - Shared utilities, constants, configuration
   - No dependencies on other layers

2. **Data Layer** (`lib/data/`)
   - External data sources (API, WebSocket)
   - Data models with JSON serialization
   - Service repositories for API calls
   - Depends only on Core layer

3. **Presentation Layer** (`lib/presentation/`)
   - UI components and screens
   - State management with Providers
   - Depends on Data and Core layers

### Key Patterns

- **Singleton**: `ApiClient`, `SecureStorageManager`, `WebSocketService`
- **Repository**: Services act as data repositories
- **Provider (ChangeNotifier)**: State management pattern
- **Interceptor**: Request/response/error handling
- **Immutability**: All models are immutable with `copyWith` methods

## Code Conventions

### Dart Style Guidelines

```dart
// 1. Use const constructors where possible
const MyWidget({super.key});

// 2. Immutable models with Equatable
class OrderModel extends Equatable {
  final int id;
  final String status;

  const OrderModel({
    required this.id,
    required this.status,
  });

  OrderModel copyWith({int? id, String? status}) {
    return OrderModel(
      id: id ?? this.id,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, status];
}

// 3. Use named parameters for clarity
void updateOrder({required int orderId, required String status}) {
  // Implementation
}

// 4. Comprehensive error handling
try {
  final response = await apiClient.get('/endpoint');
  return Right(response.data);
} catch (e) {
  AppLogger.error('Error message', error: e);
  return Left(ApiException(message: e.toString()));
}

// 5. Logging at appropriate levels
AppLogger.debug('Debug information');
AppLogger.info('Informational message');
AppLogger.warning('Warning message');
AppLogger.error('Error occurred', error: exception);
```

### File Naming

- **Snake_case**: All Dart files (`order_provider.dart`, `user_model.dart`)
- **PascalCase**: Class names (`OrderProvider`, `UserModel`)
- **camelCase**: Variables, methods, parameters
- **SCREAMING_SNAKE_CASE**: Constants (`const String API_BASE_URL`)

### Model Conventions

```dart
// Models must:
// 1. Extend Equatable for value equality
// 2. Have const constructor
// 3. Use @JsonSerializable() for code generation
// 4. Implement fromJson factory
// 5. Implement toJson method
// 6. Include copyWith method

@JsonSerializable()
class UserModel extends Equatable {
  final int id;
  final String username;
  final String email;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    UserRole? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [id, username, email, role];
}
```

### Provider Conventions

```dart
// Providers must:
// 1. Extend ChangeNotifier
// 2. Initialize dependencies in constructor
// 3. Dispose resources in @override dispose()
// 4. Call notifyListeners() after state changes
// 5. Handle loading/error states
// 6. Provide clear method names

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  OrderProvider(this._orderService);

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderService.getOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Cleanup resources
    super.dispose();
  }
}
```

## State Management

### Provider Pattern

**Setup** (in `main.dart`):
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider(...)),
    ChangeNotifierProvider(create: (_) => OrderProvider(...)),
    ChangeNotifierProvider(create: (_) => ProductProvider(...)),
  ],
  child: MyApp(),
)
```

**Usage in Widgets**:
```dart
// 1. Watch for changes (rebuilds on state change)
final orders = context.watch<OrderProvider>().orders;

// 2. Read once (no rebuild)
final provider = context.read<OrderProvider>();
provider.fetchOrders();

// 3. Select specific property (efficient rebuilds)
final isLoading = context.select<OrderProvider, bool>(
  (provider) => provider.isLoading
);
```

### State Flow

```
User Action (Button Tap)
    ↓
Provider Method Called
    ↓
Service API Call
    ↓
HTTP Request (via Dio)
    ↓
Interceptors (Auth, Logging, Error)
    ↓
Response Received
    ↓
Parse to Model
    ↓
Update Provider State
    ↓
notifyListeners()
    ↓
UI Rebuilds Automatically
```

## API Integration

### Backend Configuration

```dart
// lib/core/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8080/api';  // Android emulator
  static const String wsUrl = 'ws://10.0.2.2:8080/ws';        // WebSocket
  static const Duration timeout = Duration(seconds: 30);
}
```

**Note**: Use `10.0.2.2` for Android emulator, `localhost` for iOS simulator, or actual IP for physical devices.

### Authentication Flow

1. User logs in via `AuthService.login()`
2. JWT token received in response
3. Token stored in `SecureStorageManager`
4. `AuthInterceptor` adds token to all subsequent requests
5. Token automatically validated on app startup
6. Logout clears token and disconnects WebSocket

### WebSocket Integration

**Connection**:
```dart
// Automatically connected in AuthProvider after login
final webSocketService = WebSocketService.instance;
webSocketService.connect(token: jwtToken, userRole: userRole);
```

**Subscriptions** (role-based):
- `/topic/notifications` - All users
- `/topic/kitchen` - KITCHEN_STAFF, ADMIN
- `/topic/delivery-staff` - DELIVERY_STAFF, ADMIN
- `/topic/system` - ADMIN only

**Message Handling**:
```dart
webSocketService.messageStream.listen((message) {
  // Handle real-time updates
  AppLogger.info('WebSocket message: $message');
  // Update provider state
  notifyListeners();
});
```

### Error Handling

```dart
// All services should return Either<ApiException, T> from dartz
Future<Either<ApiException, List<OrderModel>>> getOrders() async {
  try {
    final response = await _apiClient.get('/orders');
    final orders = (response.data as List)
        .map((json) => OrderModel.fromJson(json))
        .toList();
    return Right(orders);
  } on DioException catch (e) {
    AppLogger.error('Failed to fetch orders', error: e);
    return Left(ApiException(
      message: e.response?.data['message'] ?? 'Network error',
      statusCode: e.response?.statusCode,
    ));
  } catch (e) {
    AppLogger.error('Unexpected error fetching orders', error: e);
    return Left(ApiException(message: e.toString()));
  }
}
```

## Development Workflow

### Initial Setup

```bash
# 1. Clone repository
git clone <repository-url>
cd restaurant-admin-flutter

# 2. Install dependencies
flutter pub get

# 3. Generate code (models, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run on device/emulator
flutter run

# 5. Run tests
flutter test

# 6. Analyze code
flutter analyze
```

### Code Generation

**When to run**:
- After adding/modifying `@JsonSerializable()` models
- After changing models with `json_annotation`
- If you see errors about missing `.g.dart` files

**Commands**:
```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Adding New Features

#### 1. Adding a New Model

```bash
# Create model file: lib/data/models/new_model.dart
```

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'new_model.g.dart';

@JsonSerializable()
class NewModel extends Equatable {
  final int id;
  final String name;

  const NewModel({
    required this.id,
    required this.name,
  });

  factory NewModel.fromJson(Map<String, dynamic> json) =>
      _$NewModelFromJson(json);

  Map<String, dynamic> toJson() => _$NewModelToJson(this);

  NewModel copyWith({int? id, String? name}) {
    return NewModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [id, name];
}
```

```bash
# Generate code
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 2. Adding a New Service

```dart
// lib/data/services/new_service.dart
import 'package:dartz/dartz.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/new_model.dart';

class NewService {
  final ApiClient _apiClient;

  NewService(this._apiClient);

  Future<Either<ApiException, List<NewModel>>> getItems() async {
    try {
      final response = await _apiClient.get('/items');
      final items = (response.data as List)
          .map((json) => NewModel.fromJson(json))
          .toList();
      return Right(items);
    } on DioException catch (e) {
      return Left(ApiException(
        message: e.response?.data['message'] ?? 'Failed to fetch items',
        statusCode: e.response?.statusCode,
      ));
    }
  }
}
```

#### 3. Adding a New Provider

```dart
// lib/presentation/providers/new_provider.dart
import 'package:flutter/foundation.dart';
import '../../data/models/new_model.dart';
import '../../data/services/new_service.dart';

class NewProvider extends ChangeNotifier {
  final NewService _service;

  List<NewModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NewModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  NewProvider(this._service);

  Future<void> fetchItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _service.getItems();
    result.fold(
      (error) {
        _errorMessage = error.message;
        _isLoading = false;
        notifyListeners();
      },
      (items) {
        _items = items;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
```

#### 4. Adding a New Screen

```dart
// lib/presentation/screens/new_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/new_provider.dart';

class NewScreen extends StatefulWidget {
  const NewScreen({super.key});

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewProvider>().fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Screen')),
      body: Consumer<NewProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          return ListView.builder(
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final item = provider.items[index];
              return ListTile(title: Text(item.name));
            },
          );
        },
      ),
    );
  }
}
```

### Testing

#### Unit Tests

```dart
// test/models/new_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_admin/data/models/new_model.dart';

void main() {
  group('NewModel', () {
    test('fromJson creates valid model', () {
      final json = {'id': 1, 'name': 'Test'};
      final model = NewModel.fromJson(json);

      expect(model.id, 1);
      expect(model.name, 'Test');
    });

    test('toJson returns valid map', () {
      const model = NewModel(id: 1, name: 'Test');
      final json = model.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Test');
    });

    test('copyWith creates new instance with updated values', () {
      const model = NewModel(id: 1, name: 'Test');
      final updated = model.copyWith(name: 'Updated');

      expect(updated.id, 1);
      expect(updated.name, 'Updated');
    });

    test('equality works correctly', () {
      const model1 = NewModel(id: 1, name: 'Test');
      const model2 = NewModel(id: 1, name: 'Test');
      const model3 = NewModel(id: 2, name: 'Test');

      expect(model1, model2);
      expect(model1, isNot(model3));
    });
  });
}
```

#### Widget Tests

```dart
// test/screens/new_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_admin/presentation/screens/new_screen.dart';
import 'package:restaurant_admin/presentation/providers/new_provider.dart';

void main() {
  testWidgets('NewScreen displays loading indicator', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => NewProvider(mockService),
          child: const NewScreen(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

**Run tests**:
```bash
flutter test                    # Run all tests
flutter test test/models/       # Run specific directory
flutter test --coverage         # Generate coverage report
```

## Build and Deployment

### Debug Build

```bash
# Android APK
flutter build apk --debug

# iOS (requires macOS)
flutter build ios --debug
```

### Release Build

```bash
# Android APK (single)
flutter build apk --release

# Android APK (split by ABI - smaller size)
flutter build apk --release --split-per-abi

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release
```

### CI/CD

The project has two GitHub Actions workflows:

1. **Build APK** (`.github/workflows/build-apk.yml`)
   - Triggers: Push to main/develop/claude/*, Pull Requests
   - Steps: Setup → Dependencies → Analyze → Test → Build APK
   - Output: Artifacts uploaded (30-day retention)

2. **Build Release** (`.github/workflows/build-release.yml`)
   - Triggers: Version tags (v*.*.*), Manual dispatch
   - Builds: Split APKs (arm64, armeabi, x86_64) + App Bundle
   - Output: GitHub Release with all artifacts (90-day retention)

**Creating a release**:
```bash
# Update version in pubspec.yaml
version: 1.1.0+2  # version+build_number

# Commit changes
git add pubspec.yaml
git commit -m "chore: Bump version to 1.1.0"

# Create and push tag
git tag v1.1.0
git push origin v1.1.0
```

## Important Files Reference

| File | Purpose | When to Modify |
|------|---------|----------------|
| `pubspec.yaml` | Dependencies, assets, metadata | Adding packages, assets, updating version |
| `analysis_options.yaml` | Linting rules, analyzer config | Changing code quality rules |
| `lib/main.dart` | App entry point, provider setup | Adding global providers, themes |
| `lib/core/config/api_config.dart` | API endpoints, URLs | Backend URL changes |
| `lib/core/constants/app_constants.dart` | App-wide constants | Adding new constants |
| `lib/presentation/theme/app_theme.dart` | Material Design 3 theme | UI/UX design changes |
| `android/app/build.gradle` | Android build configuration | Min SDK, permissions, signing |
| `.github/workflows/*.yml` | CI/CD pipelines | Build/test process changes |

## Common Tasks

### Update API Endpoint

1. Open `lib/core/config/api_config.dart`
2. Update `baseUrl` or `wsUrl`
3. Restart app (hot restart won't work for config changes)

### Add New Dependency

```bash
# Add to pubspec.yaml or use command
flutter pub add package_name

# For dev dependencies
flutter pub add --dev package_name

# Get dependencies
flutter pub get
```

### Fix Analysis Warnings

```bash
# Run analyzer
flutter analyze

# Common fixes:
# - Add const to constructors
# - Use prefer_const_literals_to_create_immutables
# - Add @override annotations
# - Remove unused imports
```

### Clear Cache and Rebuild

```bash
# Clean build artifacts
flutter clean

# Get dependencies
flutter pub get

# Regenerate code
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```

## Troubleshooting

### Code Generation Issues

**Problem**: Missing `.g.dart` files
**Solution**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Problem**: Conflicting outputs
**Solution**: Use `--delete-conflicting-outputs` flag

### WebSocket Connection Issues

**Problem**: WebSocket not connecting on Android emulator
**Solution**: Use `10.0.2.2` instead of `localhost`

**Problem**: Connection drops frequently
**Solution**: Check heartbeat settings in `WebSocketService`

### Provider State Not Updating

**Problem**: UI not rebuilding after state change
**Solution**:
- Ensure `notifyListeners()` is called after state updates
- Use `context.watch<Provider>()` in build method
- Check if provider is properly registered in `MultiProvider`

### JWT Token Issues

**Problem**: 401 Unauthorized errors
**Solution**:
- Check token expiration (24 hours)
- Verify `AuthInterceptor` is adding token
- Clear token and re-login

### Build Errors

**Problem**: Gradle build fails
**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

## Security Best Practices

### ✅ DO

- Store JWT tokens in `flutter_secure_storage`
- Validate token expiration before API calls
- Use HTTPS in production (not HTTP)
- Sanitize user inputs before API calls
- Log errors without exposing sensitive data
- Clear tokens on logout
- Handle 401/403 responses properly

### ❌ DON'T

- Store tokens in SharedPreferences
- Hardcode credentials in source code
- Log JWT tokens or passwords
- Skip SSL certificate validation
- Trust user input without validation
- Leave debug prints in production code

## Testing Accounts

For backend testing (provided by backend team):

| Username | Password | Role |
|----------|----------|------|
| admin | password123 | ADMIN |
| manager | password123 | MANAGER |
| kitchen | password123 | KITCHEN_STAFF |
| driver | password123 | DELIVERY_STAFF |

**Note**: These are for development only. Never use in production.

## Documentation Resources

- **Main README**: `/README.md` - Project overview
- **API Integration**: `/docs/api/README.md` - Mobile app guide
- **API Reference**: `/docs/api/API-Reference.md` - All endpoints
- **Authentication**: `/docs/api/Authentication.md` - JWT details
- **WebSocket**: `/docs/api/WebSocket-Integration.md` - Real-time features
- **CI/CD**: `/docs/CI-CD-GUIDE.md` - Build automation
- **Data Models**: `/docs/api/Data-Models.md` - Entity schemas
- **Use Cases**: `/docs/api/Use-Case-Examples.md` - Workflows

## AI Development Guidelines

### When Working on This Project

1. **Always** run `flutter analyze` before committing
2. **Always** run tests with `flutter test` to ensure nothing breaks
3. **Always** regenerate code after modifying models
4. **Prefer** editing existing files over creating new ones
5. **Follow** the Clean Architecture layers strictly
6. **Use** Provider pattern for state management
7. **Implement** comprehensive error handling with Either/dartz
8. **Add** logging for debugging (use `AppLogger`)
9. **Write** tests for new features
10. **Update** documentation when adding features

### Code Review Checklist

Before committing code, verify:

- [ ] Code follows Dart style guidelines
- [ ] No analyzer warnings (`flutter analyze`)
- [ ] All tests pass (`flutter test`)
- [ ] Models use `json_serializable` and `Equatable`
- [ ] Providers call `notifyListeners()` after state changes
- [ ] Services return `Either<ApiException, T>`
- [ ] Errors are logged with `AppLogger`
- [ ] No hardcoded strings (use constants)
- [ ] No sensitive data in logs
- [ ] UI is responsive and follows Material Design 3
- [ ] WebSocket cleanup in provider `dispose()`
- [ ] API calls have timeout handling
- [ ] Loading and error states are handled in UI

### Git Workflow

```bash
# 1. Create feature branch
git checkout -b claude/feature-name-<session-id>

# 2. Make changes, commit frequently
git add .
git commit -m "feat: Add feature description"

# 3. Before pushing, ensure quality
flutter analyze
flutter test

# 4. Push to remote
git push -u origin claude/feature-name-<session-id>

# 5. Create pull request (via GitHub UI)
```

**Commit Message Format**:
- `feat:` New feature
- `fix:` Bug fix
- `refactor:` Code refactoring
- `docs:` Documentation updates
- `test:` Test additions/modifications
- `chore:` Maintenance tasks
- `style:` Code style changes (formatting)

## Performance Optimization

### Best Practices

1. **Use `const` constructors** where possible to avoid rebuilds
2. **Implement `Equatable`** for proper equality checks
3. **Use `ListView.builder`** for long lists (lazy loading)
4. **Dispose resources** in provider `dispose()` methods
5. **Use `context.select`** for granular rebuilds
6. **Cache network responses** where appropriate
7. **Implement pagination** for large datasets
8. **Debounce search inputs** to reduce API calls
9. **Use `RepaintBoundary`** for complex widgets
10. **Profile with DevTools** to identify bottlenecks

## Conclusion

This document serves as the definitive guide for AI assistants working on the Restaurant Admin Flutter project. Follow these conventions and patterns strictly to maintain code quality, consistency, and maintainability.

For questions or clarifications, refer to the comprehensive documentation in `/docs/` or consult the project README.

**Last Updated**: 2025-11-14
**Version**: 1.0.0
