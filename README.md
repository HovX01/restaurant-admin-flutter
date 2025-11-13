# Restaurant Admin Flutter App

A modern Flutter mobile application for restaurant management following MCP (Model Context Protocol) pattern with clean architecture principles and Material Design 3.

## 📱 Overview

This Flutter app integrates with the Restaurant Admin System backend API, providing a comprehensive mobile interface for managing restaurant operations including orders, products, deliveries, and more.

### Key Features

- ✅ **JWT Authentication** with secure token storage
- ✅ **Real-time Updates** via WebSocket (STOMP protocol)
- ✅ **Role-based Access Control** (Admin, Manager, Kitchen Staff, Delivery Staff)
- ✅ **Modern Material Design 3** UI
- ✅ **Clean Architecture** with MCP pattern
- ✅ **State Management** using Provider
- ✅ **Secure Storage** for sensitive data
- ✅ **Offline-ready** architecture
- ✅ **Type-safe** API integration

## 🏗️ Architecture

### MCP (Model Context Protocol) Pattern

This app follows the MCP pattern with clean architecture:

```
lib/
├── core/                          # Core functionality
│   ├── config/                    # Configuration (API endpoints, URLs)
│   ├── constants/                 # App-wide constants and enums
│   ├── network/                   # Network layer (Dio client, interceptors)
│   ├── storage/                   # Secure storage (JWT tokens, preferences)
│   └── utils/                     # Utility classes (Logger, helpers)
│
├── data/                          # Data layer
│   ├── models/                    # Data models (JSON serialization)
│   │   ├── api_response.dart      # Generic API response wrapper
│   │   ├── user_model.dart        # User & authentication models
│   │   ├── order_model.dart       # Order & order item models
│   │   ├── product_model.dart     # Product & category models
│   │   └── delivery_model.dart    # Delivery models
│   │
│   └── services/                  # API services
│       ├── auth_service.dart      # Authentication API calls
│       ├── order_service.dart     # Order management API calls
│       ├── product_service.dart   # Product & category API calls
│       └── websocket_service.dart # Real-time WebSocket service
│
└── presentation/                  # Presentation layer
    ├── providers/                 # State management (Provider)
    │   ├── auth_provider.dart     # Authentication state
    │   ├── order_provider.dart    # Order management state
    │   └── product_provider.dart  # Product catalog state
    │
    ├── screens/                   # UI screens
    │   ├── login_screen.dart      # Login interface
    │   ├── home_screen.dart       # Main navigation
    │   ├── orders_screen.dart     # Orders list
    │   └── products_screen.dart   # Products catalog
    │
    ├── widgets/                   # Reusable widgets
    │
    └── theme/                     # App theming
        └── app_theme.dart         # Material Design 3 theme
```

### Architecture Layers

1. **Core Layer**: Foundation services (network, storage, config)
2. **Data Layer**: API communication and data models
3. **Presentation Layer**: UI components and state management

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.2.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode (for mobile development)
- Restaurant Admin Backend running (default: `http://localhost:8080`)

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd restaurant-admin-flutter
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate JSON serialization code**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Configure API endpoint** (if needed)

Edit `lib/core/config/api_config.dart`:
```dart
static const String baseUrl = 'http://YOUR_API_URL:8080/api';
static const String wsUrl = 'ws://YOUR_API_URL:8080/ws';
```

**Important**: For Android emulator, use `10.0.2.2` instead of `localhost` to access host machine.

5. **Run the app**
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

## 🔐 Authentication

### Test Accounts

The app comes with pre-configured test accounts:

| Username | Password     | Role           | Access Level                          |
|----------|--------------|----------------|---------------------------------------|
| admin    | password123  | ADMIN          | Full system access                    |
| manager  | password123  | MANAGER        | Order & product management            |
| kitchen  | password123  | KITCHEN_STAFF  | Kitchen operations & order status     |
| driver   | password123  | DELIVERY_STAFF | Delivery tracking & status updates    |

### Security Features

- **JWT Token Storage**: Secure storage using platform-specific encryption
  - iOS: Keychain Services
  - Android: EncryptedSharedPreferences
- **Token Expiration**: Automatic detection and logout on expired tokens (24h)
- **Automatic Refresh**: Checks token validity on app startup
- **Secure Communication**: HTTPS support for production

## 📦 Dependencies

### Core Dependencies

```yaml
# State Management
provider: ^6.1.1

# HTTP & Networking
dio: ^5.4.0

# WebSocket
stomp_dart_client: ^1.0.0
web_socket_channel: ^2.4.0

# Secure Storage
flutter_secure_storage: ^9.0.0
shared_preferences: ^2.2.2

# UI & Design
google_fonts: ^6.1.0
cached_network_image: ^3.3.1

# Utilities
dartz: ^0.10.1          # Functional programming
equatable: ^2.0.5       # Value equality
intl: ^0.19.0          # Internationalization
logger: ^2.0.2          # Logging
```

## 🎨 UI/UX Features

### Material Design 3

- Modern, clean interface following Material You guidelines
- Adaptive color schemes (light/dark theme support)
- Smooth animations and transitions
- Responsive layouts for different screen sizes

### Key Screens

1. **Login Screen**: Simple, intuitive authentication interface
2. **Home Screen**: Bottom navigation with Orders, Products, and Profile
3. **Orders Screen**: Real-time order tracking with status indicators
4. **Products Screen**: Grid view of available products
5. **Profile Screen**: User information and settings

## 🔄 Real-time Features

### WebSocket Integration

The app uses STOMP over WebSocket for real-time updates:

- **Automatic Connection**: Connects on successful login
- **Role-based Topics**: Subscribes based on user role
  - `/topic/notifications` - General notifications
  - `/topic/kitchen` - Kitchen-specific updates (KITCHEN_STAFF, ADMIN)
  - `/topic/delivery-staff` - Delivery updates (DELIVERY_STAFF)
  - `/topic/system` - System alerts (ADMIN)
- **Reconnection Logic**: Automatic reconnection on connection loss
- **Heartbeat**: Keeps connection alive

### Live Updates

- New orders appear instantly in the orders list
- Order status changes reflect immediately
- Product availability updates in real-time

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Manual Testing

1. **Test Authentication**
   - Login with different roles
   - Verify token persistence
   - Test logout functionality

2. **Test Orders**
   - View orders list
   - Check order details
   - Verify real-time updates

3. **Test Products**
   - Browse products
   - Filter by category
   - Check product details

## 📱 Platform-Specific Configuration

### Android

**Minimum SDK**: 24 (Android 7.0)
**Target SDK**: 34

**Required Permissions** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

**Network Security** (for development with HTTP):
Create `android/app/src/main/res/xml/network_security_config.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
    </domain-config>
</network-security-config>
```

### iOS

**Minimum Deployment Target**: iOS 12.0

**App Transport Security** (for development with HTTP):
Edit `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 🔧 Development

### Code Generation

When modifying models with `json_serializable`:

```bash
# Watch for changes and auto-generate
flutter pub run build_runner watch

# One-time generation
flutter pub run build_runner build
```

### Best Practices

- ✅ Follow clean architecture principles
- ✅ Keep business logic in providers
- ✅ Use const constructors where possible
- ✅ Implement proper error handling
- ✅ Log important events and errors
- ✅ Write widget tests for UI components
- ✅ Document complex logic

## 📚 API Documentation

For complete API documentation, refer to:
- [`docs/api/README.md`](docs/api/README.md) - Mobile integration guide
- [`docs/api/API-Reference.md`](docs/api/API-Reference.md) - Complete API endpoints
- [`docs/api/Authentication.md`](docs/api/Authentication.md) - Authentication details
- [`docs/api/Platform-Guides.md`](docs/api/Platform-Guides.md) - Platform-specific guides
- [`docs/api/WebSocket-Integration.md`](docs/api/WebSocket-Integration.md) - Real-time features

## 🐛 Troubleshooting

### Common Issues

**Issue**: Cannot connect to API
- **Solution**:
  - Verify backend is running
  - For Android emulator, use `10.0.2.2` instead of `localhost`
  - Check network security config (Android)
  - Verify firewall settings

**Issue**: 401 Unauthorized errors
- **Solution**:
  - Token may be expired (login again)
  - Verify correct Authorization header format
  - Check server logs for authentication issues

**Issue**: WebSocket not connecting
- **Solution**:
  - Verify WebSocket URL format (`ws://` not `http://`)
  - Check token validity
  - Ensure network connectivity
  - Review server logs

**Issue**: Build errors after adding dependencies
- **Solution**:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🚢 Production Deployment

### Pre-deployment Checklist

- [ ] Change API URLs to production endpoints
- [ ] Remove debug logging
- [ ] Enable HTTPS/WSS (not HTTP/WS)
- [ ] Implement certificate pinning
- [ ] Update app version in `pubspec.yaml`
- [ ] Test on physical devices
- [ ] Review app permissions
- [ ] Configure proper app signing

### Build for Release

**Android:**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📄 License

This project is part of the Restaurant Admin System.

## 👥 Contributing

1. Follow the established architecture
2. Write meaningful commit messages
3. Update documentation as needed
4. Test thoroughly before submitting

## 📞 Support

For issues or questions:
- Check the [API documentation](docs/api/README.md)
- Review troubleshooting section
- Contact the development team

---

**Version**: 1.0.0
**Last Updated**: 2025-11-13
**Flutter Version**: 3.2.0+
**Author**: Restaurant Admin System Team
