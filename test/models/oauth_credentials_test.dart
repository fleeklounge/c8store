import 'package:flutter_test/flutter_test.dart';
import 'package:c8store/models/oauth_credentials.dart';

void main() {
  group('OAuthCredentials', () {
    test('creates valid credentials', () {
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(hours: 1));

      final credentials = OAuthCredentials(
        accessToken: 'test-access-token',
        refreshToken: 'test-refresh-token',
        expiresAt: expiresAt,
        scopes: ['scope1', 'scope2'],
      );

      expect(credentials.accessToken, 'test-access-token');
      expect(credentials.refreshToken, 'test-refresh-token');
      expect(credentials.expiresAt, expiresAt);
      expect(credentials.scopes, ['scope1', 'scope2']);
    });

    test('detects expired credentials', () {
      final pastTime = DateTime.now().subtract(const Duration(hours: 1));

      final credentials = OAuthCredentials(
        accessToken: 'test-token',
        refreshToken: 'test-refresh',
        expiresAt: pastTime,
        scopes: ['scope1'],
      );

      expect(credentials.isExpired, true);
    });

    test('detects valid credentials', () {
      final futureTime = DateTime.now().add(const Duration(hours: 1));

      final credentials = OAuthCredentials(
        accessToken: 'test-token',
        refreshToken: 'test-refresh',
        expiresAt: futureTime,
        scopes: ['scope1'],
      );

      expect(credentials.isExpired, false);
    });

    test('detects credentials that will expire soon', () {
      final soonTime = DateTime.now().add(const Duration(minutes: 3));

      final credentials = OAuthCredentials(
        accessToken: 'test-token',
        refreshToken: 'test-refresh',
        expiresAt: soonTime,
        scopes: ['scope1'],
      );

      expect(credentials.willExpireIn(const Duration(minutes: 5)), true);
      expect(credentials.willExpireIn(const Duration(minutes: 2)), false);
    });

    test('serializes to JSON correctly', () {
      final expiresAt = DateTime.parse('2025-11-12T10:00:00Z');

      final credentials = OAuthCredentials(
        accessToken: 'test-access-token',
        refreshToken: 'test-refresh-token',
        expiresAt: expiresAt,
        scopes: ['scope1', 'scope2'],
      );

      final json = credentials.toJson();

      expect(json['accessToken'], 'test-access-token');
      expect(json['refreshToken'], 'test-refresh-token');
      expect(json['expiresAt'], expiresAt.toIso8601String());
      expect(json['scopes'], ['scope1', 'scope2']);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'accessToken': 'test-access-token',
        'refreshToken': 'test-refresh-token',
        'expiresAt': '2025-11-12T10:00:00.000Z',
        'scopes': ['scope1', 'scope2'],
      };

      final credentials = OAuthCredentials.fromJson(json);

      expect(credentials.accessToken, 'test-access-token');
      expect(credentials.refreshToken, 'test-refresh-token');
      expect(credentials.expiresAt, DateTime.parse('2025-11-12T10:00:00Z'));
      expect(credentials.scopes, ['scope1', 'scope2']);
    });

    test('round-trip serialization works', () {
      final original = OAuthCredentials(
        accessToken: 'test-access-token',
        refreshToken: 'test-refresh-token',
        expiresAt: DateTime.parse('2025-11-12T10:00:00Z'),
        scopes: ['scope1', 'scope2'],
      );

      final json = original.toJson();
      final deserialized = OAuthCredentials.fromJson(json);

      expect(deserialized.accessToken, original.accessToken);
      expect(deserialized.refreshToken, original.refreshToken);
      expect(deserialized.expiresAt, original.expiresAt);
      expect(deserialized.scopes, original.scopes);
    });
  });
}
