import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'package:plant_hub_app/features/articles/view_model.dart'
    show PlantViewModel;
import '../../../articles/data/models/plant_model.dart';
import '../widgets/access_login_bookmark.dart';
import '../widgets/build_error_widget.dart';
import '../widgets/build_plant_article_card.dart';

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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: SizeConfig().responsiveFont(48),
            color: ColorsManager.greyColor,
          ),
          SizedBox(height: SizeConfig().height(0.02)),
          Text(
            AppStrings.noBookmarksTitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: SizeConfig().responsiveFont(18),
            ),
          ),
          SizedBox(height: SizeConfig().height(0.01)),
          Text(
            AppStrings.noBookmarksSubtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ColorsManager.greyColor,
              fontSize: SizeConfig().responsiveFont(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantList(List<Plant> bookmarkedPlants) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: EdgeInsets.all(SizeConfig().width(0.06)),
        itemCount: bookmarkedPlants.length,
        itemBuilder: (context, index) {
          final plant = bookmarkedPlants[index];
          return buildPlantCard(plant, context);
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
          leading: Icon(Icons.close, size: SizeConfig().responsiveFont(24)),
        ),
        body: loginAccountViewBookMark(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
          size: SizeConfig().responsiveFont(24),
        ),
        title: Text(AppStrings.myBookMark,style: Theme.of(context).textTheme.headlineSmall,),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.close, size: SizeConfig().responsiveFont(35)),
        ),
      ),
      body: StreamBuilder<List<Plant>>(
        stream: widget.plantProvider.getBookmarkedPlantsStream(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return buildErrorWidget(snapshot.error!, context, _refreshData);
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

