import 'package:another_flushbar/flushbar_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';
import '../model/message_model.dart';
import 'local_databaseMessage.dart';

class FirebaseServiceMessage {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _usersCollection = 'users';
  static const String _messagesSubCollection = 'messages';

  static String? get _currentUserId => _auth.currentUser?.uid;

  static CollectionReference? get _userMessagesCollection {
    if (_currentUserId == null) return null;
    return _firestore
        .collection(_usersCollection)
        .doc(_currentUserId)
        .collection(_messagesSubCollection);
  }

  static Future<void> _initializeUserDocument() async {
    if (_currentUserId == null) return;

    final userDoc = _firestore.collection(_usersCollection).doc(_currentUserId);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
        'messageCount': 0,
      });
    } else {
      // Update last active time
      await userDoc.update({'lastActive': FieldValue.serverTimestamp()});
    }
  }

  static Future<void> saveMessage(Message message) async {
    try {
      if (_currentUserId == null) {
        FlushbarHelper.createError(message: AppStrings.noAuthUser);
        return;
      }

      await _initializeUserDocument();

      final messagesCollection = _userMessagesCollection;
      if (messagesCollection == null) return;

      // Save the message
      await messagesCollection.doc(message.id).set({
        'id': message.id,
        'isUser': message.isUser,
        'message': message.message,
        'hasImage': message.hasImage,
        'imageId': message.imageId,
        'date': message.date.millisecondsSinceEpoch,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update user's message count
      await _firestore.collection(_usersCollection).doc(_currentUserId).update({
        'messageCount': FieldValue.increment(1),
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      FlushbarHelper.createError(message: AppStrings.tryAgainLater);
    }
  }

  static Future<List<Message>> getMessages() async {
    try {
      if (_currentUserId == null) {
        FlushbarHelper.createError(message: AppStrings.noAuthUser);
        return [];
      }

      final messagesCollection = _userMessagesCollection;
      if (messagesCollection == null) return [];

      final querySnapshot =
          await messagesCollection.orderBy('date', descending: false).get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Message(
          id: data['id'],
          isUser: data['isUser'],
          message: data['message'],
          hasImage: data['hasImage'] ?? false,
          imageId: data['imageId'],
          date: DateTime.fromMillisecondsSinceEpoch(data['date']),
        );
      }).toList();
    } catch (e) {
      FlushbarHelper.createError(message: AppStrings.tryAgainLater);
      return [];
    }
  }

  static Future<void> deleteMessage(String messageId) async {
    try {
      if (_currentUserId == null) {
        FlushbarHelper.createError(message: AppStrings.noAuthUser);
        return;
      }

      final messagesCollection = _userMessagesCollection;
      if (messagesCollection == null) return;

      await messagesCollection.doc(messageId).delete();

      await _firestore.collection(_usersCollection).doc(_currentUserId).update({
        'messageCount': FieldValue.increment(-1),
      });
    } catch (e) {
      FlushbarHelper.createError(message: AppStrings.tryAgainLater);
    }
  }

  static Future<Map<String, dynamic>?> getUserChatStats() async {
    try {
      if (_currentUserId == null) return null;

      final userDoc =
          await _firestore
              .collection(_usersCollection)
              .doc(_currentUserId)
              .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      FlushbarHelper.createError(message: AppStrings.tryAgainLater);
      return null;
    }
  }

  static Future<void> clearAllMessages() async {
    try {
      if (_currentUserId == null) {
        FlushbarHelper.createError(message: AppStrings.noAuthUser);
        return;
      }
      final messagesCollection = _userMessagesCollection;
      if (messagesCollection == null) return;

      final querySnapshot = await messagesCollection.get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      await LocalDatabaseMessage.clearAllImages();

      await _firestore.collection(_usersCollection).doc(_currentUserId).update({
        'messageCount': 0,
        'lastMessageAt': FieldValue.delete(),
      });
      FlushbarHelper.createSuccess(
        message: AppStrings.successStorage,
      );
    } catch (e) {
      FlushbarHelper.createError(message: AppStrings.tryAgainLater);
    }
  }
}
