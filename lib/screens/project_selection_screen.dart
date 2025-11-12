import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/projects_provider.dart';

/// Screen for selecting Firebase project
class ProjectSelectionScreen extends StatefulWidget {
  const ProjectSelectionScreen({super.key});

  @override
  State<ProjectSelectionScreen> createState() => _ProjectSelectionScreenState();
}

class _ProjectSelectionScreenState extends State<ProjectSelectionScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectsProvider>().fetchProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Firebase Project'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search projects',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: Consumer<ProjectsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(child: Text('Error: ${provider.error}'));
                }

                final projects = _searchController.text.isEmpty
                    ? provider.projects
                    : provider.searchProjects(_searchController.text);

                if (projects.isEmpty) {
                  return const Center(
                    child: Text('No projects found'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return Card(
                      child: InkWell(
                        onTap: () => _selectProject(context, project.projectId),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                project.displayName,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                project.projectId,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (project.customLabel != null)
                                Chip(
                                  label: Text(project.customLabel!),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectProject(BuildContext context, String projectId) async {
    await context.read<ProjectsProvider>().setActiveProject(projectId);
    if (!mounted) return;
    // Navigation to main screen happens automatically via AppNavigator
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
