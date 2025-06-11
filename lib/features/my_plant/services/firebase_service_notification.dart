import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  Future<void> signInAnonymously() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
    } catch (e) {
      print('Error signing in anonymously: $e');
      rethrow;
    }
  }


  Future<void> savePlant(Plant plant) async {
    try {
      await _firestore
          .collection('plants')
          .doc(plant.id)
          .set(plant.toFirestore());
    } catch (e) {
      print('Error saving plant: $e');
      rethrow;
    }
  }

  Future<List<Plant>> getUserPlants() async {
    try {
      final String userId = currentUserId ?? '';
      if (userId.isEmpty) return [];

      final QuerySnapshot snapshot = await _firestore
          .collection('plants')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Plant.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting user plants: $e');
      return [];
    }
  }

  Future<void> updatePlant(Plant plant) async {
    try {
      await _firestore
          .collection('plants')
          .doc(plant.id)
          .update(plant.toFirestore());
    } catch (e) {
      print('Error updating plant: $e');
      rethrow;
    }
  }

  Future<void> deletePlant(String plantId) async {
    try {
      await _firestore.collection('plants').doc(plantId).delete();
    } catch (e) {
      print('Error deleting plant: $e');
      rethrow;
    }
  }

  Future<void> saveNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toFirestore());
    } catch (e) {
      print('Error saving notification: $e');
      rethrow;
    }
  }

  Future<List<NotificationModel>> getUserNotifications() async {
    try {
      final String userId = currentUserId ?? '';
      if (userId.isEmpty) return [];

      final QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('scheduledTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting user notifications: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  Future<void> markNotificationAsDelivered(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({
        'isDelivered': true,
        'deliveredTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking notification as delivered: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }
}
