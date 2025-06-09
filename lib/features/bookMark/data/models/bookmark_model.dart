import 'package:cloud_firestore/cloud_firestore.dart';

class Bookmark {
  final String id;
  final String itemId;
  final DateTime timestamp;

  Bookmark({
    required this.id,
    required this.itemId,
    required this.timestamp,
  });

  factory Bookmark.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Bookmark(
      id: doc.id,
      itemId: data['itemId'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'timestamp': timestamp,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Bookmark &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              itemId == other.itemId;

  @override
  int get hashCode => id.hashCode ^ itemId.hashCode;
}