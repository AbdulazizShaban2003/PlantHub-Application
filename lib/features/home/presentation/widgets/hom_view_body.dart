import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../account/presentation/manager/profile_provider.dart';
import '../../../articles/view_model.dart';
import '../../../diagnosis/presentation/providers/disease_provider.dart';
import 'custom_app_bar_home_view.dart';
import 'custom_ask_expert.dart';
import 'custom_explore_book.dart';
import 'custom_popular_articles.dart';
import 'explore_plant_category.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final plantProvider = Provider.of<PlantViewModel>(context, listen: true);
    final provider = context.watch<ProfileProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.loadProfile();
      if (plantProvider.allPlants.isEmpty && !plantProvider.isLoading) {
        plantProvider.fetchAllPlants();
      }
    });
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: CustomAppBarHomeView(plantProvider: plantProvider),
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () async {
            await plantProvider.fetchAllPlants();
            await provider.loadProfile();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  TextFormField(
                    onChanged: (query) {
                      Provider.of<DiseaseProvider>(
                        context,
                        listen: false,
                      ).searchDiseases(query);
                      plantProvider.searchPlants(query);
                      Provider.of<DiseaseProvider>(
                        context,
                        listen: false,
                      ).searchDiseases(query);
                    },
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
                  ExplorePlantsCategory(),
                  SizedBox(height: SizeConfig().height(0.07)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

