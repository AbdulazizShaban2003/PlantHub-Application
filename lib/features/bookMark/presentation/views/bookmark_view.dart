import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/articles/view_model.dart' show PlantViewModel;

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
  @override
  Widget build(BuildContext context) {
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
      stream: widget.plantProvider.getBookmarkedPlantsStream(context),
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
            await widget.plantProvider.fetchAllPlants();
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
}
