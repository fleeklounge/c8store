import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/projects_provider.dart';
import '../providers/authentication_provider.dart';
import '../providers/firestore_provider.dart';

/// Main application screen with sidebar and content area
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load collections when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final firestoreProvider = context.read<FirestoreProvider?>();
      if (firestoreProvider != null) {
        firestoreProvider.fetchCollections();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            extended: true,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.storage),
                label: Text('Collections'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            leading: Column(
              children: [
                Consumer<ProjectsProvider>(
                  builder: (context, provider, _) {
                    return DropdownButton<String>(
                      value: provider.activeProject?.projectId,
                      items: provider.projects.map((project) {
                        return DropdownMenuItem(
                          value: project.projectId,
                          child: Text(project.displayName),
                        );
                      }).toList(),
                      onChanged: (projectId) {
                        if (projectId != null) {
                          provider.setActiveProject(projectId);
                        }
                      },
                    );
                  },
                ),
                Consumer<AuthenticationProvider>(
                  builder: (context, auth, _) {
                    return IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => auth.logout(),
                      tooltip: 'Logout',
                    );
                  },
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main content area
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildCollectionsView();
      case 1:
        return _buildSettingsView();
      default:
        return const Center(
          child: Text('Unknown section'),
        );
    }
  }

  Widget _buildCollectionsView() {
    return Consumer<FirestoreProvider?>(
      builder: (context, provider, _) {
        // Check if provider is null
        if (provider == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.orange),
                SizedBox(height: 16),
                Text(
                  'Firestore Provider Not Initialized',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Please select a project first',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Provider is available, continue with normal flow
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading collections...'),
              ],
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading collections',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchCollections(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.collections.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.storage, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No Collections Found',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This Firestore database has no collections yet',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchCollections(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Firestore Collections',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => provider.fetchCollections(),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.collections.length,
                itemBuilder: (context, index) {
                  final collection = provider.collections[index];
                  return ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(collection),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to collection details
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Selected collection: $collection'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Configure application settings',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
