import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/asstes_manager.dart';
import '../../providers/plant_provider.dart';
import '../../services/notification_service.dart';
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
    final width = SizeConfig().width(0.05);
    final height = SizeConfig().width(0.05);
    final fontSize = SizeConfig().responsiveFont(14);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Image(
            image: AssetImage(AssetsManager.iconPlant),
            height: SizeConfig().height(0.06),
          ),
        ),
        title: Text(
          'My Plants',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_active,
              size: SizeConfig().responsiveFont(24),
            ),
            onPressed: () async {
              try {
                final notificationService = NotificationService();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: width,
                          height: height,
                          child: CircularProgressIndicator(
                            strokeWidth: SizeConfig().width(0.005),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: SizeConfig().width(0.04)),
                        Text(
                          'Scheduling test notification...',
                          style: TextStyle(fontSize: fontSize),
                        ),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
                await notificationService.scheduleTestNotification();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: SizeConfig().responsiveFont(20),
                        ),
                        SizedBox(width: SizeConfig().width(0.02)),
                        Text(
                          'Test notification scheduled for 5 seconds!',
                          style: TextStyle(fontSize: fontSize),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          Icons.error,
                          color: Colors.white,
                          size: SizeConfig().responsiveFont(20),
                        ),
                        SizedBox(width: SizeConfig().width(0.02)),
                        Expanded(
                          child: Text(
                            'Error: ${e.toString()}',
                            style: TextStyle(fontSize: fontSize),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'My Plant'),
                Tab(text: 'Herbs'),
              ],
              labelColor: ColorsManager.greenPrimaryColor,
              unselectedLabelColor: Colors.grey,
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
        children: const [
          PlantsContent(),
          Center(child: Text('Herbs Content')),
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
              MaterialPageRoute(
                builder: (context) => const AddPlantScreen(),
              ),
            ).then((_) {
              if (mounted) {
                context.read<PlantProvider>().loadPlants();
              }
            });
          },
          backgroundColor: ColorsManager.greenPrimaryColor,
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: SizeConfig().responsiveFont(33),
          ),
        ),
      )
          : _tabController.index == 1
          ? Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          heroTag: 'harvest_fab', // Tag مختلف
          onPressed: () {
            // action for Harvest tab if needed
          },
          backgroundColor: ColorsManager.greenPrimaryColor,
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: SizeConfig().responsiveFont(33),
          ),
        ),
      )
          : null,

    );
  }
}
