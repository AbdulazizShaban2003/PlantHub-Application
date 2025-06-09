class DiseaseModel {
  final String id;
  final String name;
  final String image;
  final String description;
  final List<String> images;
  final String treatment;

  DiseaseModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.images,
    required this.treatment,
  });

  // Create DiseaseModel from Firestore document
  factory DiseaseModel.fromFirestore(String id, Map<String, dynamic> data) {
    return DiseaseModel(
      id: id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      treatment: data['treatment'] ?? '',
    );
  }

  // Convert DiseaseModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'description': description,
      'images': images,
      'treatment': treatment,
    };
  }

  DiseaseModel copyWith({
    String? id,
    String? name,
    String? image,
    String? description,
    List<String>? images,
    String? treatment,
  }) {
    return DiseaseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      description: description ?? this.description,
      images: images ?? this.images,
      treatment: treatment ?? this.treatment,
    );
  }

  @override
  String toString() {
    return 'DiseaseModel(id: $id, name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiseaseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
