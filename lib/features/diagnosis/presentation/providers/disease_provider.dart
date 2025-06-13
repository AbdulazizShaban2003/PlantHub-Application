import 'package:flutter/foundation.dart';

import '../../data/disease_info.dart';
import '../../doamin/disease_service.dart';

class DiseaseProvider with ChangeNotifier {
  List<DiseaseModel> _diseases = [];
  List<DiseaseModel> _commonDiseases = [];
  bool _isLoading = false;
  String _errorMessage = '';
  DiseaseModel? _selectedDisease;

  // Getters
  List<DiseaseModel> get diseases => _diseases;
  List<DiseaseModel> get commonDiseases => _commonDiseases;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  DiseaseModel? get selectedDisease => _selectedDisease;

  // Load all diseases
  Future<void> loadAllDiseases() async {
    _setLoading(true);
    try {
      final loadedDiseases = await DiseaseService.getAllDiseases();
      _diseases = loadedDiseases;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to load diseases: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Load common diseases
  Future<void> loadCommonDiseases({int limit = 5}) async {
    _setLoading(true);
    try {
      final loadedDiseases = await DiseaseService.getRandomDiseases(limit: limit);
      _commonDiseases = loadedDiseases;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to load common diseases: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Load disease by ID
  Future<void> loadDiseaseById(String diseaseId) async {
    _setLoading(true);
    try {
      final disease = await DiseaseService.getDiseaseById(diseaseId);
      _selectedDisease = disease;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to load disease details: $e';
      print(_errorMessage);
      _selectedDisease = null;
    } finally {
      _setLoading(false);
    }
  }

  // Search diseases
  Future<List<DiseaseModel>> searchDiseases(String query) async {
    _setLoading(true);
    try {
      final results = await DiseaseService.searchDiseases(query);
      _errorMessage = '';
      _setLoading(false);
      return results;
    } catch (e) {
      _errorMessage = 'Failed to search diseases: $e';
      print(_errorMessage);
      _setLoading(false);
      return [];
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear selected disease
  void clearSelectedDisease() {
    _selectedDisease = null;
    notifyListeners();
  }
}
