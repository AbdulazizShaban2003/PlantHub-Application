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
      // Handle both string and object for disease field
      diseaseInfo: _parseDiseaseInfo(json['disease'] ?? json['disease_info'] ?? {}),
    );
  }

  static DiseaseInfo _parseDiseaseInfo(dynamic diseaseData) {
    // If disease is a string (healthy plant case)
    if (diseaseData is String) {
      return DiseaseInfo(
        name: '',
        plantType: '',
        description: diseaseData, // Use the string as description
        treatments: [],
      );
    }

    // If disease is a Map (diseased plant case)
    if (diseaseData is Map<String, dynamic>) {
      return DiseaseInfo.fromJson(diseaseData);
    }

    // Fallback for empty or null data
    return DiseaseInfo(
      name: '',
      plantType: '',
      description: '',
      treatments: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
      'disease': diseaseInfo.toJson(),
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
      category: json['category'] ?? json['type'] ?? '',
      disease: json['disease'] ?? json['message'] ?? '',
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
  final int? id;
  final String name;
  final String plantType;
  final String description;
  final int? adminId;
  final String? createdAt;
  final String? updatedAt;
  final List<Treatment> treatments;

  DiseaseInfo({
    this.id,
    required this.name,
    required this.plantType,
    required this.description,
    this.adminId,
    this.createdAt,
    this.updatedAt,
    required this.treatments,
  });

  factory DiseaseInfo.fromJson(Map<String, dynamic> json) {
    var treatmentsList = json['treatments'] as List<dynamic>?;
    List<Treatment> parsedTreatments = treatmentsList != null
        ? treatmentsList.map((i) => Treatment.fromJson(i as Map<String, dynamic>)).toList()
        : [];

    return DiseaseInfo(
      id: json['id'],
      name: json['name'] ?? '',
      plantType: json['plant_type'] ?? '',
      description: json['description'] ?? '',
      adminId: json['admin_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      treatments: parsedTreatments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plant_type': plantType,
      'description': description,
      'admin_id': adminId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'treatments': treatments.map((e) => e.toJson()).toList(),
    };
  }
}

class Treatment {
  final int? id;
  final String name;
  final String type;
  final String description;
  final int? adminId;
  final String? createdAt;
  final String? updatedAt;
  final TreatmentPivot? pivot;

  Treatment({
    this.id,
    required this.name,
    required this.type,
    required this.description,
    this.adminId,
    this.createdAt,
    this.updatedAt,
    this.pivot,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      adminId: json['admin_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      pivot: json['pivot'] != null
          ? TreatmentPivot.fromJson(json['pivot'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'admin_id': adminId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'pivot': pivot?.toJson(),
    };
  }
}

class TreatmentPivot {
  final int? diseaseId;
  final int? treatmentId;

  TreatmentPivot({
    this.diseaseId,
    this.treatmentId,
  });

  factory TreatmentPivot.fromJson(Map<String, dynamic> json) {
    return TreatmentPivot(
      diseaseId: json['disease_id'],
      treatmentId: json['treatment_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disease_id': diseaseId,
      'treatment_id': treatmentId,
    };
  }
}
