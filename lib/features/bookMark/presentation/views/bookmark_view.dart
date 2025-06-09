import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/articles/view_model.dart' show PlantViewModel;
import 'package:provider/provider.dart';

import '../../../../config/routes/route_helper.dart';
import '../../../articles/data/models/plant_model.dart';
import '../../../articles/presentation/views/article_plant_details_view.dart';
import '../../../articles/presentation/widgets/plant_card_widget.dart';
import '../../../auth/presentation/views/login_view.dart';
import '../widgets/bookmark_button.dart';

class BookmarkView extends StatefulWidget {
  const BookmarkView({super.key, required this.plantProvider});
  final PlantViewModel plantProvider;

  @override
  State<BookmarkView> createState() => _BookmarkViewState();
}

class _BookmarkViewState extends State<BookmarkView> {
  Future<void> _refreshData() async {
    await widget.plantProvider.fetchAllPlants();
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Failed to load bookmarks'),
          Text(
            'Please try again later',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bookmark_border, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No bookmarked articles yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the bookmark icon to save articles',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantList(List<Plant> bookmarkedPlants) {
    return RefreshIndicator(
      onRefresh: _refreshData,
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
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.login, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Please login to view your bookmarks'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  RouteHelper.navigateTo(const LoginView()),
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<Plant>>(
      stream: widget.plantProvider.getBookmarkedPlantsStream(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error!);
        }

        final bookmarkedPlants = snapshot.data ?? [];
        return bookmarkedPlants.isEmpty
            ? _buildEmptyState()
            : _buildPlantList(bookmarkedPlants);
      },
    );
  }
}