import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class FirebaseServiceNotify {
  static final FirebaseServiceNotify _instance = FirebaseServiceNotify._internal();
  factory FirebaseServiceNotify() => _instance;
  FirebaseServiceNotify._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> signInAnonymously() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
        print('✅ Signed in anonymously with user ID: ${currentUserId}');
      } else {
        print('✅ Already signed in with user ID: ${currentUserId}');
      }
    } catch (e) {
      print('❌ Error signing in anonymously: $e');
      rethrow;
    }
  }

  Future<void> savePlant(Plant plant) async {
    try {
      final String userId = currentUserId ?? '';
      if (userId.isEmpty) throw Exception('User not authenticated');

      print('💾 Saving plant to Firebase: ${plant.id}');

      final Map<String, dynamic> plantData = {
        'name': plant.name,
        'category': plant.category,
        'description': plant.description,
        'mainImage': plant.mainImagePath, // Local path only
        'images': plant.additionalImagePaths, // Local paths only
        'actions': plant.actions.map((action) => action.toMap()).toList(),
        'createdAt': Timestamp.fromDate(plant.createdAt),
        'updatedAt': Timestamp.fromDate(plant.updatedAt),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('myPlant')
          .doc(plant.id)
          .set(plantData);

      print('✅ Plant saved successfully to Firebase');
    } catch (e) {
      print('❌ Error saving plant to Firebase: $e');
      rethrow;
    }
  }

  Future<List<Plant>> getUserPlants() async {
    try {
      final String userId = currentUserId ?? '';
      if (userId.isEmpty) {
        print('⚠️ No user ID available');
        return [];
      }

      print('📥 Fetching plants for user: $userId');

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('myPlant')
          .orderBy('createdAt', descending: true)
          .get();

      print('📦 Fetched ${snapshot.docs.length} plants from Firebase');

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return Plant(
          id: doc.id,
          userId: userId,
          name: data['name'] ?? '',
          category: data['category'] ?? '',
          description: data['description'] ?? '',
          mainImagePath: data['mainImage'] ?? '',
          additionalImagePaths: data['images'] != null
              ? List<String>.from(data['images'])
              : [],
          actions: data['actions'] != null
              ? (data['actions'] as List).map((action) => PlantAction.fromMap(action)).toList()
              : [],
          createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
          updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('❌ Error getting user plants from Firebase: $e');
      return [];
    }
  }

  Future<void> updatePlant(Plant plant) async {
    try {
      final String userId = currentUserId ?? '';
      if (userId.isEmpty) throw Exception('User not authenticated');

      print('🔄 Updating plant in Firebase: ${plant.id}');

      final Map<String, dynamic> plantData = {
        'name': plant.name,
        'category': plant.category,
        'description': plant.description,
        'mainImage': plant.mainImagePath,
        'images': plant.additionalImagePaths,
        'actions': plant.actions.map((action) => action.toMap()).toList(),
        'updatedAt': Timestamp.fromDate(plant.updatedAt),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('myPlant')
          .doc(plant.id)
          .update(plantData);

      print('✅ Plant updated successfully in Firebase');
    } catch (e) {
      print('❌ Error updating plant in Firebase: $e');
      rethrow;
    }
  }

  Future<void> deletePlant(String plantId) async {
    try {
      final String userId = currentUserId ?? '';
      if (userId.isEmpty) throw Exception('User not authenticated');

      print('🗑️ Deleting plant from Firebase: $plantId');

      // Delete all notifications for this plant first
      await _deleteAllPlantNotifications(plantId);

      // Delete the plant document
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('myPlant')
          .doc(plantId)
          .delete();

      print('✅ Plant deleted successfully from Firebase');
    } catch (e) {
      print('❌ Error deleting plant from Firebase: $e');
      rethrow;
    }
  }

  Future<void> _deleteAllPlantNotifications(String plantId) async {
    try {
      final String userId = currentUserId ?? '';
      if (userId.isEmpty) return;

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('plantId', isEqualTo: plantId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
        print('🗑️ Deleted ${snapshot.docs.length} notifications for plant $plantId');
      }
    } catch (e) {
      print('❌ Error deleting plant notifications: $e');
    }
  }

  // Notification operations with new structure: users/{userId}/notifications/{notificationId}
  Future<void> saveNotification(NotificationModel notification) async {
    try {
      final String userId = currentUserId ?? '';
      if (userId.isEmpty) throw Exception('User not authenticated');

      print('💾 Saving notification to Firebase: ${notification.id}');

      final Map<String, dynamic> notificationData = {
        'title': notification.title,
        'body': notification.body,
        'dateTime': Timestamp.fromDate(notification.scheduledTime),
        'actionType': notification.actionType,
        'plantId': notification.plantId,
        'plantName': notification.plantName,
        'taskNames': notification.taskNames,
        'isDelivered': notification.isDelivered,
        'isRead': notification.isRead,
        'deliveredTime': notification.deliveredTime != null
            ? Timestamp.fromDate(notification.deliveredTime!)
            : null,
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notification.id)
          .set(notificationData);

      print('✅ Notification saved successfully to Firebase');
    } catch (e) {
      print('❌ Error saving notification to Firebase: $e');
      rethrow;
    }
  }

  Future<List<NotificationModel>> getUserNotifications() async {
    try {
      final String userId = currentUserId ?? '';
      if (userId.isEmpty) {
        print('⚠️ No user ID available for notifications');
        return [];
      }

      print('📥 Fetching notifications for user: $userId');

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('dateTime', descending: true)
          .get();

      print('📦 Fetched ${snapshot.docs.length} notifications from Firebase');

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return NotificationModel(
          id: doc.id,
          userId: userId,
          plantId: data['plantId'] ?? '',
          plantName: data['plantName'] ?? '',
          actionType: data['actionType'] ?? '',
          title: data['title'] ?? '',
          body: data['body'] ?? '',
          thumbnailPath: '', // Will be filled from local database
          taskNames: data['taskNames'] != null
              ? List<String>.from(data['taskNames'])
              : [],
          scheduledTime: data['dateTime']?.toDate() ?? DateTime.now(),
          deliveredTime: data['deliveredTime']?.toDate(),
          isDelivered: data['isDelivered'] ?? false,
          isRead: data['isRead'] ?? false,
        );
      }).toList();
    } catch (e) {
      print('❌ Error getting user notifications from Firebase: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final String userId = currentUserId ?? '';
      if (userId.isEmpty) throw Exception('User not authenticated');

      print('📖 Marking notification as read in Firebase: $notificationId');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      print('✅ Notification marked as read successfully in Firebase');
    } catch (e) {
      print('❌ Error marking notification as read in Firebase: $e');
      rethrow;
    }
  }

  Future<void> markNotificationAsDelivered(String notificationId) async {
    try {
      final String userId = currentUserId ?? '';
      if (userId.isEmpty) throw Exception('User not authenticated');

      print('📬 Marking notification as delivered in Firebase: $notificationId');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({
        'isDelivered': true,
        'deliveredTime': FieldValue.serverTimestamp(),
      });

      print('✅ Notification marked as delivered successfully in Firebase');
    } catch (e) {
      print('❌ Error marking notification as delivered in Firebase: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final String userId = currentUserId ?? '';
      if (userId.isEmpty) throw Exception('User not authenticated');

      print('🗑️ Deleting notification from Firebase: $notificationId');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();

      print('✅ Notification deleted successfully from Firebase');
    } catch (e) {
      print('❌ Error deleting notification from Firebase: $e');
      rethrow;
    }
  }
}
