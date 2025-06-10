import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/routes/route_helper.dart';
import 'package:plant_hub_app/core/cache/cache_network_image.dart';
import 'package:plant_hub_app/features/articles/presentation/views/article_plant_details_view.dart';
import 'package:provider/provider.dart';

import '../../../articles/data/models/plant_model.dart';
import '../../../articles/view_model.dart';

class CategoryPlantsView extends StatefulWidget {
  final String category;

  const CategoryPlantsView({
    super.key,
    required this.category,
  });

  @override
  State<CategoryPlantsView> createState() => _CategoryPlantsViewState();
}

class _CategoryPlantsViewState extends State<CategoryPlantsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plantProvider = Provider.of<PlantViewModel>(context, listen: false);
      if (plantProvider.allPlants.isEmpty) {
        plantProvider.fetchAllPlants().then((_) {
          plantProvider.fetchPlantsByCategory(widget.category);
        });
      } else {
        plantProvider.fetchPlantsByCategory(widget.category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final plantProvider = Provider.of<PlantViewModel>(context);
    final List<Plant> categoryPlants = plantProvider.getPlantsByCategory(widget.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getCategoryTitle(widget.category),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor
        ),
      ),
      body: Column(
        children: [
          Divider(),
          plantProvider.isLoading
              ? Expanded(child: const Center(child: CircularProgressIndicator()))
              : Expanded(
                child: RefreshIndicator(
                            onRefresh: () async {
                await plantProvider.fetchAllPlants();
                await plantProvider.fetchPlantsByCategory(widget.category);
                            },
                            child: categoryPlants.isEmpty
                  ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 100,),
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ${_getCategoryTitle(widget.category)} found',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try refreshing or check back later',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                            )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: categoryPlants.length,
                itemBuilder: (context, index) {
                  final plant = categoryPlants[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildPlantCard(context, plant,index),
                  );
                },
                            ),
                          ),
              ),
        ],
      ),
    );
  }
  Widget _buildPlantCard(BuildContext context, Plant plant,int index) {

    return GestureDetector(
      onTap: () {
        final plantProvider = Provider.of<PlantViewModel>(context, listen: false);
        Navigator.push(context, RouteHelper.navigateTo(ArticlePlantDetailsView(plantId: plantProvider.displayedPlants[index].id)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:  BorderRadius.circular(12),
              child: CacheNetworkImage(imageUrl: plant.image, width: double.infinity, height: 200)

            ),
            // Plant details
          ],
        ),
      ),
    );
  }

  String _getCategoryTitle(String category) {
    switch (category) {
      case 'succulents':
        return 'Succulents & Cacti';
      case 'flowering':
        return 'Flowering Plants';
      case 'foliage':
        return 'Foliage Plants';
      case 'trees':
        return 'Trees';
      case 'shrubs':
        return 'Weeds & Shrubs';
      case 'fruits':
        return 'Fruits';
      case 'vegetables':
        return 'Vegetables';
      case 'herbs':
        return 'Herbs';
      case 'mushrooms':
        return 'Mushrooms';
      case 'toxic':
        return 'Toxic Plants';
      default:
        return category.substring(0, 1).toUpperCase() + category.substring(1);
    }
  }
}