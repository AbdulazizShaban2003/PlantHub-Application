import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/bookmark_model.dart';

class BookmarkService {
  final FirebaseFirestore _firestore;
  final String? userId;

  BookmarkService(this.userId, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // الحصول على مرجع مجموعة الإشارات المرجعية للمستخدم
  CollectionReference get _bookmarksCollection => _firestore
      .collection('users')
      .doc(userId)
      .collection('bookmarks');

  // إضافة إشارة مرجعية
  Future<void> addBookmark(String itemId) async {
    if (userId == null) throw Exception('User not authenticated');

    try {
      final existing = await _bookmarksCollection
          .where('itemId', isEqualTo: itemId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) return;

      await _bookmarksCollection.add({
        'itemId': itemId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // لا نستدعي notifyListeners هنا لتجنب تأثير على جميع الـ widgets
    } catch (e) {
      debugPrint('Error adding bookmark: $e');
      rethrow;
    }
  }

  // إزالة إشارة مرجعية
  Future<void> removeBookmark(String itemId) async {
    if (userId == null) throw Exception('User not authenticated');

    try {
      final query = await _bookmarksCollection
          .where('itemId', isEqualTo: itemId)
          .get();

      if (query.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (var doc in query.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // لا نستدعي notifyListeners هنا
    } catch (e) {
      debugPrint('Error removing bookmark: $e');
      rethrow;
    }
  }

  // التحقق من وجود إشارة مرجعية
  Future<bool> isBookmarked(String itemId) async {
    if (userId == null) return false;

    try {
      final snapshot = await _bookmarksCollection
          .where('itemId', isEqualTo: itemId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking bookmark status: $e');
      return false;
    }
  }

  // Stream للحصول على حالة bookmark لعنصر محدد
  Stream<bool> getBookmarkStatusStream(String itemId) {
    if (userId == null) return Stream.value(false);

    return _bookmarksCollection
        .where('itemId', isEqualTo: itemId)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  // الحصول على جميع الإشارات المرجعية (Stream)
  Stream<List<Bookmark>> get bookmarksStream {
    if (userId == null) return Stream.value([]);

    return _bookmarksCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Bookmark.fromFirestore(doc))
        .toList());
  }
}
