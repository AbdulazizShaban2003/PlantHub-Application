import 'package:flutter/material.dart';

import '../../../../core/utils/size_config.dart';
import '../../providers/plant_provider.dart';

class ErrorPlantWidget extends StatelessWidget {
  const ErrorPlantWidget({
    super.key, required this.plantProvider,
  });
  final PlantProvider plantProvider;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error,
              size: SizeConfig().height(0.1), color: Colors.red),
          SizedBox(height: SizeConfig().height(0.02)),
          Text(
            'Error: ${plantProvider.error}',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.red,
                fontSize: SizeConfig().responsiveFont(16)),
          ),
          SizedBox(height: SizeConfig().height(0.02)),
          ElevatedButton(
            onPressed: () {
              plantProvider.clearError();
              plantProvider.loadPlants();
            },
            child: Text('Retry',
                style: TextStyle(
                    fontSize: SizeConfig().responsiveFont(16))),
          ),
        ],
      ),
    );
  }
}
