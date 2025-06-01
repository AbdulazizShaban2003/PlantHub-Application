import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/plant_model.dart' show Plant;

class PlantRepository {
  final CollectionReference<Map<String, dynamic>> _plantsCollection;

  PlantRepository({
    FirebaseFirestore? firestore,
  })  : _plantsCollection = (firestore ?? FirebaseFirestore.instance).collection('Plants');

  Future<List<Plant>> getAllPlants() async {
    try {
      final querySnapshot = await _plantsCollection.get();
      return querySnapshot.docs
          .map((doc) => Plant.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'Failed to fetch plants from Firestore',
        code: e.code,
        stackTrace: e.stackTrace,
      );
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Unexpected error while fetching plants',
        stackTrace: stackTrace,
      );
    }
  }
  Future<Plant?> getPlantById(String id) async {
    try {
      if (id.isEmpty) {
        throw RepositoryException('Plant ID cannot be empty');
      }

      final doc = await _plantsCollection.doc(id).get();
      if (!doc.exists) return null;

      return Plant.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'Failed to fetch plant with ID: $id',
        code: e.code,
        stackTrace: e.stackTrace,
      );
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Unexpected error while fetching plant',
        stackTrace: stackTrace,
      );
    }
  }
  Future<List<Plant>> searchPlants(String query) async {
    try {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) {
        return [];
      }

      final lowerQuery = trimmedQuery.toLowerCase();

      final nameQuery = _plantsCollection
          .where('name_lowercase', isGreaterThanOrEqualTo: lowerQuery)
          .where('name_lowercase', isLessThanOrEqualTo: '$lowerQuery\uf8ff')
          .limit(10);

      final descQuery = _plantsCollection
          .where('description_lowercase', isGreaterThanOrEqualTo: lowerQuery)
          .where('description_lowercase', isLessThanOrEqualTo: '$lowerQuery\uf8ff')
          .limit(10);

      final snapshots = await Future.wait([nameQuery.get(), descQuery.get()]);
      final uniqueDocs = snapshots.expand((s) => s.docs).toSet();

      return uniqueDocs.map(Plant.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw RepositoryException('فشل البحث: ${e.message}');
    } catch (e) {
      throw RepositoryException('خطأ غير متوقع أثناء البحث');
    }
  }
  Future<List<Map<String, dynamic>>> searchPlantsAsMaps(String query) async {
    try {
      final querySnapshot = await _plantsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) {
        final data = doc.data() ?? {};
        return {
          'id': doc.id,
          ...data,
        };
      })
          .toList();
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'Failed to search plants as maps with query: $query',
        code: e.code,
        stackTrace: e.stackTrace,
      );
    }
  }



}

class RepositoryException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  RepositoryException(
      this.message, {
        this.code,
        this.stackTrace,
      });

  @override
  String toString() {
    return 'RepositoryException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}