import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../articles/view_model.dart';
import 'category_plant_view.dart';
import 'custom_app_bar_home_view.dart';
import 'custom_ask_expert.dart';
import 'custom_explore_book.dart';
import 'custom_explore_plant.dart';
import 'custom_popular_articles.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final plantProvider = Provider.of<PlantViewModel>(context, listen: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (plantProvider.allPlants.isEmpty && !plantProvider.isLoading) {
        plantProvider.fetchAllPlants();
      }
    });
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: CustomAppBarHomeView(plantProvider:plantProvider ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(CupertinoIcons.search),
                    hintText: AppKeyStringTr.searchPlant,
                  ),
                ),
                SizedBox(height: SizeConfig().height(0.02)),
                CustomPopularArticles(),
                CustomAskExpert(),
                SizedBox(height: SizeConfig().height(0.025)),
                CustomExplorBook(),
                SizedBox(height: SizeConfig().height(0.03)),
                SizedBox(
                  height: 900,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildCategoryCard(
                          context: context,
                          title: 'Succulents\n& Cacti',
                          imagePath: 'assets/images/categoies/succulents Cacti.png',
                          category: 'succulents',
                        ),
                        _buildCategoryCard(
                          context: context,
                          title: 'Flowering\nPlants',
                          imagePath: 'assets/images/categoies/flowers.png',
                          category: 'flowering',
                        ),
                        _buildCategoryCard(
                          context: context,
                          title: 'Trees',
                          imagePath: 'assets/images/categoies/trees.png',
                          category: 'trees',
                        ),
                        _buildCategoryCard(
                          context: context,
                          title: 'Fruits',
                          imagePath: 'assets/images/categoies/fruits.png',
                          category: 'fruits',
                        ),
                        _buildCategoryCard(
                          context: context,
                          title: 'Vegetables',
                          imagePath: 'assets/images/vegetables.png',
                          category: 'vegetables',
                        ),
                        _buildCategoryCard(
                          context: context,
                          title: 'Herbs',
                          imagePath: 'assets/images/categoies/herbs.png',
                          category: 'herbs',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
Widget _buildCategoryCard({
  required BuildContext context,
  required String title,
  required String imagePath,
  required String category,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryPlantsView(category: category),
        ),
      );
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 60,
            width: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.local_florist,
                size: 60,
                color: Colors.green[300],
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}