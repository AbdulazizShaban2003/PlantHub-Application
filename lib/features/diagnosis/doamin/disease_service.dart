import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/disease_info.dart';

class DiseaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'diseases';

  static Future<List<DiseaseModel>> getAllDiseases(
      {DocumentSnapshot? lastDocument}) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .orderBy('name');

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => DiseaseModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching all diseases: $e');
      throw Exception('Failed to fetch diseases');
    }
  }
  static Future<DiseaseModel?> getDiseaseById(String diseaseId) async {
    try {
      final docSnapshot = await _firestore
          .collection(_collectionName)
          .doc(diseaseId)
          .get();

      return docSnapshot.exists
          ? DiseaseModel.fromFirestore(docSnapshot.id, docSnapshot.data()! as Map<String, dynamic>)
          : null;
    } catch (e) {
      print('Error fetching disease by ID: $e');
      throw Exception('Failed to fetch disease details');
    }
  }
  static Future<List<DiseaseModel>> searchDiseases(String searchQuery) async {
    try {
      if (searchQuery.trim().isEmpty) return [];

      final lowercaseQuery = searchQuery.toLowerCase();
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('name_lowercase', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('name_lowercase', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
          .orderBy('name_lowercase')
          .get();

      return querySnapshot.docs
          .map((doc) => DiseaseModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching diseases: $e');
      throw Exception('Failed to search diseases');
    }
  }

  static Future<List<DiseaseModel>> getDiseasesByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('category', isEqualTo: category)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => DiseaseModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching diseases by category: $e');
      throw Exception('Failed to fetch diseases for this category');
    }
  }

  static Future<List<DiseaseModel>> getAllDiseasesWithoutLimit() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => DiseaseModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching all diseases: $e');
      throw Exception('Failed to fetch all diseases');
    }
  }
}
