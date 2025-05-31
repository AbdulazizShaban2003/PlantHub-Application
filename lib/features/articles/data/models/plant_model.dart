import 'package:cloud_firestore/cloud_firestore.dart';

import 'care_guide_model.dart';
import 'climatic_condition_model.dart';
import 'disease_model.dart';
import 'distribution.dart';

class Plant {
  final String id;
  final String name;
  final String description;
  final String category;
  final String image;
  final List<String> listImage;
  final Care care;
  final ClimaticConditions climaticConditions;
  final Distribution distribution;
  final List<Disease> diseases;

  Plant({
    this.id = '',
    required this.name,
    required this.description,
    required this.category,
    required this.image,
    required this.listImage,
    required this.care,
    required this.climaticConditions,
    required this.distribution,
    required this.diseases,
  });

  factory Plant.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Plant(
      id: doc.id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      description: data['description'] as String? ?? '',
      image: data['image'] as String? ?? '',
      listImage: List<String>.from(data['listImage'] as List? ?? []),
      care: Care.fromJson(Map<String, dynamic>.from(data['care'] as Map? ?? {})),
      climaticConditions: ClimaticConditions.fromJson(
        Map<String, dynamic>.from(data['climaticConditions'] as Map? ?? {}),
      ),
      diseases: (data['diseases'] as List<dynamic>?)
              ?.map((d) => Disease.fromJson(Map<String, dynamic>.from(d as Map)))
              .toList() ??
          [],
      distribution: Distribution.fromJson(
        Map<String, dynamic>.from(data['distribution'] as Map? ?? {}),
      ),

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'image': image,
      'listImage': listImage,
      'care': care.toJson(),
      'climaticConditions': climaticConditions.toJson(),
      'distribution': distribution.toJson(),
      'diseases': diseases.map((d) => d.toJson()).toList(),
    };
  }
}





