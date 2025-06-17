import 'package:another_flushbar/flushbar_helper.dart';
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
import '../../../bookMark/data/datasource/bookmark_service.dart';
import '../../data/models/plant_model.dart';
import '../widgets/custom_no_plant_widget.dart';

class PopularArticlesView extends StatefulWidget {
  const PopularArticlesView({super.key});

  @override
  State<PopularArticlesView> createState() => _PopularArticlesViewState();
}

class _PopularArticlesViewState extends State<PopularArticlesView> {
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
              title: Text(
                AppKeyStringTr.popularArticles,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: SizeConfig().responsiveFont(22),
                ),
              ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(SizeConfig().width(0.0125)),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig().width(0.04),
                    vertical: SizeConfig().height(0.03)),
                child: TextFormField(
                  style: TextStyle(fontSize: SizeConfig().responsiveFont(13)),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, size: SizeConfig().responsiveFont(24)),
                    hintText: AppKeyStringTr.searchArticles,
                    hintStyle: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
                    suffixIcon: plantProvider.searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, size: SizeConfig().responsiveFont(24)),
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
          ..._buildAllArticles(plantProvider, context),
        ],
      ),
    );
  }

  List<Widget> _buildAllArticles(PlantViewModel plantProvider, BuildContext context) {
    if (plantProvider.isLoading) {
      return [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig().width(0.04)),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                  Padding(
                    // Responsive padding
                    padding: EdgeInsets.only(bottom: SizeConfig().height(0.03)),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: SizeConfig().height(0.25),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
                            ),
                          ),
                          SizedBox(height: SizeConfig().height(0.015)),
                          Container(
                            width: double.infinity,
                            height: SizeConfig().height(0.025),
                            color: Colors.white,
                          ),
                          SizedBox(height: SizeConfig().height(0.01)),
                          Container(
                            width: SizeConfig().width(0.5),
                            height: SizeConfig().height(0.02),
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
          padding: EdgeInsets.symmetric(horizontal: SizeConfig().width(0.04), vertical: SizeConfig().height(0.02)),
          sliver: SliverToBoxAdapter(
            child: Text(
              plantProvider.error!,
              style: TextStyle(color: Colors.red, fontSize: SizeConfig().responsiveFont(16)),
            ),
          ),
        ),
      ];
    }

    if (plantProvider.displayedPlants.isEmpty &&
        plantProvider.searchQuery.isNotEmpty) {
      return [
        SliverToBoxAdapter(
          child: CustomNoPlantWidget(),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig().width(0.04)),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final article = plantProvider.displayedPlants[index];
              return Padding(
                padding: EdgeInsets.only(bottom: SizeConfig().height(0.03)),
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
                        borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
                        child: CachedNetworkImage(
                          imageUrl: article.image,
                          width: double.infinity,
                          height: SizeConfig().height(0.25),
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          errorWidget: (context, url, error) =>
                              Container(
                                color: Colors.grey[200],
                                child: Icon( // Removed const
                                    Icons.error, color: Colors.red, size: SizeConfig().responsiveFont(30)),
                              ),
                          fadeInDuration: const Duration(milliseconds: 300),
                          fadeInCurve: Curves.easeIn,
                        ),
                      ),
                      SizedBox(height: SizeConfig().height(0.015)),

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
                          const Spacer(), // Keep const
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
  SizeConfig().init(context);

  final bookmarkService = Provider.of<BookmarkService>(context, listen: false);

  return StreamBuilder<bool>(
    stream: bookmarkService.getBookmarkStatusStream(article.id),
    builder: (context, snapshot) {
      final isBookmarked = snapshot.data ?? false;
      return PopupMenuButton<String>(
        color: Theme.of(context).scaffoldBackgroundColor,
        icon: Icon(Icons.more_vert, size: SizeConfig().responsiveFont(24),color: Theme.of(context).primaryColor,),
        onSelected: (value) => _handleMenuSelection(context, value, article),
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share, size: SizeConfig().responsiveFont(20),color: Theme.of(context).primaryColor,),
                SizedBox(width: SizeConfig().width(0.02)),
                Text('Share', style: Theme.of(context).textTheme.bodySmall),
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
                    color: Theme.of(context).primaryColor
                ),
                SizedBox(width: SizeConfig().width(0.02)),
                Text(isBookmarked ? 'remove bookmark' : 'add bookmark', style: Theme.of(context).textTheme.bodySmall),
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
        FlushbarHelper.createSuccess(message: 'remove bookmark').show(context);
      }
    } else {
      await bookmarkService.addBookmark(article.id);
      if (context.mounted) {
        FlushbarHelper.createSuccess(message: 'add bookmark').show(context);


      }
    }
  }
}
