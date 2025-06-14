class DiseaseModel {
  final String id;
  final String name;
  final String image;
  final String description;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> treatment;

  DiseaseModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.treatment,
  });

  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    return DiseaseModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      symptoms: List<String>.from(json['symptoms']?.map((e) => e.toString()) ?? []),
      causes: List<String>.from(json['causes']?.map((e) => e.toString()) ?? []),
      treatment: List<String>.from(json['treatment']?.map((e) => e.toString()) ?? []),
    );
  }

  factory DiseaseModel.fromFirestore(String id, Map<String, dynamic> data) {
    return DiseaseModel(
      id: id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      symptoms: List<String>.from(data['symptoms'] ?? []),
      causes: List<String>.from(data['causes'] ?? []),
      treatment: List<String>.from(data['treatment'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'description': description,
      'symptoms': symptoms,
      'causes': causes,
      'treatment': treatment,
    };
  }
}
