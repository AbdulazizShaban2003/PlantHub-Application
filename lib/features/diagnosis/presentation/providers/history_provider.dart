import 'package:flutter/foundation.dart';
import '../../doamin/local_storage_service.dart';

class HistoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _historyItems = [];
  bool _isLoading = false;
  String _errorMessage = '';
  final LocalStorageService _storageService = LocalStorageService();

  // Getters
  List<Map<String, dynamic>> get historyItems => _historyItems;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Load history
  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final history = await _storageService.getDiagnosisHistory();
      _historyItems = history;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error loading history: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search history
  Future<void> searchHistory(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = query.isEmpty
          ? await _storageService.getDiagnosisHistory()
          : await _storageService.searchHistory(query);
      
      _historyItems = results;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error searching history: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear history
  Future<void> clearHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.clearHistory();
      _historyItems = [];
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error clearing history: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete history item
  Future<void> deleteHistoryItem(int id) async {
    try {
      await _storageService.deleteHistoryItem(id);
      await loadHistory(); // Reload history after deletion
    } catch (e) {
      _errorMessage = 'Error deleting item: $e';
      print(_errorMessage);
      notifyListeners();
    }
  }
}
