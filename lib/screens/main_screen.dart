import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/projects_provider.dart';
import '../providers/authentication_provider.dart';

/// Main application screen with sidebar and content area
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storage, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Collections View',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Browse and manage your Firestore collections',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
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
