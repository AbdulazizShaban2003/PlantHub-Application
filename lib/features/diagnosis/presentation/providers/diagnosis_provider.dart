import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../data/disease_info.dart';
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
  DiseaseModel? _detectedDisease;
  String _errorMessage = '';
  final LocalStorageService _storageService = LocalStorageService();

  // Getters
  DiagnosisStatus get status => _status;
  String get imagePath => _imagePath;
  DiseaseModel? get detectedDisease => _detectedDisease;
  String get errorMessage => _errorMessage;

  // Reset diagnosis
  void resetDiagnosis() {
    _status = DiagnosisStatus.initial;
    _imagePath = '';
    _detectedDisease = null;
    _errorMessage = '';
    notifyListeners();
  }

  // Process image for diagnosis
  Future<void> processImage(String imagePath) async {
    _imagePath = imagePath;
    _status = DiagnosisStatus.loading;
    notifyListeners();

    try {
      // In a real app, you would send the image to your API
      // For demo purposes, we'll simulate an API response
      await Future.delayed(Duration(seconds: 2));
       
      // Simulate API call
      final result = await _simulateApiCall(imagePath);
      
      await _handleDiagnosisResult(result);
    } catch (e) {
      _status = DiagnosisStatus.error;
      _errorMessage = 'Error processing image: $e';
      print(_errorMessage);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _simulateApiCall(String imagePath) async {
    final random = DateTime.now().millisecondsSinceEpoch % 3;
    
    if (random == 0) {
      return {'diagnosis_type': 'No Plant'};
    } else if (random == 1) {
      return {'diagnosis_type': 'Healthy'};
    } else {
      return {
        'diagnosis_type': 'Diseased',
        'disease_data': {
          'id': 'disease-1',
          'name': 'Leaf Spot',
          'image': 'https://example.com/leaf-spot.jpg',
          'description': 'A common fungal disease that affects many plants, causing spots on leaves.',
          'symptoms': [
            'Brown or black spots on leaves',
            'Yellow halos around spots',
            'Leaves turning yellow and falling off'
          ],
          'causes': [
            'Fungal pathogens',
            'Wet conditions',
            'Poor air circulation'
          ],
          'treatment': [
            'Remove and destroy affected leaves',
            'Apply fungicide',
            'Improve air circulation around plants',
            'Avoid overhead watering'
          ],
        },
      };
    }
  }

  // Handle diagnosis result
  Future<void> _handleDiagnosisResult(Map<String, dynamic> result) async {
    final diagnosisType = result['diagnosis_type'];
    
    switch (diagnosisType) {
      case 'No Plant':
        _status = DiagnosisStatus.noPlant;
        break;
      
      case 'Healthy':
        _status = DiagnosisStatus.healthy;
        // Save to history
        await _saveToHistory('Healthy', null);
        break;
      
      case 'Diseased':
        _status = DiagnosisStatus.diseased;
        final diseaseData = DiseaseModel.fromJson(result['disease_data']);
        _detectedDisease = diseaseData;
        // Save to history
        await _saveToHistory('Diseased', diseaseData);
        break;
      
      default:
        _status = DiagnosisStatus.error;
        _errorMessage = 'Unknown diagnosis result';
    }
    
    notifyListeners();
  }

  // Save diagnosis to history
  Future<void> _saveToHistory(String type, DiseaseModel? disease) async {
    try {
      await _storageService.saveDiagnosisToHistory(
        type: type,
        disease: disease,
        imagePath: _imagePath,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Error saving to history: $e');
    }
  }
}
