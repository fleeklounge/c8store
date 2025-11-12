import 'package:flutter_test/flutter_test.dart';
import 'package:c8store/services/secure_storage_service.dart';
import 'package:c8store/models/oauth_credentials.dart';
import 'package:c8store/models/connection_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([FlutterSecureStorage])
import 'secure_storage_service_test.mocks.dart';

void main() {
  group('SecureStorageServiceImpl', () {
    late MockFlutterSecureStorage mockStorage;
    late SecureStorageServiceImpl service;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      service = SecureStorageServiceImpl(storage: mockStorage);
    });

    group('Credentials Management', () {
      test('stores credentials successfully', () async {
        final credentials = OAuthCredentials(
          accessToken: 'test-access-token',
          refreshToken: 'test-refresh-token',
          expiresAt: DateTime.parse('2025-11-12T10:00:00Z'),
          scopes: ['scope1', 'scope2'],
        );

        when(mockStorage.write(
          key: anyNamed('key'),
          value: anyNamed('value'),
        )).thenAnswer((_) async => {});

        await service.storeCredentials(credentials);

        verify(mockStorage.write(
          key: SecureStorageService.keyCredentials,
          value: anyNamed('value'),
        )).called(1);
      });

      test('retrieves credentials successfully', () async {
        final credentialsJson = '''
        {
          "accessToken": "test-access-token",
          "refreshToken": "test-refresh-token",
          "expiresAt": "2025-11-12T10:00:00.000Z",
          "scopes": ["scope1", "scope2"]
        }
        ''';

        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => credentialsJson);

        final credentials = await service.getCredentials();

        expect(credentials, isNotNull);
        expect(credentials!.accessToken, 'test-access-token');
        expect(credentials.refreshToken, 'test-refresh-token');
        expect(credentials.scopes, ['scope1', 'scope2']);
      });

      test('returns null when credentials not found', () async {
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);

        final credentials = await service.getCredentials();

        expect(credentials, isNull);
      });

      test('clears credentials successfully', () async {
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async => {});

        await service.clearCredentials();

        verify(mockStorage.delete(
          key: SecureStorageService.keyCredentials,
        )).called(1);
      });
    });

    group('Connection State Management', () {
      test('stores connection state successfully', () async {
        final state = ConnectionState.empty();

        when(mockStorage.write(
          key: anyNamed('key'),
          value: anyNamed('value'),
        )).thenAnswer((_) async => {});

        await service.storeConnectionState(state);

        verify(mockStorage.write(
          key: SecureStorageService.keyConnectionState,
          value: anyNamed('value'),
        )).called(1);
      });

      test('retrieves connection state successfully', () async {
        final stateJson = '''
        {
          "activeProjectId": null,
          "projects": [],
          "credentials": null,
          "lastSync": null
        }
        ''';

        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => stateJson);

        final state = await service.getConnectionState();

        expect(state, isNotNull);
        expect(state!.activeProjectId, isNull);
        expect(state.projects, isEmpty);
      });

      test('returns null when connection state not found', () async {
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);

        final state = await service.getConnectionState();

        expect(state, isNull);
      });

      test('clears connection state successfully', () async {
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async => {});

        await service.clearConnectionState();

        verify(mockStorage.delete(
          key: SecureStorageService.keyConnectionState,
        )).called(1);
      });
    });

    group('Custom Data Management', () {
      test('stores custom data successfully', () async {
        final data = {'key1': 'value1', 'key2': 123};

        when(mockStorage.write(
          key: anyNamed('key'),
          value: anyNamed('value'),
        )).thenAnswer((_) async => {});

        await service.storeData('custom-key', data);

        verify(mockStorage.write(
          key: 'custom-key',
          value: anyNamed('value'),
        )).called(1);
      });

      test('retrieves custom data successfully', () async {
        final dataJson = '{"key1":"value1","key2":123}';

        when(mockStorage.read(key: 'custom-key'))
            .thenAnswer((_) async => dataJson);

        final data = await service.getData('custom-key');

        expect(data, isNotNull);
        expect(data!['key1'], 'value1');
        expect(data['key2'], 123);
      });

      test('returns null when custom data not found', () async {
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);

        final data = await service.getData('non-existent-key');

        expect(data, isNull);
      });

      test('clears custom data successfully', () async {
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async => {});

        await service.clearData('custom-key');

        verify(mockStorage.delete(key: 'custom-key')).called(1);
      });
    });

    group('Bulk Operations', () {
      test('clears all data successfully', () async {
        when(mockStorage.deleteAll()).thenAnswer((_) async => {});

        await service.clearAll();

        verify(mockStorage.deleteAll()).called(1);
      });

      test('checks if authenticated with valid credentials', () async {
        final credentialsJson = '''
        {
          "accessToken": "test-token",
          "refreshToken": "test-refresh",
          "expiresAt": "2099-11-12T10:00:00.000Z",
          "scopes": ["scope1"]
        }
        ''';

        when(mockStorage.read(key: SecureStorageService.keyCredentials))
            .thenAnswer((_) async => credentialsJson);

        final isAuth = await service.isAuthenticated();

        expect(isAuth, true);
      });

      test('checks if not authenticated with expired credentials', () async {
        final credentialsJson = '''
        {
          "accessToken": "test-token",
          "refreshToken": "test-refresh",
          "expiresAt": "2020-01-01T10:00:00.000Z",
          "scopes": ["scope1"]
        }
        ''';

        when(mockStorage.read(key: SecureStorageService.keyCredentials))
            .thenAnswer((_) async => credentialsJson);

        final isAuth = await service.isAuthenticated();

        expect(isAuth, false);
      });

      test('checks if not authenticated when no credentials', () async {
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);

        final isAuth = await service.isAuthenticated();

        expect(isAuth, false);
      });

      test('checks if data exists', () async {
        when(mockStorage.read(key: 'existing-key'))
            .thenAnswer((_) async => 'some-value');
        when(mockStorage.read(key: 'non-existent-key'))
            .thenAnswer((_) async => null);

        expect(await service.hasData('existing-key'), true);
        expect(await service.hasData('non-existent-key'), false);
      });

      test('gets all storage keys', () async {
        when(mockStorage.readAll()).thenAnswer((_) async => {
              'key1': 'value1',
              'key2': 'value2',
              'key3': 'value3',
            });

        final keys = await service.getAllKeys();

        expect(keys.length, 3);
        expect(keys, contains('key1'));
        expect(keys, contains('key2'));
        expect(keys, contains('key3'));
      });
    });

    group('Error Handling', () {
      test('throws StorageException when storage write fails', () async {
        final credentials = OAuthCredentials(
          accessToken: 'test-token',
          refreshToken: 'test-refresh',
          expiresAt: DateTime.now(),
          scopes: ['scope1'],
        );

        when(mockStorage.write(
          key: anyNamed('key'),
          value: anyNamed('value'),
        )).thenThrow(Exception('Storage error'));

        expect(
          () => service.storeCredentials(credentials),
          throwsA(isA<StorageException>()),
        );
      });

      test('throws StorageException when storage read fails', () async {
        when(mockStorage.read(key: anyNamed('key')))
            .thenThrow(Exception('Read error'));

        expect(
          () => service.getCredentials(),
          throwsA(isA<StorageException>()),
        );
      });

      test('throws StorageException when storage delete fails', () async {
        when(mockStorage.delete(key: anyNamed('key')))
            .thenThrow(Exception('Delete error'));

        expect(
          () => service.clearCredentials(),
          throwsA(isA<StorageException>()),
        );
      });

      test('throws StorageException when deleteAll fails', () async {
        when(mockStorage.deleteAll()).thenThrow(Exception('DeleteAll error'));

        expect(
          () => service.clearAll(),
          throwsA(isA<StorageException>()),
        );
      });

      test('throws StorageException when getAllKeys fails', () async {
        when(mockStorage.readAll()).thenThrow(Exception('ReadAll error'));

        expect(
          () => service.getAllKeys(),
          throwsA(isA<StorageException>()),
        );
      });
    });
  });
}
