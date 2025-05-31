import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

class CareItem extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const CareItem({super.key,
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: ColorsManager.greenPrimaryColor),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold,color: Colors.black87),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(content,style: TextStyle(
              color: Colors.black
          ),),
        ),
        minVerticalPadding: 16,
      ),
    );
  }
}
