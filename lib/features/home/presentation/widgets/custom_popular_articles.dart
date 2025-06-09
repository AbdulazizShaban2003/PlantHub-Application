import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/articles/presentation/views/article_plant_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:plant_hub_app/config/routes/route_helper.dart';
import 'package:plant_hub_app/features/articles/presentation/views/article_plant_details_view.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../articles/view_model.dart';
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
        BuildHeader(header: AppKeyStringTr.popularArticles, onTab: () {Navigator.push(context, RouteHelper.navigateTo(const PopularArticlesView()));  },),
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
      return _buildShimmerEffect(context);
    }

    if (plantProvider.displayedPlants.isEmpty) {
      return Center(child: Text('No articles available'.tr()));
    }

    return ListView.separated(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final article = plantProvider.displayedPlants[index];
        return InkWell(
          onTap: () {
            Navigator.push(
                context,
                RouteHelper.navigateTo(ArticlePlantDetailsView(plantId: article.id))
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
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
                  fadeInDuration: const Duration(milliseconds: 300),
                  fadeInCurve: Curves.easeIn,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 220,
                child: Text(
                  article.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => SizedBox(width: SizeConfig().width(0.03)),
      itemCount: plantProvider.displayedPlants.length,
    );
  }

  Widget _buildShimmerEffect(BuildContext context) {
    final plantProvider = Provider.of<PlantViewModel>(context, listen: true);

    return ListView.separated(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: plantProvider.displayedPlants.length,
      separatorBuilder: (context, index) => SizedBox(width: SizeConfig().width(0.03)),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
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
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Container(
                width: 180,
                height: 16,
                color: Colors.white,
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
}