import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plant_provider.dart';
import '../models/notification_model.dart';
import '../services/database_helper.dart';
import 'add_plant_screen.dart';
import 'edit_plant_screen.dart';
import 'plant_detail_screen.dart';
import 'notifications_screen.dart'; // Import the notifications screen
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PlantsTab(),
    const NotificationsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlantProvider>().loadPlants();
      context.read<NotificationProvider>().loadNotifications();
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Plants',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                Consumer<NotificationProvider>(
                  builder: (context, provider, child) {
                    final unreadCount = provider.unreadCount;
                    if (unreadCount > 0) {
                      return Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
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
            MaterialPageRoute(builder: (context) => const AddPlantScreen()),
          ).then((_) {
            // Refresh data when returning from add plant screen
            context.read<PlantProvider>().loadPlants();
          });
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
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
        title: const Text(
          'My Plant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              try {
                print('Test notification button pressed');
                final notificationService = NotificationService();

                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text('Scheduling test notification...'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );

                await notificationService.scheduleTestNotification();

                // Hide loading and show success
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('🧪 Test notification scheduled for 5 seconds!'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );

              } catch (e) {
                print('Error in test notification: $e');

                // Hide loading and show error
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Error: ${e.toString()}'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'Settings',
                      textColor: Colors.white,
                      onPressed: () {
                        // You can add code here to open app settings
                        print('Open notification settings');
                      },
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Test Notifications',
          ),
        ],
      ),
      body: Consumer<PlantProvider>(
        builder: (context, plantProvider, child) {
          if (plantProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (plantProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${plantProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      plantProvider.clearError();
                      plantProvider.loadPlants();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (plantProvider.plants.isEmpty) {
            return const EmptyPlantsWidget();
          }

          return RefreshIndicator(
            onRefresh: () => plantProvider.loadPlants(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: plantProvider.plants.length,
              itemBuilder: (context, index) {
                final plant = plantProvider.plants[index];
                return PlantCard(plant: plant);
              },
            ),
          );
        },
      ),
    );
  }
}

class EmptyPlantsWidget extends StatelessWidget {
  const EmptyPlantsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco,
              size: 60,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'You Have No Plants',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You haven\'t added any plants yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPlantScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Plant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class PlantCard extends StatelessWidget {
  final Plant plant;

  const PlantCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to plant detail screen when card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailScreen(plant: plant),
          ),
        ).then((_) {
          // Refresh data when returning from detail screen
          context.read<PlantProvider>().loadPlants();
        });
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Plant Image
              Hero(
                tag: 'plant_image_${plant.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: plant.mainImagePath.isNotEmpty && File(plant.mainImagePath).existsSync()
                        ? Image.file(
                      File(plant.mainImagePath),
                      fit: BoxFit.cover,
                    )
                        : const Icon(
                      Icons.eco,
                      size: 30,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Plant Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plant.category,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Action Indicators
                    Row(
                      children: plant.actions
                          .where((action) => action.isEnabled)
                          .take(4)
                          .map((action) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: action.type.color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          action.type.icon,
                          size: 12,
                          color: Colors.white,
                        ),
                      ))
                          .toList(),
                    ),
                  ],
                ),
              ),

              // More Options
              IconButton(
                onPressed: () => _showPlantOptions(context, plant),
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlantOptions(BuildContext context, Plant plant) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlantDetailScreen(plant: plant),
                  ),
                ).then((_) {
                  // Refresh data when returning from detail screen
                  context.read<PlantProvider>().loadPlants();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Plant'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPlantScreen(plant: plant),
                  ),
                ).then((_) {
                  // Refresh data when returning from edit screen
                  context.read<PlantProvider>().loadPlants();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Plant', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, plant);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Plant plant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plant'),
        content: Text('Are you sure you want to delete ${plant.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PlantProvider>().deletePlant(plant.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
