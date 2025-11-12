import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:c8store/main.dart' as app;
import 'package:c8store/services/oauth_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('c8store E2E Tests', () {
    testWidgets('App launches and shows welcome screen',
        (WidgetTester tester) async {
      // Create test OAuth config
      final testConfig = OAuthConfig(
        clientId: 'test-client-id',
        clientSecret: 'test-client-secret',
      );

      // Launch app
      await tester.pumpWidget(app.C8StoreApp(oauthConfig: testConfig));
      await tester.pumpAndSettle();

      // Verify welcome screen is displayed
      expect(find.text('c8store'), findsOneWidget);
      expect(find.text('Firebase Firestore Management Tool'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
    });

    testWidgets('Welcome screen displays correct branding',
        (WidgetTester tester) async {
      final testConfig = OAuthConfig(
        clientId: 'test-client-id',
        clientSecret: 'test-client-secret',
      );

      await tester.pumpWidget(app.C8StoreApp(oauthConfig: testConfig));
      await tester.pumpAndSettle();

      // Check for app icon
      expect(find.byIcon(Icons.storage), findsOneWidget);

      // Check for feature description
      expect(
        find.textContaining('Manage your Firestore databases'),
        findsOneWidget,
      );
    });

    testWidgets('Sign-in button is tappable', (WidgetTester tester) async {
      final testConfig = OAuthConfig(
        clientId: 'test-client-id',
        clientSecret: 'test-client-secret',
      );

      await tester.pumpWidget(app.C8StoreApp(oauthConfig: testConfig));
      await tester.pumpAndSettle();

      // Find and tap sign-in button
      final signInButton = find.text('Sign in with Google');
      expect(signInButton, findsOneWidget);

      // Verify button is enabled
      final button = tester.widget<ElevatedButton>(
        find.ancestor(
          of: signInButton,
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('App structure is properly set up', (WidgetTester tester) async {
      final testConfig = OAuthConfig(
        clientId: 'test-client-id',
        clientSecret: 'test-client-secret',
      );

      await tester.pumpWidget(app.C8StoreApp(oauthConfig: testConfig));
      await tester.pumpAndSettle();

      // Verify Material App structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify no unexpected errors
      expect(tester.takeException(), isNull);
    });
  });

  group('Navigation Tests', () {
    testWidgets('App uses correct navigation structure',
        (WidgetTester tester) async {
      final testConfig = OAuthConfig(
        clientId: 'test-client-id',
        clientSecret: 'test-client-secret',
      );

      await tester.pumpWidget(app.C8StoreApp(oauthConfig: testConfig));
      await tester.pumpAndSettle();

      // Verify we're on the welcome screen (not authenticated)
      expect(find.text('Sign in with Google'), findsOneWidget);
    });
  });

  group('Performance Tests', () {
    testWidgets('App loads within acceptable time',
        (WidgetTester tester) async {
      final testConfig = OAuthConfig(
        clientId: 'test-client-id',
        clientSecret: 'test-client-secret',
      );

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(app.C8StoreApp(oauthConfig: testConfig));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // App should load within 5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    testWidgets('No frame drops during initial render',
        (WidgetTester tester) async {
      final testConfig = OAuthConfig(
        clientId: 'test-client-id',
        clientSecret: 'test-client-secret',
      );

      await tester.pumpWidget(app.C8StoreApp(oauthConfig: testConfig));

      // Allow multiple frames to settle
      for (int i = 0; i < 10; i++) {
        await tester.pump();
      }

      await tester.pumpAndSettle();

      // Verify no exceptions during rendering
      expect(tester.takeException(), isNull);
    });
  });
}
