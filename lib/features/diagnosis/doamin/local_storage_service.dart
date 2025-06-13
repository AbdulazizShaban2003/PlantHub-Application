import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../data/disease_info.dart' show DiseaseModel;

class LocalStorageService {
  static Database? _database;
  static final String tableName = 'diagnosis_history';

  // Initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Create and open the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'plant_diagnosis.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            disease_id TEXT,
            disease_name TEXT,
            disease_data TEXT,
            image_path TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // Save diagnosis to history
  Future<int> saveDiagnosisToHistory({
    required String type,
    required DiseaseModel? disease,
    required String imagePath,
    required DateTime timestamp,
  }) async {
    final db = await database;

    Map<String, dynamic> row = {
      'type': type,
      'disease_id': disease?.id,
      'disease_name': disease?.name,
      'disease_data': disease != null ? jsonEncode(disease.toMap()) : null,
      'image_path': imagePath,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };

    return await db.insert(tableName, row);
  }

  // Get diagnosis history
  Future<List<Map<String, dynamic>>> getDiagnosisHistory() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'timestamp DESC',
    );

    return _processMaps(maps);
  }

  // Search in history
  Future<List<Map<String, dynamic>>> searchHistory(String query) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'disease_name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'timestamp DESC',
    );

    return _processMaps(maps);
  }

  // Process database maps into usable format
  List<Map<String, dynamic>> _processMaps(List<Map<String, dynamic>> maps) {
    return maps.map((map) {
      final diseaseData = map['disease_data'];
      DiseaseModel? disease;

      if (diseaseData != null) {
        try {
          final Map<String, dynamic> decodedData = jsonDecode(diseaseData);
          disease = DiseaseModel.fromJson(decodedData);
        } catch (e) {
          print('Error decoding disease data: $e');
        }
      }

      return {
        'id': map['id'],
        'type': map['type'],
        'disease': disease,
        'imagePath': map['image_path'],
        'timestamp': DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      };
    }).toList();
  }

  // Clear history
  Future<int> clearHistory() async {
    final db = await database;
    return await db.delete(tableName);
  }

  // Delete specific history item
  Future<int> deleteHistoryItem(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
