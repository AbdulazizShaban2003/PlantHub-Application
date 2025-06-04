import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/routes/route_helper.dart';
import 'package:plant_hub_app/features/articles/presentation/views/article_plant_details_view.dart';
import 'package:plant_hub_app/features/articles/view_model.dart';
import 'package:plant_hub_app/features/home/presentation/widgets/custom_category_card.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/errors/flush_bar.dart';
import '../../../../core/function/flush_bar_fun.dart';
import '../../../auth/presentation/views/login_view.dart';
import '../../../bookMark/bookmark_button.dart';
import '../../data/models/plant_model.dart';
import '../widgets/custom_no_plant_widget.dart';
import '../widgets/plant_card_widget.dart';

class PlantsPage extends StatefulWidget {
  const PlantsPage({super.key});

  @override
  State<PlantsPage> createState() => _PlantsPageState();
}
class _PlantsPageState extends State<PlantsPage>  with SingleTickerProviderStateMixin{
  late TabController _tabController;
  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
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
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: const Text('Popular Articles'),
            centerTitle: true,
            pinned: true,
            floating: true,
            forceElevated: true,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'All Articles'),
                Tab(text: 'My Bookmarks'),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(1),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                child: TextFormField(
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
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAllArticles(plantProvider),
            _buildBookmarkedArticles(plantProvider,context),
          ],
        ),
      ),
    );
  }

  Widget _buildAllArticles(PlantViewModel plantProvider) {
     return CustomScrollView(
        slivers: [

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
                            Row(
                              children: [
                                SizedBox(
                                  width: 250,
                                  child: Text(
                                    article.description,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                BookmarkButton(itemId: article.id),

                              ],
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
    );
  }
}
// ... (الكود السابق يبقى كما هو حتى دالة _buildBookmarkedArticles)

Widget _buildBookmarkedArticles(PlantViewModel plantProvider, BuildContext context) {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Please login to view your bookmarks'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  return StreamBuilder<List<Plant>>(
    stream: plantProvider.getBookmarkedPlantsStream(context),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text('something went wrong: ${snapshot.error}'),
          ]
          ),
        );
      }

      final bookmarkedPlants = snapshot.data ?? [];

      if (bookmarkedPlants.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_border, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text('No bookmarked articles yet'),
              SizedBox(height: 8),
              Text(
                'Tap the bookmark icon to save articles',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await plantProvider.fetchAllPlants();
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final article = bookmarkedPlants[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            RouteHelper.navigateTo(
                              ArticlePlantDetailsView(plantId: article.id),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            PlantCard(
                              plantId: article.id,
                              imageUrl: article.image,
                              description: article.description,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  RouteHelper.navigateTo(
                                    ArticlePlantDetailsView(plantId: article.id),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: BookmarkButton(itemId: article.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: bookmarkedPlants.length,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}