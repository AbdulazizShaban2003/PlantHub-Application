import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification_model.dart';
import '../providers/plant_provider.dart';
import '../services/database_helper.dart';
import 'plant_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];
  Map<String, Plant> _plantsMap = {};

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to avoid setState during build
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
      // Load notifications using post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        final notificationProvider = context.read<NotificationProvider>();
        await notificationProvider.loadNotifications();

        // Load plants to map plant IDs to plant objects
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
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You\'ll see notifications about your plants here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Group notifications by date
    final Map<String, List<NotificationModel>> groupedNotifications = {};
    for (final notification in _notifications) {
      final String dateKey = _getDateKey(notification.scheduledTime);
      if (!groupedNotifications.containsKey(dateKey)) {
        groupedNotifications[dateKey] = [];
      }
      groupedNotifications[dateKey]!.add(notification);
    }

    // Sort date keys
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
                    fontSize: 16,
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
    final Color actionColor = _getActionTypeColor(notification.actionType);
    final IconData actionIcon = _getActionTypeIcon(notification.actionType);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: notification.isRead ? null : Colors.green.shade50,
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

              // Notification content - Fixed overflow
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
                              _formatTime(notification.scheduledTime),
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

              // Status indicator
              Column(
                children: [
                  Icon(
                    notification.isDelivered
                        ? Icons.notifications_active
                        : Icons.notifications_none,
                    color: notification.isDelivered
                        ? Colors.green
                        : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  String _getDateKey(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
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
}
