import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'oauth_service.dart';

/// Exception for Firestore API errors
class FirestoreException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic originalError;

  FirestoreException(
    this.message, {
    this.code,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() =>
      'FirestoreException: $message${code != null ? ' ($code)' : ''}${statusCode != null ? ' [HTTP $statusCode]' : ''}';
}

/// Service for interacting with Firestore REST API
class FirestoreService {
  final String projectId;
  final OAuthService oauthService;
  final http.Client httpClient;

  static const String _baseUrl = 'https://firestore.googleapis.com/v1';
  static const String _defaultDatabase = '(default)';

  FirestoreService({
    required this.projectId,
    required this.oauthService,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  /// Get base path for database operations
  String get _databasePath => '$_baseUrl/projects/$projectId/databases/$_defaultDatabase';

  /// List all collections in the database
  Future<List<String>> listCollections({String? parentPath}) async {
    try {
      final path = parentPath ?? '$_databasePath/documents';
      final url = '$path:listCollectionIds';

      final response = await _authenticatedRequest('POST', url);
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      final collectionIds = json['collectionIds'] as List<dynamic>?;
      if (collectionIds == null) return [];

      return collectionIds.map((id) => id as String).toList();
    } catch (e) {
      if (e is FirestoreException) rethrow;
      throw FirestoreException(
        'Failed to list collections',
        originalError: e,
      );
    }
  }

  /// List documents in a collection
  Future<Map<String, dynamic>> listDocuments(
    String collectionId, {
    int? pageSize,
    String? pageToken,
  }) async {
    try {
      var url = '$_databasePath/documents/$collectionId';

      // Add query parameters
      final params = <String, String>{};
      if (pageSize != null) params['pageSize'] = pageSize.toString();
      if (pageToken != null) params['pageToken'] = pageToken;

      if (params.isNotEmpty) {
        final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
        url = '$url?$queryString';
      }

      final response = await _authenticatedRequest('GET', url);
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      return {
        'documents': json['documents'] as List<dynamic>? ?? [],
        'nextPageToken': json['nextPageToken'] as String?,
      };
    } catch (e) {
      if (e is FirestoreException) rethrow;
      throw FirestoreException(
        'Failed to list documents',
        originalError: e,
      );
    }
  }

  /// Get a specific document
  Future<Map<String, dynamic>?> getDocument(
    String collectionId,
    String documentId,
  ) async {
    try {
      final url = '$_databasePath/documents/$collectionId/$documentId';
      final response = await _authenticatedRequest('GET', url);

      return jsonDecode(response.body) as Map<String, dynamic>;
    } on FirestoreException catch (e) {
      // Return null if document not found
      if (e.statusCode == 404) return null;
      rethrow;
    } catch (e) {
      throw FirestoreException(
        'Failed to get document',
        originalError: e,
      );
    }
  }

  /// Create a new document
  Future<Map<String, dynamic>> createDocument(
    String collectionId,
    Map<String, dynamic> data, {
    String? documentId,
  }) async {
    try {
      var url = '$_databasePath/documents/$collectionId';

      // If documentId is provided, add it as a query parameter
      if (documentId != null) {
        url = '$url?documentId=$documentId';
      }

      final response = await _authenticatedRequest(
        'POST',
        url,
        body: {'fields': data},
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is FirestoreException) rethrow;
      throw FirestoreException(
        'Failed to create document',
        originalError: e,
      );
    }
  }

  /// Update an existing document
  Future<Map<String, dynamic>> updateDocument(
    String collectionId,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = '$_databasePath/documents/$collectionId/$documentId';

      final response = await _authenticatedRequest(
        'PATCH',
        url,
        body: {'fields': data},
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is FirestoreException) rethrow;
      throw FirestoreException(
        'Failed to update document',
        originalError: e,
      );
    }
  }

  /// Delete a document
  Future<void> deleteDocument(
    String collectionId,
    String documentId,
  ) async {
    try {
      final url = '$_databasePath/documents/$collectionId/$documentId';
      await _authenticatedRequest('DELETE', url);
    } catch (e) {
      if (e is FirestoreException) rethrow;
      throw FirestoreException(
        'Failed to delete document',
        originalError: e,
      );
    }
  }

  /// Make authenticated HTTP request
  Future<http.Response> _authenticatedRequest(
    String method,
    String url, {
    Map<String, dynamic>? body,
  }) async {
    final token = await oauthService.getAccessToken();
    if (token == null) {
      throw FirestoreException('No valid access token available');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final uri = Uri.parse(url);
    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await httpClient.get(uri, headers: headers);
      case 'POST':
        response = await httpClient.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PATCH':
        response = await httpClient.patch(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'DELETE':
        response = await httpClient.delete(uri, headers: headers);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }

    if (response.statusCode >= 400) {
      throw FirestoreException(
        'Firestore API request failed',
        statusCode: response.statusCode,
        originalError: response.body,
      );
    }

    return response;
  }

  /// Dispose resources
  void dispose() {
    httpClient.close();
  }
}
