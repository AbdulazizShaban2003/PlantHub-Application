import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/plant_model.dart' show Plant;

class PlantRepository {
  final CollectionReference<Map<String, dynamic>> _plantsCollection;

  PlantRepository({
    FirebaseFirestore? firestore,
  })  : _plantsCollection = (firestore ?? FirebaseFirestore.instance).collection('Plants');

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'Plants'; // تم تصحيح اسم المجموعة

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

  Future<List<Plant>> getPlantsByCategory(String category) async {
    try {
      if (category.isEmpty) {
        throw RepositoryException('Category cannot be empty');
      }

      final querySnapshot = await _plantsCollection
          .where('category', isEqualTo: category)
          .get();

      if (querySnapshot.docs.isEmpty) {
        final allPlantsSnapshot = await _plantsCollection.get();
        final filteredDocs = allPlantsSnapshot.docs.where((doc) {
          final data = doc.data();
          final plantCategory = data['category'] as String? ?? '';
          return plantCategory.toLowerCase().contains(category.toLowerCase());
        }).toList();

        return filteredDocs.map((doc) => Plant.fromFirestore(doc)).toList();
      }

      return querySnapshot.docs
          .map((doc) => Plant.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'Failed to fetch plants by category: $category',
        code: e.code,
        stackTrace: e.stackTrace,
      );
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Unexpected error while fetching plants by category',
        stackTrace: stackTrace,
      );
    }
  }

  // دالة جديدة للبحث في التصنيفات بمرونة أكثر
  Future<List<Plant>> getPlantsByCategoryFlexible(String category) async {
    try {
      final allPlants = await getAllPlants();

      return allPlants.where((plant) {
        final plantCategory = plant.category.toLowerCase();
        final searchCategory = category.toLowerCase();

        // البحث بطرق متعددة
        return plantCategory == searchCategory ||
            plantCategory.contains(searchCategory) ||
            _matchCategoryKeywords(plantCategory, searchCategory);
      }).toList();
    } catch (e) {
      throw RepositoryException('Failed to fetch plants by category: $category');
    }
  }

  // دالة مساعدة لمطابقة الكلمات المفتاحية
  bool _matchCategoryKeywords(String plantCategory, String searchCategory) {
    final categoryMappings = {
      'succulents': ['succulent', 'cacti', 'cactus'],
      'flowering': ['flower', 'bloom', 'blossom'],
      'foliage': ['leaf', 'leaves', 'foliage'],
      'trees': ['tree', 'woody'],
      'shrubs': ['shrub', 'bush', 'weed'],
      'fruits': ['fruit', 'berry'],
      'vegetables': ['vegetable', 'veggie'],
      'herbs': ['herb', 'aromatic'],
      'mushrooms': ['mushroom', 'fungi'],
      'toxic': ['toxic', 'poisonous', 'dangerous'],
    };

    final keywords = categoryMappings[searchCategory] ?? [];
    return keywords.any((keyword) => plantCategory.contains(keyword));
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
