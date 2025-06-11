import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String plantId;
  final String plantName;
  final String actionType;
  final String title;
  final String body;
  final String thumbnailPath;
  final List<String> taskNames;
  final DateTime scheduledTime;
  final DateTime? deliveredTime;
  final bool isDelivered;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.plantId,
    required this.plantName,
    required this.actionType,
    required this.title,
    required this.body,
    required this.thumbnailPath,
    required this.taskNames,
    required this.scheduledTime,
    this.deliveredTime,
    required this.isDelivered,
    required this.isRead,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'plantId': plantId,
      'plantName': plantName,
      'actionType': actionType,
      'title': title,
      'body': body,
      'thumbnailPath': thumbnailPath,
      'taskNames': taskNames.join(','),
      'scheduledTime': scheduledTime.millisecondsSinceEpoch,
      'deliveredTime': deliveredTime?.millisecondsSinceEpoch,
      'isDelivered': isDelivered ? 1 : 0,
      'isRead': isRead ? 1 : 0,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'plantId': plantId,
      'plantName': plantName,
      'actionType': actionType,
      'title': title,
      'body': body,
      'taskNames': taskNames,
      'scheduledTime': scheduledTime,
      'deliveredTime': deliveredTime,
      'isDelivered': isDelivered,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      plantId: map['plantId'] ?? '',
      plantName: map['plantName'] ?? '',
      actionType: map['actionType'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      thumbnailPath: map['thumbnailPath'] ?? '',
      taskNames: map['taskNames'] != null
          ? (map['taskNames'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : [],
      scheduledTime: DateTime.fromMillisecondsSinceEpoch(map['scheduledTime'] ?? 0),
      deliveredTime: map['deliveredTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deliveredTime'])
          : null,
      isDelivered: (map['isDelivered'] ?? 0) == 1,
      isRead: (map['isRead'] ?? 0) == 1,
    );
  }

  factory NotificationModel.fromFirestore(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      plantId: map['plantId'] ?? '',
      plantName: map['plantName'] ?? '',
      actionType: map['actionType'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      thumbnailPath: '',
      taskNames: map['taskNames'] != null
          ? List<String>.from(map['taskNames'])
          : [],
      scheduledTime: map['scheduledTime']?.toDate() ?? DateTime.now(),
      deliveredTime: map['deliveredTime']?.toDate(),
      isDelivered: map['isDelivered'] ?? false,
      isRead: map['isRead'] ?? false,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? plantId,
    String? plantName,
    String? actionType,
    String? title,
    String? body,
    String? thumbnailPath,
    List<String>? taskNames,
    DateTime? scheduledTime,
    DateTime? deliveredTime,
    bool? isDelivered,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plantId: plantId ?? this.plantId,
      plantName: plantName ?? this.plantName,
      actionType: actionType ?? this.actionType,
      title: title ?? this.title,
      body: body ?? this.body,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      taskNames: taskNames ?? this.taskNames,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      deliveredTime: deliveredTime ?? this.deliveredTime,
      isDelivered: isDelivered ?? this.isDelivered,
      isRead: isRead ?? this.isRead,
    );
  }
}

class Plant {
  final String id;
  final String userId;
  final String name;
  final String category;
  final String description;
  final String mainImagePath;
  final List<String> additionalImagePaths;
  final List<PlantAction> actions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Plant({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.description,
    required this.mainImagePath,
    required this.additionalImagePaths,
    required this.actions,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'category': category,
      'description': description,
      'mainImagePath': mainImagePath,
      'additionalImagePaths': additionalImagePaths.join(','),
      'actions': actions.map((action) => action.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'category': category,
      'description': description,
      'actions': actions.map((action) => action.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      mainImagePath: map['mainImagePath'] ?? '',
      additionalImagePaths: map['additionalImagePaths'] != null
          ? (map['additionalImagePaths'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : [],
      actions: map['actions'] != null
          ? (map['actions'] as List).map((action) => PlantAction.fromMap(action)).toList()
          : [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  factory Plant.fromFirestore(Map<String, dynamic> map) {
    return Plant(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      mainImagePath: '',
      additionalImagePaths: [],
      actions: map['actions'] != null
          ? (map['actions'] as List).map((action) => PlantAction.fromMap(action)).toList()
          : [],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Plant copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    String? description,
    String? mainImagePath,
    List<String>? additionalImagePaths,
    List<PlantAction>? actions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Plant(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      mainImagePath: mainImagePath ?? this.mainImagePath,
      additionalImagePaths: additionalImagePaths ?? this.additionalImagePaths,
      actions: actions ?? this.actions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PlantAction {
  final String id;
  final ActionType type;
  final bool isEnabled;
  final Reminder? reminder;

  PlantAction({
    required this.id,
    required this.type,
    required this.isEnabled,
    this.reminder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'isEnabled': isEnabled,
      'reminder': reminder?.toMap(),
    };
  }

  factory PlantAction.fromMap(Map<String, dynamic> map) {
    return PlantAction(
      id: map['id'] ?? '',
      type: ActionType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => ActionType.watering,
      ),
      isEnabled: map['isEnabled'] ?? false,
      reminder: map['reminder'] != null ? Reminder.fromMap(map['reminder']) : null,
    );
  }
}

enum ActionType {
  watering,
  fertilizing,
  misting,
  pruning,
  note,
  photo,
}

extension ActionTypeExtension on ActionType {
  String get displayName {
    switch (this) {
      case ActionType.watering:
        return 'Watering';
      case ActionType.fertilizing:
        return 'Fertilizing';
      case ActionType.misting:
        return 'Misting';
      case ActionType.pruning:
        return 'Pruning';
      case ActionType.note:
        return 'Note';
      case ActionType.photo:
        return 'Photo';
    }
  }

  Color get color {
    switch (this) {
      case ActionType.watering:
        return Colors.blue;
      case ActionType.fertilizing:
        return Colors.red;
      case ActionType.misting:
        return Colors.purple;
      case ActionType.pruning:
        return Colors.orange;
      case ActionType.note:
        return Colors.indigo;
      case ActionType.photo:
        return Colors.green;
    }
  }

  IconData get icon {
    switch (this) {
      case ActionType.watering:
        return Icons.water_drop;
      case ActionType.fertilizing:
        return Icons.eco;
      case ActionType.misting:
        return Icons.cloud;
      case ActionType.pruning:
        return Icons.content_cut;
      case ActionType.note:
        return Icons.note;
      case ActionType.photo:
        return Icons.photo_camera;
    }
  }
}

class Reminder {
  final String id;
  final DateTime time;
  final RepeatType repeat;
  final String remindMeTo;
  final List<String> tasks;
  final bool isActive;

  Reminder({
    required this.id,
    required this.time,
    required this.repeat,
    required this.remindMeTo,
    this.tasks = const [],
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time.millisecondsSinceEpoch,
      'repeat': repeat.name,
      'remindMeTo': remindMeTo,
      'tasks': tasks.join(','),
      'isActive': isActive,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] ?? '',
      time: DateTime.fromMillisecondsSinceEpoch(map['time'] ?? 0),
      repeat: RepeatType.values.firstWhere(
            (e) => e.name == map['repeat'],
        orElse: () => RepeatType.daily,
      ),
      remindMeTo: map['remindMeTo'] ?? '',
      tasks: map['tasks'] != null
          ? (map['tasks'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : [],
      isActive: map['isActive'] ?? true,
    );
  }
}

enum RepeatType {
  once,
  daily,
  weekly,
  monthly,
}

extension RepeatTypeExtension on RepeatType {
  String get displayName {
    switch (this) {
      case RepeatType.once:
        return 'Once';
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekly:
        return 'Weekly';
      case RepeatType.monthly:
        return 'Monthly';
    }
  }
}
