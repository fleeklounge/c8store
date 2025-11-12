import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/firebase_project.dart';
import 'oauth_service.dart';

/// Exception for Firebase Management API errors
class FirebaseManagementException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  FirebaseManagementException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() =>
      'FirebaseManagementException: $message${statusCode != null ? ' (HTTP $statusCode)' : ''}';
}

/// Service for interacting with Firebase Management API
class FirebaseManagementService {
  final OAuthService oauthService;
  final http.Client httpClient;

  static const String _baseUrl = 'https://firebase.googleapis.com/v1beta1';
  static const int _maxRetries = 5;
  static const Duration _initialBackoff = Duration(seconds: 1);

  FirebaseManagementService({
    required this.oauthService,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  /// List all Firebase projects accessible to the authenticated user
  Future<List<FirebaseProject>> listProjects() async {
    try {
      final allProjects = <FirebaseProject>[];
      String? pageToken;

      // Fetch all pages of projects
      do {
        final url = pageToken == null
            ? '$_baseUrl/projects?pageSize=100'
            : '$_baseUrl/projects?pageSize=100&pageToken=$pageToken';

        final response = await _authenticatedGet(url);
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        // Parse projects from current page
        final projects = _parseProjectsResponse(response.body);
        allProjects.addAll(projects);

        // Check for next page
        pageToken = json['nextPageToken'] as String?;
      } while (pageToken != null);

      return allProjects;
    } catch (e) {
      if (e is FirebaseManagementException) rethrow;
      throw FirebaseManagementException(
        'Failed to list Firebase projects',
        originalError: e,
      );
    }
  }

  /// Get a specific Firebase project by ID
  Future<FirebaseProject?> getProject(String projectId) async {
    try {
      final url = '$_baseUrl/projects/$projectId';
      final response = await _authenticatedGet(url);

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      return FirebaseProject(
        projectId: json['projectId'] as String,
        displayName: json['displayName'] as String,
        projectNumber: json['projectNumber'] as String,
        location: json['resources']?['locationId'] as String?,
        connectedAt: DateTime.now(),
      );
    } on FirebaseManagementException catch (e) {
      // Return null if project not found
      if (e.statusCode == 404) return null;
      rethrow;
    } catch (e) {
      throw FirebaseManagementException(
        'Failed to get Firebase project',
        originalError: e,
      );
    }
  }

  /// Make authenticated HTTP GET request with retry logic
  Future<http.Response> _authenticatedGet(String url) async {
    final token = await oauthService.getAccessToken();
    if (token == null) {
      throw FirebaseManagementException('No valid access token available');
    }

    return _retryRequest(() async {
      final response = await httpClient.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode >= 400) {
        throw FirebaseManagementException(
          'API request failed',
          statusCode: response.statusCode,
          originalError: response.body,
        );
      }

      return response;
    });
  }

  /// Retry logic with exponential backoff
  Future<T> _retryRequest<T>(Future<T> Function() request) async {
    var delay = _initialBackoff;

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        return await request();
      } catch (e) {
        if (attempt == _maxRetries - 1) rethrow;

        // Check if error is retryable (network error, 5xx, rate limit)
        if (e is FirebaseManagementException) {
          if (e.statusCode != null &&
              e.statusCode! != 429 &&
              e.statusCode! < 500) {
            // Don't retry client errors (except rate limiting)
            rethrow;
          }
        }

        // Exponential backoff with jitter
        final jitter = Duration(milliseconds: delay.inMilliseconds ~/ 2);
        await Future.delayed(delay + jitter);
        delay *= 2;
      }
    }

    throw FirebaseManagementException('Max retries exceeded');
  }

  /// Parse API response to list of Firebase projects
  List<FirebaseProject> _parseProjectsResponse(String responseBody) {
    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    final projects = json['results'] as List<dynamic>?;

    if (projects == null) return [];

    return projects.map((p) {
      final project = p as Map<String, dynamic>;
      return FirebaseProject(
        projectId: project['projectId'] as String,
        displayName: project['displayName'] as String,
        projectNumber: project['projectNumber'] as String,
        location: project['resources']?['locationId'] as String?,
        connectedAt: DateTime.now(),
      );
    }).toList();
  }

  /// Dispose resources
  void dispose() {
    httpClient.close();
  }
}
