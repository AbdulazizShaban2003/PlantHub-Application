import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/articles/view_model.dart' show PlantViewModel;
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../config/routes/route_helper.dart';
import '../../../articles/data/models/plant_model.dart';
import '../../../articles/presentation/views/article_plant_details_view.dart';
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

  Widget _buildPlantCard(Plant plant) {
    return Container(
      height: 280,
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              RouteHelper.navigateTo(
                ArticlePlantDetailsView(plantId: plant.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة النبات
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: CachedNetworkImage(
                        imageUrl: plant.image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error, color: Colors.red, size: 40),
                        ),
                      ),
                    ),
                  ),
                  // وصف النبات
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plant.name ?? 'Unknown Plant',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              plant.description ?? 'No description available',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: BookmarkButton(
                    itemId: plant.id,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlantList(List<Plant> bookmarkedPlants) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: bookmarkedPlants.length,
        itemBuilder: (context, index) {
          final plant = bookmarkedPlants[index];
          return _buildPlantCard(plant);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.close),
        ),
        body: Center(
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
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        leading: GestureDetector(
            onTap: (){Navigator.pop(context);},
            child: Icon(Icons.close,size: 25,)),
      ),
      body: StreamBuilder<List<Plant>>(
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
      ),
    );
  }
}
