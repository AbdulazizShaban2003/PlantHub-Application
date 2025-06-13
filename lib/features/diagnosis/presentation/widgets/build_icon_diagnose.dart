import 'package:flutter/material.dart';

import '../../../../core/widgets/outlined_button_widget.dart';

class BuildIconDiagnose extends StatelessWidget {
  const BuildIconDiagnose({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/icon_diagnosis.png',
            width: 100,
            height: 100,
            errorBuilder:
                (_, __, ___) => Container(
              width: 100,
              height: 100,
              color: Colors.grey.shade200,
              child: const Icon(
                Icons.eco,
                color: Color(0xFF00A67E),
                size: 40,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Check Your Plant',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Take photos, start diagnose diseases & get plant care tips',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  child: OutlinedButtonWidget(
                    nameButton: 'Diagnose',
                    onPressed: onPressed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
