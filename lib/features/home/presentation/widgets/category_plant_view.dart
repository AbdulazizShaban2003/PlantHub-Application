import 'package:flutter/material.dart';
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
    final plantProvider = Provider.of<PlantViewModel>(context, listen: true);

    final List<Plant> categoryPlants = plantProvider.getPlantsByCategory(widget.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getCategoryTitle(widget.category),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: plantProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryPlants.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                plantProvider.fetchAllPlants().then((_) {
                  plantProvider.fetchPlantsByCategory(widget.category);
                });
              },
              child: const Text('Refresh'),
            ),
          ],
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categoryPlants.length,
        itemBuilder: (context, index) {
          final plant = categoryPlants[index];
          return _buildPlantCard(context, plant);
        },
      ),
    );
  }

  Widget _buildPlantCard(BuildContext context, Plant plant) {
    return GestureDetector(
      onTap: () {
        // Navigate to plant details
        final plantProvider = Provider.of<PlantViewModel>(context, listen: false);
        plantProvider.fetchPlantById(plant.id);
        // Navigate to plant details page
        // Navigator.push(context, MaterialPageRoute(builder: (context) => PlantDetailsView()));
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
            // Plant image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                plant.image,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  );
                },
              ),
            ),
            // Plant details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plant.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
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