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


  factory Bookmark.fromMap(String id, Map<String, dynamic> map) {
    return Bookmark(
      id: id,
      itemId: map['itemId'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
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