import 'package:flutter/foundation.dart';
import '../models/firebase_project.dart';
import '../models/connection_state.dart';
import '../services/firebase_management_service.dart';
import '../services/secure_storage_service.dart';

/// Provider for Firebase projects state management
class ProjectsProvider with ChangeNotifier {
  final FirebaseManagementService _managementService;
  final SecureStorageService _storage;

  ConnectionState _state = ConnectionState.empty();
  bool _isLoading = false;
  String? _error;

  ProjectsProvider({
    required FirebaseManagementService managementService,
    required SecureStorageService storage,
  })  : _managementService = managementService,
        _storage = storage {
    _initialize();
  }

  /// Current connection state
  ConnectionState get state => _state;

  /// List of projects
  List<FirebaseProject> get projects => _state.projects;

  /// Active project
  FirebaseProject? get activeProject => _state.activeProject;

  /// Is loading
  bool get isLoading => _isLoading;

  /// Error message
  String? get error => _error;

  /// Initialize and load saved state
  Future<void> _initialize() async {
    try {
      final savedState = await _storage.getConnectionState();
      if (savedState != null) {
        _state = savedState;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to load saved state: $e';
      notifyListeners();
    }
  }

  /// Fetch projects from Firebase Management API
  Future<void> fetchProjects() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final projects = await _managementService.listProjects();
      _state = _state.copyWith(projects: projects);
      await _storage.storeConnectionState(_state);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch projects: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set active project
  Future<void> setActiveProject(String projectId) async {
    try {
      _state = _state.setActiveProject(projectId);
      await _storage.storeConnectionState(_state);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to set active project: $e';
      notifyListeners();
    }
  }

  /// Add or update a project
  Future<void> upsertProject(FirebaseProject project) async {
    _state = _state.upsertProject(project);
    await _storage.storeConnectionState(_state);
    notifyListeners();
  }

  /// Search projects
  List<FirebaseProject> searchProjects(String query) {
    return _state.searchProjects(query);
  }
}
