import 'package:flutter/material.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../controller/home_controller.dart';
import '../components/build_header.dart';
import 'custom_category_card.dart';

class CustomExplorePlant extends StatefulWidget {
  const CustomExplorePlant({super.key});

  @override
  State<CustomExplorePlant> createState() => _CustomExplorePlantState();
}
final List<PlantCategory> plantCategories = [
  PlantCategory('Succulents\n& Cacti', Icons.local_florist),
  PlantCategory('Flowering\nPlants', Icons.local_florist),
  PlantCategory('Foliage\nPlants', Icons.eco),
  PlantCategory('Trees', Icons.park),
  PlantCategory('Weeds &\nShrubs', Icons.grass),
  PlantCategory('Fruits', Icons.apple),
  PlantCategory('Vegetables', Icons.restaurant),
  PlantCategory('Herbs', Icons.local_pharmacy),
  PlantCategory('Mushrooms', Icons.umbrella),
  PlantCategory('Toxic Plants', Icons.warning),
];

class _CustomExplorePlantState extends State<CustomExplorePlant> {
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.all(16),
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: plantCategories.length,
          itemBuilder: (context, index) {
            return PlantCategoryCard(
              category: plantCategories[index],
              onTap: () {
                // Handle category tap
              },
            );
          },
        ),
      ),
    );

  }
}
class PlantCategory {
  final String name;
  final IconData icon;

  PlantCategory(this.name, this.icon);
}

class PlantCategoryCard extends StatelessWidget {
  final PlantCategory category;
  final VoidCallback onTap;

  const PlantCategoryCard({
    Key? key,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                category.icon,
                color: Colors.green[600],
                size: 24,
              ),
            ),
            SizedBox(height: 12),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}