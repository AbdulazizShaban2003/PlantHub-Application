import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/routes/route_helper.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart' show SizeConfig;
import '../../data/models/notification_model.dart';
import '../../providers/plant_provider.dart';
import '../views/edit_plant_view.dart';
import '../views/plant_detail_view.dart';

class MyPlantCard extends StatelessWidget {
  final Plant plant;

  const MyPlantCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {

    final displayActions =
    plant.actions.where((action) => action.isEnabled).take(4).toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            RouteHelper.navigateTo(PlantDetailScreen(plant: plant))
        ).then((_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<PlantProvider>().loadPlants();
            }
          });
        });
      },
      child: Card(
        color: Theme.of(context).scaffoldBackgroundColor,
        margin: EdgeInsets.only(bottom: SizeConfig().height(0.02)),
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig().width(0.03))),
        child: Padding(
          padding: EdgeInsets.all(SizeConfig().width(0.04)),
          child: Row(
            children: [
              Hero(
                tag: 'plant_image_${plant.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SizeConfig().width(0.02)),
                  child: Container(
                    width: SizeConfig().width(0.3),
                    height: SizeConfig().height(0.15),
                    color: Colors.grey[200],
                    child: plant.mainImagePath.isNotEmpty &&
                        File(plant.mainImagePath).existsSync()
                        ? Image.file(
                      File(plant.mainImagePath),
                      fit: BoxFit.cover,
                    )
                        : Icon(
                      Icons.eco,
                      size: SizeConfig().height(0.04),
                      color: ColorsManager.greenPrimaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: SizeConfig().width(0.04)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      style: TextStyle(
                        fontSize: SizeConfig().responsiveFont(18),
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: SizeConfig().height(0.005)),
                    Text(
                      plant.category,
                      style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(14),
                          color: Colors.grey[800]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: SizeConfig().height(0.01)),

                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: SizeConfig().width(0.01),
                        runSpacing: SizeConfig().width(0.01),
                        children: displayActions
                            .map(
                              (action) => Container(
                            width: SizeConfig().height(0.025),
                            height: SizeConfig().height(0.025),
                            decoration: BoxDecoration(
                              color: action.type.color,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              action.type.icon,
                              size: SizeConfig().height(0.015),
                              color: ColorsManager.whiteColor,
                            ),
                          ),
                        )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () => _showPlantOptions(context, plant),
                icon: Icon(Icons.more_vert,
                    size: SizeConfig().responsiveFont(24)),
                color: Theme.of(context).primaryColor,
                constraints: BoxConstraints(
                  minWidth: SizeConfig().height(0.05),
                  minHeight: SizeConfig().height(0.05),
                ),
                padding: EdgeInsets.all(SizeConfig().width(0.02)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlantOptions(BuildContext context, Plant plant) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(SizeConfig().width(0.04)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.visibility,
                  size: SizeConfig().responsiveFont(24)),
              title: Text(AppStrings.viewDetails,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w500
                  )

              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlantDetailScreen(plant: plant),
                  ),
                ).then((_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      context.read<PlantProvider>().loadPlants();
                    }
                  });
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, size: SizeConfig().responsiveFont(24)),
              title: Text(AppStrings.editPlant,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w500
                  )),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPlantScreen(plant: plant),
                  ),
                ).then((_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      context.read<PlantProvider>().loadPlants();
                    }
                  });
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.delete,
                  color: ColorsManager.redColor, size: SizeConfig().responsiveFont(24)),
              title: Text(
                AppStrings.deletePlant,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w500
                )
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, plant);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Plant plant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.deletePlant,
            style: TextStyle(fontSize: SizeConfig().responsiveFont(18))),
        content: Text('${AppStrings.confirmDeletePlant} ${plant.name}?',
            style:  Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w500
                )

            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.read<PlantProvider>().deletePlant(plant.id);
                }
              });
            },
            style: TextButton.styleFrom(foregroundColor: ColorsManager.redColor),
            child: Text(AppStrings.deletePlant,
                style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
          ),
        ],
      ),
    );
  }
}
