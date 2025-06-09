import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/disease_info.dart';

class DiseaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'diseases';

  // Get all diseases
  static Future<List<DiseaseModel>> getAllDiseases() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => DiseaseModel.fromFirestore(doc.id, doc.data()))
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

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return DiseaseModel.fromFirestore(docSnapshot.id, docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching disease by ID: $e');
      throw Exception('Failed to fetch disease details');
    }
  }

  // Search diseases by name
  static Future<List<DiseaseModel>> searchDiseases(String searchQuery) async {
    try {
      if (searchQuery.isEmpty) return [];

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff')
          .orderBy('name')
          .limit(20)
          .get();

      return querySnapshot.docs
          .map((doc) => DiseaseModel.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error searching diseases: $e');
      throw Exception('Failed to search diseases');
    }
  }

  // Get diseases stream for real-time updates
  static Stream<List<DiseaseModel>> getDiseasesStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => DiseaseModel.fromFirestore(doc.id, doc.data()))
        .toList());
  }

  // Add new disease (for admin purposes)
  static Future<String> addDisease(DiseaseModel disease) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(disease.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding disease: $e');
      throw Exception('Failed to add disease');
    }
  }

  // Update disease (for admin purposes)
  static Future<void> updateDisease(String diseaseId, DiseaseModel disease) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(diseaseId)
          .update(disease.toMap());
    } catch (e) {
      print('Error updating disease: $e');
      throw Exception('Failed to update disease');
    }
  }

  // Delete disease (for admin purposes)
  static Future<void> deleteDisease(String diseaseId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(diseaseId)
          .delete();
    } catch (e) {
      print('Error deleting disease: $e');
      throw Exception('Failed to delete disease');
    }
  }

  // Get random diseases for featured section
  static Future<List<DiseaseModel>> getRandomDiseases({int limit = 5}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .limit(limit * 2) // Get more to randomize
          .get();

      final diseases = querySnapshot.docs
          .map((doc) => DiseaseModel.fromFirestore(doc.id, doc.data()))
          .toList();

      // Shuffle and return limited results
      diseases.shuffle();
      return diseases.take(limit).toList();
    } catch (e) {
      print('Error fetching random diseases: $e');
      throw Exception('Failed to fetch random diseases');
    }
  }

  // Create sample data for testing
  static Future<void> createSampleData() async {
    try {
      final sampleDiseases = [
        DiseaseModel(
          id: '',
          name: 'Black Spot',
          image: 'https://example.com/blackspot.jpg',
          description: 'Black spot is a common fungal disease that affects roses and other plants. It appears as black spots on leaves, which eventually turn yellow and drop off.',
          images: [
            'https://example.com/blackspot1.jpg',
            'https://example.com/blackspot2.jpg',
            'https://example.com/blackspot3.jpg',
          ],
          treatment: 'Remove affected leaves immediately. Apply fungicide spray every 7-14 days. Improve air circulation around plants. Water at soil level to avoid wetting leaves. Apply preventive fungicide in early spring.',
        ),
        DiseaseModel(
          id: '',
          name: 'Powdery Mildew',
          image: 'https://example.com/mildew.jpg',
          description: 'Powdery mildew appears as white, powdery spots on leaves and stems. It thrives in warm, humid conditions and can spread rapidly.',
          images: [
            'https://example.com/mildew1.jpg',
            'https://example.com/mildew2.jpg',
          ],
          treatment: 'Spray with baking soda solution (1 tsp per quart of water). Remove affected plant parts. Ensure good air circulation. Apply neem oil or sulfur-based fungicide. Avoid overhead watering.',
        ),
        DiseaseModel(
          id: '',
          name: 'Bacterial Blight',
          image: 'https://example.com/blight.jpg',
          description: 'Bacterial blight causes water-soaked spots on leaves that turn brown or black. It spreads quickly in warm, moist conditions.',
          images: [
            'https://example.com/blight1.jpg',
            'https://example.com/blight2.jpg',
            'https://example.com/blight3.jpg',
          ],
          treatment: 'Remove and destroy infected plants. Apply copper-based bactericide. Avoid overhead watering. Improve drainage. Disinfect tools between plants. Plant resistant varieties.',
        ),
        DiseaseModel(
          id: '',
          name: 'Aphid Infestation',
          image: 'https://example.com/aphids.jpg',
          description: 'Aphids are small, soft-bodied insects that feed on plant sap. They can cause leaves to curl, yellow, and stunt plant growth.',
          images: [
            'https://example.com/aphids1.jpg',
            'https://example.com/aphids2.jpg',
          ],
          treatment: 'Spray with insecticidal soap or neem oil. Introduce beneficial insects like ladybugs. Remove aphids by hand or with water spray. Apply systemic insecticide if severe. Keep plants healthy to resist infestation.',
        ),
        DiseaseModel(
          id: '',
          name: 'Leaf Rust',
          image: 'https://example.com/rust.jpg',
          description: 'Leaf rust appears as orange or reddish-brown spots on the undersides of leaves. It can cause premature leaf drop and weaken plants.',
          images: [
            'https://example.com/rust1.jpg',
            'https://example.com/rust2.jpg',
            'https://example.com/rust3.jpg',
          ],
          treatment: 'Remove affected leaves immediately. Apply fungicide containing copper or sulfur. Ensure good air circulation. Water at soil level. Apply preventive treatments in early season.',
        ),
      ];

      for (var disease in sampleDiseases) {
        await addDisease(disease);
      }

      print('Sample disease data created successfully');
    } catch (e) {
      print('Error creating sample data: $e');
      throw Exception('Failed to create sample data');
    }
  }
}
