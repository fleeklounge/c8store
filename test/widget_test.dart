// Basic widget test for c8store application

import 'package:flutter_test/flutter_test.dart';
import 'package:c8store/services/oauth_service.dart';
import 'package:c8store/main.dart';

void main() {
  testWidgets('App starts and shows welcome screen',
      (WidgetTester tester) async {
    // Build our app with test OAuth config
    final testConfig = OAuthConfig(
      clientId: 'test-client-id',
      clientSecret: 'test-client-secret',
    );

    await tester.pumpWidget(C8StoreApp(oauthConfig: testConfig));

    // Verify that welcome screen is displayed
    expect(find.text('c8store'), findsOneWidget);
    expect(find.text('Firebase Firestore Management Tool'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}
