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

    if (status.contains('no') && status.contains('plant')) {
      _status = DiagnosisStatus.noPlant;
    } else if (status.contains('healthy')) {
      _status = DiagnosisStatus.healthy;
      await _saveToHistory(response);
    } else if (status.contains('diseased') || response.diseaseInfo.name.isNotEmpty) {
      _status = DiagnosisStatus.diseased;
      await _saveToHistory(response);
    } else {
      _status = DiagnosisStatus.error;
      _errorMessage = 'Unknown diagnosis result: $status';
    }

    notifyListeners();
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
