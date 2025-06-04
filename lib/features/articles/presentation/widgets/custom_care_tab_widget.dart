import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';

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
        SectionTitle(title: AppKeyStringTr.watering, icon: Icons.water),
        CareItem(
          title: AppKeyStringTr.frequency,
          content: care.fertilizer.frequency,
          icon: Icons.schedule,
        ),
        CareItem(
          title: AppKeyStringTr.notes,
          content: care.water.notes,
          icon: Icons.opacity,
        ),

        SectionTitle(title: AppKeyStringTr.fertilizing, icon: Icons.nature_people),
        CareItem(
          title: AppKeyStringTr.type,
          content: care.fertilizer.type,
          icon: Icons.local_florist,
        ),
        CareItem(
          title: AppKeyStringTr.frequency,
          content: care.fertilizer.frequency,
          icon: Icons.schedule_send,
        ),
        CareItem(
          title: AppKeyStringTr.warning,
          content: care.fertilizer.warning,
          icon: Icons.warning_amber_outlined,
        ),

        SectionTitle(title: AppKeyStringTr.humidity, icon: Icons.cut),
        CareItem(
          title: AppKeyStringTr.preference,
          content: care.humidity.preference,
          icon: Icons.water_drop_outlined,
        ),
        CareItem(
          title: AppKeyStringTr.risk,
          content: care.humidity.risk,
          icon: Icons.water_drop_rounded,
        ),
        SectionTitle(title: AppKeyStringTr.propagation, icon: Icons.cut),
        CareItem(
          title: AppKeyStringTr.method,
          content: care.propagation.method,
          icon: Icons.add_circle_outline,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: care.propagation.steps.map((material) {
            return CareItem(
              title: '${AppKeyStringTr.step} ${care.propagation.steps.indexOf(material) + 1}',
              content: material,
              icon: Icons.check_circle_outline,
            );
          }).toList(),
        )


      ],
    );
  }
}
