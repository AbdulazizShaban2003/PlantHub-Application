import 'package:flutter/material.dart';

import '../../data/models/disease_model.dart';
import '../components/disease_cart_component.dart';
import '../views/article_plant_details_view.dart';

class DiseasesTab extends StatelessWidget {
  final List<Disease> diseases;

  const DiseasesTab({super.key, required this.diseases});

  @override
  Widget build(BuildContext context) {
    if (diseases.isEmpty) {
      return const EmptyStateView(
        icon: Icons.health_and_safety,
        message: 'No disease information available',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: diseases.length,
      itemBuilder: (context, index) => DiseaseCard(disease: diseases[index]),
    );
  }
}
