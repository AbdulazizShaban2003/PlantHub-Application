import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';

import '../../data/models/care_guide_model.dart';
import '../sections/care_item_section.dart';
import '../sections/title_section.dart';

class CareTab extends StatelessWidget {
  final Care? care;

  const CareTab({super.key, required this.care});

  @override
  Widget build(BuildContext context) {
    if (care == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_florist, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No care information available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (care!.water != null) ...[
          SectionTitle(title: AppKeyStringTr.watering, icon: Icons.water),
          if (care!.water!.frequency != null)
            CareItem(
              title: AppKeyStringTr.frequency,
              content: care!.water!.frequency!,
              icon: Icons.schedule,
            ),
          if (care!.water!.notes != null)
            CareItem(
              title: AppKeyStringTr.notes,
              content: care!.water!.notes!,
              icon: Icons.opacity,
            ),
        ],

        if (care!.fertilizer != null) ...[
          SectionTitle(title: AppKeyStringTr.fertilizing, icon: Icons.nature_people),
          if (care!.fertilizer!.type != null)
            CareItem(
              title: AppKeyStringTr.type,
              content: care!.fertilizer!.type!,
              icon: Icons.local_florist,
            ),
          if (care!.fertilizer!.frequency != null)
            CareItem(
              title: AppKeyStringTr.frequency,
              content: care!.fertilizer!.frequency!,
              icon: Icons.schedule_send,
            ),
          if (care!.fertilizer!.warning != null)
            CareItem(
              title: AppKeyStringTr.warning,
              content: care!.fertilizer!.warning!,
              icon: Icons.warning_amber_outlined,
            ),
        ],

        if (care!.humidity != null) ...[
          SectionTitle(title: AppKeyStringTr.humidity, icon: Icons.water_drop),
          if (care!.humidity!.preference != null)
            CareItem(
              title: AppKeyStringTr.preference,
              content: care!.humidity!.preference!,
              icon: Icons.water_drop_outlined,
            ),
          if (care!.humidity!.risk != null)
            CareItem(
              title: AppKeyStringTr.risk,
              content: care!.humidity!.risk!,
              icon: Icons.water_drop_rounded,
            ),
        ],

        if (care!.propagation != null) ...[
          SectionTitle(title: AppKeyStringTr.propagation, icon: Icons.cut),
          if (care!.propagation!.method != null)
            CareItem(
              title: AppKeyStringTr.method,
              content: care!.propagation!.method!,
              icon: Icons.add_circle_outline,
            ),
          if (care!.propagation!.steps != null)
            ...care!.propagation!.steps!.asMap().entries.map((entry) {
              return CareItem(
                title: '${AppKeyStringTr.step} ${entry.key + 1}',
                content: entry.value,
                icon: Icons.check_circle_outline,
              );
            }).toList(),
        ],
      ],
    );
  }
}
