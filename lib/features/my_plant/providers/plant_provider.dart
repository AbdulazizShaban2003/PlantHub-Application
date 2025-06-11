import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import '../services/database_helper.dart';
import '../services/firebase_service_notification.dart';
import '../services/notification_service.dart';

class PlantProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();
  final ImagePicker _imagePicker = ImagePicker();
  final Uuid _uuid = const Uuid();

  List<Plant> _plants = [];
  bool _isLoading = false;
  String? _error;

  List<Plant> get plants => _plants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPlants() async {
    _setLoading(true);
    try {
      _plants = await _firebaseService.getUserPlants();

      // Load images from local database for each plant
      for (int i = 0; i < _plants.length; i++) {
        final String? mainImagePath = await _databaseHelper.getMainPlantImage(_plants[i].id);
        final List<String> additionalImagePaths = await _databaseHelper.getPlantImages(_plants[i].id);

        _plants[i] = _plants[i].copyWith(
          mainImagePath: mainImagePath ?? '',
          additionalImagePaths: additionalImagePaths.where((path) => path != mainImagePath).toList(),
        );
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addPlant({
    required String name,
    required String category,
    required String description,
    required XFile mainImage,
    required List<XFile> additionalImages,
    required List<PlantAction> actions,
  }) async {
    _setLoading(true);
    try {
      final String userId = _firebaseService.currentUserId ?? '';
      if (userId.isEmpty) throw Exception('User not authenticated');

      final String plantId = _uuid.v4();

      // Save main image
      final String mainImagePath = await saveImageToLocal(mainImage, plantId, true);

      // Save additional images
      final List<String> additionalImagePaths = [];
      for (final image in additionalImages) {
        final String imagePath = await saveImageToLocal(image, plantId, false);
        additionalImagePaths.add(imagePath);
      }

      // Create plant
      final Plant plant = Plant(
        id: plantId,
        userId: userId,
        name: name,
        category: category,
        description: description,
        mainImagePath: mainImagePath,
        additionalImagePaths: additionalImagePaths,
        actions: actions,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firebase
      await _firebaseService.savePlant(plant);

      // Schedule reminders
      for (final action in actions) {
        if (action.isEnabled && action.reminder != null) {
          await _notificationService.scheduleReminder(
            plant: plant,
            action: action,
            reminder: action.reminder!,
          );
        }
      }

      // Add to local list
      _plants.insert(0, plant);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePlant(Plant updatedPlant) async {
    _setLoading(true);
    try {
      // Cancel existing reminders for this plant
      await _notificationService.cancelAllPlantReminders(updatedPlant.id);

      // Save to Firebase
      await _firebaseService.updatePlant(updatedPlant);

      // Schedule new reminders
      for (final action in updatedPlant.actions) {
        if (action.isEnabled && action.reminder != null) {
          await _notificationService.scheduleReminder(
            plant: updatedPlant,
            action: action,
            reminder: action.reminder!,
          );
        }
      }

      final int index = _plants.indexWhere((plant) => plant.id == updatedPlant.id);
      if (index != -1) {
        _plants[index] = updatedPlant;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePlant(String plantId) async {
    _setLoading(true);
    try {
      // Cancel all reminders for this plant
      await _notificationService.cancelAllPlantReminders(plantId);

      // Delete images from local storage
      await _databaseHelper.deletePlantImages(plantId);

      // Delete from Firebase
      await _firebaseService.deletePlant(plantId);

      // Remove from local list
      _plants.removeWhere((plant) => plant.id == plantId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<String> saveImageToLocal(XFile image, String plantId, bool isMainImage) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = '${_uuid.v4()}.${path.extension(image.path).substring(1)}';
    final String localPath = path.join(appDir.path, 'images', fileName);

    // Create directory if it doesn't exist
    final Directory imageDir = Directory(path.dirname(localPath));
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    // Copy image to local storage
    await File(image.path).copy(localPath);

    // Save image info to database
    final String userId = _firebaseService.currentUserId ?? '';
    await _databaseHelper.saveImage(
      userId: userId,
      plantId: plantId,
      imagePath: localPath,
      isMainImage: isMainImage,
    );

    return localPath;
  }

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      return await _imagePicker.pickImage(source: source);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<List<XFile>> pickMultipleImages() async {
    try {
      return await _imagePicker.pickMultiImage();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _setLoading(true);
    try {
      _notifications = await _notificationService.getUserNotifications();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);

      final int index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      for (final notification in _notifications.where((n) => !n.isRead)) {
        await _notificationService.markNotificationAsRead(notification.id);
      }

      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
