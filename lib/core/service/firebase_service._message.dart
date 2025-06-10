import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/chatAi/data/model/message_model.dart';
import '../cache/local_databaseMessage.dart';

class FirebaseServiceMessage {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _usersCollection = 'users';
  static const String _messagesSubCollection = 'messages';

  static String? get _currentUserId => _auth.currentUser?.uid;

  // Get reference to user's messages collection
  static CollectionReference? get _userMessagesCollection {
    if (_currentUserId == null) return null;
    return _firestore
        .collection(_usersCollection)
        .doc(_currentUserId)
        .collection(_messagesSubCollection);
  }

  // Initialize user document if it doesn't exist
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
      await userDoc.update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<void> saveMessage(Message message) async {
    try {
      if (_currentUserId == null) {
        print('Error: No authenticated user');
        return;
      }

      // Initialize user document
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

      print('Message saved to Firebase: ${message.id}');

    } catch (e) {
      print('Error saving message to Firebase: $e');
    }
  }

  static Future<List<Message>> getMessages() async {
    try {
      if (_currentUserId == null) {
        print('Error: No authenticated user');
        return [];
      }

      final messagesCollection = _userMessagesCollection;
      if (messagesCollection == null) return [];

      final querySnapshot = await messagesCollection
          .orderBy('date', descending: false)
          .get();

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
      print('Error getting messages from Firebase: $e');
      return [];
    }
  }

  static Stream<List<Message>> getMessagesStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    final messagesCollection = _userMessagesCollection;
    if (messagesCollection == null) {
      return Stream.value([]);
    }

    return messagesCollection
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
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
    });
  }

  static Future<void> deleteMessage(String messageId) async {
    try {
      if (_currentUserId == null) {
        print('Error: No authenticated user');
        return;
      }

      final messagesCollection = _userMessagesCollection;
      if (messagesCollection == null) return;

      await messagesCollection.doc(messageId).delete();

      // Update user's message count
      await _firestore.collection(_usersCollection).doc(_currentUserId).update({
        'messageCount': FieldValue.increment(-1),
      });

      print('Message deleted from Firebase: $messageId');

    } catch (e) {
      print('Error deleting message from Firebase: $e');
    }
  }

  // Get user's chat statistics
  static Future<Map<String, dynamic>?> getUserChatStats() async {
    try {
      if (_currentUserId == null) return null;

      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user chat stats: $e');
      return null;
    }
  }

  // Clear all messages for current user
  static Future<void> clearAllMessages() async {
    try {
      if (_currentUserId == null) {
        print('Error: No authenticated user');
        return;
      }

      final messagesCollection = _userMessagesCollection;
      if (messagesCollection == null) return;

      // Get all messages
      final querySnapshot = await messagesCollection.get();

      // Delete all messages in batch
      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Clear all local images
      await LocalDatabaseMessage.clearAllImages();

      // Reset user's message count
      await _firestore.collection(_usersCollection).doc(_currentUserId).update({
        'messageCount': 0,
        'lastMessageAt': FieldValue.delete(),
      });

      print('All messages and images cleared from Firebase and local storage');

    } catch (e) {
      print('Error clearing all messages: $e');
    }
  }

  // Get messages with pagination
  static Future<List<Message>> getMessagesWithPagination({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      if (_currentUserId == null) {
        print('Error: No authenticated user');
        return [];
      }

      final messagesCollection = _userMessagesCollection;
      if (messagesCollection == null) return [];

      Query query = messagesCollection
          .orderBy('date', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();

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
      print('Error getting paginated messages: $e');
      return [];
    }
  }
}
