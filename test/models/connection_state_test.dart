import 'package:flutter_test/flutter_test.dart';
import 'package:c8store/models/connection_state.dart';
import 'package:c8store/models/firebase_project.dart';
import 'package:c8store/models/oauth_credentials.dart';

void main() {
  group('ConnectionState', () {
    test('creates empty state', () {
      final state = ConnectionState.empty();

      expect(state.activeProjectId, null);
      expect(state.projects, []);
      expect(state.credentials, null);
      expect(state.lastSync, null);
      expect(state.isAuthenticated, false);
      expect(state.hasProjects, false);
      expect(state.hasActiveProject, false);
    });

    test('creates state with projects', () {
      final project = FirebaseProject(
        projectId: 'test-project',
        projectNumber: '123',
        displayName: 'Test Project',
        connectedAt: DateTime.now(),
      );

      final state = ConnectionState(
        projects: [project],
        activeProjectId: 'test-project',
      );

      expect(state.projects.length, 1);
      expect(state.activeProjectId, 'test-project');
      expect(state.hasProjects, true);
      expect(state.hasActiveProject, true);
      expect(state.activeProject, project);
    });

    test('detects authenticated state', () {
      final credentials = OAuthCredentials(
        accessToken: 'test-token',
        refreshToken: 'test-refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        scopes: ['scope1'],
      );

      final state = ConnectionState(
        projects: [],
        credentials: credentials,
      );

      expect(state.isAuthenticated, true);
    });

    test('detects unauthenticated state with expired credentials', () {
      final credentials = OAuthCredentials(
        accessToken: 'test-token',
        refreshToken: 'test-refresh',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        scopes: ['scope1'],
      );

      final state = ConnectionState(
        projects: [],
        credentials: credentials,
      );

      expect(state.isAuthenticated, false);
    });

    test('finds project by ID', () {
      final project1 = FirebaseProject(
        projectId: 'project-1',
        projectNumber: '123',
        displayName: 'Project 1',
        connectedAt: DateTime.now(),
      );

      final project2 = FirebaseProject(
        projectId: 'project-2',
        projectNumber: '456',
        displayName: 'Project 2',
        connectedAt: DateTime.now(),
      );

      final state = ConnectionState(projects: [project1, project2]);

      expect(state.findProject('project-1'), project1);
      expect(state.findProject('project-2'), project2);
      expect(state.findProject('non-existent'), null);
    });

    test('searches projects by query', () {
      final project1 = FirebaseProject(
        projectId: 'yoga-app',
        projectNumber: '123',
        displayName: 'Yoga Fitness App',
        connectedAt: DateTime.now(),
      );

      final project2 = FirebaseProject(
        projectId: 'meditation-app',
        projectNumber: '456',
        displayName: 'Meditation App',
        connectedAt: DateTime.now(),
      );

      final state = ConnectionState(projects: [project1, project2]);

      expect(state.searchProjects('yoga').length, 1);
      expect(state.searchProjects('yoga').first, project1);
      expect(state.searchProjects('app').length, 2);
      expect(state.searchProjects('nonexistent').length, 0);
    });

    test('upserts project correctly', () {
      final project1 = FirebaseProject(
        projectId: 'project-1',
        projectNumber: '123',
        displayName: 'Project 1',
        connectedAt: DateTime.now(),
      );

      final state = ConnectionState.empty();
      final updated = state.upsertProject(project1);

      expect(updated.projects.length, 1);
      expect(updated.projects.first, project1);
    });

    test('removes project correctly', () {
      final project1 = FirebaseProject(
        projectId: 'project-1',
        projectNumber: '123',
        displayName: 'Project 1',
        connectedAt: DateTime.now(),
      );

      final state = ConnectionState(
        projects: [project1],
        activeProjectId: 'project-1',
      );

      final updated = state.removeProject('project-1');

      expect(updated.projects.length, 0);
      expect(updated.activeProjectId, null);
    });

    test('clears auth correctly', () {
      final credentials = OAuthCredentials(
        accessToken: 'test-token',
        refreshToken: 'test-refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        scopes: ['scope1'],
      );

      final state = ConnectionState(
        projects: [],
        credentials: credentials,
        activeProjectId: 'test-project',
        lastSync: DateTime.now(),
      );

      final cleared = state.clearAuth();

      expect(cleared.credentials, null);
      expect(cleared.activeProjectId, null);
      expect(cleared.lastSync, null);
    });

    test('serializes to JSON correctly', () {
      final state = ConnectionState.empty();
      final json = state.toJson();

      expect(json['activeProjectId'], null);
      expect(json['projects'], []);
      expect(json['credentials'], null);
      expect(json['lastSync'], null);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'activeProjectId': null,
        'projects': [],
        'credentials': null,
        'lastSync': null,
      };

      final state = ConnectionState.fromJson(json);

      expect(state.activeProjectId, null);
      expect(state.projects, []);
      expect(state.credentials, null);
      expect(state.lastSync, null);
    });
  });
}
