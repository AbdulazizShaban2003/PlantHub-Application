import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/notification_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'myplant.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createTables(db);
    }
  }

  Future<void> _createTables(Database db) async {
    // Create images table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS images(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        plantId TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        isMainImage INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL
      )
    ''');

    // Create notifications table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        plantId TEXT NOT NULL,
        plantName TEXT NOT NULL,
        actionType TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        thumbnailPath TEXT NOT NULL,
        taskNames TEXT NOT NULL,
        scheduledTime INTEGER NOT NULL,
        deliveredTime INTEGER,
        isDelivered INTEGER NOT NULL DEFAULT 0,
        isRead INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_images_userId ON images(userId)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_images_plantId ON images(plantId)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_notifications_userId ON notifications(userId)');
  }

  // Image operations
  Future<String> saveImage({
    required String userId,
    required String plantId,
    required String imagePath,
    required bool isMainImage,
  }) async {
    final db = await database;
    final String imageId = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insert('images', {
      'id': imageId,
      'userId': userId,
      'plantId': plantId,
      'imagePath': imagePath,
      'isMainImage': isMainImage ? 1 : 0,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });

    return imageId;
  }

  Future<List<String>> getPlantImages(String plantId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'images',
      where: 'plantId = ?',
      whereArgs: [plantId],
      orderBy: 'isMainImage DESC, createdAt ASC',
    );

    return maps.map((map) => map['imagePath'] as String).toList();
  }

  Future<String?> getMainPlantImage(String plantId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'images',
      where: 'plantId = ? AND isMainImage = 1',
      whereArgs: [plantId],
      limit: 1,
    );

    return maps.isNotEmpty ? maps.first['imagePath'] as String : null;
  }

  Future<void> deletePlantImages(String plantId) async {
    final db = await database;

    // Get all image paths before deleting
    final List<Map<String, dynamic>> maps = await db.query(
      'images',
      where: 'plantId = ?',
      whereArgs: [plantId],
    );

    // Delete image files
    for (final map in maps) {
      final String imagePath = map['imagePath'];
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        try {
          await imageFile.delete();
        } catch (e) {
          print('Error deleting image file: $e');
        }
      }
    }

    // Delete from database
    await db.delete(
      'images',
      where: 'plantId = ?',
      whereArgs: [plantId],
    );
  }

  Future<void> deleteUserImages(String userId) async {
    final db = await database;

    // Get all image paths before deleting
    final List<Map<String, dynamic>> maps = await db.query(
      'images',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    // Delete image files
    for (final map in maps) {
      final String imagePath = map['imagePath'];
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        try {
          await imageFile.delete();
        } catch (e) {
          print('Error deleting image file: $e');
        }
      }
    }

    // Delete from database
    await db.delete(
      'images',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // Notification operations
  Future<void> insertNotification(NotificationModel notification) async {
    final db = await database;
    await db.insert(
      'notifications',
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'scheduledTime DESC',
    );

    return maps.map((map) => NotificationModel.fromMap(map)).toList();
  }

  Future<void> markNotificationAsDelivered(String notificationId) async {
    final db = await database;
    await db.update(
      'notifications',
      {
        'isDelivered': 1,
        'deliveredTime': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final db = await database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    final db = await database;
    await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> deleteUserNotifications(String userId) async {
    final db = await database;
    await db.delete(
      'notifications',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}
