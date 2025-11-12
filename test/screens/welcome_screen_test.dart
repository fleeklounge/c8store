import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:c8store/screens/welcome_screen.dart';
import 'package:c8store/providers/authentication_provider.dart';
import 'package:c8store/services/oauth_service.dart';
import 'package:c8store/services/secure_storage_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([SecureStorageService, OAuthService])
import 'welcome_screen_test.mocks.dart';

void main() {
  group('WelcomeScreen', () {
    late MockSecureStorageService mockStorage;
    late MockOAuthService mockOAuth;

    setUp(() {
      mockStorage = MockSecureStorageService();
      mockOAuth = MockOAuthService();

      // Default mocking behavior
      when(mockStorage.getCredentials()).thenAnswer((_) async => null);
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AuthenticationProvider(
            oauthService: mockOAuth,
            storage: mockStorage,
          ),
          child: const WelcomeScreen(),
        ),
      );
    }

    testWidgets('displays app branding', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('c8store'), findsOneWidget);
      expect(find.text('Firebase Firestore Management Tool'), findsOneWidget);
      expect(find.byIcon(Icons.storage), findsOneWidget);
    });

    testWidgets('displays sign-in button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('displays feature description', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Manage your Firestore databases'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Connect to multiple Firebase projects'),
        findsOneWidget,
      );
    });

    testWidgets('shows loading indicator during sign-in',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Mock delayed sign-in
      when(mockOAuth.login()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        throw Exception('Test error');
      });

      // Tap sign-in button
      await tester.tap(find.text('Sign in with Google'));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
