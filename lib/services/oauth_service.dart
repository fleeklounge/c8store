import 'dart:async';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/oauth_credentials.dart';
import 'secure_storage_service.dart';

/// OAuth2 scopes required for Firebase/Firestore access
class OAuth2Scopes {
  /// Full access to Google Cloud Platform services
  static const cloudPlatform = 'https://www.googleapis.com/auth/cloud-platform';

  /// Firebase-specific scope
  static const firebase = 'https://www.googleapis.com/auth/firebase';

  /// Default scopes for this application
  static const List<String> defaultScopes = [cloudPlatform];
}

/// OAuth configuration for Google OAuth2 authentication
class OAuthConfig {
  /// OAuth2 client ID (Desktop app type)
  final String clientId;

  /// OAuth2 client secret
  final String clientSecret;

  /// Redirect URI for localhost callback
  final String redirectUri;

  /// OAuth scopes to request
  final List<String> scopes;

  OAuthConfig({
    required this.clientId,
    required this.clientSecret,
    String? redirectUri,
    List<String>? scopes,
  })  : redirectUri = redirectUri ?? 'http://localhost:8080',
        scopes = scopes ?? OAuth2Scopes.defaultScopes {
    if (clientId.isEmpty) {
      throw ArgumentError('clientId cannot be empty');
    }
    if (clientSecret.isEmpty) {
      throw ArgumentError('clientSecret cannot be empty');
    }
  }

  /// Create OAuthConfig from environment variables or config file
  factory OAuthConfig.fromEnvironment() {
    // TODO: Load from environment variables or secure config
    throw UnimplementedError(
      'OAuth credentials must be configured. '
      'Create a Google Cloud OAuth2 Desktop App credential and provide clientId/clientSecret.',
    );
  }
}

/// Exception for OAuth-related errors
class OAuthException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  OAuthException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'OAuthException: $message${code != null ? ' (code: $code)' : ''}';
}

/// OAuth2 authentication service for Google APIs
class OAuthService {
  final OAuthConfig config;
  final SecureStorageService storage;

  HttpServer? _redirectServer;

  OAuthService({
    required this.config,
    required this.storage,
  });

  /// Check if user is currently authenticated with valid credentials
  Future<bool> isAuthenticated() async {
    try {
      final credentials = await storage.getCredentials();
      if (credentials == null) return false;
      return !credentials.isExpired;
    } catch (e) {
      return false;
    }
  }

  /// Get current access token, refreshing if necessary
  Future<String?> getAccessToken() async {
    try {
      final credentials = await storage.getCredentials();
      if (credentials == null) return null;

      // If token is expired or will expire soon, refresh it
      if (credentials.willExpireIn(const Duration(minutes: 5))) {
        await refreshToken();
        final refreshedCredentials = await storage.getCredentials();
        return refreshedCredentials?.accessToken;
      }

      return credentials.accessToken;
    } catch (e) {
      throw OAuthException('Failed to get access token', originalError: e);
    }
  }

  /// Initiate OAuth2 login flow
  ///
  /// Opens browser for user authentication and returns credentials on success
  Future<OAuthCredentials> login() async {
    try {
      print('🔐 Starting OAuth login flow...');
      print('📋 Client ID: ${config.clientId}');
      print('📋 Scopes: ${config.scopes.join(", ")}');

      final clientId = ClientId(config.clientId, config.clientSecret);
      final client = http.Client();

      try {
        print('🌐 Opening browser for user consent...');

        // Use googleapis_auth to obtain credentials via browser
        // This will:
        // 1. Start a local HTTP server on an available port
        // 2. Open the browser to Google's OAuth consent page
        // 3. Wait for the callback with authorization code
        // 4. Exchange the code for access/refresh tokens
        final accessCredentials = await obtainAccessCredentialsViaUserConsent(
          clientId,
          config.scopes,
          client,
          _promptUserConsent,
        );

        print('✅ Received credentials from Google');
        print('📝 Has refresh token: ${accessCredentials.refreshToken != null}');

        if (accessCredentials.refreshToken == null) {
          print('❌ No refresh token received!');
          throw OAuthException(
            'No refresh token received. Ensure OAuth consent screen is configured for offline access.',
            code: 'NO_REFRESH_TOKEN',
          );
        }

        // Convert to our OAuthCredentials model
        final credentials = OAuthCredentials(
          accessToken: accessCredentials.accessToken.data,
          refreshToken: accessCredentials.refreshToken!,
          expiresAt: accessCredentials.accessToken.expiry,
          scopes: config.scopes,
        );

        print('💾 Storing credentials securely...');
        // Store credentials securely
        await storage.storeCredentials(credentials);

        print('✅ OAuth login completed successfully!');
        return credentials;
      } finally {
        client.close();
      }
    } catch (e) {
      print('❌ OAuth login failed: $e');
      if (e is OAuthException) rethrow;
      throw OAuthException(
        'OAuth login failed',
        originalError: e,
      );
    }
  }

  /// Callback to prompt user to visit authorization URL
  ///
  /// This is called by googleapis_auth when it's ready for user to authenticate
  void _promptUserConsent(String authorizationUrl) async {
    try {
      final uri = Uri.parse(authorizationUrl);

      // Launch browser with authorization URL
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw OAuthException(
          'Could not launch browser. Please visit this URL manually: $authorizationUrl',
          code: 'BROWSER_LAUNCH_FAILED',
        );
      }
    } catch (e) {
      throw OAuthException(
        'Failed to open authorization URL',
        code: 'URL_LAUNCH_FAILED',
        originalError: e,
      );
    }
  }

  /// Refresh access token using refresh token
  Future<void> refreshToken() async {
    try {
      final credentials = await storage.getCredentials();
      if (credentials == null) {
        throw OAuthException('No credentials to refresh');
      }

      final clientId = ClientId(config.clientId, config.clientSecret);

      // Create AccessCredentials from stored credentials
      final accessCredentials = AccessCredentials(
        AccessToken(
          'Bearer',
          credentials.accessToken,
          credentials.expiresAt.toUtc(),
        ),
        credentials.refreshToken,
        config.scopes,
      );

      // Refresh the token
      final client = http.Client();
      try {
        final refreshedCredentials = await refreshCredentials(
          clientId,
          accessCredentials,
          client,
        );

        // Store refreshed credentials
        final newCredentials = OAuthCredentials(
          accessToken: refreshedCredentials.accessToken.data,
          refreshToken: refreshedCredentials.refreshToken ?? credentials.refreshToken,
          expiresAt: refreshedCredentials.accessToken.expiry,
          scopes: config.scopes,
        );

        await storage.storeCredentials(newCredentials);
      } finally {
        client.close();
      }
    } catch (e) {
      throw OAuthException('Failed to refresh token', originalError: e);
    }
  }

  /// Logout and clear stored credentials
  Future<void> logout() async {
    try {
      await storage.clearCredentials();
      await _redirectServer?.close();
    } catch (e) {
      throw OAuthException('Failed to logout', originalError: e);
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _redirectServer?.close();
  }
}
