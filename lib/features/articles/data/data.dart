import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/plant_model.dart' show Plant;

class PlantRepository {
  final FirebaseFirestore _firestore;
  final CollectionReference<Map<String, dynamic>> _plantsCollection;

  PlantRepository({
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _plantsCollection = (firestore ?? FirebaseFirestore.instance).collection('Plants');

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

  Future<List<Map<String, dynamic>>> getAllPlantsAsMaps() async {
    try {
      final querySnapshot = await _plantsCollection.get();
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
        'Failed to fetch plants as maps',
        code: e.code,
        stackTrace: e.stackTrace,
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

  Future<Map<String, dynamic>?> getPlantMapById(String id) async {
    try {
      if (id.isEmpty) {
        throw RepositoryException('Plant ID cannot be empty');
      }

      final doc = await _plantsCollection.doc(id).get();
      if (!doc.exists) return null;

      return {
        'id': doc.id,
        ...doc.data() ?? {},
      };
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'Failed to fetch plant map with ID: $id',
        code: e.code,
        stackTrace: e.stackTrace,
      );
    }
  }

  Future<List<Plant>> getPlantsByCategory(String category) async {
    try {
      final querySnapshot = await _plantsCollection
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs
          .map((doc) => Plant.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'Failed to fetch plants by category: $category',
        code: e.code,
        stackTrace: e.stackTrace,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getPlantsByCategoryAsMaps(String category) async {
    try {
      final querySnapshot = await _plantsCollection
          .where('category', isEqualTo: category)
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
        'Failed to fetch plants by category as maps: $category',
        code: e.code,
        stackTrace: e.stackTrace,
      );
    }
  }

  Future<List<Plant>> searchPlants(String query) async {
    try {
      final querySnapshot = await _plantsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) => Plant.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'Failed to search plants with query: $query',
        code: e.code,
        stackTrace: e.stackTrace,
      );
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

  Future<String> addPlant(Map<String, dynamic> plantData) async {
    try {
      final docRef = await _plantsCollection.add(plantData);
      return docRef.id;
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'Failed to add plant',
        code: e.code,
        stackTrace: e.stackTrace,
      );
    }
  }

  Future<void> updatePlant(String id, Map<String, dynamic> updates) async {
    try {
      if (id.isEmpty) {
        throw RepositoryException('Plant ID cannot be empty');
      }
      await _plantsCollection.doc(id).update(updates);
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'Failed to update plant with ID: $id',
        code: e.code,
        stackTrace: e.stackTrace,
      );
    }
  }

  Future<void> deletePlant(String id) async {
    try {
      if (id.isEmpty) {
        throw RepositoryException('Plant ID cannot be empty');
      }
      await _plantsCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'Failed to delete plant with ID: $id',
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