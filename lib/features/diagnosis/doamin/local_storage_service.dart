import 'package:plant_hub_app/features/diagnosis/data/plant_diagnosis_response_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class LocalStorageService {
  static Database? _database;
  static final String tableName = 'diagnosis_history';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'plant_diagnosis.db');
    return await openDatabase(
      path,
      version: 2, // Increased version to trigger migration
      onCreate: (Database db, int version) async {
        await _createTable(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          // Drop old table and recreate with correct schema
          await db.execute('DROP TABLE IF EXISTS $tableName');
          await _createTable(db);
        }
      },
    );
  }

  Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        status TEXT NOT NULL,
        response_data TEXT NOT NULL,
        image_path TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  // Check if table exists and has correct schema
  Future<bool> _checkTableSchema() async {
    try {
      final db = await database;
      final result = await db.rawQuery("PRAGMA table_info($tableName)");

      // Check if all required columns exist
      final columnNames = result.map((row) => row['name'] as String).toList();
      final requiredColumns = ['id', 'status', 'response_data', 'image_path', 'timestamp'];

      for (String column in requiredColumns) {
        if (!columnNames.contains(column)) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Fix database schema if needed
  Future<void> _fixDatabaseSchema() async {
    try {
      final hasCorrectSchema = await _checkTableSchema();
      if (!hasCorrectSchema) {
        final db = await database;
        await db.execute('DROP TABLE IF EXISTS $tableName');
        await _createTable(db);
      }
    } catch (e) {
      print('Error fixing database schema: $e');
    }
  }

  Future<int> saveDiagnosisToHistory({
    required PlantDiagnosisResponse response,
    required String imagePath,
    required DateTime timestamp,
  }) async {
    try {
      await _fixDatabaseSchema(); // Ensure schema is correct
      final db = await database;

      Map<String, dynamic> row = {
        'status': response.status,
        'response_data': jsonEncode(response.toJson()),
        'image_path': imagePath,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

      return await db.insert(tableName, row);
    } catch (e) {
      print('Error saving diagnosis to history: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDiagnosisHistory() async {
    try {
      await _fixDatabaseSchema(); // Ensure schema is correct
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: 'timestamp DESC',
      );

      return _processMaps(maps);
    } catch (e) {
      print('Error getting diagnosis history: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchHistory(String query) async {
    try {
      await _fixDatabaseSchema(); // Ensure schema is correct
      final db = await database;

      // First check if table exists and has data
      final tableExists = await _tableExists(db);
      if (!tableExists) {
        return [];
      }

      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'response_data LIKE ? OR status LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'timestamp DESC',
      );

      return _processMaps(maps);
    } catch (e) {
      print('Error searching history: $e');
      // If search fails, return all history as fallback
      return await getDiagnosisHistory();
    }
  }

  Future<bool> _tableExists(Database db) async {
    try {
      final result = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'"
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  List<Map<String, dynamic>> _processMaps(List<Map<String, dynamic>> maps) {
    return maps.map((map) {
      PlantDiagnosisResponse? response;

      try {
        final responseDataString = map['response_data'] as String?;
        if (responseDataString != null && responseDataString.isNotEmpty) {
          final Map<String, dynamic> decodedData = jsonDecode(responseDataString);
          response = PlantDiagnosisResponse.fromJson(decodedData);
        }
      } catch (e) {
        print('Error decoding response data: $e');
      }

      return {
        'id': map['id'],
        'status': map['status'] ?? '',
        'response': response,
        'imagePath': map['image_path'] ?? '',
        'timestamp': DateTime.fromMillisecondsSinceEpoch(
            map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch
        ),
      };
    }).where((item) => item['response'] != null).toList();
  }

  Future<int> clearHistory() async {
    try {
      final db = await database;
      return await db.delete(tableName);
    } catch (e) {
      print('Error clearing history: $e');
      return 0;
    }
  }

  Future<int> deleteHistoryItem(int id) async {
    try {
      final db = await database;
      return await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting history item: $e');
      return 0;
    }
  }

  // Reset database completely if needed
  Future<void> resetDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'plant_diagnosis.db');
      await deleteDatabase(path);
      _database = null;
      await database; // Reinitialize
    } catch (e) {
      print('Error resetting database: $e');
    }
  }
}
