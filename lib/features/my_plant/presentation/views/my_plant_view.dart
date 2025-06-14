import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/routes/route_helper.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/asstes_manager.dart';
import '../../providers/plant_provider.dart';
import '../widgets/harvest_content_widget.dart';
import '../widgets/plant_content_widget.dart';
import 'add_plant_screen.dart';

class MyPlantView extends StatefulWidget {
  const MyPlantView({super.key});

  @override
  State<MyPlantView> createState() => _MyPlantViewState();
}

class _MyPlantViewState extends State<MyPlantView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PlantProvider>().loadPlants();
        context.read<NotificationProvider>().loadNotifications();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Image(
            image: AssetImage(AssetsManager.iconPlant),
            height: SizeConfig().height(0.05),
          ),
        ),
        title: Text(
          AppStrings.myPlant,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              controller: _tabController,
              tabs:  [
                Tab(text: AppStrings.myPlant),
                Tab(text: AppStrings.harvest),
              ],
              labelColor: ColorsManager.greenPrimaryColor,
              unselectedLabelColor: Theme.of(context).primaryColor,
              indicatorColor: ColorsManager.greenPrimaryColor,
              indicatorWeight: 3.0,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              labelStyle: TextStyle(
                fontSize: SizeConfig().responsiveFont(16),
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: SizeConfig().responsiveFont(14),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const PlantsContent(),
          HarvestGuideWidget(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          heroTag: 'plants_fab',
          onPressed: () {
            Navigator.push(
              context,
              RouteHelper.navigateTo(const AddPlantScreen())).then((_) {
              if (mounted) {
                context.read<PlantProvider>().loadPlants();
              }
            });
          },
          backgroundColor: ColorsManager.greenPrimaryColor,
          child: Icon(
            Icons.add,
            color: ColorsManager.whiteColor,
            size: SizeConfig().responsiveFont(33),
          ),
        ),
      )
          : _tabController.index == 1
          ? Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          heroTag: 'harvest_fab',
          onPressed: () {
          },
          backgroundColor: ColorsManager.greenPrimaryColor,
          child: Icon(
            Icons.add,
            color: ColorsManager.whiteColor,
            size: SizeConfig().responsiveFont(33),
          ),
        ),
      )
          : null,

    );
  }
}
