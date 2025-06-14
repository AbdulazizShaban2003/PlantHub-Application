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

  Future<void> loadCommonDiseases() async {
    _setLoading(true);
    try {
      final loadedDiseases = await DiseaseService.getAllDiseasesWithoutLimit();
      _commonDiseases = loadedDiseases;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to load diseases: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearSelectedDisease() {
    _selectedDisease = null;
    notifyListeners();
  }
}
