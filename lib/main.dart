import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/project_selection_screen.dart';
import 'screens/main_screen.dart';
import 'providers/authentication_provider.dart';
import 'providers/projects_provider.dart';
import 'providers/firestore_provider.dart';
import 'services/oauth_service.dart';
import 'services/secure_storage_service.dart';
import 'services/firebase_management_service.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load OAuth config (from file if exists, otherwise use default)
  final oauthConfig = await _loadOAuthConfig();

  runApp(C8StoreApp(oauthConfig: oauthConfig));
}

/// Load OAuth configuration from bundled asset
///
/// The oauth_config.json file should be placed in the project root
/// and will be bundled with the app as an asset.
Future<OAuthConfig> _loadOAuthConfig() async {
  try {
    // Load from bundled asset
    final content = await rootBundle.loadString('oauth_config.json');
    final json = jsonDecode(content) as Map<String, dynamic>;

    debugPrint('✅ Using OAuth config from bundled asset');
    return OAuthConfig(
      clientId: json['clientId'] as String,
      clientSecret: json['clientSecret'] as String,
    );
  } catch (e) {
    debugPrint('❌ Failed to load oauth_config.json: $e');
    debugPrint('');
    debugPrint('Please create oauth_config.json in the project root:');
    debugPrint('1. Copy oauth_config.json.example to oauth_config.json');
    debugPrint('2. Fill in your OAuth credentials from Google Cloud Console');
    debugPrint('3. Run flutter run again');
    debugPrint('');
    debugPrint('See docs/oauth-setup-detailed.md for detailed setup instructions.');

    throw Exception(
      'OAuth configuration not found. '
      'Please create oauth_config.json with your Google OAuth credentials. '
      'See docs/oauth-setup-detailed.md for setup instructions.',
    );
  }
}

class C8StoreApp extends StatelessWidget {
  final OAuthConfig oauthConfig;

  const C8StoreApp({super.key, required this.oauthConfig});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final storage = SecureStorageServiceImpl();

    final oauthService = OAuthService(
      config: oauthConfig,
      storage: storage,
    );

    return MultiProvider(
      providers: [
        // Authentication Provider
        ChangeNotifierProvider(
          create: (_) => AuthenticationProvider(
            oauthService: oauthService,
            storage: storage,
          ),
        ),

        // Projects Provider
        ChangeNotifierProvider(
          create: (_) => ProjectsProvider(
            managementService: FirebaseManagementService(
              oauthService: oauthService,
            ),
            storage: storage,
          ),
        ),

        // Firestore Provider - initialized later when project is selected
        ChangeNotifierProxyProvider<ProjectsProvider, FirestoreProvider?>(
          create: (_) => null,
          update: (context, projects, previous) {
            if (projects.activeProject != null) {
              return FirestoreProvider(
                firestoreService: FirestoreService(
                  projectId: projects.activeProject!.projectId,
                  oauthService: oauthService,
                ),
              );
            }
            return previous;
          },
        ),
      ],
      child: MaterialApp(
        title: 'c8store - Firestore Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const AppNavigator(),
      ),
    );
  }
}

/// Handles navigation based on authentication state
class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthenticationProvider, ProjectsProvider>(
      builder: (context, auth, projects, _) {
        // Not authenticated -> Welcome screen
        if (!auth.isAuthenticated) {
          return const WelcomeScreen();
        }

        // Authenticated but no active project -> Project selection
        if (projects.activeProject == null) {
          return const ProjectSelectionScreen();
        }

        // Authenticated with active project -> Main screen
        return const MainScreen();
      },
    );
  }
}

