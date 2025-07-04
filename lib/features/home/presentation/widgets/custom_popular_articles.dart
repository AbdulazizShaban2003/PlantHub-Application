import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/articles/presentation/views/article_plant_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:plant_hub_app/config/routes/route_helper.dart';
import 'package:plant_hub_app/features/articles/presentation/views/article_plant_details_view.dart';
import 'package:provider/provider.dart';
import '../../../../core/function/flush_bar_fun.dart';
import '../../../../core/function/plant_share.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../articles/data/models/plant_model.dart';
import '../../../articles/view_model.dart';
import '../../../bookMark/data/datasource/bookmark_service.dart';
import '../components/build_header.dart';

class CustomPopularArticles extends StatelessWidget {
  const CustomPopularArticles({super.key});

  @override
  Widget build(BuildContext context) {
    final plantProvider = Provider.of<PlantViewModel>(context, listen: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (plantProvider.allPlants.isEmpty && !plantProvider.isLoading) {
        plantProvider.fetchAllPlants();
      }
    });

    return Column(
      children: [
        BuildHeader(
          header: AppKeyStringTr.popularArticles,
          onTab: () {
            Navigator.push(context, RouteHelper.navigateTo(const PopularArticlesView()));
          },
        ),
        SizedBox(height: SizeConfig().height(0.035)),
        SizedBox(
          height: SizeConfig().width(0.65),
          child: _buildContent(plantProvider, context),
        ),
      ],
    );
  }

  Widget _buildContent(PlantViewModel plantProvider, BuildContext context) {
    if (plantProvider.isLoading && plantProvider.displayedPlants.isEmpty) {
      return _buildEnhancedShimmerEffect();
    }

    if (plantProvider.displayedPlants.isEmpty) {
      return Center(
        child: Text(
          'No articles available'.tr(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final article = plantProvider.displayedPlants[index];
        return _buildArticleItem(article, context, plantProvider );
      },
      separatorBuilder: (context, index) => SizedBox(width: SizeConfig().width(0.03)),
      itemCount: plantProvider.displayedPlants.length,
    );
  }

  Widget _buildArticleItem(Plant article, BuildContext context,PlantViewModel plantProvider) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          RouteHelper.navigateTo(ArticlePlantDetailsView(plantId: article.id)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: article.image,
              width: 220,
              height: 140,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildImageShimmer(),
              errorWidget: (context, url, error) => _buildErrorWidget(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 190,
                  child: _buildArticleText(article, context, plantProvider)),

              
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildArticleMenu(BuildContext context, Plant article) {
    SizeConfig().init(context);

    final bookmarkService = Provider.of<BookmarkService>(context, listen: false);

    return StreamBuilder<bool>(
      stream: bookmarkService.getBookmarkStatusStream(article.id),
      builder: (context, snapshot) {
        final isBookmarked = snapshot.data ?? false;
        return PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, size: SizeConfig().responsiveFont(24),color: Theme.of(context).primaryColor,),
          onSelected: (value) => _handleMenuSelection(context, value, article),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: SizeConfig().responsiveFont(20)),
                  SizedBox(width: SizeConfig().width(0.02)),
                  Text('Share', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'bookmark',
              child: Row(
                children: [
                  Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border_outlined,
                    size: SizeConfig().responsiveFont(18),
                  ),
                  SizedBox(width: SizeConfig().width(0.02)),
                  Text(isBookmarked ? 'remove bookmark' : 'add bookmark', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
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
      final isBookmarked = await bookmarkService.isBookmarked(article.id);
      if (isBookmarked) {
        await bookmarkService.removeBookmark(article.id);
        if (context.mounted) {
          FlushbarHelperTest.showSuccess(message: "remove bookmark", context: context);
        }
      } else {
        await bookmarkService.addBookmark(article.id);
        if (context.mounted) {
          FlushbarHelperTest.showSuccess(message: "add bookmark",context: context);

        }
      }
    }
  }

  
  Widget _buildEnhancedShimmerEffect() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      separatorBuilder: (context, index) => SizedBox(width: SizeConfig().width(0.03)),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          period: const Duration(milliseconds: 1500), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 220,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 220,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 180,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 220,
        height: 140,
        color: Colors.white,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: 220,
      height: 140,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 8),
          Text(
            'Failed to load image'.tr(),
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleText(Plant article, BuildContext context , PlantViewModel plantProvider) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plantProvider.isLoading)
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 220,
                height: 16,
                color: Colors.white,
              ),
            )
          else
            Text(
              article.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}