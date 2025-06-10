import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseMessage {
  static Database? _database;
  static const String _tableName = 'images';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_images.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTable,
    );
  }

  static Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        imagePath TEXT NOT NULL,
        messageId TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');
  }

  static Future<String> saveImage(String messageId, String imagePath) async {
    try {
      final db = await database;
      final imageId = DateTime.now().millisecondsSinceEpoch.toString();

      await db.insert(_tableName, {
        'id': imageId,
        'imagePath': imagePath,
        'messageId': messageId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      print('Image saved to local database: messageId=$messageId, imagePath=$imagePath');
      return imageId;
    } catch (e) {
      print('Error saving image to local database: $e');
      rethrow;
    }
  }

  static Future<String?> getImagePath(String messageId) async {
    try {
      final db = await database;
      final result = await db.query(
        _tableName,
        where: 'messageId = ?',
        whereArgs: [messageId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final imagePath = result.first['imagePath'] as String;
        print('Retrieved image path for messageId=$messageId: $imagePath');
        return imagePath;
      }
      print('No image found for messageId=$messageId');
      return null;
    } catch (e) {
      print('Error getting image path: $e');
      return null;
    }
  }

  static Future<void> deleteImage(String messageId) async {
    try {
      final db = await database;

      // First get the image path to delete the actual file
      final imagePath = await getImagePath(messageId);
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
          print('Deleted image file: $imagePath');
        }
      }

      // Then delete from database
      final deletedRows = await db.delete(
        _tableName,
        where: 'messageId = ?',
        whereArgs: [messageId],
      );

      print('Deleted $deletedRows image records for messageId=$messageId');
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // Clear all images
  static Future<void> clearAllImages() async {
    try {
      final db = await database;

      // Get all image paths first
      final result = await db.query(_tableName);

      // Delete all image files
      for (var row in result) {
        final imagePath = row['imagePath'] as String;
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
          print('Deleted image file: $imagePath');
        }
      }

      // Clear database
      final deletedRows = await db.delete(_tableName);
      print('Cleared $deletedRows image records from database');

    } catch (e) {
      print('Error clearing all images: $e');
    }
  }

  // Get all images (for debugging)
  static Future<List<Map<String, dynamic>>> getAllImages() async {
    try {
      final db = await database;
      final result = await db.query(_tableName, orderBy: 'createdAt DESC');
      return result;
    } catch (e) {
      print('Error getting all images: $e');
      return [];
    }
  }
}
