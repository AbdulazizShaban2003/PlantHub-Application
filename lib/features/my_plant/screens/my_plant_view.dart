import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/asstes_manager.dart';
import '../presentation/widgets/empty_plant_widget.dart';
import '../presentation/widgets/error_plant_widget.dart';
import '../presentation/widgets/plant_Cart_widget.dart';
import '../providers/plant_provider.dart';
import '../services/database_helper.dart';
import 'add_plant_screen.dart';
import 'notifications_screen.dart';
import '../services/notification_service.dart';

class MyPlantView extends StatefulWidget {
  const MyPlantView({super.key});

  @override
  State<MyPlantView> createState() => _MyPlantViewState();
}

class _MyPlantViewState extends State<MyPlantView> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PlantsTab(),
    const NotificationsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PlantProvider>().loadPlants();
        context.read<NotificationProvider>().loadNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.eco, size: SizeConfig().responsiveFont(24)),
            label: 'Plants',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.notifications, size: SizeConfig().responsiveFont(24)),
                Consumer<NotificationProvider>(
                  builder: (context, provider, child) {
                    final unreadCount = provider.unreadCount;
                    if (unreadCount > 0) {
                      return Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(SizeConfig().width(0.01)),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(
                                SizeConfig().width(0.015)),
                          ),
                          constraints: BoxConstraints(
                            minWidth: SizeConfig().width(0.03),
                            minHeight: SizeConfig().width(0.03),
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: SizeConfig().responsiveFont(10),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            label: 'Notifications',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
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
          size: SizeConfig().responsiveFont(24),
        ),
      )
          : null,
    );
  }
}

class PlantsTab extends StatelessWidget {
  const PlantsTab({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        leading:Padding(
          padding: const EdgeInsets.all(9.0),
          child: Image(image: AssetImage(AssetsManager.iconPlant),height: SizeConfig().height(0.06),),
        ),
        title: Text(
          'My Plant',
          style: Theme.of(context).textTheme.headlineSmall
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
                          width: SizeConfig().width(0.05),
                          height: SizeConfig().width(0.05),
                          child: CircularProgressIndicator(
                            strokeWidth: SizeConfig().width(0.005),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: SizeConfig().width(0.04)),
                        Text('Scheduling test notification...',
                            style: TextStyle(
                                fontSize: SizeConfig().responsiveFont(14))),
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
                        Icon(Icons.check_circle,
                            color: Colors.white,
                            size: SizeConfig().responsiveFont(20)),
                        SizedBox(width: SizeConfig().width(0.02)),
                        Text('🧪 Test notification scheduled for 5 seconds!',
                            style: TextStyle(
                                fontSize: SizeConfig().responsiveFont(14))),
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
                        Icon(Icons.error,
                            color: Colors.white,
                            size: SizeConfig().responsiveFont(20)),
                        SizedBox(width: SizeConfig().width(0.02)),
                        Expanded(
                            child: Text('Error: ${e.toString()}',
                                style: TextStyle(
                                    fontSize: SizeConfig().responsiveFont(14)))),
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
      ),
      body: Consumer<PlantProvider>(
        builder: (context, plantProvider, child) {
          if (plantProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (plantProvider.error != null) {
            return  ErrorPlantWidget(plantProvider: plantProvider,);
          }
          if (plantProvider.plants.isEmpty) {
            return const EmptyPlantsWidget();
          }
          return RefreshIndicator(
            onRefresh: () => plantProvider.loadPlants(),
            child: ListView.builder(
              padding: EdgeInsets.all(SizeConfig().width(0.04)),
              itemCount: plantProvider.plants.length,
              itemBuilder: (context, index) {
                final plant = plantProvider.plants[index];
                return MyPlantCard(plant: plant);
              },
            ),
          );
        },
      ),
    );
  }
}



