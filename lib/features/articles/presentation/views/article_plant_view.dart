import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/routes/route_helper.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'package:plant_hub_app/features/articles/presentation/views/article_plant_details_view.dart';
import 'package:plant_hub_app/features/articles/view_model.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/function/plant_share.dart';
import '../../../bookMark/data/models/datasource/bookmark_service.dart';
import '../../data/models/plant_model.dart';
import '../widgets/custom_no_plant_widget.dart';

class PopularArticlesView extends StatefulWidget {
  const PopularArticlesView({super.key});

  @override
  State<PopularArticlesView> createState() => _PopularArticlesViewState();
}

class _PopularArticlesViewState extends State<PopularArticlesView> {
  bool? _isBookmarked;
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
            backgroundColor: Theme
                .of(context)
                .appBarTheme
                .backgroundColor,
            title: Text(AppKeyStringTr.popularArticles,style:Theme.of(context).textTheme.headlineMedium),
            centerTitle: true,
            iconTheme: Theme.of(context).iconTheme
          ),
          SliverPadding(
            padding: const EdgeInsets.all(5),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig().width(0.04),
                    vertical: SizeConfig().height(0.03)),
                child: TextFormField(
                  style: TextStyle(fontSize: SizeConfig().responsiveFont(13)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: AppKeyStringTr.searchArticles,
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
          ..._buildAllArticles(plantProvider),
        ],
      ),
    );
  }

  List<Widget> _buildAllArticles(PlantViewModel plantProvider) {
    if (plantProvider.isLoading) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                  Padding(
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
              childCount: 3,
            ),
          ),
        ),
      ];
    }

    if (plantProvider.error != null) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          sliver: SliverToBoxAdapter(
            child: Text(
              plantProvider.error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ];
    }

    if (plantProvider.displayedPlants.isEmpty &&
        plantProvider.searchQuery.isNotEmpty) {
      return const [
        SliverToBoxAdapter(
          child: CustomNoPlantWidget(),
        ),
      ];
    }

    return [
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
                          placeholder: (context, url) =>
                              Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          errorWidget: (context, url, error) =>
                              Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                    Icons.error, color: Colors.red),
                              ),
                          fadeInDuration: const Duration(milliseconds: 300),
                          fadeInCurve: Curves.easeIn,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: SizeConfig().width(0.7),
                            child: Text(
                              article.description,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: SizeConfig().responsiveFont(15),
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          _buildArticleMenu(context, article),

                        ],
                      )
                    ],
                  ),
                ),
              );
            },
            childCount: plantProvider.displayedPlants.length,
          ),
        ),
      ),
    ];
  }
}

Widget _buildArticleMenu(BuildContext context, Plant article) {
  return FutureBuilder<bool>(
    future: Provider.of<BookmarkService>(context, listen: false)
        .isItemBookmarked(article.id),
    builder: (context, snapshot) {
      final isBookmarked = snapshot.data ?? false;
      return PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) => _handleMenuSelection(context, value, article),
        itemBuilder: (context) => [
          const PopupMenuItem<String>(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share, size: 20),
                SizedBox(width: 8),
                Text('Share'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'bookmark',
            child: Row(
              children: [
                Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border_outlined,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(isBookmarked ? 'remove bookmark' : 'add to bookmarks'),
              ],
            ),
          ),
        ],
      );
    },
  );
}

Future<void> _handleMenuSelection(
    BuildContext context, String value, Plant article) async {
  final bookmarkService = Provider.of<BookmarkService>(context, listen: false);

  if (value == 'share') {
    sharePlantDetails(plant: article, context: context);
  } else if (value == 'bookmark') {
    final isBookmarked = await bookmarkService.isItemBookmarked(article.id);
    if (isBookmarked) {
      await bookmarkService.removeBookmarkByItemId(article.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إزالة من المفضلة')),
      );
    } else {
      await bookmarkService.addBookmark(article.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت الإضافة إلى المفضلة')),
      );
    }
  }
}
