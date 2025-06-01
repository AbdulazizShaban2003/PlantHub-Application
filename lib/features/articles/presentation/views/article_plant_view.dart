import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/routes/route_helper.dart';
import 'package:plant_hub_app/features/articles/presentation/views/article_plant_details_view.dart';
import 'package:plant_hub_app/features/articles/view_model.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/custom_no_plant_widget.dart';

class PlantsPage extends StatelessWidget {
  const PlantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final plantProvider = Provider.of<PlantViewModel>(context, listen: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (plantProvider.allPlants.isEmpty && !plantProvider.isLoading) {
        plantProvider.fetchAllPlants();
      }
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Popular Articles'),
            centerTitle: true,
            pinned: true,
            floating: true,
            expandedHeight: 0,
            forceElevated: true,
          ),

          SliverPadding(
            padding: const EdgeInsets.all(1),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search articles..',
                      suffixIcon: plantProvider.searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => plantProvider.clearSearch(),
                      )
                          : null,
                    ),
                    onChanged: (value) {
                      plantProvider.searchPlants(value);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          if (plantProvider.isLoading)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 200,
                          height: 16,
                          color: Colors.white,
                        ),
                        ],
                      ),
                    ),
                  ),
                  childCount: 3, // 3 placeholder items while loading
                ),
              ),
            ),

          if (plantProvider.error != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  plantProvider.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),

          if (!plantProvider.isLoading &&
              plantProvider.displayedPlants.isEmpty &&
              plantProvider.searchQuery.isNotEmpty)
            const SliverToBoxAdapter(
              child: CustomNoPlantWidget(),
            ),

          if (!plantProvider.isLoading && plantProvider.error == null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final article = plantProvider.displayedPlants[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            RouteHelper.navigateTo(
                              ArticlePlantDetailsView(plantId: article.id),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: article.image,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.error, color: Colors.red),
                                ),
                                fadeInDuration: const Duration(milliseconds: 300),
                                fadeInCurve: Curves.easeIn,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              article.description,
                              maxLines: 2,
                              style: const TextStyle(
                                fontSize: 18,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: plantProvider.displayedPlants.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}