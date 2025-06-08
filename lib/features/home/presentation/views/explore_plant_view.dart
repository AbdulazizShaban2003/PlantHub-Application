import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../articles/data/models/plant_model.dart';
import '../../../articles/view_model.dart';
import '../../controller/home_controller.dart';
import '../widgets/category_plant_view.dart';

class ExplorePlantView extends StatefulWidget {
  const ExplorePlantView({super.key});

  @override
  State<ExplorePlantView> createState() => _ExplorePlantViewState();
}

class _ExplorePlantViewState extends State<ExplorePlantView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plantProvider = Provider.of<PlantViewModel>(context, listen: false);
      if (plantProvider.allPlants.isEmpty && !plantProvider.isLoading) {
        plantProvider.fetchAllPlants();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plantProvider = Provider.of<PlantViewModel>(context, listen: true);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar with back button and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Explore Plants',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }


}


