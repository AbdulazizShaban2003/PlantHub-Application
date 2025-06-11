import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/my_plant/presentation/widgets/plant_Cart_widget.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/size_config.dart';
import '../../providers/plant_provider.dart';
import 'empty_plant_widget.dart';
import 'error_plant_widget.dart';

class PlantsContent extends StatelessWidget {
  const PlantsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantProvider>(
      builder: (context, plantProvider, child) {
        if (plantProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (plantProvider.error != null) {
          return ErrorPlantWidget(plantProvider: plantProvider);
        }
        if (plantProvider.plants.isEmpty) {
          return const EmptyPlantsWidget();
        }
        return RefreshIndicator(
          onRefresh: () => plantProvider.loadPlants(),
          child: ListView.builder(
            padding: EdgeInsets.all(SizeConfig().width(0.04)),
            itemCount: plantProvider.plants.length,
            itemBuilder: (context, index) {
              final plant = plantProvider.plants[index];
              return MyPlantCard(plant: plant);
            },
          ),
        );
      },
    );
  }
}