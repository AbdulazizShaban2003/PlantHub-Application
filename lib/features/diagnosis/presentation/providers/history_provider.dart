import 'package:flutter/foundation.dart';
import '../../doamin/local_storage_service.dart';

class HistoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _historyItems = [];
  List<Map<String, dynamic>> _filteredHistoryItems = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';

  final LocalStorageService _localStorageService = LocalStorageService();

  // Getters
  List<Map<String, dynamic>> get historyItems =>
      _searchQuery.isEmpty ? _historyItems : _filteredHistoryItems;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final history = await _localStorageService.getDiagnosisHistory();
      _historyItems = history;
      _applySearchFilter();
    } catch (e) {
      _errorMessage = 'Error loading history. Please try again.';
      debugPrint('Error loading history: $e');

      // Try to reset database if error persists
      if (e.toString().contains('no such column') ||
          e.toString().contains('no such table')) {
        await _resetDatabaseAndReload();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _resetDatabaseAndReload() async {
    try {
      await _localStorageService.resetDatabase();
      final history = await _localStorageService.getDiagnosisHistory();
      _historyItems = history;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to reset database. Please reinstall the app.';
      debugPrint('Error resetting database: $e');
    }
  }

  Future<void> searchHistory(String query) async {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      _filteredHistoryItems = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final results = await _localStorageService.searchHistory(_searchQuery);
      _filteredHistoryItems = results;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error searching history. Showing all results.';
      debugPrint('Error searching history: $e');

      // Fallback to local filtering if database search fails
      _applyLocalSearchFilter();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredHistoryItems = [];
    } else {
      _applyLocalSearchFilter();
    }
  }

  void _applyLocalSearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredHistoryItems = [];
      return;
    }

    _filteredHistoryItems = _historyItems.where((item) {
      try {
        final response = item['response'];
        if (response == null) return false;

        final searchText = _searchQuery.toLowerCase();
        final status = item['status']?.toString().toLowerCase() ?? '';
        final diseaseName = response.diseaseInfo?.name?.toLowerCase() ?? '';
        final description = response.diseaseInfo?.description?.toLowerCase() ?? '';
        final care = response.data?.care?.toLowerCase() ?? '';

        return status.contains(searchText) ||
            diseaseName.contains(searchText) ||
            description.contains(searchText) ||
            care.contains(searchText);
      } catch (e) {
        debugPrint('Error filtering item: $e');
        return false;
      }
    }).toList();
  }

  Future<void> deleteHistoryItem(int id) async {
    try {
      await _localStorageService.deleteHistoryItem(id);
      await loadHistory(); // Reload history after deletion
    } catch (e) {
      _errorMessage = 'Error deleting item. Please try again.';
      debugPrint('Error deleting item: $e');
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _localStorageService.clearHistory();
      _historyItems = [];
      _filteredHistoryItems = [];
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error clearing history. Please try again.';
      debugPrint('Error clearing history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredHistoryItems = [];
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> resetDatabase() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _localStorageService.resetDatabase();
      _historyItems = [];
      _filteredHistoryItems = [];
      _errorMessage = '';
      await loadHistory();
    } catch (e) {
      _errorMessage = 'Failed to reset database.';
      debugPrint('Error resetting database: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
