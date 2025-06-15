import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../data/models/notification_model.dart';
import '../services/database_helper.dart';
import '../services/firebase_service_notification.dart';
import '../services/notification_service.dart';

class PlantProvider with ChangeNotifier {
  final FirebaseServiceNotify _firebaseService = FirebaseServiceNotify();
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
    _clearError();

    try {
      print('📥 Loading plants...');

      // Get plants from Firebase
      _plants = await _firebaseService.getUserPlants();

      // Load local images for each plant
      for (int i = 0; i < _plants.length; i++) {
        final String? mainImagePath = await _databaseHelper.getMainPlantImage(_plants[i].id);
        final List<String> additionalImagePaths = await _databaseHelper.getPlantImages(_plants[i].id);

        // Update plant with local image paths
        _plants[i] = _plants[i].copyWith(
          mainImagePath: mainImagePath ?? _plants[i].mainImagePath,
          additionalImagePaths: additionalImagePaths.where((path) => path != mainImagePath).toList(),
        );
      }

      print('✅ Loaded ${_plants.length} plants successfully');

    } catch (e) {
      print('❌ Error loading plants: $e');
      _error = 'Failed to load plants: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addPlant({
    required String name,
    required String category,
    required String description,
     XFile ? mainImage,
     List<XFile> ?additionalImages,
    required List<PlantAction> actions,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final String userId = _firebaseService.currentUserId ?? '';
      if (userId.isEmpty) throw Exception('User not authenticated');

      final String plantId = _uuid.v4();

      print('💾 Adding new plant: $name');

      // Save main image to local storage
      final String mainImagePath = await saveImageToLocal(mainImage!, plantId, true);
      print('📸 Main image saved: $mainImagePath');

      // Save additional images to local storage
      final List<String> additionalImagePaths = [];
      for (int i = 0; i < additionalImages!.length; i++) {
        final String imagePath = await saveImageToLocal(additionalImages[i], plantId, false);
        additionalImagePaths.add(imagePath);
        print('📸 Additional image ${i + 1} saved: $imagePath');
      }

      // Create plant object
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
      print('☁️ Plant saved to Firebase');

      // Schedule reminders for enabled actions
      for (final action in actions) {
        if (action.isEnabled && action.reminder != null) {
          try {
            await _notificationService.scheduleReminder(
              plant: plant,
              action: action,
              reminder: action.reminder!,
            );
            print('📅 Reminder scheduled for ${action.type.displayName}');
          } catch (e) {
            print('⚠️ Failed to schedule reminder for ${action.type.displayName}: $e');
          }
        }
      }

      // Add to local list
      _plants.insert(0, plant);
      print('✅ Plant added successfully: $name');

    } catch (e) {
      print('❌ Error adding plant: $e');
      _error = 'Failed to add plant: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePlant(Plant updatedPlant) async {
    _setLoading(true);
    _clearError();

    try {
      print('🔄 Updating plant: ${updatedPlant.name}');

      // Cancel existing reminders for this plant
      await _notificationService.cancelAllPlantReminders(updatedPlant.id);
      print('🗑️ Cancelled existing reminders');

      // Update plant in Firebase
      await _firebaseService.updatePlant(updatedPlant);
      print('☁️ Plant updated in Firebase');

      // Schedule new reminders for enabled actions
      for (final action in updatedPlant.actions) {
        if (action.isEnabled && action.reminder != null) {
          try {
            await _notificationService.scheduleReminder(
              plant: updatedPlant,
              action: action,
              reminder: action.reminder!,
            );
            print('📅 New reminder scheduled for ${action.type.displayName}');
          } catch (e) {
            print('⚠️ Failed to schedule reminder for ${action.type.displayName}: $e');
          }
        }
      }

      // Update in local list
      final int index = _plants.indexWhere((plant) => plant.id == updatedPlant.id);
      if (index != -1) {
        _plants[index] = updatedPlant;
      }

      print('✅ Plant updated successfully: ${updatedPlant.name}');

    } catch (e) {
      print('❌ Error updating plant: $e');
      _error = 'Failed to update plant: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePlant(String plantId) async {
    _setLoading(true);
    _clearError();

    try {
      print('🗑️ Deleting plant: $plantId');

      // Cancel all reminders for this plant
      await _notificationService.cancelAllPlantReminders(plantId);
      print('🗑️ Cancelled all reminders');

      // Delete images from local storage
      await _databaseHelper.deletePlantImages(plantId);
      print('🗑️ Deleted local images');

      // Delete from Firebase
      await _firebaseService.deletePlant(plantId);
      print('☁️ Plant deleted from Firebase');

      // Remove from local list
      _plants.removeWhere((plant) => plant.id == plantId);

      print('✅ Plant deleted successfully');

    } catch (e) {
      print('❌ Error deleting plant: $e');
      _error = 'Failed to delete plant: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<String> saveImageToLocal(XFile image, String plantId, bool isMainImage) async {
    try {
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

      print('📸 Image saved locally: $localPath');
      return localPath;
    } catch (e) {
      print('❌ Error saving image: $e');
      rethrow;
    }
  }

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      return await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
    } catch (e) {
      print('❌ Error picking image: $e');
      _error = 'Failed to pick image: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<List<XFile>> pickMultipleImages() async {
    try {
      return await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
    } catch (e) {
      print('❌ Error picking multiple images: $e');
      _error = 'Failed to pick images: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
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
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _setLoading(true);
      _clearError();

      try {
        print('📥 Loading notifications...');
        _notifications = await _notificationService.getUserNotifications();
        print('✅ Loaded ${_notifications.length} notifications');
      } catch (e) {
        print('❌ Error loading notifications: $e');
        _error = 'Failed to load notifications: ${e.toString()}';
      } finally {
        _setLoading(false);
      }
    });
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);

      final int index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }

      print('📖 Notification marked as read: $notificationId');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      _error = 'Failed to mark notification as read: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      print('📖 Marking all notifications as read...');

      for (final notification in _notifications.where((n) => !n.isRead)) {
        await _notificationService.markNotificationAsRead(notification.id);
      }

      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();

      print('✅ All notifications marked as read');
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      _error = 'Failed to mark all notifications as read: ${e.toString()}';
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
