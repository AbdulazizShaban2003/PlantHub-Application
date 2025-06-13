import 'package:flutter/material.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/size_config.dart';
import '../../models/notification_model.dart';
import '../components/plant_action_indicator.dart';

class PlantInfoSection extends StatelessWidget {
  final Plant plant;

  const PlantInfoSection({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Container(
      padding: EdgeInsets.all(SizeConfig().width(0.05)),
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
                        fontSize: SizeConfig().responsiveFont(16),
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: SizeConfig().height(0.01)),
                    Text(
                      '${AppStrings.added} ${DateFormatter.formatDate(plant.createdAt)}',
                      style: TextStyle(
                        fontSize: SizeConfig().responsiveFont(14),
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: _buildActionIndicators(),
              ),
            ],
          ),
          SizedBox(height: SizeConfig().height(0.025)),
          Text(
            AppStrings.description,
            style: TextStyle(
              fontSize: SizeConfig().responsiveFont(18),
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: SizeConfig().height(0.01)),
          Text(
            plant.description,
            maxLines: 3,
            style: TextStyle(
              fontSize: SizeConfig().responsiveFont(16),
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
      spacing: SizeConfig().width(0.02),
      runSpacing: SizeConfig().height(0.01),
      children: plant.actions
          .where((action) => action.isEnabled)
          .map((action) => PlantActionIndicator(action: action))
          .toList(),
    );
  }
}
