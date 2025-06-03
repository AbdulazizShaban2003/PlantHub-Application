import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'bookmark_model.dart';

class BookmarkService with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final String? userId;

  BookmarkService(this.userId, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addBookmark(String itemId) async {
    if (userId == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .add({
        'itemId': itemId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding bookmark: $e');
      rethrow;
    }
  }

  Future<void> removeBookmark(String bookmarkId) async {
    if (userId == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(bookmarkId)
          .delete();
    } catch (e) {
      debugPrint('Error removing bookmark: $e');
      rethrow;
    }
  }

  Future<void> removeBookmarkByItemId(String itemId) async {
    if (userId == null) throw Exception('User not authenticated');

    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .where('itemId', isEqualTo: itemId)
          .get();

      final batch = _firestore.batch();
      for (var doc in query.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error removing bookmark by itemId: $e');
      rethrow;
    }
  }

  Stream<List<Bookmark>> getUserBookmarks() {
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Bookmark.fromMap(doc.id, doc.data()))
        .toList());
  }

  Stream<bool> isItemBookmarked(String itemId) {
    if (userId == null) return Stream.value(false);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .where('itemId', isEqualTo: itemId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  Future<List<Bookmark>> getBookmarksForItem(String itemId) async {
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .where('itemId', isEqualTo: itemId)
        .get();

    return snapshot.docs
        .map((doc) => Bookmark.fromMap(doc.id, doc.data()))
        .toList();
  }
}