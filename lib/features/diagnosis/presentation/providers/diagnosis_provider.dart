import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/plant_diagnosis_response_model.dart';
import '../../doamin/diagnosis_api_service.dart';
import '../../doamin/local_storage_service.dart';


enum DiagnosisStatus {
  initial,
  loading,
  noPlant,
  healthy,
  diseased,
  error,
}

class DiagnosisProvider with ChangeNotifier {
  DiagnosisStatus _status = DiagnosisStatus.initial;
  String _imagePath = '';
  PlantDiagnosisResponse? _diagnosisResponse;
  String _errorMessage = '';

  final DiagnosisApiService _apiService = DiagnosisApiService();
  final LocalStorageService _localStorageService = LocalStorageService();

  // Getters
  DiagnosisStatus get status => _status;
  String get imagePath => _imagePath;
  PlantDiagnosisResponse? get diagnosisResponse => _diagnosisResponse;
  String get errorMessage => _errorMessage;

  void resetDiagnosis() {
    _status = DiagnosisStatus.initial;
    _imagePath = '';
    _diagnosisResponse = null;
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> processImage(String imagePath) async {
    _imagePath = imagePath;
    _status = DiagnosisStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _diagnosisResponse = await _apiService.diagnosePlant(imagePath);
      await _handleDiagnosisResult(_diagnosisResponse!);
    } catch (e) {
      _status = DiagnosisStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> _handleDiagnosisResult(PlantDiagnosisResponse response) async {
    final status = response.status.toLowerCase();
    final dataCategory = response.data.category.toLowerCase();
    final dataDisease = response.data.disease.toLowerCase();
    final diseaseDescription = response.diseaseInfo.description.toLowerCase();

    print('API Status: $status');
    print('Data Category: $dataCategory');
    print('Data Disease: $dataDisease');
    print('Disease Description: $diseaseDescription');

    // Check if it's not a plant
    if (dataCategory.contains('not') && dataCategory.contains('plant')) {
      _status = DiagnosisStatus.noPlant;
    }
    else if (dataDisease.contains('not') && dataDisease.contains('plant')) {
      _status = DiagnosisStatus.noPlant;
    }
    else if (status.contains('no') && status.contains('plant')) {
      _status = DiagnosisStatus.noPlant;
    }
    // Check if it's healthy - Updated logic for new API response
    else if (_isHealthyPlant(dataDisease, diseaseDescription, response)) {
      _status = DiagnosisStatus.healthy;
      await _saveToHistory(response);
    }
    // Check if it's diseased
    else if (_isDiseasedPlant(dataDisease, response)) {
      _status = DiagnosisStatus.diseased;
      await _saveToHistory(response);
    }
    // Default case for success status
    else if (status.contains('success')) {
      // If we have disease information with actual disease data, it's diseased
      if (response.diseaseInfo.name.isNotEmpty ||
          response.diseaseInfo.treatments.isNotEmpty) {
        _status = DiagnosisStatus.diseased;
        await _saveToHistory(response);
      }
      // If description suggests healthy or we have care instructions, it's healthy
      else if (diseaseDescription.contains('healthy') ||
          diseaseDescription.contains('no disease') ||
          response.data.care.isNotEmpty) {
        _status = DiagnosisStatus.healthy;
        await _saveToHistory(response);
      }
      else {
        _status = DiagnosisStatus.noPlant;
      }
    }
    else {
      _status = DiagnosisStatus.error;
      _errorMessage = 'Unable to process diagnosis result. Please try again.';
    }

    print('Final Status: $_status');
    notifyListeners();
  }

  bool _isHealthyPlant(String dataDisease, String diseaseDescription, PlantDiagnosisResponse response) {
    // Check for explicit healthy indicators
    if (dataDisease.contains('healthy') ||
        diseaseDescription.contains('healthy') ||
        diseaseDescription.contains('the plant is healthy')) {
      return true;
    }

    // Check for "no disease" indicators
    if (diseaseDescription.contains('no disease') ||
        diseaseDescription.contains('not diseased')) {
      return true;
    }

    // Check if disease field contains healthy pattern like "Grape___healthy"
    if (dataDisease.contains('___healthy') ||
        dataDisease.endsWith('_healthy')) {
      return true;
    }

    return false;
  }

  bool _isDiseasedPlant(String dataDisease, PlantDiagnosisResponse response) {
    // Check if we have actual disease information
    if (response.diseaseInfo.name.isNotEmpty &&
        !response.diseaseInfo.name.toLowerCase().contains('healthy')) {
      return true;
    }

    if (response.diseaseInfo.treatments.isNotEmpty) {
      return true;
    }

    // Check for disease patterns in data.disease field
    if (dataDisease.isNotEmpty &&
        !dataDisease.contains('healthy') &&
        !dataDisease.contains('normal') &&
        dataDisease != 'none') {

      // Check for disease keywords
      List<String> diseaseKeywords = [
        'scab', 'blight', 'rot', 'wilt', 'spot', 'rust', 'mildew',
        'canker', 'virus', 'bacterial', 'fungal', 'infection',
        'diseased', 'disease', 'sick', 'infected', 'pathogen'
      ];

      for (String keyword in diseaseKeywords) {
        if (dataDisease.contains(keyword)) {
          return true;
        }
      }

      // Check for disease naming patterns like "Apple___Apple_scab"
      if (dataDisease.contains('___') && !dataDisease.contains('healthy')) {
        return true;
      }
    }

    return false;
  }

  Future<void> _saveToHistory(PlantDiagnosisResponse response) async {
    try {
      await _localStorageService.saveDiagnosisToHistory(
        response: response,
        imagePath: _imagePath,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // Don't fail the diagnosis if history saving fails
      debugPrint('Error saving to history: $e');
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}


