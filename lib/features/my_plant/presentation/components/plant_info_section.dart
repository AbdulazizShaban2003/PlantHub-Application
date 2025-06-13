import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../models/notification_model.dart';
import '../components/plant_action_indicator.dart';

class PlantInfoSection extends StatelessWidget {
  final Plant plant;

  const PlantInfoSection({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.category,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Added ${DateFormatter.formatDate(plant.createdAt)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              _buildActionIndicators(),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plant.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIndicators() {
    return Wrap(
      spacing: 8,
      children: plant.actions
          .where((action) => action.isEnabled)
          .map((action) => PlantActionIndicator(action: action))
          .toList(),
    );
  }
}