import 'package:flutter/foundation.dart';
import '../models/oauth_credentials.dart';
import '../services/oauth_service.dart';
import '../services/secure_storage_service.dart';

/// Provider for authentication state management
class AuthenticationProvider with ChangeNotifier {
  final OAuthService _oauthService;
  final SecureStorageService _storage;

  OAuthCredentials? _credentials;
  bool _isLoading = false;
  String? _error;

  AuthenticationProvider({
    required OAuthService oauthService,
    required SecureStorageService storage,
  })  : _oauthService = oauthService,
        _storage = storage {
    _initialize();
  }

  /// Current credentials
  OAuthCredentials? get credentials => _credentials;

  /// Is user authenticated
  bool get isAuthenticated => _credentials != null && !_credentials!.isExpired;

  /// Is loading state
  bool get isLoading => _isLoading;

  /// Error message
  String? get error => _error;

  /// Initialize provider and load saved credentials
  Future<void> _initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      _credentials = await _storage.getCredentials();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize authentication: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with OAuth
  Future<void> login() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _credentials = await _oauthService.login();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Logout and clear credentials
  Future<void> logout() async {
    try {
      await _oauthService.logout();
      _credentials = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed: $e';
      notifyListeners();
    }
  }

  /// Refresh access token
  Future<void> refreshToken() async {
    try {
      await _oauthService.refreshToken();
      _credentials = await _storage.getCredentials();
      notifyListeners();
    } catch (e) {
      _error = 'Token refresh failed: $e';
      notifyListeners();
      rethrow;
    }
  }
}
