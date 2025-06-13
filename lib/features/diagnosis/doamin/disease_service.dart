import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/disease_info.dart';

class DiseaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'diseases';
  static const int _searchLimit = 20;

  // Get all diseases with pagination support
  static Future<List<DiseaseModel>> getAllDiseases({int limit = 10, DocumentSnapshot? lastDocument}) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .orderBy('name')
          .limit(limit);

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

  // Get disease by ID
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

  // Search diseases
  static Future<List<DiseaseModel>> searchDiseases(String searchQuery) async {
    try {
      if (searchQuery.trim().isEmpty) return [];

      final lowercaseQuery = searchQuery.toLowerCase();
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('name_lowercase', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('name_lowercase', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
          .orderBy('name_lowercase')
          .limit(_searchLimit)
          .get();

      return querySnapshot.docs
          .map((doc) => DiseaseModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching diseases: $e');
      throw Exception('Failed to search diseases');
    }
  }

  // Get diseases by category
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

  // Get random diseases
  static Future<List<DiseaseModel>> getRandomDiseases({int limit = 5}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .get();

      final allDiseases = querySnapshot.docs
          .map((doc) => DiseaseModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      if (allDiseases.isEmpty) return [];
      if (allDiseases.length <= limit) return allDiseases;

      // Shuffle and take first 'limit' items
      allDiseases.shuffle(Random());
      return allDiseases.take(limit).toList();
    } catch (e) {
      print('Error fetching random diseases: $e');
      throw Exception('Failed to fetch random diseases');
    }
  }
}
