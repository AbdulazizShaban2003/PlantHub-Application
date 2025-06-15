import 'dart:io';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../my_plant/data/models/notification_model.dart';
import '../../../my_plant/presentation/views/plant_detail_view.dart';
import '../../../my_plant/providers/plant_provider.dart';
import '../../controller/notification_controller.dart';
import '../widgets/empty_notification_widget.dart';
class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];
  Map<String, Plant> _plantsMap = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadNotifications();
      }
    });
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        final notificationProvider = context.read<NotificationProvider>();
        await notificationProvider.loadNotifications();

        final plantProvider = context.read<PlantProvider>();
        if (plantProvider.plants.isEmpty) {
          await plantProvider.loadPlants();
        }

        final Map<String, Plant> plantsMap = {};
        for (final plant in plantProvider.plants) {
          plantsMap[plant.id] = plant;
        }

        if (mounted) {
          setState(() {
            _notifications = notificationProvider.notifications;
            _plantsMap = plantsMap;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      print('Error loading notifications: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'Notifications',
          style: Theme.of(context).textTheme.headlineMedium
        ),
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildNotificationsList(),
    );
  }
  Widget _buildNotificationsList() {
    if (_notifications.isEmpty) {
      return EmptyNotifyWidget();
    }
    final Map<String, List<NotificationModel>> groupedNotifications = {};
    for (final notification in _notifications) {
      final String dateKey = getDateKey(notification.scheduledTime);
      if (!groupedNotifications.containsKey(dateKey)) {
        groupedNotifications[dateKey] = [];
      }
      groupedNotifications[dateKey]!.add(notification);
    }
    final List<String> sortedDateKeys = groupedNotifications.keys.toList()
      ..sort((a, b) {
        if (a == 'Today') return -1;
        if (b == 'Today') return 1;
        if (a == 'Yesterday') return -1;
        if (b == 'Yesterday') return 1;
        return b.compareTo(a);
      });

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: sortedDateKeys.length,
        itemBuilder: (context, index) {
          final dateKey = sortedDateKeys[index];
          final notificationsForDate = groupedNotifications[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  dateKey,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              ...notificationsForDate.map((notification) =>
                  _buildNotificationCard(notification)
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final Plant? plant = _plantsMap[notification.plantId];
    final Color actionColor = getActionTypeColor(notification.actionType);
    final IconData actionIcon = getActionTypeIcon(notification.actionType);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: InkWell(
        onTap: () => _onNotificationTapped(notification, plant),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Action icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: actionColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  actionIcon,
                  color: actionColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    // Fixed overflow in time row
                    Wrap(
                      spacing: 12,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formatTime(notification.scheduledTime),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        if (plant != null)
                          Text(
                            plant.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(
                    notification.isDelivered
                        ? Icons.notifications_active
                        : Icons.notifications_none,
                    color: notification.isDelivered
                        ? ColorsManager.redColor
                        : ColorsManager.greenPrimaryColor,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration:  BoxDecoration(
                        color: ColorsManager.greenPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onNotificationTapped(NotificationModel notification, Plant? plant) async {
    // Mark notification as read
    if (!notification.isRead) {
      final notificationProvider = context.read<NotificationProvider>();
      await notificationProvider.markAsRead(notification.id);

      // Update local state
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
      });
    }

    // Navigate to plant detail if plant exists
    if (plant != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlantDetailScreen(plant: plant),
        ),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final notificationProvider = context.read<NotificationProvider>();
      await notificationProvider.markAllAsRead();

      setState(() {
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      });

      if (mounted) {

        FlushbarHelper.createSuccess(message: 'All notifications marked as read');

      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }



}

