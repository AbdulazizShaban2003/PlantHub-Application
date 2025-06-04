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
      // Check if already bookmarked to avoid duplicates
      final isBookmarked = await isItemBookmarked(itemId);
      if (isBookmarked) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .add({
        'itemId': itemId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      notifyListeners();
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
      notifyListeners();
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

      if (query.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (var doc in query.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      notifyListeners();
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
        .handleError((error) {
      debugPrint('Error in bookmarks stream: $error');
      return [];
    })
        .map((snapshot) => snapshot.docs
        .map((doc) => Bookmark.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<bool> isItemBookmarked(String itemId) async {
    if (userId == null) return false;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .where('itemId', isEqualTo: itemId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking bookmark status: $e');
      return false;
    }
  }

  Future<List<Bookmark>> getBookmarksForItem(String itemId) async {
    if (userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .where('itemId', isEqualTo: itemId)
          .get();

      return snapshot.docs
          .map((doc) => Bookmark.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting bookmarks for item: $e');
      return [];
    }
  }
}