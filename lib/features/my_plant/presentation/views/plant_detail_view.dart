import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/plant_provider.dart';
import '../../services/database_helper.dart';
import '../../services/notification_service.dart';
import 'edit_plant_view.dart';

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> with TickerProviderStateMixin {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();
  late TabController _tabController;
  List<String> _allImages = [];
  List<NotificationModel> _plantNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPlantData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPlantData() async {
    setState(() => _isLoading = true);

    try {
      // Load all images for this plant
      final List<String> images = await _databaseHelper.getPlantImages(widget.plant.id);

      // Load notifications for this plant
      final List<NotificationModel> allNotifications = await _notificationService.getUserNotifications();
      final List<NotificationModel> plantNotifications = allNotifications
          .where((notification) => notification.plantId == widget.plant.id)
          .toList();

      setState(() {
        _allImages = images;
        _plantNotifications = plantNotifications;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading plant data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(50),
                child: CircularProgressIndicator(),
              ),
            )
                : Column(
              children: [
                _buildPlantInfo(),
                _buildTabSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.plant.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: _buildImageGallery(),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPlantScreen(plant: widget.plant),
              ),
            ).then((_) => _loadPlantData());
          },
          icon: const Icon(Icons.edit),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _confirmDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Plant', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageGallery() {
    if (_allImages.isEmpty) {
      return Container(
        color: Colors.green.withOpacity(0.1),
        child: const Center(
          child: Icon(
            Icons.eco,
            size: 80,
            color: Colors.green,
          ),
        ),
      );
    }

    return PageView.builder(
      itemCount: _allImages.length,
      itemBuilder: (context, index) {
        final imagePath = _allImages[index];
        return Container(
          decoration: BoxDecoration(
            image: File(imagePath).existsSync()
                ? DecorationImage(
              image: FileImage(File(imagePath)),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: !File(imagePath).existsSync()
              ? Container(
            color: Colors.green.withOpacity(0.1),
            child: const Center(
              child: Icon(
                Icons.broken_image,
                size: 80,
                color: Colors.grey,
              ),
            ),
          )
              : Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlantInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plant.category,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Added ${_formatDate(widget.plant.createdAt)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              _buildActionIndicators(),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.plant.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIndicators() {
    return Wrap(
      spacing: 8,
      children: widget.plant.actions
          .where((action) => action.isEnabled)
          .map((action) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: action.type.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: action.type.color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              action.type.icon,
              size: 16,
              color: action.type.color,
            ),
            const SizedBox(width: 4),
            Text(
              action.type.displayName,
              style: TextStyle(
                fontSize: 12,
                color: action.type.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ))
          .toList(),
    );
  }

  Widget _buildTabSection() {
    return Column(
      children: [
        Container(
          color: Colors.grey[100],
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
            tabs: const [
              Tab(icon: Icon(Icons.schedule), text: 'Care Schedule'),
              Tab(icon: Icon(Icons.notifications), text: 'Reminders'),
              Tab(icon: Icon(Icons.photo_library), text: 'Gallery'),
              Tab(icon: Icon(Icons.history), text: 'History'),
            ],
          ),
        ),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCareScheduleTab(),
              _buildRemindersTab(),
              _buildGalleryTab(),
              _buildHistoryTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCareScheduleTab() {
    final enabledActions = widget.plant.actions.where((action) => action.isEnabled).toList();

    if (enabledActions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No care schedule set',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Edit your plant to add care reminders',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: enabledActions.length,
      itemBuilder: (context, index) {
        final action = enabledActions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: action.type.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                action.type.icon,
                color: action.type.color,
                size: 24,
              ),
            ),
            title: Text(
              action.type.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: action.reminder != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next: ${_formatDateTime(action.reminder!.time)}'),
                Text('Repeat: ${action.reminder!.repeat.displayName}'),
                if (action.reminder!.tasks.isNotEmpty)
                  Text('Tasks: ${action.reminder!.tasks.join(', ')}'),
              ],
            )
                : const Text('No reminder set'),
            trailing: action.reminder != null
                ? Icon(Icons.notifications_active, color: action.type.color)
                : const Icon(Icons.notifications_off, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildRemindersTab() {
    if (_plantNotifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No reminders yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _plantNotifications.length,
      itemBuilder: (context, index) {
        final notification = _plantNotifications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getActionTypeColor(notification.actionType).withOpacity(0.1),
              child: Icon(
                _getActionTypeIcon(notification.actionType),
                color: _getActionTypeColor(notification.actionType),
              ),
            ),
            title: Text(notification.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.body),
                Text(
                  'Scheduled: ${_formatDateTime(notification.scheduledTime)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  notification.isDelivered
                      ? Icons.check_circle
                      : Icons.schedule,
                  color: notification.isDelivered
                      ? Colors.green
                      : Colors.orange,
                ),
                Text(
                  notification.isDelivered ? 'Sent' : 'Pending',
                  style: TextStyle(
                    fontSize: 10,
                    color: notification.isDelivered
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGalleryTab() {
    if (_allImages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No photos yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _allImages.length,
      itemBuilder: (context, index) {
        final imagePath = _allImages[index];
        return GestureDetector(
          onTap: () => _showImageFullScreen(imagePath),
          child: Hero(
            tag: 'image_$index',
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: File(imagePath).existsSync()
                    ? Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                )
                    : Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.broken_image,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    final deliveredNotifications = _plantNotifications
        .where((notification) => notification.isDelivered)
        .toList()
      ..sort((a, b) => b.deliveredTime!.compareTo(a.deliveredTime!));

    if (deliveredNotifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No care history yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deliveredNotifications.length,
      itemBuilder: (context, index) {
        final notification = deliveredNotifications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              child: Icon(
                _getActionTypeIcon(notification.actionType),
                color: Colors.green,
              ),
            ),
            title: Text(notification.title),
            subtitle: Text(
              'Completed: ${_formatDateTime(notification.deliveredTime!)}',
            ),
            trailing: const Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
          ),
        );
      },
    );
  }

  void _showImageFullScreen(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: Hero(
              tag: 'image_fullscreen',
              child: InteractiveViewer(
                child: Image.file(File(imagePath)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getActionTypeColor(String actionTypeName) {
    try {
      final actionType = ActionType.values.firstWhere(
            (type) => type.name == actionTypeName,
      );
      return actionType.color;
    } catch (e) {
      return Colors.grey;
    }
  }

  IconData _getActionTypeIcon(String actionTypeName) {
    try {
      final actionType = ActionType.values.firstWhere(
            (type) => type.name == actionTypeName,
      );
      return actionType.icon;
    } catch (e) {
      return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      // Past date
      final pastDifference = now.difference(dateTime);
      if (pastDifference.inDays == 0) {
        return 'Today at ${_formatTime(dateTime)}';
      } else if (pastDifference.inDays == 1) {
        return 'Yesterday at ${_formatTime(dateTime)}';
      } else {
        return '${pastDifference.inDays} days ago at ${_formatTime(dateTime)}';
      }
    } else {
      // Future date
      if (difference.inDays == 0) {
        return 'Today at ${_formatTime(dateTime)}';
      } else if (difference.inDays == 1) {
        return 'Tomorrow at ${_formatTime(dateTime)}';
      } else {
        return 'In ${difference.inDays} days at ${_formatTime(dateTime)}';
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plant'),
        content: Text('Are you sure you want to delete ${widget.plant.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
              // Use a post-frame callback to ensure context is still valid
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.read<PlantProvider>().deletePlant(widget.plant.id);
                }
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
