import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import 'custom_app_bar_home_view.dart';
import 'custom_ask_expert.dart';
import 'custom_explore_book.dart';
import 'custom_explore_plant.dart';
import 'custom_popular_articles.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: CustomAppBarHomeView(),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(CupertinoIcons.search),
                    hintText: AppKeyStringTr.searchPlant,
                  ),
                ),
                SizedBox(height: SizeConfig().height(0.02)),
                CustomPopularArticles(),
                CustomAskExpert(),
                SizedBox(height: SizeConfig().height(0.025)),
                CustomExplorBook(),
                SizedBox(height: SizeConfig().height(0.03)),
                CustomExplorePlant(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
