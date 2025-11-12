import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/authentication_provider.dart';

/// Welcome screen with Google Sign-In
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo and branding
                const Icon(
                  Icons.storage,
                  size: 120,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'c8store',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Firebase Firestore Management Tool',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),

                // Feature description
                const Text(
                  'Manage your Firestore databases with ease.\n'
                  'Connect to multiple Firebase projects using Google OAuth.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 48),

                // Sign-in button
                Consumer<AuthenticationProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.isLoading) {
                      return const CircularProgressIndicator();
                    }

                    return Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _handleSignIn(context),
                          icon: const Icon(Icons.login),
                          label: const Text('Sign in with Google'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                        if (authProvider.error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            authProvider.error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignIn(BuildContext context) async {
    final authProvider = context.read<AuthenticationProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await authProvider.login();
      // Navigation to project selection happens automatically via AppNavigator
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Sign-in failed: $e')),
      );
    }
  }
}
