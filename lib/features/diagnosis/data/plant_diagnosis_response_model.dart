class PlantDiagnosisResponse {
  final String status;
  final DiagnosisData data;
  final DiseaseInfo diseaseInfo;

  PlantDiagnosisResponse({
    required this.status,
    required this.data,
    required this.diseaseInfo,
  });

  factory PlantDiagnosisResponse.fromJson(Map<String, dynamic> json) {
    return PlantDiagnosisResponse(
      status: json['status'] ?? '',
      data: DiagnosisData.fromJson(json['data'] ?? {}),
      diseaseInfo: DiseaseInfo.fromJson(json['disease_info'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
      'disease_info': diseaseInfo.toJson(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}

class DiagnosisData {
  final String category;
  final String disease;
  final String care;

  DiagnosisData({
    required this.category,
    required this.disease,
    required this.care,
  });

  factory DiagnosisData.fromJson(Map<String, dynamic> json) {
    return DiagnosisData(
      category: json['category'] ?? '',
      disease: json['disease'] ?? '',
      care: json['care'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'disease': disease,
      'care': care,
    };
  }
}

class DiseaseInfo {
  final String name;
  final String plantType;
  final String description;
  final List<Treatment> treatments;

  DiseaseInfo({
    required this.name,
    required this.plantType,
    required this.description,
    required this.treatments,
  });

  factory DiseaseInfo.fromJson(Map<String, dynamic> json) {
    var treatmentsList = json['treatments'] as List<dynamic>?;
    List<Treatment> parsedTreatments = treatmentsList != null
        ? treatmentsList.map((i) => Treatment.fromJson(i as Map<String, dynamic>)).toList()
        : [];

    return DiseaseInfo(
      name: json['name'] ?? '',
      plantType: json['plant_type'] ?? '',
      description: json['description'] ?? '',
      treatments: parsedTreatments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'plant_type': plantType,
      'description': description,
      'treatments': treatments.map((e) => e.toJson()).toList(),
    };
  }
}

class Treatment {
  final String name;
  final String description;

  Treatment({
    required this.name,
    required this.description,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
