import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';

/// Provider for Firestore data state management
class FirestoreProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  List<String> _collections = [];
  Map<String, List<Map<String, dynamic>>> _documentsCache = {};
  bool _isLoading = false;
  String? _error;

  FirestoreProvider({
    required FirestoreService firestoreService,
  }) : _firestoreService = firestoreService;

  /// List of collections
  List<String> get collections => _collections;

  /// Is loading
  bool get isLoading => _isLoading;

  /// Error message
  String? get error => _error;

  /// Fetch collections
  Future<void> fetchCollections() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _collections = await _firestoreService.listCollections();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch collections: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch documents from a collection
  Future<void> fetchDocuments(String collectionId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _firestoreService.listDocuments(collectionId);
      _documentsCache[collectionId] = result['documents'] as List<Map<String, dynamic>>? ?? [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch documents: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get cached documents for a collection
  List<Map<String, dynamic>> getDocuments(String collectionId) {
    return _documentsCache[collectionId] ?? [];
  }

  /// Clear cache
  void clearCache() {
    _collections = [];
    _documentsCache = {};
    notifyListeners();
  }
}
