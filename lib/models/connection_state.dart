import 'firebase_project.dart';
import 'oauth_credentials.dart';

/// Application connection state managing Firebase projects and OAuth credentials
class ConnectionState {
  /// Currently active Firebase project ID
  final String? activeProjectId;

  /// List of all connected Firebase projects
  final List<FirebaseProject> projects;

  /// OAuth credentials for API access
  final OAuthCredentials? credentials;

  /// Timestamp of last successful data synchronization
  final DateTime? lastSync;

  ConnectionState({
    this.activeProjectId,
    required this.projects,
    this.credentials,
    this.lastSync,
  });

  /// Create an empty connection state (not authenticated)
  factory ConnectionState.empty() {
    return ConnectionState(
      projects: [],
    );
  }

  /// Get the currently active Firebase project
  FirebaseProject? get activeProject {
    if (activeProjectId == null) return null;
    try {
      return projects.firstWhere((p) => p.projectId == activeProjectId);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => credentials != null && !credentials!.isExpired;

  /// Check if there are any connected projects
  bool get hasProjects => projects.isNotEmpty;

  /// Check if there is an active project selected
  bool get hasActiveProject => activeProjectId != null && activeProject != null;

  /// Find a project by its ID
  FirebaseProject? findProject(String projectId) {
    try {
      return projects.firstWhere((p) => p.projectId == projectId);
    } catch (e) {
      return null;
    }
  }

  /// Find projects by custom label
  List<FirebaseProject> findProjectsByLabel(String label) {
    return projects.where((p) => p.customLabel == label).toList();
  }

  /// Search projects by name, ID, or custom label
  List<FirebaseProject> searchProjects(String query) {
    final lowerQuery = query.toLowerCase();
    return projects.where((p) {
      return p.displayName.toLowerCase().contains(lowerQuery) ||
          p.projectId.toLowerCase().contains(lowerQuery) ||
          (p.customLabel?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Create ConnectionState from JSON map
  factory ConnectionState.fromJson(Map<String, dynamic> json) {
    return ConnectionState(
      activeProjectId: json['activeProjectId'] as String?,
      projects: (json['projects'] as List<dynamic>)
          .map((p) => FirebaseProject.fromJson(p as Map<String, dynamic>))
          .toList(),
      credentials: json['credentials'] != null
          ? OAuthCredentials.fromJson(json['credentials'] as Map<String, dynamic>)
          : null,
      lastSync: json['lastSync'] != null
          ? DateTime.parse(json['lastSync'] as String)
          : null,
    );
  }

  /// Convert ConnectionState to JSON map
  Map<String, dynamic> toJson() {
    return {
      'activeProjectId': activeProjectId,
      'projects': projects.map((p) => p.toJson()).toList(),
      'credentials': credentials?.toJson(),
      'lastSync': lastSync?.toIso8601String(),
    };
  }

  /// Create a copy of this state with optional field updates
  ConnectionState copyWith({
    String? activeProjectId,
    List<FirebaseProject>? projects,
    OAuthCredentials? credentials,
    DateTime? lastSync,
    bool clearActiveProject = false,
    bool clearCredentials = false,
    bool clearLastSync = false,
  }) {
    return ConnectionState(
      activeProjectId: clearActiveProject ? null : (activeProjectId ?? this.activeProjectId),
      projects: projects ?? this.projects,
      credentials: clearCredentials ? null : (credentials ?? this.credentials),
      lastSync: clearLastSync ? null : (lastSync ?? this.lastSync),
    );
  }

  /// Add or update a project in the list
  ConnectionState upsertProject(FirebaseProject project) {
    final updatedProjects = List<FirebaseProject>.from(projects);
    final index = updatedProjects.indexWhere((p) => p.projectId == project.projectId);

    if (index >= 0) {
      updatedProjects[index] = project;
    } else {
      updatedProjects.add(project);
    }

    return copyWith(projects: updatedProjects);
  }

  /// Remove a project from the list
  ConnectionState removeProject(String projectId) {
    final updatedProjects = projects.where((p) => p.projectId != projectId).toList();
    final newActiveProjectId = activeProjectId == projectId ? null : activeProjectId;

    return copyWith(
      projects: updatedProjects,
      activeProjectId: newActiveProjectId,
    );
  }

  /// Set the active project
  ConnectionState setActiveProject(String? projectId) {
    if (projectId != null && !projects.any((p) => p.projectId == projectId)) {
      throw ArgumentError('Project with ID $projectId not found');
    }
    return copyWith(activeProjectId: projectId);
  }

  /// Clear all authentication data (logout)
  ConnectionState clearAuth() {
    return copyWith(
      clearCredentials: true,
      clearActiveProject: true,
      clearLastSync: true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConnectionState &&
        other.activeProjectId == activeProjectId &&
        _listEquals(other.projects, projects) &&
        other.credentials == credentials &&
        other.lastSync == lastSync;
  }

  @override
  int get hashCode {
    return Object.hash(
      activeProjectId,
      Object.hashAll(projects),
      credentials,
      lastSync,
    );
  }

  @override
  String toString() {
    return 'ConnectionState(activeProjectId: $activeProjectId, '
        'projects: ${projects.length}, credentials: ${credentials != null}, '
        'lastSync: $lastSync, isAuthenticated: $isAuthenticated)';
  }

  /// Helper method to compare lists
  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
