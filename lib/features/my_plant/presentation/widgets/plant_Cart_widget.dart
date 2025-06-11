import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/size_config.dart' show SizeConfig;
import '../../models/notification_model.dart';
import '../../providers/plant_provider.dart';
import '../../screens/edit_plant_screen.dart' show EditPlantScreen;
import '../../screens/plant_detail_screen.dart';

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
              // Plant Image
              Hero(
                tag: 'plant_image_${plant.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SizeConfig().width(0.02)),
                  child: Container(
                    width: SizeConfig().height(0.08),
                    height: SizeConfig().height(0.08),
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
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
              SizedBox(width: SizeConfig().width(0.04)),

              // Plant Info
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
                          color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: SizeConfig().height(0.01)),

                    // Action Indicators
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
                              color: Colors.white,
                            ),
                          ),
                        )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // More Options
              IconButton(
                onPressed: () => _showPlantOptions(context, plant),
                icon: Icon(Icons.more_vert,
                    size: SizeConfig().responsiveFont(24)),
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
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(SizeConfig().width(0.04)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.visibility,
                  size: SizeConfig().responsiveFont(24)),
              title: Text('View Details',
                  style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
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
              title: Text('Edit Plant',
                  style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
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
                  color: Colors.red, size: SizeConfig().responsiveFont(24)),
              title: Text(
                'Delete Plant',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: SizeConfig().responsiveFont(16)),
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
        title: Text('Delete Plant',
            style: TextStyle(fontSize: SizeConfig().responsiveFont(18))),
        content: Text('Are you sure you want to delete ${plant.name}?',
            style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete',
                style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
          ),
        ],
      ),
    );
  }
}