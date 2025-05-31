import 'package:flutter/material.dart';

import '../../data/models/care_guide_model.dart';
import '../sections/care_item_section.dart';
import '../sections/title_section.dart';

class CareTab extends StatelessWidget {
  final Care care;


  const CareTab({super.key, required this.care});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionTitle(title: 'Watering', icon: Icons.water),
        CareItem(
          title: 'Frequency',
          content: care.fertilizer.frequency,
          icon: Icons.schedule,
        ),
        CareItem(
          title: 'Notes',
          content: care.water.notes,
          icon: Icons.opacity,
        ),

        SectionTitle(title: 'Fertilizing', icon: Icons.nature_people),
        CareItem(
          title: 'Type',
          content: care.fertilizer.type,
          icon: Icons.local_florist,
        ),
        CareItem(
          title: 'Frequency',
          content: care.fertilizer.frequency,
          icon: Icons.schedule_send,
        ),
        CareItem(
          title: 'Warning',
          content: care.fertilizer.warning,
          icon: Icons.warning_amber_outlined,
        ),

        SectionTitle(title: 'Humidity', icon: Icons.cut),
        CareItem(
          title: 'preference',
          content: care.humidity.preference,
          icon: Icons.water_drop_outlined,
        ),
        CareItem(
          title: 'risk',
          content: care.humidity.risk,
          icon: Icons.water_drop_rounded,
        ),
        SectionTitle(title: 'Propagation', icon: Icons.cut),
        CareItem(
          title: 'Method',
          content: care.propagation.method,
          icon: Icons.add_circle_outline,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: care.propagation.steps.map((material) {
            return CareItem(
              title: 'Step ${care.propagation.steps.indexOf(material) + 1}',
              content: material,
              icon: Icons.check_circle_outline,
            );
          }).toList(),
        )


      ],
    );
  }
}
