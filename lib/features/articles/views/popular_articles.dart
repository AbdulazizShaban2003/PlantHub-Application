import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'package:provider/provider.dart';
import '../view_model/plant_provider.dart';

enum Menu { share, addToBookmark }

class PopularArticles extends StatelessWidget {
  const PopularArticles({super.key});

  static AnimationStyle animationStyle = AnimationStyle(
    curve: Curves.easeInOut,
    duration: Duration(milliseconds: 300),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(AppKeyStringTr.popularArticles,
                style: Theme.of(context).textTheme.headlineMedium),
            centerTitle: true,
            floating: true,
            snap: true,
          ),
          Consumer<PlantProvider>(
            builder: (context, provider, child) {
              return SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search articles..',
                      ),
                      onChanged: (value) {
                        provider.searchArticles(value);
                      },
                    ),
                    SizedBox(height: SizeConfig().height(0.05)),

                    if (provider.isSearching)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (!provider.isSearching && provider.filteredArticles.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image(image: AssetImage('assets/images/no_searsh.png'),height: 200,),
                            Text(
                              'No Plants Found',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: SizeConfig().height(0.02)),
                            Text(
                              'Check your keywords or try searching with another keywords.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ]),
                ),
              );
            },
          ),
          Consumer<PlantProvider>(
            builder: (context, provider, child) {
              if (provider.isSearching || provider.filteredArticles.isEmpty) {
                return SliverToBoxAdapter();
              }
              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final article = provider.filteredArticles[index];
                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: Image.network(
                              article.imageUrl,
                              height: SizeConfig().height(0.3),
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: SizeConfig().height(0.01)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 270,
                                child: Text(
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  article.title,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              PopupMenuButton<Menu>(
                                popUpAnimationStyle: animationStyle,
                                icon: const Icon(Icons.more_vert, size: 20),
                                onSelected: (Menu item) {
                                  switch (item) {
                                    case Menu.addToBookmark:
                                      provider.toggleBookmark(article.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            article.isBookmarked
                                                ? 'Added to bookmarks'
                                                : 'Removed from bookmarks',
                                          ),
                                        ),
                                      );
                                      break;
                                    case Menu.share:
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
                                  PopupMenuItem<Menu>(
                                    height: 40,
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    value: Menu.addToBookmark,
                                    child: SizedBox(
                                      width: 120,
                                      child: ListTile(
                                        dense: true,
                                        visualDensity: VisualDensity.compact,
                                        contentPadding: EdgeInsets.zero,
                                        leading: Icon(
                                          article.isBookmarked
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                          size: 18,
                                        ),
                                        title: Text(
                                          'Bookmark',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem<Menu>(
                                    height: 40,
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    value: Menu.share,
                                    child: SizedBox(
                                      width: 120,
                                      child: ListTile(
                                        dense: true,
                                        visualDensity: VisualDensity.compact,
                                        contentPadding: EdgeInsets.zero,
                                        leading: Icon(
                                          Icons.share_outlined,
                                          size: 18,
                                        ),
                                        title: Text(
                                          'Share',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: SizeConfig().height(0.02)),
                        ],
                      );
                    },
                    childCount: provider.filteredArticles.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}