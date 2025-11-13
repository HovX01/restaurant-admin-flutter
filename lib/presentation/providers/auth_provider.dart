import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/secure_storage_manager.dart';
import '../../core/utils/logger.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/websocket_service.dart';

/// Authentication provider using Provider pattern
/// Manages authentication state and user session
class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final SecureStorageManager _storage;
  final WebSocketService _webSocketService;

  AuthProvider({
    AuthService? authService,
    SecureStorageManager? storage,
    WebSocketService? webSocketService,
  })  : _authService = authService ?? AuthService(),
        _storage = storage ?? SecureStorageManager(),
        _webSocketService = webSocketService ?? WebSocketService();

  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Check authentication status on app start
  Future<void> checkAuthentication() async {
    try {
      _setLoading(true);

      // Check if token exists and is not expired
      final hasToken = await _storage.hasToken();
      if (!hasToken) {
        _setAuthenticated(false);
        return;
      }

      final isExpired = await _storage.isTokenExpired();
      if (isExpired) {
        AppLogger.warning('Token expired, logging out');
        await logout();
        return;
      }

      // Verify token with API
      final user = await _authService.getUserInfo();
      _setCurrentUser(user);
      _setAuthenticated(true);

      // Connect WebSocket for real-time updates
      await _connectWebSocket();

      AppLogger.info('Authentication verified: ${user.username}');
    } on ApiException catch (e) {
      AppLogger.error('Authentication check failed', e);
      await logout();
    } catch (e, stackTrace) {
      AppLogger.error('Authentication check error', e, stackTrace);
      await logout();
    } finally {
      _setLoading(false);
    }
  }

  /// Login with username and password
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      AppLogger.info('Attempting login: $username');

      // Call login API
      final loginData = await _authService.login(username, password);

      // Save token securely
      await _storage.saveToken(loginData.token);
      await _storage.saveUserId(loginData.user.id);

      // Update state
      _setCurrentUser(loginData.user);
      _setAuthenticated(true);

      // Connect WebSocket
      await _connectWebSocket();

      AppLogger.info('Login successful: ${loginData.user.username}');
      return true;
    } on ApiException catch (e) {
      AppLogger.error('Login failed', e);
      _setError(e.message);
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Login error', e, stackTrace);
      _setError('An unexpected error occurred during login');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout and clear all data
  Future<void> logout() async {
    try {
      AppLogger.info('Logging out');

      // Disconnect WebSocket
      _webSocketService.disconnect();

      // Clear secure storage
      await _storage.clearAll();

      // Clear state
      _currentUser = null;
      _setAuthenticated(false);
      _clearError();

      AppLogger.info('Logout successful');
    } catch (e, stackTrace) {
      AppLogger.error('Logout error', e, stackTrace);
    }
  }

  /// Register new user
  Future<bool> register({
    required String username,
    required String password,
    String? email,
    String? fullName,
    required String role,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final request = RegisterRequest(
        username: username,
        password: password,
        email: email,
        fullName: fullName,
        role: role,
      );

      await _authService.register(request);
      AppLogger.info('Registration successful');

      // Automatically login after registration
      return await login(username: username, password: password);
    } on ApiException catch (e) {
      AppLogger.error('Registration failed', e);
      _setError(e.message);
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Registration error', e, stackTrace);
      _setError('An unexpected error occurred during registration');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      await _authService.changePassword(request);
      AppLogger.info('Password changed successfully');
      return true;
    } on ApiException catch (e) {
      AppLogger.error('Failed to change password', e);
      _setError(e.message);
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Change password error', e, stackTrace);
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Connect WebSocket based on user role
  Future<void> _connectWebSocket() async {
    if (_currentUser == null) return;

    try {
      await _webSocketService.connect();

      // Subscribe to role-specific topics
      switch (_currentUser!.role) {
        case UserRole.kitchenStaff:
          _webSocketService.subscribeToKitchen();
          break;
        case UserRole.deliveryStaff:
          _webSocketService.subscribeToDeliveryStaff();
          break;
        case UserRole.admin:
          _webSocketService.subscribeToSystem();
          _webSocketService.subscribeToKitchen();
          break;
        case UserRole.manager:
          _webSocketService.subscribeToKitchen();
          break;
      }

      AppLogger.info('WebSocket connected for role: ${_currentUser!.role}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to connect WebSocket', e, stackTrace);
    }
  }

  // Private helper methods
  void _setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void _setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }
}
