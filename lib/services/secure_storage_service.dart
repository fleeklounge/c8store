import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/oauth_credentials.dart';
import '../models/connection_state.dart';

/// Custom exception for storage-related errors
class StorageException implements Exception {
  final String message;
  final dynamic originalError;

  StorageException(this.message, [this.originalError]);

  @override
  String toString() => 'StorageException: $message${originalError != null ? ' ($originalError)' : ''}';
}

/// Exception thrown when credentials are not found in storage
class CredentialsNotFoundException extends StorageException {
  CredentialsNotFoundException([String? key])
      : super('Credentials not found${key != null ? ' for key: $key' : ''}');
}

/// Exception thrown when encryption or decryption fails
class EncryptionException extends StorageException {
  EncryptionException(super.message, [super.originalError]);
}

/// Abstract interface for secure credential storage service
///
/// Provides methods to securely store, retrieve, and manage OAuth credentials
/// and connection state using platform-specific secure storage mechanisms.
abstract class SecureStorageService {
  /// Storage key for OAuth credentials
  static const String keyCredentials = 'oauth_credentials';

  /// Storage key for connection state
  static const String keyConnectionState = 'connection_state';

  /// Storage key for user preferences
  static const String keyUserPreferences = 'user_preferences';

  /// Store OAuth credentials securely
  ///
  /// [credentials] The OAuth credentials to store
  /// Throws [StorageException] if storage operation fails
  /// Throws [EncryptionException] if encryption fails
  Future<void> storeCredentials(OAuthCredentials credentials);

  /// Retrieve stored OAuth credentials
  ///
  /// Returns the stored credentials or null if not found
  /// Throws [StorageException] if storage read operation fails
  /// Throws [EncryptionException] if decryption fails
  Future<OAuthCredentials?> getCredentials();

  /// Store connection state securely
  ///
  /// [state] The connection state to store
  /// Throws [StorageException] if storage operation fails
  Future<void> storeConnectionState(ConnectionState state);

  /// Retrieve stored connection state
  ///
  /// Returns the stored state or null if not found
  /// Throws [StorageException] if storage read operation fails
  Future<ConnectionState?> getConnectionState();

  /// Store arbitrary data with a custom key
  ///
  /// [key] The storage key
  /// [data] The data to store as a JSON-serializable map
  /// Throws [StorageException] if storage operation fails
  Future<void> storeData(String key, Map<String, dynamic> data);

  /// Retrieve data for a custom key
  ///
  /// [key] The storage key
  /// Returns the stored data or null if not found
  /// Throws [StorageException] if storage read operation fails
  Future<Map<String, dynamic>?> getData(String key);

  /// Clear OAuth credentials from storage
  ///
  /// Throws [StorageException] if storage operation fails
  Future<void> clearCredentials();

  /// Clear connection state from storage
  ///
  /// Throws [StorageException] if storage operation fails
  Future<void> clearConnectionState();

  /// Clear specific data by key
  ///
  /// [key] The storage key to clear
  /// Throws [StorageException] if storage operation fails
  Future<void> clearData(String key);

  /// Clear all stored data (complete logout)
  ///
  /// Removes all credentials, connection state, and user preferences
  /// Throws [StorageException] if storage operation fails
  Future<void> clearAll();

  /// Check if user has valid stored credentials
  ///
  /// Returns true if credentials exist and are not expired
  Future<bool> isAuthenticated();

  /// Check if specific data exists in storage
  ///
  /// [key] The storage key to check
  /// Returns true if data exists for the given key
  Future<bool> hasData(String key);

  /// Get all storage keys
  ///
  /// Returns a list of all keys currently in storage
  /// Useful for debugging and migration
  Future<List<String>> getAllKeys();
}

/// Implementation of SecureStorageService using flutter_secure_storage
class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageServiceImpl({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
              lOptions: LinuxOptions(),
              wOptions: WindowsOptions(),
              mOptions: MacOsOptions(),
            );

  @override
  Future<void> storeCredentials(OAuthCredentials credentials) async {
    try {
      final json = jsonEncode(credentials.toJson());
      await _storage.write(
        key: SecureStorageService.keyCredentials,
        value: json,
      );
    } catch (e) {
      throw StorageException('Failed to store credentials', e);
    }
  }

  @override
  Future<OAuthCredentials?> getCredentials() async {
    try {
      final json = await _storage.read(key: SecureStorageService.keyCredentials);
      if (json == null) return null;

      final data = jsonDecode(json) as Map<String, dynamic>;
      return OAuthCredentials.fromJson(data);
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException('Failed to retrieve credentials', e);
    }
  }

  @override
  Future<void> storeConnectionState(ConnectionState state) async {
    try {
      final json = jsonEncode(state.toJson());
      await _storage.write(
        key: SecureStorageService.keyConnectionState,
        value: json,
      );
    } catch (e) {
      throw StorageException('Failed to store connection state', e);
    }
  }

  @override
  Future<ConnectionState?> getConnectionState() async {
    try {
      final json = await _storage.read(key: SecureStorageService.keyConnectionState);
      if (json == null) return null;

      final data = jsonDecode(json) as Map<String, dynamic>;
      return ConnectionState.fromJson(data);
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException('Failed to retrieve connection state', e);
    }
  }

  @override
  Future<void> storeData(String key, Map<String, dynamic> data) async {
    try {
      final json = jsonEncode(data);
      await _storage.write(key: key, value: json);
    } catch (e) {
      throw StorageException('Failed to store data for key: $key', e);
    }
  }

  @override
  Future<Map<String, dynamic>?> getData(String key) async {
    try {
      final json = await _storage.read(key: key);
      if (json == null) return null;

      return jsonDecode(json) as Map<String, dynamic>;
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException('Failed to retrieve data for key: $key', e);
    }
  }

  @override
  Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: SecureStorageService.keyCredentials);
    } catch (e) {
      throw StorageException('Failed to clear credentials', e);
    }
  }

  @override
  Future<void> clearConnectionState() async {
    try {
      await _storage.delete(key: SecureStorageService.keyConnectionState);
    } catch (e) {
      throw StorageException('Failed to clear connection state', e);
    }
  }

  @override
  Future<void> clearData(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw StorageException('Failed to clear data for key: $key', e);
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw StorageException('Failed to clear all storage', e);
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final credentials = await getCredentials();
      if (credentials == null) return false;

      // Check if token is not expired
      return !credentials.isExpired;
    } catch (e) {
      // If there's any error reading credentials, consider not authenticated
      return false;
    }
  }

  @override
  Future<bool> hasData(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getAllKeys() async {
    try {
      final allData = await _storage.readAll();
      return allData.keys.toList();
    } catch (e) {
      throw StorageException('Failed to retrieve all keys', e);
    }
  }
}
